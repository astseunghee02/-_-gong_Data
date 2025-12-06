from django.contrib import admin
from .models import Corporation

@admin.register(Corporation)
class CorporationAdmin(admin.ModelAdmin):
    list_display = ('법인명칭', '법인종류', '허가번호')
    search_fields = ('법인명칭', '대표자', '법인종류')