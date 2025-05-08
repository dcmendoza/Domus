from django.contrib import admin
from django.contrib.auth import get_user_model
from .models import (
    Tower, Apartment, Facility, ParkingSpot,
    ShiftAssignment, LeaveRequest, Reservation
)

# Register your models here.
CustomUser = get_user_model()

@admin.register(CustomUser)
class CustomUserAdmin(admin.ModelAdmin):
    list_display = ('email', 'nombre_completo', 'role', 'subrole', 'is_staff')
    search_fields = ('email', 'nombre_completo')
    list_filter = ('role', 'subrole', 'is_staff')

# Registrar otros modelos
@admin.register(Tower)
class TowerAdmin(admin.ModelAdmin):
    list_display = ('name', 'num_floors')

@admin.register(Apartment)
class ApartmentAdmin(admin.ModelAdmin):
    list_display = ('number', 'tower', 'floor', 'owner')
    list_filter = ('tower', 'floor')
    search_fields = ('number',)

@admin.register(Facility)
class FacilityAdmin(admin.ModelAdmin):
    list_display = ('name', 'is_reserved')
    list_filter = ('is_reserved',)
    search_fields = ('name',)

@admin.register(ParkingSpot)
class ParkingSpotAdmin(admin.ModelAdmin):
    list_display = ('identifier', 'apartment')
    search_fields = ('identifier',)

@admin.register(ShiftAssignment)
class ShiftAssignmentAdmin(admin.ModelAdmin):
    list_display = ('employee', 'area', 'start_datetime', 'end_datetime', 'tower', 'facility')
    list_filter = ('area', 'tower', 'facility')
    search_fields = ('employee__nombre_completo',)

@admin.register(LeaveRequest)
class LeaveRequestAdmin(admin.ModelAdmin):
    list_display = ('employee', 'type', 'status', 'start_date', 'end_date')
    list_filter = ('type', 'status')
    search_fields = ('employee__nombre_completo',)

@admin.register(Reservation)
class ReservationAdmin(admin.ModelAdmin):
    list_display = ('facility', 'user', 'status', 'start_datetime', 'end_datetime')
    list_filter = ('status', 'facility')
    search_fields = ('user__nombre_completo', 'facility__name')