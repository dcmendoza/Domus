"""" Modulos para las vistas de la API """
from rest_framework import viewsets, filters, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAdminUser, IsAuthenticated, AllowAny
from rest_framework.response import Response
from django.contrib.auth import get_user_model
from django.core.mail import send_mail
from .models import (Tower, Apartment, Facility, ParkingSpot,
                    ShiftAssignment, LeaveRequest, Reservation)
from .serializers import (TowerSerializer, ApartmentSerializer, FacilitySerializer,
                        ParkingSpotSerializer, ShiftAssignmentSerializer, LeaveRequestSerializer,
                        UserSerializer, ReservationSerializer)
from .utils import send_approval_email, send_rejection_email

# Constants
NO_REPLY_EMAIL = 'no-reply@domus.com'

# Create your views here.
CustomUser = get_user_model()

class ReservationViewSet(viewsets.ModelViewSet):
    """
    Vista para gestionar reservas.
    """
    serializer_class = ReservationSerializer
    filter_backends = [filters.OrderingFilter, filters.SearchFilter]
    ordering_fields = ['start_datetime']
    search_fields = ['facility__name', 'user__nombre_completo']

    def get_queryset(self):
        user = self.request.user
        if user.role == 'admin':
            return Reservation.objects.all()
        return Reservation.objects.filter(user=user)

    def perform_create(self, serializer):
        instance = serializer.save(user=self.request.user)
        # notificar al admin
        send_mail(
            'Nueva Solicitud de Reserva',
            f"Usuario {instance.user.get_full_name()} solicita reserva de {instance.facility.name} "
            f"de {instance.start_datetime} a {instance.end_datetime}.",
            NO_REPLY_EMAIL,
            [admin.email for admin in CustomUser.objects.filter(role='admin')],
            fail_silently=True
        )

    @action(detail=True, methods=['post'], permission_classes=[IsAdminUser])
    def review(self, request):
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
    """
    queryset = Facility.objects.all()
    serializer_class = FacilitySerializer
    permission_classes = [IsAdminUser]

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
    search_fields = ['employee__nombre_completo', 'area']

    def get_queryset(self):
        qs = ShiftAssignment.objects.all()
        # Filtros por area, fechas y empleado
        area = self.request.query_params.get('area')
        start = self.request.query_params.get('start')
        end = self.request.query_params.get('end')
        emp = self.request.query_params.get('employee')
        if area:
            qs = qs.filter(area=area)
        if start and end:
            qs = qs.filter(start_datetime__date__gte=start,
                        end_datetime__date__lte=end)
        if emp:
            qs = qs.filter(employee=emp)
        return qs

    def perform_create(self, serializer):
        instance = serializer.save()
        send_mail(
            'Nuevo turno asignado',
            f"Se ha asignado un nuevo turno {instance.start_datetime} al {instance.end_datetime} "
            f"en el área de {instance.area} en "
            f"{'Torre ' + instance.tower.name if instance.tower else instance.facility.name}.",
            NO_REPLY_EMAIL,
            [instance.employee.email],
            fail_silently=True
        )

class LeaveRequestViewSet(viewsets.ModelViewSet):
    """
    Vista para gestionar solicitudes de licencia.
    """
    serializer_class = LeaveRequestSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.role == 'admin':
            qs = LeaveRequest.objects.all()
        else:
            qs = LeaveRequest.objects.filter(employee=user)
        status_filter = self.request.query_params.get('status')
        if status_filter in ['pendiente', 'aprobada', 'rechazada']:
            qs = qs.filter(status=status_filter)
        return qs

    @action(detail=True, methods=['post'], permission_classes=[IsAdminUser])
    def review(self, request):
        """
        Revisa una solicitud de licencia.
        """
        leave = self.get_object()
        decision = request.data.get('decision')
        reviewer = request.user
        if decision == 'aprobada':
            leave.approve(reviewer)
        elif decision == 'rechazada':
            leave.reject(reviewer)
        else:
            return Response({'detail': 'Decisión inválida.'}, status=status.HTTP_400_BAD_REQUEST)
        return Response({'status': leave.status})

class UserViewSet(viewsets.ModelViewSet):
    """
    ViewSet para gestionar usuarios. Solo accesible por administradores.
    """
    queryset = CustomUser.objects.all().order_by('id')
    serializer_class = UserSerializer

    def get_permissions(self):
        if self.action == 'create':
            return [AllowAny()]
        if self.action in ('approve', 'reject'):
            return [IsAdminUser()]
        if self.action == 'me':
            return [IsAuthenticated()]
        # list, retrieve, update, destroy → admin
        return [IsAdminUser()]

    @action(detail=False, methods=['get'], url_path='me')
    def me(self, request):
        """Devuelve datos del propio usuario."""
        serializer = self.get_serializer(request.user)
        return Response(serializer.data)

    @action(detail=True, methods=['post'], url_path='approve')
    def approve(self):
        """Admin aprueba registro pendiente."""
        user = self.get_object()
        user.approve()
        send_approval_email(user)
        return Response({'status': 'approved'}, status=status.HTTP_200_OK)

    @action(detail=True, methods=['post'], url_path='reject')
    def reject(self):
        """Admin rechaza registro pendiente."""
        user = self.get_object()
        user.reject()
        send_rejection_email(user)
        return Response({'status': 'rejected'}, status=status.HTTP_200_OK)
