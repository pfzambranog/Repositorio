Declare
   @w_idError                 Integer,
   @w_error                   Integer,
   @w_registros               Integer,
   @w_linea                   Integer,
   @w_anio                    Integer,
   @w_desc_error              Varchar(  Max);

Begin
   Set Nocount       On
   Set Xact_Abort    On

   Select @w_registros = 0,
          @w_linea     = 0;

   Select @w_anio = ejercicio
   From   dbo.Control With  (Nolock)
   Where  idEstatus = 1
   If @@Rowcount = 0
      Begin
         Select  @w_Error      = 9999,
                 @w_desc_error = 'Error: No hay Ejercicios en Estatus 1 en la tabla control.'

         Set Xact_Abort Off
         Return
      End

   Begin Transaction
      If Exists ( Select Top 1 1
                  From   dbo.RelacionImp)
         Begin
            Begin Try
               Truncate Table dbo.RelacionImp
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
         Insert Into dbo.RelacionImp
        (Referencia, Fecha_Mov,   Fecha_Cap,        NewReferencia,
         Usuario,    FuenteDatos, FechaImportacion, Ejercicio,
         mes)
         Select Referencia, Fecha_Mov,   Fecha_Cap,   NewReferencia,
                Usuario,    FuenteDatos, Isnull(FechaImportacion, Fecha_Mov), DatePart(yyyy, Fecha_Mov) ejercicio,
                DatePart(mm, Fecha_Mov) mes
         From   DB_GEN_DES.dbo.RelacionImp;
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
