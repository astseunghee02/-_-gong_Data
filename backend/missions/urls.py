from django.urls import path
from .views import (
    GenerateMissionsView,
    AvailableMissionsView,
    OngoingMissionsView,
    StartMissionView,
    CompleteMissionView,
    CancelMissionView,
    MissionStatsView,
)

urlpatterns = [
    path('generate/', GenerateMissionsView.as_view(), name='generate_missions'),
    path('available/', AvailableMissionsView.as_view(), name='available_missions'),
    path('ongoing/', OngoingMissionsView.as_view(), name='ongoing_missions'),
    path('<int:mission_id>/start/', StartMissionView.as_view(), name='start_mission'),
    path('<int:mission_id>/complete/', CompleteMissionView.as_view(), name='complete_mission'),
    path('<int:mission_id>/cancel/', CancelMissionView.as_view(), name='cancel_mission'),
    path('stats/', MissionStatsView.as_view(), name='mission_stats'),
]
