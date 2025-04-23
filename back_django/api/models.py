"""Modulo de modelos para la aplicación de usuarios de Django."""
from django.contrib.auth.models import AbstractUser
from django.db import models

# Create your models here.
class CustomUser(AbstractUser):
    """
    Modelo de usuario personalizado para Domus.
    Extiende AbstractUser e incluye campos para nombre completo, teléfono,
    verificación de email, aprobación de admin y roles.
    """
    # El campo 'username' se mantiene internamente, pero usaremos email para login
    email = models.EmailField('Correo Electrónico', unique=True)
    nombre_completo = models.CharField('Nombre Completo', max_length=150)
    telefono = models.CharField('Número de Teléfono', max_length=20)

    # Roles de usuario
    ADMIN = 'admin'
    EMPLEADO = 'empleado'
    PROPIETARIO = 'propietario'
    ROLE_CHOICES = [
        (ADMIN, 'Administrador'),
        (EMPLEADO, 'Empleado'),
        (PROPIETARIO, 'Propietario'),
    ]
    role = models.CharField('Rol', max_length=20, choices=ROLE_CHOICES)

    # Sub-roles solo aplican si es EMPLEADO
    LIMPIEZA = 'limpieza'
    SEGURIDAD = 'seguridad'
    MANTENIMIENTO = 'mantenimiento'
    SUBROLE_CHOICES = [
        (LIMPIEZA, 'Limpieza'),
        (SEGURIDAD, 'Seguridad'),
        (MANTENIMIENTO, 'Mantenimiento'),
    ]
    subrole = models.CharField(
        'Subrol (solo empleados)',
        max_length=20,
        choices=SUBROLE_CHOICES,
        blank=True,
        null=True,
        help_text='Especifica el subrol si el usuario es un empleado.'
    )

    # Configuración de autenticación
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username', 'nombre_completo', 'telefono', 'role']

    def __str__(self):
        return f"{self.nombre_completo} <{self.email}>"
