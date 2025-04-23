"""" Modulos para las vistas de la API """
from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAdminUser, IsAuthenticated
from rest_framework.response import Response
from django.contrib.auth import get_user_model
from .serializers import UserSerializer
from .utils import send_credentials_email

# Create your views here.
User = get_user_model()

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
