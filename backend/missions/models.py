from django.db import models
from django.contrib.auth.models import User
from places.models import Place
from datetime import datetime, timedelta


class Mission(models.Model):
    """미션 모델 - 특정 장소 방문하기"""
    DIFFICULTY_CHOICES = [
        ('easy', '쉬움'),
        ('normal', '보통'),
        ('hard', '어려움'),
    ]

    place = models.ForeignKey(Place, on_delete=models.CASCADE)
    title = models.CharField(max_length=200)
    description = models.TextField()
    difficulty = models.CharField(max_length=20, choices=DIFFICULTY_CHOICES, default='normal')

    # 거리 기반 점수 (자동 계산)
    base_points = models.IntegerField(default=100)  # 기본 점수
    distance_bonus = models.IntegerField(default=0)  # 거리 보너스
    difficulty_bonus = models.IntegerField(default=0)  # 난이도 보너스

    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.title} ({self.get_difficulty_display()})"

    @property
    def total_points(self):
        """총 획득 가능 점수"""
        return self.base_points + self.distance_bonus + self.difficulty_bonus

    @classmethod
    def calculate_points(cls, distance_km, difficulty='normal'):
        """거리와 난이도에 따른 점수 계산"""
        base_points = 100

        # 거리 보너스 (1km당 20점, 최대 500점)
        distance_bonus = min(int(distance_km * 20), 500)

        # 난이도 보너스
        difficulty_bonus_map = {
            'easy': 0,
            'normal': 100,
            'hard': 300,
        }
        difficulty_bonus = difficulty_bonus_map.get(difficulty, 0)

        return {
            'base_points': base_points,
            'distance_bonus': distance_bonus,
            'difficulty_bonus': difficulty_bonus,
            'total_points': base_points + distance_bonus + difficulty_bonus,
        }


class UserMission(models.Model):
    """사용자별 미션 진행 상황"""
    STATUS_CHOICES = [
        ('available', '도전 가능'),
        ('ongoing', '진행중'),
        ('completed', '완료'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE)
    mission = models.ForeignKey(Mission, on_delete=models.CASCADE)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='available')

    # 사용자 위치 기준 거리 (미션 시작 시 계산)
    distance_from_user = models.FloatField(null=True, blank=True)

    started_at = models.DateTimeField(null=True, blank=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    points_earned = models.IntegerField(default=0)

    class Meta:
        unique_together = ['user', 'mission']
        ordering = ['-started_at', '-completed_at']

    def __str__(self):
        return f"{self.user.username} - {self.mission.title} ({self.get_status_display()})"

    def start_mission(self, distance_km):
        """미션 시작"""
        self.status = 'ongoing'
        self.distance_from_user = distance_km
        self.started_at = datetime.now()
        self.save()

    def complete_mission(self):
        """미션 완료 및 보상 지급"""
        if self.status != 'ongoing':
            return False

        self.status = 'completed'
        self.completed_at = datetime.now()
        self.points_earned = self.mission.total_points
        self.save()

        # 사용자 프로필에 경험치/포인트 추가
        profile = self.user.profile
        profile.add_points(self.points_earned)

        return True

    def cancel_mission(self):
        """진행 중 미션을 다시 도전 가능 상태로 되돌림"""
        if self.status != 'ongoing':
            return False

        self.status = 'available'
        self.started_at = None
        self.completed_at = None
        self.points_earned = 0
        self.distance_from_user = None
        self.save(update_fields=[
            'status',
            'started_at',
            'completed_at',
            'points_earned',
            'distance_from_user',
        ])
        return True

    @classmethod
    def get_user_stats(cls, user):
        """사용자 미션 통계"""
        ongoing_count = cls.objects.filter(user=user, status='ongoing').count()
        total_completed = cls.objects.filter(user=user, status='completed').count()

        # 이번주 완료 (월요일 기준)
        today = datetime.now()
        week_start = today - timedelta(days=today.weekday())
        week_start = week_start.replace(hour=0, minute=0, second=0, microsecond=0)

        weekly_completed = cls.objects.filter(
            user=user,
            status='completed',
            completed_at__gte=week_start
        ).count()

        return {
            'ongoing': ongoing_count,
            'weekly_completed': weekly_completed,
            'total_completed': total_completed,
        }
