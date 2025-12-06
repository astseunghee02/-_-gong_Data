from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from .views import RegisterView, UserInfoView, LogoutView

urlpatterns = [
    path("register/", RegisterView.as_view()),
    path("login/", TokenObtainPairView.as_view()),   # username + password → JWT 토큰
    path("token/refresh/", TokenRefreshView.as_view()),
    path("me/", UserInfoView.as_view()),
    path("logout/", LogoutView.as_view()),
]