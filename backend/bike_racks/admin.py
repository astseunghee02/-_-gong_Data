from django.contrib import admin
from .models import BikeRack

@admin.register(BikeRack)
class BikeRackAdmin(admin.ModelAdmin):
    list_display = ('자전거보관소명', '관리기관명', '보관대수')
    search_fields = ('자전거보관소명', '관리기관명')