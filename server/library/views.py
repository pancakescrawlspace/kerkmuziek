import json

from django.http import JsonResponse
from django.shortcuts import render
from django.views.decorators.http import require_GET, require_POST

from .files import LISTERS
from .jobs import ACTIONS, start_job
from .models import Job


@require_GET
def index(request):
    action_meta = {
        key: {"label": label, "kind": kind} for key, (label, kind, _, _) in ACTIONS.items()
    }
    context = {
        "musicxml": LISTERS["musicxml"](),
        "midi": LISTERS["midi"](),
        "mp3": LISTERS["mp3"](),
        "pdf": LISTERS["pdf"](),
        "actions_json": json.dumps(action_meta),
    }
    return render(request, "library/index.html", context)


@require_GET
def api_files(request, category):
    if category not in LISTERS:
        return JsonResponse({"error": f"unknown category {category!r}"}, status=404)
    return JsonResponse({"files": LISTERS[category]()})


@require_POST
def api_start_job(request):
    try:
        body = json.loads(request.body)
        action = body["action"]
        source_path = body["source_path"]
    except (json.JSONDecodeError, KeyError):
        return JsonResponse({"error": "expected JSON {action, source_path}"}, status=400)

    try:
        job = start_job(action, source_path)
    except ValueError as exc:
        return JsonResponse({"error": str(exc)}, status=400)

    return JsonResponse({"id": job.id, "status": job.status})


@require_GET
def api_job_status(request, job_id):
    try:
        job = Job.objects.get(id=job_id)
    except Job.DoesNotExist:
        return JsonResponse({"error": "no such job"}, status=404)
    return JsonResponse(
        {
            "id": job.id,
            "action": job.action,
            "source_path": job.source_path,
            "target_label": job.target_label,
            "status": job.status,
            "log": job.log,
        }
    )
