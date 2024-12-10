Declare
   @w_tabla                   Sysname,
   @w_anioIni                 Integer,
   @w_anioFin                 Integer,
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
          @w_anioIni   = 2017,
          @w_anioFin   = 2024,
          @w_comilla   = Char(39),
          @w_registros = 0;

   Select @w_anioFin = ejercicio
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
                  From   dbo.PolizaAnio)
         Begin
            Begin Try
               Delete dbo.MovimientosAnio
               Delete dbo.PolizaAnio
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

      While @w_anioIni  < @w_anioFin
      Begin
         Select @w_mes     = 0,
                @w_anioIni = @w_anioIni + 1,
                @w_tabla = Concat('movDia', @w_anioIni);

         If Ejercicio_DES.dbo.Fn_existe_tabla( @w_tabla ) = 0
            Begin
               Goto Siguiente
            End

         Set @w_sql = Concat('Select Distinct Referencia, Fecha_mov, Fecha_Cap,       Concepto, ',
                                    'Cargos,     Abonos,    TCons,           Usuario, ',
                                    'TipoPoliza, Documento, Usuario_cancela, Fecha_Cancela, ',
                                    'Status,     Mes_Mov,   TipoPolizaConta, FuenteDatos, ',
                                     @w_anioIni, ', DatePart(mm, fecha_Mov) ',
                             'From   Ejercicio_DES.dbo.' + @w_tabla);

         Begin Try
            Insert Into dbo.PolizaAnio
            (Referencia, Fecha_mov, Fecha_Cap,       Concepto,
             Cargos,     Abonos,    TCons,           Usuario,
             TipoPoliza, Documento, Usuario_cancela, Fecha_Cancela,
             Status,     Mes_Mov,   TipoPolizaConta, FuenteDatos,
             ejercicio,  mes)
            Execute(@w_sql)
         
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

Siguiente:


      End

    Commit Transaction

    Select @w_registros RegistrosAdic;

Salida:


    Set Xact_Abort    On
    Return

End
Go
