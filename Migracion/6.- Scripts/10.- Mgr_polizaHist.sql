Declare
   @w_tabla                   Sysname,
   @w_anioIni                 Integer,
   @w_anioFin                 Integer,
   @w_error                   Integer,
   @w_registros               Integer,
   @w_linea                   Integer,
   @w_mes                     Smallint,
   @w_comilla                 Char(1),
   @w_chmes                   Char(3),
   @w_desc_error              Varchar( 250),
   @w_inicio                  Bit,
   @w_mesProc                 Tinyint,
   @w_idusuario               Varchar(  Max),
   @w_usuario                 Nvarchar(  20),
   @w_sql                     NVarchar(1500),
   @w_param                   NVarchar( 750),
   @w_ultactual               Datetime;

Begin
   Set Nocount       On
   Set Xact_Abort    On

   Select @w_mes       = -1,
          @w_anioIni   = 0,
          @w_anioFin   = 0,
          @w_comilla   = Char(39),
          @w_registros = 0,
          @w_inicio    = 1;

   Select @w_anioIni  = Datepart(yyyy, parametroFecha) -1,
          @w_mesProc  = Datepart(mm,   parametroFecha)
   From   dbo.conParametrosGralesTbl With (Nolock)
   Where  idParametroGral = 11;
   
   Select @w_anioFin = ejercicio -1
   From   dbo.Control With  (Nolock)
   Where  idEstatus = 1
   If @@Rowcount = 0
      Begin
         Select  @w_Error      = 9999,
                 @w_desc_error = 'Error: No hay Ejercicios en Estatus 1 en la tabla control.'

         Set Xact_Abort Off
         Goto Salida
      End

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
                  From   dbo.PolizaHist)
         Begin
            Begin Try
               Delete dbo.MovimientosHist
               Delete dbo.PolizaHist
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
         Select @w_mes     = -1,
                @w_anioIni = @w_anioIni + 1;

         If @w_inicio = 1
            Begin
               Select @w_mes    = @w_mesProc -1,
                      @w_inicio = 0;
            End

         While @w_mes < 13
         Begin
            Select @w_mes   = @w_mes + 1,
                   @w_chmes = dbo.Fn_BuscaMes (@w_mes),
                   @w_tabla = Concat('mov', @w_chmes, @w_anioIni);

            If Ejercicio_DES.dbo.Fn_existe_tabla( @w_tabla ) = 0
               Begin
                  Goto Siguiente
               End

            Set @w_sql = Concat('Select Referencia, Fecha_mov, Fecha_Cap,       Concepto, ',
                                       'Cargos,     Abonos,    TCons,           Usuario, ',
                                       'TipoPoliza, Documento, Usuario_cancela, Fecha_Cancela, ',
                                       'Status,     Mes_Mov,   TipoPolizaConta, FuenteDatos, ',
                                        @w_anioIni, ', ', @w_mes, ' ',
                                'From   Ejercicio_DES.dbo.' + @w_tabla);

            Begin Try
               Insert Into dbo.PolizaHist
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

    End

    Commit Transaction
    Select @w_registros RegistrosAdic;;

Salida:
    Set Xact_Abort    On
    Return

End
Go
