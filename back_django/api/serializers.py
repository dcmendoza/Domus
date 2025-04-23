"""Modulos de serializadores para la API REST"""
from rest_framework import serializers
from django.contrib.auth import get_user_model

User = get_user_model()

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
        user = User(**validated_data)
        user.set_password(password)
        # Guardamos temporalmente la contraseña para el envío de correo
        user.raw_password = password  # Use a public attribute instead of a protected one
        user.save()
        return user
