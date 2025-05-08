"""Modulos de serializadores para la API REST"""
from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import Tower, Apartment, Facility, ParkingSpot, ShiftAssignment, LeaveRequest, Reservation

User = get_user_model()

class ReservationSerializer(serializers.ModelSerializer):
    facility_name = serializers.CharField(source='facility.name', read_only=True)
    user_name = serializers.CharField(source='user.nombre_completo', read_only=True)

    class Meta:
        model = Reservation
        fields = [
            'id', 'facility', 'facility_name',
            'user', 'user_name',
            'start_datetime', 'end_datetime',
            'status', 'created_at'
        ]
        read_only_fields = ['status', 'created_at']

    def validate(self, data):
        instance = Reservation(**data)
        instance.clean()
        return data

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
    Solo administradores pueden crear usuarios asignando contraseña.
    """
    password = serializers.CharField(write_only=True, required=True)

    class Meta:
        """
        Clase Meta para el serializador UserSerializer.
        Define los campos a serializar y las restricciones de acceso.
        """
        model = User
        fields = ['id', 'email', 'nombre_completo', 'telefono', 'role', 'subrole', 'password']
        read_only_fields = ['id']

    def validate(self, attrs):
        # subrole solo si role == EMPLEADO
        role = attrs.get('role')
        sub = attrs.get('subrole')
        if role != User.EMPLEADO and sub:
            raise serializers.ValidationError(
                {'subrole': 'Solo los empleados pueden tener un subrol.'}
            )
        return attrs

    def create(self, validated_data):
        password = validated_data.pop('password')

        if 'username' not in validated_data or not validated_data['username']:
            email = validated_data.get('email')
            validated_data['username'] = email.split('@')[0]

        user = User(**validated_data)
        user.set_password(password)
        # Guardamos temporalmente la contraseña para el envío de correo
        user.raw_password = password  # Use a public attribute instead of a protected one
        user.save()
        return user
