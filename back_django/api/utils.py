""" Modulos utiles de la API """
from django.core.mail import send_mail
from django.conf import settings

def send_approval_email(user):
    """
    Informa al usuario que su cuenta ha sido aprobada.
    """
    subject = 'Domus: tu registro ha sido aprobado'
    message = (
        f"Hola {user.nombre_completo},\n\n"
        "¡Felicidades! Tu solicitud de registro en Domus ha sido aprobada.\n"
        "Ya puedes iniciar sesión con tu correo y la contraseña que elegiste al registrarte.\n\n"
        "— El equipo de Domus"
    )
    send_mail(
        subject,
        message,
        settings.DEFAULT_FROM_EMAIL,
        [user.email],
        fail_silently=False,
    )

def send_rejection_email(user):
    """
    Informa al usuario que su cuenta ha sido rechazada.
    """
    subject = 'Domus: tu registro ha sido rechazado'
    message = (
        f"Hola {user.nombre_completo},\n\n"
        "Sentimos informarte que tu solicitud de registro en Domus ha sido rechazada.\n"
        "Si crees que ha sido un error, por favor contacta al administrador.\n\n"
        "— El equipo de Domus"
    )
    send_mail(
        subject,
        message,
        settings.DEFAULT_FROM_EMAIL,
        [user.email],
        fail_silently=False,
    )
