Declare
   @w_tabla                   Sysname,
   @w_anioIni                 Integer,
   @w_anio                    Integer,
   @w_error                   Integer,
   @w_registros               Integer,
   @w_linea                   Integer,
   @w_mes                     Tinyint,
   @w_comilla                 Char(1),
   @w_chmes                   Char(3),
   @w_usuario                 Nvarchar(  20),
   @w_sql                     NVarchar(1500),
   @w_param                   NVarchar( 750),
   @w_desc_error              Varchar(  250),
   @w_idusuario               Varchar(  Max),
   @w_fechaAct                Datetime;

Begin
   Set Nocount       On
   Set Xact_Abort    On

   Select @w_mes       = 0,
          @w_anioIni   = 2016,
          @w_comilla   = Char(39),
          @w_registros = 0,
          @w_fechaAct  = Getdate();

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
                  From   dbo.PolDiaError)
         Begin
            truncate table dbo.MovDiaError
            Delete dbo.PolDiaError
         End

      Begin Try
         Insert Into dbo.PolDiaError
        (Referencia,  Fecha_Mov,      Fecha_Cap,       Concepto,
         Cargos,      Abonos,         TCons,           Usuario,
         TipoPoliza,  Documento,      Usuario_cancela, Fecha_Cancela,
         Status,      Mes_Mov,        TipoPolizaConta, FuenteDatos,
         Ejercicio,   mes,            Causa_Rechazo,
         Fecha_importacion)
         Select Referencia, Fecha_Mov,     Fecha_Cap,       Concepto,
                Cargos,     Abonos,        TCons,           Usuario,
                TipoPoliza, Documento,     Usuario_cancela, Fecha_Cancela,
                Status,     Mes_Mov,       TipoPolizaConta, FuenteDatos,
                Datepart(yyyy, Fecha_Mov)  Ejercicio, Datepart(mm, Fecha_Mov)  mes,
                Causa_Rechazo, Fecha_importacion
         From   DB_GEN_DES.dbo.MovDiaError
         Where  Referencia Is Not Null
         And    Datepart(yyyy, Fecha_Mov) = @w_anio
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

   Commit Transaction

   Select @w_registros;

Salida:

   Set Xact_Abort    Off
   Return

End
Go
