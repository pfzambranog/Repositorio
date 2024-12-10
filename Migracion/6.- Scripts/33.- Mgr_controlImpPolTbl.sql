--
-- Objetivo:    Script de Migración de datos de la Tabla controlImpPolTbl
-- Programador: Pedro Zambrano
-- Fecha:       01/10/2024
--

Declare
   @w_Error                   Integer,
   @w_desc_error              Varchar(Max),
--
   @w_linea                   Integer,
   @w_registros               Integer;


Begin
   Set Nocount       On
   Set Xact_Abort    On

   Select @w_Error     = 0,
          @w_registros = 0,
          @w_linea     = 0;

   Set Identity_insert dbo.controlImpPolTbl On;

   Begin Transaction
      If Exists ( Select Top 1 1
                  From   dbo.controlImpPolTbl)
         Begin
            Begin Try
               Delete dbo.controlImpPolTbl
            End Try

            Begin Catch
               Select  @w_Error      = @@Error,
                       @w_linea      = Error_line(),
                       @w_desc_error = Substring (Error_Message(), 1, 200)

            End   Catch

            If @w_error != 0
               Begin
                  Select @w_error error, @w_desc_error "Mensaje Error";
                  RollBack Transaction

                  Goto Salida
               End

         End


      Begin Try
         Insert Into dbo.controlImpPolTbl
        (Id_control, Fecha_Mov, Polizas_Imp, polizas_no_imp)
		 Select Id_control, Fecha_Mov, Polizas_Imp, polizas_no_imp
		 From   DB_GEN_DES.dbo.tmpControl
		 Where  Fecha_Mov Is Not Null;
         Set @w_registros =  @@Rowcount;
      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_desc_error = Error_Message()
      End   Catch

      If @w_error != 0
         Begin
            Rollback Transaction
            Select @w_error error, @w_desc_error "Mensaje Error"

         End

   Commit Transaction

   Set Identity_insert dbo.controlImpPolTbl Off;

   Select @w_registros  "Registros Alta";

Salida:

    Set Xact_Abort        Off
    Return

End
Go
