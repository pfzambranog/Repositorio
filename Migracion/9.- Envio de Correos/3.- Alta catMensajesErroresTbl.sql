--
-- Observación: Script de alta de mensajes de error en envío de correo.
-- Fecha:       19-sep-2024.
-- Programador: Pedro Zambrano
--

Begin
   Delete dbo.catMensajesErroresTbl
   Where  idFormulario   = 9999
   And    idError  Between 120 And 141;

   Insert Into dbo.catMensajesErroresTbl (idFormulario, idError, mensaje, idUsuarioAct, ipAct)
   Select 9999, 120, 'El Encabezado del Correo No es Valido', 1, dbo.Fn_buscaDireccionIP()
   Union
   Select 9999, 121, 'El cuerpo del Correo no es Valido', 1, dbo.Fn_buscaDireccionIP()
   Union
   Select 9999, 122, 'El Codigo Grupo Receptor Correo ya se Encuentra Registrado.', 1, dbo.Fn_buscaDireccionIP()
   Union
   Select 9999, 123, 'EL Grupo Receptor de Correo ya Existe.', 1, dbo.Fn_buscaDireccionIP()
   Union
   Select 9999, 124, 'El Grupo Receptor de Correo No existe.', 1, dbo.Fn_buscaDireccionIP()
   Union
   Select 9999, 125, 'El Grupo Receptor de Correo Se encuentra Inhabilitado.', 1, dbo.Fn_buscaDireccionIP()
   Union
   Select 9999, 126, 'No Existe el Registro de Grupo Receptor Correo Detalle.', 1, dbo.Fn_buscaDireccionIP()
   Union
   Select 9999, 127, 'El Perfil de Correo no es Válido.', 1, dbo.Fn_buscaDireccionIP()
   Union
   Select 9999, 128, 'El Motivo de Emisión de Correo Seleccionado No es Válido.', 1, dbo.Fn_buscaDireccionIP()
   Union
   Select 9999, 129, 'El Correo Emisor Seleccionado No Existe.', 1, dbo.Fn_buscaDireccionIP()
   Union
   Select 9999, 130, 'No se Envia Correo ya que el Es Estatus Seleccionado no es Valido.', 1, dbo.Fn_buscaDireccionIP()
   Union
   Select 9999, 131, 'El Usuario de Correo Receptor Seleccionado No Existe.', 1, dbo.Fn_buscaDireccionIP()
   Union
   Select 9999, 132, 'El Correo No esta Activo', 1, dbo.Fn_buscaDireccionIP()
   Union
   Select 9999, 133, 'No se Envia Correo por que No existen Correos de Receptores.', 1, dbo.Fn_buscaDireccionIP()
   Union
   Select 9999, 134, 'El correo del usuario Receptor seleccionado no Válido', 1, dbo.Fn_buscaDireccionIP()
   Union
   Select 9999, 135, 'La Cadena de Parámetros de entrada no es tipo Json', 1, dbo.Fn_buscaDireccionIP()
   Union
   Select 9999, 136, 'La Cadena de Parámetros de entrada no tiene registros.', 1, dbo.Fn_buscaDireccionIP()
   Union
   Select 9999, 137, 'La Cadena de Parámetros de entrada contiene mas de 1 registro.', 1, dbo.Fn_buscaDireccionIP()
   Union
   Select 9999, 138, 'No Existen Información de cierre para el ejercicio Seleccionado.', 1, dbo.Fn_buscaDireccionIP()
   Union
   Select 9999, 139, 'No esta Cargado el Dia y Mes de Inicio y Fin Para Proceso de fin ejercicio.', 1, dbo.Fn_buscaDireccionIP()
   Union
   Select 9999, 140, 'No Existe ejercicio para actualizar.', 1, dbo.Fn_buscaDireccionIP()
   Union
   Select 9999, 141, 'No Existe el Período para actualizar.', 1, dbo.Fn_buscaDireccionIP();


End
Go
