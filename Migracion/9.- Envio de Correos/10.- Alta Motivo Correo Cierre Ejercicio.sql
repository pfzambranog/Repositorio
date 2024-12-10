--
-- Observación: Script de alta de Motivo de correo.
-- Programador: Pedro Zambrano
-- Fecha:       19-sep-2024.
--

Declare
   @w_idusuario             Varchar(  Max),
   @w_desc_error            Varchar(  250),
   @w_Error                 Integer,
   @w_linea                 Integer,
   @w_idMotivo              Integer,
   @w_usuario               Varchar(   10),
   @w_ipAct                 Varchar(   30),
   @w_codigoMotivoCorreo    Varchar(   30),
   @w_descripcion           Varchar(  100),
   @w_titulo                Varchar( 1000),
   @w_html                  NVarchar( Max),
   @w_consulta              NVarchar(1500),
   @w_param                 NVarchar( 750);

Begin
   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off

--
-- Obtención del usuario de la aplicación para procesos batch.
--

   Select @w_html    = '<!DOCTYPE html>
    <html lang="es">
        <tbody>
                <p>&saludos&, &Nombre&
                <p  style="margin:0 0 12px 0;font-size:16px;line-height:24px;font-family:Arial,sans-serif;color:#153643">
                    Por medio del presente te informamos que el proceso de cierre &observacion& y el detalle del proceso es el siguiente:

                <p> Ejecicio:             &Ejercicio&
                <p> Cierre Procesado por: &usuario&
                <p> Fecha de cierre:      &fechaproc&
                ',
          @w_codigoMotivoCorreo = 'CierrePeriodo',
          @w_titulo             = 'Cierre periodo &periodo&',
          @w_descripcion        = 'Incidencias Cierre Periodo',
          @w_ipAct              = dbo.Fn_buscaDireccionIp();

   Select @w_idusuario = parametroChar
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 6;

   Select @w_consulta   = Concat('Select @o_usuario = dbo.Fn_Desencripta_cadena (', @w_idusuario, ')'),
          @w_param      = '@o_usuario    Nvarchar(20) Output';

   Begin Try
      Execute Sp_executeSql @w_consulta, @w_param, @o_usuario = @w_usuario Output
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_linea      = Error_line(),
              @w_desc_error = Substring (Error_Message(), 1, 200)

   End   Catch

   If Isnull(@w_error, 0) != 0
      Begin
         Select @w_error, @w_desc_error;

         Set Xact_Abort    Off
         Return
      End

   Select @w_idMotivo = idMotivoCorreo
   From   dbo.conMotivosCorreoTbl
   Where  codigoMotivoCorreo = @w_codigoMotivoCorreo;
   If @@rowcount != 0
      Begin
         Select @w_idMotivo idMotivoCorreo

         Set Xact_Abort    Off
         Return
      End

   Begin Try
      Insert Into dbo.conMotivosCorreoTbl
     (codigoMotivoCorreo, descripcion, titulo, html,
      idUsuarioAct,       ipAct)
      Select @w_codigoMotivoCorreo, @w_descripcion, @w_titulo, @w_html,
             @w_usuario,            @w_ipAct
      Select @w_idMotivo = @@Identity;
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_linea      = Error_line(),
              @w_desc_error = Substring (Error_Message(), 1, 200)

   End   Catch

   If Isnull(@w_error, 0) != 0
      Begin
         Select @w_error, @w_desc_error;

         Set Xact_Abort    Off
         Return
      End

   Select @w_idMotivo idMotivoCorreo
   Set Xact_Abort    Off
   Return

End
Go