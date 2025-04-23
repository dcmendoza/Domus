"""" Modulos para las vistas de la API """
from rest_framework import viewsets, filters, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAdminUser, IsAuthenticated
from rest_framework.response import Response
from django.contrib.auth import get_user_model
from django.core.mail import send_mail
from .models import Tower, Apartment, Facility, ParkingSpot, ShiftAssignment, LeaveRequest
from .serializers import (
    TowerSerializer, ApartmentSerializer, FacilitySerializer,
    ParkingSpotSerializer, ShiftAssignmentSerializer, LeaveRequestSerializer, UserSerializer
    )
from .utils import send_credentials_email

# Create your views here.
User = get_user_model()

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
        user = self.request.user
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
            f"Se te ha asignado un nuevo turno del {instance.start_datetime} al {instance.end_datetime} "
            f"en el área de {instance.area} en {'Torre ' + instance.tower.name if instance.tower else instance.facility.name}.",
            'no-reply@domus.com',
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
        status = self.request.query_params.get('status')
        if status in ['pendiente', 'aprobada', 'rechazada']:
            qs = qs.filter(status=status)
        return qs

    @action(detail=True, methods=['post'], permission_classes=[IsAdminUser])
    def review(self, request, pk=None):
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
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsAdminUser]

    # Opcional: override de create para enviar correo con credenciales
    def perform_create(self, serializer):
        user = serializer.save()
        send_credentials_email(user)

    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated])
    def me(self, request):
        """Retorna datos del usuario autenticado."""
        serializer = self.get_serializer(request.user)
        return Response(serializer.data)
