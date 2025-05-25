from django.urls import reverse
from rest_framework.test import APITestCase
from rest_framework import status
from rest_framework.authtoken.models import Token
from django.utils import timezone

from api.models import CustomUser, Facility, Reservation

class EndToEndTests(APITestCase):
    def setUp(self):
        # Crear admin y facility
        self.admin = CustomUser.objects.create_user(
            username='admin',
            email='admin@example.com',
            password='adminpass',
            first_name='Admin',
            last_name='User',
            telefono='3000000000',
            role=CustomUser.ADMIN
        )
        self.admin.is_active = True
        self.admin.is_staff = True
        self.admin.registration_status = CustomUser.APROBADO
        self.admin.save()
        self.admin_token = Token.objects.create(user=self.admin)

        self.facility = Facility.objects.create(name='Gimnasio', is_reserved=False)

    def test_full_user_flow_reservation_review(self):
        # 1. Registro público de nuevo empleado
        signup_url = reverse('user-list')
        new_user_data = {
            'email': 'emp_new@example.com',
            'first_name': 'Emp',
            'last_name': 'Nuevo',
            'telefono': '3001230000',
            'role': CustomUser.EMPLEADO,
            'subrole': CustomUser.LIMPIEZA,
            'password': 'clave1234'
        }
        resp = self.client.post(signup_url, new_user_data)
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        new_user_id = resp.data['id']

        # 2. El admin aprueba al nuevo usuario
        approve_url = reverse('user-approve', args=[new_user_id])
        self.client.credentials(HTTP_AUTHORIZATION=f'Token {self.admin_token.key}')
        resp = self.client.post(approve_url)
        self.assertEqual(resp.status_code, status.HTTP_200_OK)

        # 3. El usuario nuevo obtiene token via api-token-auth
        self.client.credentials()  # limpiar credenciales
        auth_url = reverse('api_token_auth')
        login_resp = self.client.post(auth_url, {
            'username': 'emp_new@example.com',  # El backend usa email como username
            'password': 'clave1234'
        })
        self.assertEqual(login_resp.status_code, status.HTTP_200_OK)
        user_token = login_resp.data['token']

        # 4. El usuario autenticado crea una reserva
        self.client.credentials(HTTP_AUTHORIZATION=f'Token {user_token}')
        reserve_url = reverse('reservations-list')
        start = (timezone.now() + timezone.timedelta(hours=1)).isoformat()
        end = (timezone.now() + timezone.timedelta(hours=2)).isoformat()
        reservation_data = {
            'facility': self.facility.id,
            'start_datetime': start,
            'end_datetime': end
        }
        reserve_resp = self.client.post(reserve_url, reservation_data)
        self.assertEqual(reserve_resp.status_code, status.HTTP_201_CREATED)
        reservation_id = reserve_resp.data['id']
        self.assertEqual(reserve_resp.data['status'], 'pendiente')

        # 5. El admin revisa (aprueba) la reserva
        review_url = reverse('reservations-review', args=[reservation_id])
        self.client.credentials(HTTP_AUTHORIZATION=f'Token {self.admin_token.key}')
        review_resp = self.client.post(review_url, {'decision': 'aprobada'})
        self.assertEqual(review_resp.status_code, status.HTTP_200_OK)
        self.assertEqual(review_resp.data['status'], 'aprobada')

        # 6. El usuario consulta su reserva y ve estado actualizado
        detail_url = reverse('reservations-detail', args=[reservation_id])
        self.client.credentials(HTTP_AUTHORIZATION=f'Token {user_token}')
        detail_resp = self.client.get(detail_url)
        self.assertEqual(detail_resp.status_code, status.HTTP_200_OK)
        self.assertEqual(detail_resp.data['status'], 'aprobada')
