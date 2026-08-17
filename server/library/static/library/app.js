(() => {
  "use strict";

  const ACTIONS = JSON.parse(document.getElementById("actions-data").textContent);
  // action -> which tab's listing needs refreshing once it succeeds
  const REFRESH_TARGET = {
    midi: "midi",
    mp3: "mp3",
    "pdf-scoryst": "pdf",
    "pdf-typst": "pdf",
    "pdf-mscore": "pdf",
    "pdf-verovio-direct": "pdf",
    "mp3-from-midi": "mp3",
  };

  function getCookie(name) {
    const match = document.cookie.match(new RegExp("(^|; )" + name + "=([^;]*)"));
    return match ? decodeURIComponent(match[2]) : null;
  }
  const csrftoken = getCookie("csrftoken");

  // ---- tabs ----
  document.querySelectorAll(".tab-button").forEach((button) => {
    button.addEventListener("click", () => {
      document.querySelectorAll(".tab-button").forEach((b) => b.classList.remove("active"));
      document.querySelectorAll(".tab-panel").forEach((p) => (p.hidden = true));
      button.classList.add("active");
      document.getElementById("tab-" + button.dataset.tab).hidden = false;
    });
  });

  // ---- status bar ----
  const statusBar = document.getElementById("status-bar");
  function showStatus(cls, text) {
    statusBar.hidden = false;
    statusBar.className = "status-bar " + cls;
    statusBar.textContent = text;
  }

  // ---- context menu ----
  const menu = document.getElementById("context-menu");

  function actionsFor(row) {
    const kind = row.dataset.kind;
    return Object.entries(ACTIONS).filter(([key, meta]) => {
      if (meta.kind !== kind) return false;
      if (key === "pdf-scoryst" && row.dataset.hasScorystTyp !== "1") return false;
      if (key === "pdf-typst" && row.dataset.hasTypstTyp !== "1") return false;
      return true;
    });
  }

  document.addEventListener("contextmenu", (event) => {
    const row = event.target.closest(".file-row");
    if (!row || (row.dataset.kind !== "musicxml" && row.dataset.kind !== "midi")) {
      hideMenu();
      return;
    }
    event.preventDefault();
    const entries = actionsFor(row);
    menu.innerHTML = "";
    entries.forEach(([key, meta]) => {
      const li = document.createElement("li");
      li.textContent = meta.label;
      li.addEventListener("click", () => {
        hideMenu();
        runAction(key, row.dataset.path);
      });
      menu.appendChild(li);
    });
    menu.style.left = event.pageX + "px";
    menu.style.top = event.pageY + "px";
    menu.hidden = false;
  });

  document.addEventListener("click", hideMenu);
  function hideMenu() {
    menu.hidden = true;
  }

  // ---- running jobs ----
  function runAction(action, sourcePath) {
    fetch("/api/jobs/start/", {
      method: "POST",
      headers: { "Content-Type": "application/json", "X-CSRFToken": csrftoken },
      body: JSON.stringify({ action, source_path: sourcePath }),
    })
      .then((r) => r.json())
      .then((data) => {
        if (data.error) {
          showStatus("failed", data.error);
          return;
        }
        showStatus("running", `${action} ${sourcePath}: started...`);
        pollJob(data.id, action, sourcePath);
      });
  }

  function pollJob(jobId, action, sourcePath) {
    fetch(`/api/jobs/${jobId}/`)
      .then((r) => r.json())
      .then((job) => {
        if (job.status === "pending" || job.status === "running") {
          showStatus("running", `${action} ${sourcePath}: ${job.status}...`);
          setTimeout(() => pollJob(jobId, action, sourcePath), 1000);
          return;
        }
        if (job.status === "success") {
          showStatus("success", `${action} ${sourcePath}: done`);
          const target = REFRESH_TARGET[action];
          if (target) refreshTab(target);
        } else {
          showStatus("failed", `${action} ${sourcePath} failed:\n${job.log}`);
        }
      });
  }

  // ---- refreshing a tab's table after a successful job ----
  const COLUMNS = {
    midi: (f) => [f.name, f.path, f.size],
    mp3: (f) => [f.name, f.path, f.size],
    pdf: (f) => [f.name, f.pipeline, f.path, f.size],
  };

  function refreshTab(category) {
    fetch(`/api/files/${category}/`)
      .then((r) => r.json())
      .then((data) => {
        const tbody = document.querySelector(`#tab-${category} tbody`);
        tbody.innerHTML = "";
        data.files.forEach((f) => {
          const tr = document.createElement("tr");
          tr.className = "file-row";
          tr.dataset.kind = category;
          tr.dataset.path = f.path;
          COLUMNS[category](f).forEach((value) => {
            const td = document.createElement("td");
            td.textContent = value;
            tr.appendChild(td);
          });
          tbody.appendChild(tr);
        });
      });
  }
})();
