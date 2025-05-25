class Routes {
  /// Pantalla de bienvenida.
  static const welcome = '/';

  /// Pantalla de login unificado para todos los roles.
  static const login = '/login';

  /// Pantalla de registro de usuario.
  static const signup = '/signup';

  /// Pantalla principal después de autenticación.
  static const home = '/home';

  /// Pantalla de finanzas.
  static const finance  = '/finance';

  /// Pantalla de trabajadores.
  static const workers  = '/workers';

  /// Pantalla de reservas.
  static const reserves = '/reserves';

  /// Pantalla para crear nueva reserva.
  static const newReservation = '/reserves/new';

  /// Pantalla de detalle de reserva.
  static const reservationDetails = '/reserves/details';

  /// Pantalla de chat.
  static const chat     = '/chat';

  /// Pantalla de perfil.
  static const profile  = '/profile';

  /// Pantalla de notificaciones.
  static const notifications = '/notifications';

  static const shifts = '/shifts';

  static const shiftDetails = '/shift/details';

  static const shiftEdit = '/shift/edit';

  static const shiftAssign = '/shift/assign';

  /// Pantalla de listado de solicitudes
  static const leaves         = '/leaves';

  /// Pantalla de nuevo request
  static const leaveRequest   = '/leaves/request';

  /// Pantalla de detalle
  static const leaveDetails   = '/leaves/details';

  /// Pantalla de edición
  static const leaveEdit      = '/leaves/edit';

  /// Pantalla de borrado (confirmación)
  static const leaveDelete    = '/leaves/delete';
}
