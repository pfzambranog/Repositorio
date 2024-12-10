Declare
   @w_tabla                   Sysname,
   @w_anio                    Integer,
   @w_error                   Integer,
   @w_registros               Integer,
   @w_linea                   Integer,
   @w_mes                     Tinyint,
   @w_comilla                 Char(1),
   @w_chmes                   Char(3),
   @w_sql                     Varchar(Max),
   @w_desc_error              Varchar( 250);

Begin
   Set Nocount       On
   Set Xact_Abort    On

   Select @w_mes       = 0,
          @w_comilla   = Char(39),
          @w_registros = 0;

   Select @w_anio = ejercicio
   From   dbo.Control With  (Nolock)
   Where  idEstatus = 1
   If @@Rowcount = 0
      Begin
         Select  @w_Error      = 9999,
                 @w_desc_error = 'Error: No hay Ejercicios en Estatus 1 en la tabla control.'

         Set Xact_Abort Off
         Goto Salida
      End

   Begin Transaction
      If Exists ( Select Top 1 1
                  From   dbo.PolDia)
         Begin
            Begin Try
               Delete dbo.MovDia
               Delete dbo.PolDia
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
         Insert Into dbo.PolDia
         (Referencia, Fecha_Mov, Fecha_Cap,       Concepto,
          Cargos,     Abonos,    TCons,           Usuario,
          TipoPoliza, Documento, Usuario_cancela, Fecha_Cancela,
          Status,     Mes_Mov,   TipoPolizaConta, FuenteDatos,
          Ejercicio,  Mes,       CausaRechazo)
         Select Referencia, Fecha_Mov, Fecha_Cap,       Concepto,
                Cargos,     Abonos,    TCons,           Usuario,
                TipoPoliza, Documento, Usuario_cancela, Fecha_Cancela,
                Status,     Mes_Mov,   TipoPolizaConta, FuenteDatos,
                DatePart(yyyy, Fecha_Mov) Ejercicio,  DatePart(mm, Fecha_Mov) Mes,
                Causa_Rechazo
         From   DB_Gen_des.dbo.MovDia

            Set @w_registros = @w_registros + @@Rowcount;
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

   Commit Transaction

Salida:

   Select @w_registros "Nuevos Registros";

   Set Xact_Abort    Off
   Return

End
Go
