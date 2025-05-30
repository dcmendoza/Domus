"""
Autentica al usuario por email
"""
from django.contrib.auth.backends import ModelBackend
from django.contrib.auth import get_user_model

User = get_user_model()

class EmailBackend(ModelBackend):
    """
    Permite autenticar con email en lugar de username.
    """
    def authenticate(self, request, username=None, password=None, **kwargs):
        email = kwargs.get('email') or username
        if email is None or password is None:
            return None
        try:
            user = User.objects.get(email__iexact=email)
        except User.DoesNotExist:
            return None
        if user.check_password(password) and self.user_can_authenticate(user):
            return user
        return None
