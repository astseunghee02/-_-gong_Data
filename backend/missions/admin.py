from django.contrib import admin
from .models import Mission, UserMission


@admin.register(Mission)
class MissionAdmin(admin.ModelAdmin):
    list_display = ['title', 'place', 'difficulty', 'total_points', 'is_active']
    list_filter = ['difficulty', 'is_active']
    search_fields = ['title', 'place__name']


@admin.register(UserMission)
class UserMissionAdmin(admin.ModelAdmin):
    list_display = ['user', 'mission', 'status', 'points_earned', 'started_at', 'completed_at']
    list_filter = ['status', 'completed_at']
    search_fields = ['user__username', 'mission__title']
