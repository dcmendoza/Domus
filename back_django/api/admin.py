"""Django admin configuration for the application."""
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
    """
    Configuración del panel de administración para el modelo CustomUser.
    """
    list_display = (
        'email','first_name','last_name',
        'role','subrole','registration_status','is_active'
    )
    list_filter = ('role', 'subrole', 'registration_status', 'is_active')
    search_fields = ('email', 'first_name', 'last_name')
    actions = ['approve_users','reject_users']

    def approve_users(self, request, queryset):
        """
        Acción personalizada para aprobar usuarios seleccionados.
        """
        for u in queryset.filter(registration_status=CustomUser.PENDIENTE):
            u.approve()
    approve_users.short_description = "Aprobar usuarios seleccionados"

    def reject_users(self, request, queryset):
        """
        Acción personalizada para rechazar usuarios seleccionados.
        """
        for u in queryset.filter(registration_status=CustomUser.PENDIENTE):
            u.reject()
    reject_users.short_description = "Rechazar usuarios seleccionados"

# Registrar otros modelos
@admin.register(Tower)
class TowerAdmin(admin.ModelAdmin):
    """
    Configuración del panel de administración para el modelo Tower.
    """
    list_display = ('name', 'num_floors')

@admin.register(Apartment)
class ApartmentAdmin(admin.ModelAdmin):
    """
    Configuración del panel de administración para el modelo Apartment
    """
    list_display = ('number', 'tower', 'floor', 'owner')
    list_filter = ('tower', 'floor')
    search_fields = ('number',)

@admin.register(Facility)
class FacilityAdmin(admin.ModelAdmin):
    """
    Configuración del panel de administración para el modelo Facility.
    """
    list_display = ('name', 'is_reserved')
    list_filter = ('is_reserved',)
    search_fields = ('name',)

@admin.register(ParkingSpot)
class ParkingSpotAdmin(admin.ModelAdmin):
    """
    Configuración del panel de administración para el modelo Parking
    """
    list_display = ('identifier', 'apartment')
    search_fields = ('identifier',)

@admin.register(ShiftAssignment)
class ShiftAssignmentAdmin(admin.ModelAdmin):
    """
    Configuración del panel de administración para el modelo ShiftAssignment."""
    list_display = ('employee', 'area', 'start_datetime', 'end_datetime', 'tower', 'facility')
    list_filter = ('area', 'tower', 'facility')
    search_fields = ('employee__first_name', 'employee__last_name')

@admin.register(LeaveRequest)
class LeaveRequestAdmin(admin.ModelAdmin):
    """
    Configuración del panel de administración para el modelo LeaveRequest.
    """
    list_display = ('employee', 'type', 'status', 'start_date', 'end_date')
    list_filter = ('type', 'status')
    search_fields = ('employee__first_name', 'employee__last_name')

@admin.register(Reservation)
class ReservationAdmin(admin.ModelAdmin):
    """
    Configuración del panel de administración para el modelo Reservation.
    """
    list_display = ('facility', 'user', 'status', 'start_datetime', 'end_datetime')
    list_filter = ('status', 'facility')
    search_fields = ('user__first_name', 'user__last_name', 'facility__name')
