from django.urls import reverse
from rest_framework.test import APITestCase, APIClient
from rest_framework import status
from rest_framework.authtoken.models import Token

from api.models import CustomUser, Facility

class ViewTests(APITestCase):
    def setUp(self):
        # Crear usuarios admin y propietario
        self.admin = CustomUser.objects.create_user(
            username='admin', email='admin@example.com', password='adminpass',
            first_name='Admin', last_name='Uno', telefono='3000000000', role=CustomUser.ADMIN
        )
        self.admin.is_active = True
        self.admin.is_staff = True
        self.admin.registration_status = CustomUser.APROBADO
        self.admin.save()
        self.admin_token = Token.objects.create(user=self.admin)

        self.user = CustomUser.objects.create_user(
            username='prop', email='prop@example.com', password='userpass',
            first_name='Prop', last_name='Dos', telefono='3001111111', role=CustomUser.PROPIETARIO
        )
        self.user.is_active = True
        self.user.save()
        self.user_token = Token.objects.create(user=self.user)

        self.client = APIClient()

    def test_facility_list_authenticated(self):
        # Cualquiera autenticado puede listar instalaciones
        Facility.objects.create(name='Gimnasio', is_reserved=False)
        url = reverse('facility-list')
        self.client.credentials(HTTP_AUTHORIZATION=f'Token {self.user_token.key}')
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('results', response.data)
        self.assertIsInstance(response.data['results'], list)

    def test_facility_create_by_admin(self):
        # Solo admin puede crear instalaciones
        url = reverse('facility-list')
        self.client.credentials(HTTP_AUTHORIZATION=f'Token {self.admin_token.key}')
        data = {'name': 'Piscina', 'is_reserved': False}
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(Facility.objects.filter(name='Piscina').exists())

    def test_facility_create_forbidden_to_non_admin(self):
        # Propietario no debe poder crear
        url = reverse('facility-list')
        self.client.credentials(HTTP_AUTHORIZATION=f'Token {self.user_token.key}')
        data = {'name': 'Sauna', 'is_reserved': True}
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_user_signup(self):
        # Registro público de nuevo usuario
        url = reverse('user-list')
        payload = {
            'email': 'nuevo@example.com',
            'first_name': 'Nuevo',
            'last_name': 'Usuario',
            'telefono': '3002223333',
            'role': CustomUser.PROPIETARIO,
            'password': 'clave1234'
        }
        response = self.client.post(url, payload)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(CustomUser.objects.filter(email='nuevo@example.com').exists())

    def test_me_endpoint(self):
        # Obtener datos propios con /api/users/me/
        url = reverse('user-me')
        self.client.credentials(HTTP_AUTHORIZATION=f'Token {self.user_token.key}')
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['email'], self.user.email)
