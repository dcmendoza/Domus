"""" Modulos para las vistas de la API """
from rest_framework import viewsets, filters, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAdminUser, IsAuthenticated, AllowAny
from rest_framework.response import Response
from rest_framework.exceptions import PermissionDenied
from django.contrib.auth import get_user_model
from django.core.mail import send_mail
from django_filters.rest_framework import DjangoFilterBackend
from .models import (Tower, Apartment, Facility, ParkingSpot,
                    ShiftAssignment, LeaveRequest, Reservation)
from .serializers import (TowerSerializer, ApartmentSerializer, FacilitySerializer,
                        ParkingSpotSerializer, ShiftAssignmentSerializer, LeaveRequestSerializer,
                        UserSerializer, ReservationSerializer)

# Constants
NO_REPLY_EMAIL = 'no-reply@domus.com'

# Create your views here.
CustomUser = get_user_model()

class ReservationViewSet(viewsets.ModelViewSet):
    """
    Vista para gestionar reservas.
    """
    serializer_class = ReservationSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [filters.OrderingFilter, filters.SearchFilter]
    ordering_fields = ['start_datetime', 'created_at']
    search_fields = ['facility__name', 'user__get_full_name']

    def get_queryset(self):
        user = self.request.user
        if user.role == CustomUser.ADMIN:
            return Reservation.objects.all()
        return Reservation.objects.filter(user=user)

    def perform_create(self, serializer):
        instance = serializer.save(user=self.request.user)
        # Notificar al admin
        send_mail(
            'Nueva Solicitud de Reserva',
            f"Usuario {instance.user.get_full_name()} solicita reserva de {instance.facility.name} "
            f"de {instance.start_datetime} a {instance.end_datetime}.",
            NO_REPLY_EMAIL,
            [admin.email for admin in CustomUser.objects.filter(role='admin')],
            fail_silently=True
        )

    @action(detail=True, methods=['post'], permission_classes=[IsAdminUser])
    def review(self, request, pk=None):
        """
        Revisa una reserva. Solo accesible por administradores.
        """
        reservation = self.get_object()
        decision = request.data.get('decision')  # 'aprobada' o 'rechazada'
        reservation.status = decision
        reservation.save()
        # notificar al usuario
        subject = 'Reserva ' + ('aprobada' if decision=='aprobada' else 'rechazada')
        send_mail(
            subject,
            f"Tu reserva de {reservation.facility.name} del {reservation.start_datetime} "
            f"al {reservation.end_datetime} ha sido {decision}.",
            NO_REPLY_EMAIL,
            [reservation.user.email],
            fail_silently=True
        )
        return Response({'status': reservation.status})

class TowerViewSet(viewsets.ModelViewSet):
    """
    Vista para gestionar torres.
    """
    queryset = Tower.objects.all()
    serializer_class = TowerSerializer
    permission_classes = [IsAdminUser]

class ApartmentViewSet(viewsets.ModelViewSet):
    """
    Vista para gestionar apartamentos.
    """
    queryset = Apartment.objects.all()
    serializer_class = ApartmentSerializer
    permission_classes = [IsAdminUser]

class FacilityViewSet(viewsets.ModelViewSet):
    """
    Vista para gestionar instalaciones.
    - GET (list/retrieve): cualquier usuario autenticado.
    - POST/PUT/DELETE: solo administradores.
    """
    queryset = Facility.objects.all().order_by('name')  # <-- orden fijo
    serializer_class = FacilitySerializer
    ordering_fields = ['name']

    def get_permissions(self):
        # admin para mutaciones, auth para lecturas
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            perms = [IsAdminUser]
        else:
            perms = [IsAuthenticated]
        return [p() for p in perms]

class ParkingSpotViewSet(viewsets.ModelViewSet):
    """
    Vista para gestionar estacionamientos.
    """
    queryset = ParkingSpot.objects.all()
    serializer_class = ParkingSpotSerializer
    permission_classes = [IsAdminUser]

class ShiftAssignmentViewSet(viewsets.ModelViewSet):
    """
    Vista para gestionar asignaciones de turnos.
    """
    queryset = ShiftAssignment.objects.all()
    serializer_class = ShiftAssignmentSerializer
    permission_classes = [IsAdminUser]

    filter_backends = [filters.OrderingFilter, filters.SearchFilter]
    ordering_fields = ['start_datetime', 'area']
    search_fields = ['employee__email', 'area']

    def get_queryset(self):
        user = self.request.user
        qs = ShiftAssignment.objects.all()
        # Si no es admin, sólo sus propios turnos
        if user.role != CustomUser.ADMIN:
            qs = qs.filter(employee=user)
        # Filtros opcionales por área, fechas y empleado
        area = self.request.query_params.get('area')
        start = self.request.query_params.get('start')
        end = self.request.query_params.get('end')
        emp = self.request.query_params.get('employee')
        if area:
            qs = qs.filter(area=area)
        if start and end:
            qs = qs.filter(
                start_datetime__date__gte=start,
                end_datetime__date__lte=end
            )
        if emp:
            qs = qs.filter(employee__id=emp)
        return qs

    def perform_create(self, serializer):
        instance = serializer.save()
        # Notificar al empleado por correo
        send_mail(
            'Nuevo turno asignado',
            f"Se ha asignado un nuevo turno de {instance.start_datetime} a {instance.end_datetime} "
            f"en el área de {instance.area}.",
            NO_REPLY_EMAIL,
            [instance.employee.email],
            fail_silently=True
        )

    def get_permissions(self):
        # Sólo admin crea/modifica/borra
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            perms = [IsAdminUser]
        else:
            perms = [IsAuthenticated]
        return [p() for p in perms]

