from django.test import TestCase, override_settings
from django.core.exceptions import ValidationError
from django.core import mail
from django.utils import timezone
from django.core.files.uploadedfile import SimpleUploadedFile

from api.models import CustomUser, Tower, Facility, ShiftAssignment, Reservation, LeaveRequest

class ModelTests(TestCase):
    def setUp(self):
        # Usuario empleado activo
        self.user = CustomUser.objects.create_user(
            username='emp1',
            email='emp1@example.com',
            password='testpass123',
            first_name='Juan',
            last_name='Pérez',
            telefono='3001234567',
            role=CustomUser.EMPLEADO,
            subrole=CustomUser.LIMPIEZA
        )
        self.user.is_active = True
        self.user.save()

        # Datos base: torre y facility
        self.tower = Tower.objects.create(name='Torre A', num_floors=5)
        self.facility = Facility.objects.create(name='Gimnasio', is_reserved=True)

    def test_shift_invalid_date_range(self):
        """start_datetime >= end_datetime debe validar error"""
        start = timezone.now()
        end = start - timezone.timedelta(hours=1)
        shift = ShiftAssignment(
            employee=self.user,
            area='aseo',
            start_datetime=start,
            end_datetime=end
        )
        with self.assertRaises(ValidationError):
            shift.clean()

    def test_shift_overlapping(self):
        """Turnos solapados deben generar ValidationError"""
        start = timezone.now()
        end = start + timezone.timedelta(hours=2)
        # Primer turno válido
        ShiftAssignment.objects.create(
            employee=self.user,
            area='aseo',
            start_datetime=start,
            end_datetime=end
        )
        # Turno que solapa
        overlap = ShiftAssignment(
            employee=self.user,
            area='aseo',
            start_datetime=start + timezone.timedelta(hours=1),
            end_datetime=end + timezone.timedelta(hours=1)
        )
        with self.assertRaises(ValidationError):
            overlap.clean()

    def test_reservation_str_and_overlap(self):
        """__str__ debe incluir nombre de facility y clean() maneja solapamientos"""
        start = timezone.now()
        end = start + timezone.timedelta(hours=1)
        # __str__ antes de guardar
        r = Reservation(
            facility=self.facility,
            user=self.user,
            start_datetime=start,
            end_datetime=end
        )
        self.assertIn('Reserva Gimnasio', str(r))
        # Validación de rango correcto
        r.clean()  # no debería levantar
        r.save()
        # Nueva reserva solapada
        r2 = Reservation(
            facility=self.facility,
            user=self.user,
            start_datetime=start,
            end_datetime=end
        )
        with self.assertRaises(ValidationError):
            r2.clean()

    @override_settings(EMAIL_BACKEND='django.core.mail.backends.locmem.EmailBackend')
    def test_leave_request_approve_removes_shifts_and_sends_email(self):
        """approve() borra turnos y envía correo"""
        # Creamos documento simulado
        doc = SimpleUploadedFile('req.txt', b'data')
        # Fechas para solicitud
        today = timezone.now().date()
        tomorrow = today + timezone.timedelta(days=1)
        # Creamos solicitud
        lr = LeaveRequest.objects.create(
            employee=self.user,
            type='permiso',
            start_date=today,
            end_date=tomorrow,
            reason='Motivo',
            document=doc
        )
        # Asignamos un turno para que luego sea borrado
        ShiftAssignment.objects.create(
            employee=self.user,
            area='aseo',
            start_datetime=timezone.now(),
            end_datetime=timezone.now() + timezone.timedelta(hours=1)
        )
        # Ejecutamos approve
        lr.approve(reviewer=self.user)
        # Verificamos que no existan turnos
        self.assertFalse(ShiftAssignment.objects.filter(employee=self.user).exists())
        # Verificamos correo
        self.assertEqual(len(mail.outbox), 1)
