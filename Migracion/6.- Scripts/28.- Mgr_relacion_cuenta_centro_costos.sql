Declare
   @w_idError                 Integer,
   @w_error                   Integer,
   @w_registros               Integer,
   @w_linea                   Integer,
   @w_desc_error              Varchar(  Max);

Begin
   Set Nocount       On
   Set Xact_Abort    On

   Select @w_registros = 0;

   Begin Transaction
      If Exists ( Select Top 1 1
                  From   dbo.relacion_cuenta_centro_costos)
         Begin
            Begin Try
               Truncate Table dbo.relacion_cuenta_centro_costos
            End Try

            Begin Catch
               Select  @w_Error      = @@Error,
                       @w_linea      = Error_line(),
                       @w_desc_error = Substring (Error_Message(), 1, 200)

            End   Catch

            If @w_error != 0
               Begin
                  Select @w_error, @w_desc_error;
                  RollBack Transaction

                  Goto Salida
               End

         End

      Begin Try
         Insert Into dbo.relacion_cuenta_centro_costos
        (cuenta, moneda_id, centro_costos)
         Select cuenta, '00' moneda_id, centro_costos
         From   DB_GEN_DES.dbo.relacion_cuenta_centro_costos;
         Set @w_registros = @w_registros + @@Rowcount

      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End   Catch

      If @w_error != 0
         Begin
            Select @w_error Error, @w_desc_error mensajeError;
            RollBack Transaction

            Goto Salida
         End

   Commit Transaction

   Select @w_registros registros;


Salida:

   Set Xact_Abort  Off
   Return

End
Go
