"""" Modulos de rutas de la API """
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework.authtoken import views as drf_token_views
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
  path('api-token-auth/', drf_token_views.obtain_auth_token, name='api_token_auth'),  # Token
  path('api-auth/', include('rest_framework.urls'), name='rest_framework'),  # Autenticación API
  # path para login/token, etc.
]
