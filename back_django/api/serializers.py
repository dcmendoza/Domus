"""Modulos de serializadores para la API REST"""
from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import (Tower, Apartment, Facility, ParkingSpot,
                    ShiftAssignment, LeaveRequest, Reservation)

CustomUser = get_user_model()

class ReservationSerializer(serializers.ModelSerializer):
    """
    Serializador para la clase Reservation.
    Permite la creación y actualización de reservas en el sistema.
    """
    facility_name = serializers.CharField(source='facility.name', read_only=True)
    user_name = serializers.CharField(source='user.nombre_completo', read_only=True)

    class Meta:
        """
        Clase Meta para el serializador ReservationSerializer
        Define los campos a serializar y las restricciones de acceso.
        """
        model = Reservation
        fields = [
            'id', 'facility', 'facility_name',
            'user', 'user_name',
            'start_datetime', 'end_datetime',
            'status', 'created_at'
        ]
        read_only_fields = ['status', 'created_at']

    def validate(self, attrs):
        instance = Reservation(**attrs)
        instance.clean()
        return attrs

class TowerSerializer(serializers.ModelSerializer):
    """
    Serializador para la clase Tower.
    Permite la creación y actualización de torres en el sistema.
    """
    class Meta:
        """
        Clase Meta para el serializador TowerSerializer.
        Define los campos a serializar y las restricciones de acceso.
        """
        model = Tower
        fields = ['id', 'name', 'num_floors']

class ApartmentSerializer(serializers.ModelSerializer):
    """
    Serializador para la clase Apartment.
    Permite la creación y actualización de apartamentos en el sistema.
    """
    class Meta:
        """
        Clase Meta para el serializador ApartmentSerializer.
        Define los campos a serializar y las restricciones de acceso.
        """
        model = Apartment
        fields = [
            'id', 'tower', 'floor', 'number', 'rooms',
            'bathrooms', 'rent_price', 'parking_slots', 'owner'
        ]

class FacilitySerializer(serializers.ModelSerializer):
    """
    Serializador para la clase Facility.
    Permite la creación y actualización de instalaciones en el sistema.
    """
    class Meta:
        """
        Clase Meta para el serializador FacilitySerializer.
        Define los campos a serializar y las restricciones de acceso.
        """
        model = Facility
        fields = ['id', 'name', 'is_reserved']

class ParkingSpotSerializer(serializers.ModelSerializer):
    """
    Serializador para la clase ParkingSpot.
    Permite la creación y actualización de espacios de estacionamiento en el sistema.
    """
    class Meta:
        """
        Clase Meta para el serializador ParkingSpotSerializer.
        Define los campos a serializar y las restricciones de acceso.
        """
        model = ParkingSpot
        fields = ['id', 'apartment', 'identifier']

class ShiftAssignmentSerializer(serializers.ModelSerializer):
    """
    Serializador para la clase ShiftAssignment.
    Permite la creación y actualización de turnos en el sistema.
    """
    class Meta:
        """
        Clase Meta para el serializador ShiftAssignmentSerializer.
        Define los campos a serializar y las restricciones de acceso.
        """
        model = ShiftAssignment
        fields = [
            'id', 'employee', 'area', 'start_datetime',
            'end_datetime', 'tower', 'facility'
        ]

    def validate(self, attrs):
        # delegar a clean()
        instance = ShiftAssignment(**attrs)
        instance.clean()
        return attrs

class LeaveRequestSerializer(serializers.ModelSerializer):
    """
    Serializador para la clase LeaveRequest.
    Permite la creación y actualización de solicitudes de licencia en el sistema.
    """
    class Meta:
        """
        Clase Meta para el serializador LeaveRequestSerializer.
        Define los campos a serializar y las restricciones de acceso.
        """
        model = LeaveRequest
        fields = [
            'id', 'employee', 'type', 'start_date',
            'end_date', 'reason', 'document', 'status',
            'reviewed_by', 'created_at', 'reviewed_at'
        ]
        read_only_fields = [
            'status', 'reviewed_by', 'created_at', 'reviewed_at'
        ]

class UserSerializer(serializers.ModelSerializer):
    """
    Serializer para la creación y listado de usuarios.
    """
    password = serializers.CharField(write_only=True, required=True)
    registration_status = serializers.CharField(read_only=True)

    class Meta:
        """
        Clase Meta para el serializador UserSerializer.
        Define los campos a serializar y las restricciones de acceso.
        """
        model = CustomUser
        fields = [
            'id', 'email', 'nombre_completo', 'telefono',
            'role', 'subrole', 'password', 'registration_status'
        ]
        read_only_fields = ['id', 'registration_status']

    def validate(self, attrs):
        # 1) subrole solo si role == EMPLEADO
        role = attrs.get('role')
        sub = attrs.get('subrole')
        if role != CustomUser.EMPLEADO and sub:
            raise serializers.ValidationError(
                {'subrole': 'Solo los empleados pueden tener un subrol.'}
            )

        # 2) Self-signup: solo propietario o empleado-portería, nunca admin
        request = self.context.get('request')
        if request and not request.user.is_staff:
            if role == CustomUser.ADMIN:
                raise serializers.ValidationError(
                    {'role': 'No puedes registrarte como administrador.'}
                )
            if role == CustomUser.EMPLEADO and sub != CustomUser.PORTERIA:
                raise serializers.ValidationError(
                    {'subrole': 'Solo portería puede auto-registrarse como empleado.'}
                )
        return attrs

    def create(self, validated_data):
        # 1) Extraer y cifrar contraseña
        password = validated_data.pop('password')
        # 2) Crear usuario inactivo y pendiente
        user = CustomUser(**validated_data)
        user.set_password(password)
        user.is_active = False
        user.registration_status = CustomUser.PENDING
        user.save()
        return user
