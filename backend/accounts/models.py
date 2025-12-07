from django.db import models
from django.contrib.auth.models import User
from django.db.models.signals import post_save
from django.dispatch import receiver


class UserProfile(models.Model):
    """사용자 프로필 - 레벨, 경험치, 캐릭터 정보 등"""
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    level = models.IntegerField(default=1)  # 캐릭터 레벨
    experience = models.IntegerField(default=0)  # 경험치
    total_points = models.IntegerField(default=0)  # 총 획득 포인트

    # 추가 사용자 정보 (회원가입 시 입력한 정보)
    name = models.CharField(max_length=50, blank=True)
    phone = models.CharField(max_length=20, blank=True)
    age = models.IntegerField(null=True, blank=True)
    gender = models.CharField(max_length=10, blank=True)  # male, female, other
    weight = models.FloatField(null=True, blank=True)
    height = models.FloatField(null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.user.username} - Level {self.level}"

    def add_experience(self, exp):
        """경험치를 추가하고 레벨업 체크"""
        self.experience += exp
        # 레벨업 로직 (100 경험치당 1레벨)
        while self.experience >= 100:
            self.experience -= 100
            self.level += 1
        self.save()

    def add_points(self, points):
        """포인트 획득"""
        self.total_points += points
        self.add_experience(points // 10)  # 포인트의 10%를 경험치로


@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    """새 유저 생성 시 자동으로 프로필 생성 (레벨 1)"""
    if created:
        UserProfile.objects.create(user=instance)
