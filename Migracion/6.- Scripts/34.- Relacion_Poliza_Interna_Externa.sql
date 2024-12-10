--
-- Objetivo:    Script de Migración de datos de la Tabla Relacion_Poliza_Interna_Externa
-- Programador: Pedro Zambrano
-- Fecha:       01/10/2024
--

Declare
   @w_Error               Integer,
   @w_linea               Integer,
   @w_registros           Integer,
   @w_comilla             Char(1),
   @w_fechaProc           Datetime,
   @w_Desc_Error          Varchar(  250),
   @w_idusuario           Varchar(  Max),
   @w_usuario             Nvarchar(  20),
   @w_sql                 NVarchar(1500),
   @w_param               NVarchar( 750);

Begin
   Set Nocount       On
   Set Xact_Abort    On

   Select @w_comilla   = Char(39),
          @w_fechaProc = Getdate();

   Select @w_idusuario = parametroChar
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 6;

   Select @w_sql   = Concat('Select @o_usuario = dbo.Fn_Desencripta_cadena (', @w_idusuario, ')'),
          @w_param = '@o_usuario    Nvarchar(20) Output';

   Begin Try
      Execute Sp_executeSql @w_sql, @w_param, @o_usuario = @w_usuario Output
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_linea      = Error_line(),
              @w_desc_error = Substring (Error_Message(), 1, 200)

   End   Catch

   If @w_error != 0
      Begin
         Select @w_error, @w_desc_error;

         Goto Salida
      End

   Begin Transaction
      If Exists ( Select Top 1 1
                  From   dbo.Relacion_Poliza_Interna_Externa With (Nolock))
         Begin
            Begin Try
               Truncate Table dbo.Relacion_Poliza_Interna_Externa
            End   Try

            Begin Catch
               Select  @w_Error      = @@Error,
                       @w_linea      = Error_line(),
                       @w_desc_error = Substring (Error_Message(), 1, 200)

            End   Catch

            If Isnull(@w_error, 0) != 0
               Begin
                  Rollback Transaction

                  Select @w_error, @w_desc_error;

                  Set Xact_Abort    Off
                  Return
               End

         End

      Begin Try
         Insert Into dbo.Relacion_Poliza_Interna_Externa
        (Referencia, Fecha_Mov, Fuentedatos, Referencia_contable,
         Fecha_Cap,  Usuario)
         Select Referencia, Fecha_Mov, Fuentedatos, Referencia_contable,
                Isnull(Fecha_Cap, @w_fechaProc), Isnull(Usuario, @w_usuario)
         From   DB_GEN_DES.dbo.dbo_Relacion_Poliza_Interna_Externa
         Set @w_registros = @@Rowcount

      End   Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End   Catch

      If Isnull(@w_error, 0) != 0
         Begin
            Rollback Transaction

            Select @w_error, @w_desc_error;

            Set Xact_Abort    Off
            Return
         End

   Commit Transaction

   Select @w_registros "Nuevos Registros"

Salida:

   Set Xact_Abort    Off
   Return
End
Go
