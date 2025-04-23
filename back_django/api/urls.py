from django.urls import path, include
from rest_framework.routers import DefaultRouter
from api import views

router = DefaultRouter()
#router.register(r'propiedades', views.PropiedadViewSet)

urlpatterns = [
  path('api/', include(router.urls)),
  # path para login/token, etc.
]