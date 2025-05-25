from django.test import TestCase
from django.utils import timezone
from rest_framework.exceptions import ValidationError
from api.serializers import ReservationSerializer, UserSerializer
from api.models import Facility, CustomUser

class SerializerTests(TestCase):
    def setUp(self):
        # Crear facility y usuario
        self.facility = Facility.objects.create(name='Sala TV', is_reserved=False)
        self.user = CustomUser.objects.create_user(
            username='prop1',
            email='prop1@example.com',
            password='pass1234',
            first_name='Ana',
            last_name='Gómez',
            telefono='3007654321',
            role=CustomUser.PROPIETARIO
        )
        self.user.is_active = True
        self.user.save()

    def test_reservation_serializer_valid(self):
        now = timezone.now()
        data = {
            'facility': self.facility.id,
            'start_datetime': (now + timezone.timedelta(hours=1)).isoformat(),
            'end_datetime': (now + timezone.timedelta(hours=2)).isoformat()
        }
        serializer = ReservationSerializer(data=data, context={'request': None})
        self.assertTrue(serializer.is_valid(), serializer.errors)
        inst = serializer.save(user=self.user)
        self.assertEqual(inst.status, 'pendiente')
        self.assertEqual(inst.user, self.user)

    def test_reservation_serializer_invalid_dates(self):
        now = timezone.now()
        data = {
            'facility': self.facility.id,
            'start_datetime': now.isoformat(),
            'end_datetime': (now - timezone.timedelta(hours=1)).isoformat()
        }
        serializer = ReservationSerializer(data=data, context={'request': None})
        self.assertFalse(serializer.is_valid())
        self.assertIn('non_field_errors', serializer.errors)

    def test_user_serializer_employee_requires_subrole(self):
        # Empleado sin subrol debe fallar
        data = {
            'email': 'emp2@example.com',
            'first_name': 'Emp',
            'last_name': 'Uno',
            'telefono': '3000000000',
            'role': CustomUser.EMPLEADO,
            'subrole': ''
        }
        context = {'request': type('r', (), {'user': None})}
        serializer = UserSerializer(data=data, context=context)
        with self.assertRaises(ValidationError):
            serializer.is_valid(raise_exception=True)

    def test_user_serializer_forbid_admin_signup(self):
        # Usuario no admin no puede registrarse como administrador
        data = {
            'email': 'newadmin@example.com',
            'first_name': 'New',
            'last_name': 'Admin',
            'telefono': '3001112222',
            'role': CustomUser.ADMIN,
            'subrole': ''
        }
        context = {'request': type('r', (), {'user': None})}
        serializer = UserSerializer(data=data, context=context)
        with self.assertRaises(ValidationError):
            serializer.is_valid(raise_exception=True)