class LeaveRequestViewSet(viewsets.ModelViewSet):
    """
    Vista para gestionar solicitudes de permisos/incapacidades.
    - EMPLEADO: GET (list/retrieve) de sus propias solicitudes, POST para crear,
    PUT/PATCH/DELETE solo sobre sus solicitudes PENDIENTES.
    - ADMIN: CRUD completo + action 'review' para aprobar/rechazar.
    """
    serializer_class = LeaveRequestSerializer
    queryset = LeaveRequest.objects.all().order_by('-created_at')
    ordering = ['-created_at']
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter, filters.SearchFilter]
    filterset_fields = ['status', 'type', 'start_date', 'end_date']
    ordering_fields = ['created_at', 'start_date']
    search_fields = ['employee__first_name', 'employee__last_name', 'type']

    def get_queryset(self):
        qs = super().get_queryset()
        if self.request.user.role != CustomUser.ADMIN:
            qs = qs.filter(employee=self.request.user)
        return qs

    def get_permissions(self):
        # review solo admin
        if self.action == 'review':
            perms = [IsAdminUser]
        # crear, listar y ver detalles → cualquier autenticado
        elif self.action in ['create', 'list', 'retrieve']:
            perms = [IsAuthenticated]
        # editar/borrar → cualquier autenticado, chequeo extra en perform_*
        elif self.action in ['update', 'partial_update', 'destroy']:
            perms = [IsAuthenticated]
        else:
            # (p.ej. review está más arriba; actions extra si los tuvieras)
            perms = [IsAdminUser]
        return [p() for p in perms]

    def perform_create(self, serializer):
        # al crear, fijar employee = quien hace la petición
        serializer.save(employee=self.request.user)

    def perform_update(self, serializer):
        leave = self.get_object()
        user = self.request.user
        # Si no es admin, sólo puede editar su propia solicitud PENDIENTE
        if user.role != 'admin':
            if leave.employee != user:
                raise PermissionDenied("No puedes editar solicitudes de otro usuario.")
            if leave.status != LeaveRequest.STATUS_CHOICES[0][0]:  # 'pendiente'
                raise PermissionDenied("Solo puedes editar solicitudes pendientes.")
        serializer.save()

    def perform_destroy(self, instance):
        user = self.request.user
        # Si no es admin, sólo puede borrar su propia solicitud PENDIENTE
        if user.role != 'admin':
            if instance.employee != user:
                raise PermissionDenied("No puedes eliminar solicitudes de otro usuario.")
            if instance.status != LeaveRequest.STATUS_CHOICES[0][0]:  # 'pendiente'
                raise PermissionDenied("Solo puedes eliminar solicitudes pendientes.")
        instance.delete()

    @action(detail=True, methods=['post'], permission_classes=[IsAdminUser])
    def review(self, request, pk=None):
        """
        Admin aprueba o rechaza la solicitud.
        body: { "decision": "aprobada" }  ó  { "decision": "rechazada" }
        """
        leave = self.get_object()
        decision = request.data.get('decision')
        if decision == 'aprobada':
            leave.approve(request.user)
        elif decision == 'rechazada':
            leave.reject(request.user)
        else:
            return Response(
                {'detail': 'Decision inválida; use "aprobada" o "rechazada".'},
                status=status.HTTP_400_BAD_REQUEST
            )
        return Response({'status': leave.status}, status=status.HTTP_200_OK)

class UserViewSet(viewsets.ModelViewSet):
    """
    ViewSet para gestionar usuarios. Solo accesible por administradores.
    """
    queryset = CustomUser.objects.all().order_by('id')
    serializer_class = UserSerializer
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter, filters.SearchFilter]
    filterset_fields = ['role', 'registration_status']
    search_fields = ['first_name', 'last_name', 'email']

    def get_permissions(self):
        if self.action == 'create':
            return [AllowAny()]
        if self.action in ('approve', 'reject'):
            return [IsAdminUser()]
        if self.action == 'me':
            return [IsAuthenticated()]
        # list, retrieve, update, destroy → admin
        return [IsAdminUser()]

    def perform_create(self, serializer):
        """
        Al crearse un usuario (estado PENDIENTE e is_active=False),
        notificamos por email a todos los administradores.
        """
        user = serializer.save()
        admins = CustomUser.objects.filter(role=CustomUser.ADMIN)
        send_mail(
            'Nueva solicitud de registro',
            f'El usuario {user.get_full_name()} ({user.email}) '
            f'ha solicitado acceso y está pendiente de aprobación.',
            NO_REPLY_EMAIL,
            [a.email for a in admins],
            fail_silently=True,
        )

    def get_queryset(self):
        qs = super().get_queryset()
        return qs


    @action(detail=False, methods=['get'], url_path='me')
    def me(self, request):
        """Devuelve datos del propio usuario."""
        serializer = self.get_serializer(request.user)
        return Response(serializer.data)

    @action(detail=True, methods=['post'], url_path='approve')
    def approve(self, request, pk=None):
        """Admin aprueba registro pendiente."""
        user = self.get_object()
        user.approve()
        return Response({'registration_status': user.registration_status})

    @action(detail=True, methods=['post'], url_path='reject')
    def reject(self):
        """Admin rechaza registro pendiente."""
        user = self.get_object()
        user.reject()
        return Response({'registration_status': user.registration_status})
