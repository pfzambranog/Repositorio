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
                  From   dbo.BalanzaComprobacionTbl)
         Begin
            Begin Try
               Truncate Table dbo.BalanzaComprobacionTbl
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
         Insert Into dbo.BalanzaComprobacionTbl
        (llave,       moneda_id, Descrip, region_id,
         sucursal_id, saldo_ant, cargos,  abonos,
         saldo_actual)
         Select llave,    '00' Moneda_id, Descrip, region,
                sucursal, saldo_ant,   cargos,  abonos,
                saldo_actual
         From   Ejercicio_DES.dbo.BalanzaCmpb;
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