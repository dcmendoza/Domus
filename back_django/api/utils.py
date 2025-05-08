""" Modulos utiles de la API """
from django.core.mail import send_mail
from django.conf import settings

def send_credentials_email(user):
    """
    Envía un correo al nuevo usuario con sus credenciales temporales.
    """
    subject = 'Bienvenido a Domus - Tus credenciales'
    message = (
        f"Hola {user.nombre_completo},\n\n"
        f"Se ha creado tu cuenta en Domus con las siguientes credenciales:\n"
        f"Email: {user.email}\n"
        f"Contraseña temporal: {user.raw_password}\n\n"
        "Por favor, cambia tu contraseña en tu primer inicio de sesión."
    )
    send_mail(
        subject,
        message,
        settings.DEFAULT_FROM_EMAIL,
        [user.email],
        fail_silently=False,
    )
