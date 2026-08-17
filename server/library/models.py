from django.db import models


class Job(models.Model):
    """One regenerate-script run, tracked so the frontend can poll for
    completion. The filesystem (songs/) stays the source of truth for what
    files exist -- this table only exists to track in-flight/finished runs.
    """

    PENDING = "pending"
    RUNNING = "running"
    SUCCESS = "success"
    FAILED = "failed"
    STATUS_CHOICES = [
        (PENDING, "Pending"),
        (RUNNING, "Running"),
        (SUCCESS, "Success"),
        (FAILED, "Failed"),
    ]

    action = models.CharField(max_length=40)
    source_path = models.CharField(max_length=500)
    target_label = models.CharField(max_length=200)
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default=PENDING)
    log = models.TextField(blank=True, default="")
    created_at = models.DateTimeField(auto_now_add=True)
    finished_at = models.DateTimeField(null=True, blank=True)

    def __str__(self) -> str:
        return f"{self.action} {self.source_path} [{self.status}]"
