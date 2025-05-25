"""
Modulo de configuración de la aplicación API.
"""
from django.apps import AppConfig

class ApiConfig(AppConfig):
    """
    Clase de configuración para la aplicación API.
    """
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'api'
