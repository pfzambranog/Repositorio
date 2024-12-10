Declare
   @w_tabla                   Sysname,
   @w_anioIni                 Smallint,
   @w_anioProc                Smallint,
   @w_anio                    Integer,
   @w_error                   Integer,
   @w_registros               Integer,
   @w_linea                   Integer,
   @w_mes                     Tinyint,
   @w_mesProc                 Tinyint,
   @w_comilla                 Char(1),
   @w_chmes                   Char(3),
   @w_usuario                 Nvarchar(20),
   @w_sql                     NVarchar(1500),
   @w_param                   NVarchar( 750),
   @w_desc_error              Varchar( 250),
   @w_idusuario               Varchar( Max);

Begin
   Set Nocount       On
   Set Xact_Abort    On

   Select @w_mes       = 0,
          @w_anioIni   = 0,
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
         Return
      End

   Select @w_anioIni  = Datepart(yyyy, parametroFecha) -1,
          @w_anioProc = Datepart(yyyy, parametroFecha),
          @w_mesProc  = Datepart(mm,   parametroFecha)
   From   dbo.conParametrosGralesTbl With (Nolock)
   Where  idParametroGral = 11;

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
                  From   dbo.ControlPoliza)
         Begin
            Delete dbo.ControlPoliza
         End

      While @w_anioIni < @w_anio
      Begin
         Select @w_anioIni = @w_anioIni + 1,
                @w_tabla   = Concat('ContPol', @w_anioIni);

         If Ejercicio_DES.dbo.Fn_existe_tabla( @w_tabla ) = 0
            Begin
               Goto Siguiente
            End


         Set @w_sql = Concat('Select a.tipo, ', @w_anioIni, ', b.valor, Contador ',
                             'From   Ejercicio_DES.dbo.' + @w_tabla, ' a ',
                             'Join   dbo.catCriteriosTbl b ',
                             'On     b.ValorAdicional = a.mes ',
                             'Where  b.criterio       = ', @w_comilla, 'mes', @w_comilla);

         Begin Try
            Insert Into dbo.ControlPoliza
            (TipoComprobante, Ejercicio, Mes, Contador)
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
               Select @w_error Error, @w_desc_error mensajeError;
               RollBack Transaction

               Goto Salida
            End

Siguiente:

      End

      Begin Try
         Delete dbo.ControlPoliza
         Where  Ejercicio = @w_anioProc
         And    Mes       < @w_mesProc;
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

   Select @w_registros;

Salida:

   Set Xact_Abort    Off
   Return

End
Go
