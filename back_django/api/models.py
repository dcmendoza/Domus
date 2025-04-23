"""Modulo de modelos para la aplicación de usuarios de Django."""
from django.contrib.auth.models import AbstractUser
from django.db import models
from django.conf import settings
from django.core.exceptions import ValidationError
from django.core.mail import send_mail
from django.utils import timezone

# Create your models here.
User = settings.AUTH_USER_MODEL

class Tower(models.Model):
    """
    Modelo para representar una torre en el edificio.
    Cada torre tiene un nombre único.
    """
    name = models.CharField(max_length=100)
    num_floors = models.PositiveIntegerField()

    def __str__(self):
        return str(self.name)

class Apartment(models.Model):
    """
    Modelo para representar un apartamento en una torre.
    Cada apartamento tiene un número único, una relación con la torre y propietarios.
    """
    tower = models.ForeignKey(Tower, related_name='apartments', on_delete=models.CASCADE)
    floor = models.PositiveIntegerField()
    number = models.CharField(max_length=10)
    owner = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True)
    rooms = models.PositiveIntegerField()
    bathrooms = models.PositiveIntegerField()
    rent_price = models.DecimalField(max_digits=10, decimal_places=2)
    parking_slots = models.IntegerField()

    def __str__(self):
        return f"Apt {self.number} - {self.tower.name}"

class Facility(models.Model):
    """
    Modelo para representar una instalación común en el edificio.
    Cada instalación tiene un nombre único y puede ser reservable o no.
    """
    name = models.CharField(max_length=100)
    is_reserved = models.BooleanField(default=False)

    def __str__(self):
        return str(self.name)

class ParkingSpot(models.Model):
    """
    Modelo para representar un parqueadero en el edificio.
    Cada parqueadero tiene un número único y puede estar asociado a un apartamento.
    """
    apartment = models.ForeignKey(
                Apartment, related_name='parkings', on_delete=models.SET_NULL, null=True, blank=True
                )
    identifier = models.CharField(max_length=20)

    def __str__(self):
        label = f"Parking {self.identifier}"
        return f"{label} - Apto {self.apartment.number}" if self.apartment else label

class ShiftAssignment(models.Model):
    """
    Modelo para asignar turnos a empleados de aseo y seguridad.
    Cada turno tiene un inicio y fin, y puede estar asociado a una torre o instalación.
    """
    # Solo empleados de Aseo y Seguridad
    AREA_CHOICES = (
        ('aseo', 'Aseo'),
        ('seguridad', 'Seguridad'),
    )

    employee = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        limit_choices_to={'role': 'empleado'}
    )
    area = models.CharField(max_length=20, choices=AREA_CHOICES)
    start_datetime = models.DateTimeField()
    end_datetime = models.DateTimeField()
    tower = models.ForeignKey(
        Tower,
        on_delete=models.SET_NULL,
        null=True,
        blank=True
    )
    facility = models.ForeignKey(
        Facility,
        on_delete=models.SET_NULL,
        null=True,
        blank=True
    )
    created_at = models.DateTimeField(auto_now_add=True)

    def clean(self):
        if self.area not in dict(self.AREA_CHOICES):
            raise ValidationError("Área no válida.")
        overlapping_shifts = ShiftAssignment.objects.filter(
            employee=self.employee,
            start_datetime__lt=self.end_datetime,
            end_datetime__gt=self.start_datetime
        ).exclude(id=self.id)
        if overlapping_shifts.exists():
            raise ValidationError("El empleado ya tiene un turno asignado en este horario.")
        if self.start_datetime >= self.end_datetime:
            raise ValidationError('La fecha de inicio debe ser anterior a la fecha de fin.')
        # ubicación exclusiva
        if bool(self.tower) == bool(self.facility):
            raise ValidationError('Especifique torre o instalación, no ambos ni ninguno.')

    def __str__(self):
        loc = self.tower or self.facility
        return f"{self.employee} - {self.area} from {self.start_datetime} to {self.end_datetime} @ {loc}"

class LeaveRequest(models.Model):
    """
    Modelo para solicitudes de permisos y incapacidades.
    Cada solicitud tiene un tipo, fechas de inicio y fin, motivo, documento adjunto,
    estado, fecha de creación y revisión.
    """
    STATUS_CHOICES = (
        ('pendiente', 'Pendiente'),
        ('aprobada', 'Aprobada'),
        ('rechazada', 'Rechazada')
    )

    TYPE_CHOICES = (
        ('permiso', 'Permiso'),
        ('incapacidad', 'Incapacidad')
    )

    employee = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        limit_choices_to={'role': 'empleado'}
    )
    type = models.CharField(max_length=20, choices=TYPE_CHOICES)
    start_date = models.DateField()
    end_date = models.DateField()
    reason = models.TextField()
    document = models.FileField(upload_to='leave_docs/')
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='pendiente'
    )
    reviewed_by = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='reviewed_leaves'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    reviewed_at = models.DateTimeField(null=True, blank=True)

    def clean(self):
        if self.start_date >= self.end_date:
            raise ValidationError('Fecha inicio posterior a fecha fin.')

    def approve(self, reviewer):
        self.status = 'aprobada'
        self.reviewed_by = reviewer
        self.reviewed_at = timezone.now()
        self.save()

        ShiftAssignment.objects.filter(
            employee=self.employee,
            start_datetime__date__gte=self.start_date,
            end_datetime__date__lte=self.end_date
        ).delete()

        send_mail(
            subject="Solicitud de permiso aprobada",
            message=f"Tu solicitud fue aprobada para el periodo {self.start_date} a {self.end_date}.",
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[self.employee.email]
        )

    def reject(self, reviewer):
        self.status = 'rechazada'
        self.reviewed_by = reviewer
        self.save()

        send_mail(
            subject="Solicitud de permiso rechazada",
            message=f"Tu solicitud fue rechazada. Motivo: {self.reason}.",
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[self.employee.email]
        )

    def __str__(self):
        return f"{self.employee.email} - {self.type} ({self.status})"

class Reservation(models.Model):
    STATUS_CHOICES = (
        ('pendiente', 'Pendiente'),
        ('aprobada', 'Aprobada'),
        ('rechazada', 'Rechazada'),
    )
    facility = models.ForeignKey(
        Facility,
        on_delete=models.CASCADE,
        related_name='reservations'
    )
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='reservations'
    )
    start_datetime = models.DateTimeField()
    end_datetime = models.DateTimeField()
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='pendiente'
    )
    created_at = models.DateTimeField(auto_now_add=True)

    def clean(self):
        from django.core.exceptions import ValidationError
        if self.start_datetime >= self.end_datetime:
            raise ValidationError("La fecha de inicio debe ser anterior a la fecha de fin.")
        overlapping = Reservation.objects.filter(
            facility=self.facility,
            start_datetime__lt=self.end_datetime,
            end_datetime__gt=self.start_datetime
        ).exclude(id=self.id)
        if overlapping.exists():
            raise ValidationError("Ya existe una reserva para este rango horario.")

    def __str__(self):
        return f"Reserva {self.facility.name} por {self.user.get_full_name()} ({self.status})"

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
