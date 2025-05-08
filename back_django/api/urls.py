"""" Modulos de rutas de la API """
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
            UserViewSet, TowerViewSet, ApartmentViewSet, FacilityViewSet, ParkingSpotViewSet,
            ShiftAssignmentViewSet, LeaveRequestViewSet, ReservationViewSet
            )

router = DefaultRouter()
router.register(r'users', UserViewSet, basename='user')
router.register(r'towers', TowerViewSet, basename='tower')
router.register(r'apartments', ApartmentViewSet, basename='apartment')
router.register(r'facilities', FacilityViewSet, basename='facility')
router.register(r'parkings', ParkingSpotViewSet, basename='parking')
router.register(r'shifts', ShiftAssignmentViewSet, basename='shift')
router.register(r'leaves', LeaveRequestViewSet, basename='leave')
router.register(r'reservations', ReservationViewSet, basename='reservations')

urlpatterns = [
  path('api/', include(router.urls)),
  # path para login/token, etc.
]
