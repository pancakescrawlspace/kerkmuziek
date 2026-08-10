// midirender.swift -- offline MIDI -> WAV renderer using macOS's built-in
// General MIDI synth. No third-party synthesizer or soundfont needed: it drives
// the system DLSMusicDevice audio unit (which loads Apple's GM soundfont) with a
// GenericOutput unit in offline mode, pulling audio and writing a 16-bit WAV.
//
// Build: swiftc -O tools/midirender.swift -o midirender
// Use:   ./midirender <in.mid> <out.wav> [tailSeconds]
// (For MIDI -> MP3 in one step, use tools/mid2mp3.sh.)

import AudioToolbox
import Foundation

func chk(_ s: OSStatus, _ what: String) {
    if s != noErr {
        FileHandle.standardError.write("ERROR \(what): \(s)\n".data(using: .utf8)!)
        exit(1)
    }
}

let args = CommandLine.arguments
guard args.count >= 3 else { print("usage: midirender <in.mid> <out.wav> [tailSeconds]"); exit(2) }
let inPath = args[1], outPath = args[2]
let tail = args.count >= 4 ? Double(args[3]) ?? 2.0 : 2.0
let sr = 44100.0

// --- AUGraph: DLS synth -> generic (offline) output ---
var graph: AUGraph?
chk(NewAUGraph(&graph), "NewAUGraph")
var synthDesc = AudioComponentDescription(componentType: kAudioUnitType_MusicDevice,
    componentSubType: kAudioUnitSubType_DLSSynth, componentManufacturer: kAudioUnitManufacturer_Apple,
    componentFlags: 0, componentFlagsMask: 0)
var outDesc = AudioComponentDescription(componentType: kAudioUnitType_Output,
    componentSubType: kAudioUnitSubType_GenericOutput, componentManufacturer: kAudioUnitManufacturer_Apple,
    componentFlags: 0, componentFlagsMask: 0)
var synthNode = AUNode(), outNode = AUNode()
chk(AUGraphAddNode(graph!, &synthDesc, &synthNode), "add synth")
chk(AUGraphAddNode(graph!, &outDesc, &outNode), "add out")
chk(AUGraphOpen(graph!), "open")
chk(AUGraphConnectNodeInput(graph!, synthNode, 0, outNode, 0), "connect")
var synthUnit: AudioUnit?, outUnit: AudioUnit?
chk(AUGraphNodeInfo(graph!, synthNode, nil, &synthUnit), "synth info")
chk(AUGraphNodeInfo(graph!, outNode, nil, &outUnit), "out info")

// non-interleaved float32 stereo (canonical AU render format)
var asbd = AudioStreamBasicDescription(mSampleRate: sr, mFormatID: kAudioFormatLinearPCM,
    mFormatFlags: kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked | kAudioFormatFlagIsNonInterleaved,
    mBytesPerPacket: 4, mFramesPerPacket: 1, mBytesPerFrame: 4,
    mChannelsPerFrame: 2, mBitsPerChannel: 32, mReserved: 0)
let sz = UInt32(MemoryLayout<AudioStreamBasicDescription>.size)
chk(AudioUnitSetProperty(synthUnit!, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &asbd, sz), "synth fmt")
chk(AudioUnitSetProperty(outUnit!, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &asbd, sz), "out in fmt")
chk(AudioUnitSetProperty(outUnit!, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &asbd, sz), "out out fmt")
chk(AUGraphInitialize(graph!), "init graph")

// --- load MIDI ---
var seq: MusicSequence?
chk(NewMusicSequence(&seq), "new seq")
let inURL = URL(fileURLWithPath: inPath) as CFURL
chk(MusicSequenceFileLoad(seq!, inURL, .midiType, MusicSequenceLoadFlags()), "load midi")
chk(MusicSequenceSetAUGraph(seq!, graph!), "seq graph")

var nTracks: UInt32 = 0
MusicSequenceGetTrackCount(seq!, &nTracks)
var lenBeats: MusicTimeStamp = 0
for i in 0..<nTracks {
    var t: MusicTrack?
    MusicSequenceGetIndTrack(seq!, i, &t)
    var tl: MusicTimeStamp = 0
    var s = UInt32(MemoryLayout<MusicTimeStamp>.size)
    MusicTrackGetProperty(t!, kSequenceTrackProperty_TrackLength, &tl, &s)
    if tl > lenBeats { lenBeats = tl }
}
var lenSec: Float64 = 0
MusicSequenceGetSecondsForBeats(seq!, lenBeats, &lenSec)
let totalSec = lenSec + tail

var player: MusicPlayer?
chk(NewMusicPlayer(&player), "new player")
chk(MusicPlayerSetSequence(player!, seq!), "set seq")
chk(MusicPlayerPreroll(player!), "preroll")

// --- WAV output via ExtAudioFile (16-bit) ---
var fileFmt = AudioStreamBasicDescription(mSampleRate: sr, mFormatID: kAudioFormatLinearPCM,
    mFormatFlags: kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked,
    mBytesPerPacket: 4, mFramesPerPacket: 1, mBytesPerFrame: 4,
    mChannelsPerFrame: 2, mBitsPerChannel: 16, mReserved: 0)
var extFile: ExtAudioFileRef?
let outURL = URL(fileURLWithPath: outPath) as CFURL
chk(ExtAudioFileCreateWithURL(outURL, kAudioFileWAVEType, &fileFmt, nil,
    AudioFileFlags.eraseFile.rawValue, &extFile), "create wav")
chk(ExtAudioFileSetProperty(extFile!, kExtAudioFileProperty_ClientDataFormat, sz, &asbd), "client fmt")

chk(MusicPlayerStart(player!), "start")

let slice: UInt32 = 512
let totalFrames = Int64(totalSec * sr)
var done: Int64 = 0
var ts = AudioTimeStamp(); ts.mFlags = .sampleTimeValid; ts.mSampleTime = 0
let bufL = UnsafeMutablePointer<Float>.allocate(capacity: Int(slice))
let bufR = UnsafeMutablePointer<Float>.allocate(capacity: Int(slice))
defer { bufL.deallocate(); bufR.deallocate() }
let abl = AudioBufferList.allocate(maximumBuffers: 2)

while done < totalFrames {
    let n = UInt32(min(Int64(slice), totalFrames - done))
    abl[0] = AudioBuffer(mNumberChannels: 1, mDataByteSize: n * 4, mData: UnsafeMutableRawPointer(bufL))
    abl[1] = AudioBuffer(mNumberChannels: 1, mDataByteSize: n * 4, mData: UnsafeMutableRawPointer(bufR))
    var flags = AudioUnitRenderActionFlags()
    chk(AudioUnitRender(outUnit!, &flags, &ts, 0, n, abl.unsafeMutablePointer), "render")
    chk(ExtAudioFileWrite(extFile!, n, abl.unsafeMutablePointer), "write")
    ts.mSampleTime += Double(n)
    done += Int64(n)
}
MusicPlayerStop(player!)
ExtAudioFileDispose(extFile!)
DisposeMusicPlayer(player!)
DisposeMusicSequence(seq!)
AUGraphUninitialize(graph!)
DisposeAUGraph(graph!)
print(String(format: "rendered %.2fs -> %@", totalSec, outPath))
