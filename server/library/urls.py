from django.urls import path

from . import views

app_name = "library"

urlpatterns = [
    path("", views.index, name="index"),
    path("api/files/<str:category>/", views.api_files, name="api_files"),
    path("api/jobs/start/", views.api_start_job, name="api_start_job"),
    path("api/jobs/<int:job_id>/", views.api_job_status, name="api_job_status"),
]
