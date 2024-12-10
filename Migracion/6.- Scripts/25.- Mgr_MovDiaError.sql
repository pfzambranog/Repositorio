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
          @w_anio      = 2024,
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
                  From   dbo.MovDiaError)
         Begin
            truncate table dbo.MovDiaError
         End

      Begin Try
         Insert Into dbo.MovDiaError
        (Referencia,      Cons,             Moneda,        Fecha_mov,
         Llave,           Concepto,         Importe,       Documento,
         Clave,           FecCap,           Sector_id,     Sucursal_id,
         Region_id,       Importe_Cargo,    Importe_Abono, Descripcion,
         TipoPolizaConta, ReferenciaFiscal, Fecha_Doc,     Ejercicio,
         Mes,             Causa_Rechazo,    Fecha_importacion)
         Select Distinct a.Referencia,      a.Cons,             '00' Moneda_id,            a.Fecha_mov,
                a.Llave,           a.Concepto,         Isnull(a.Importe, 0),   a.Documento,
                a.Clave,           a.FecCap,           a.Sector_id,            a.Sucursal_id,
                a.Region_id,       Isnull(a.Importe_Cargo, 0),    Isnull(a.Importe_Abono, 0), a.Descripcion,
                a.TipoPolizaConta, a.ReferenciaFiscal, a.Fecha_Doc,            Datepart(yyyy, fecha_mov) Ejercicio,
                Datepart(mm, fecha_mov) Mes,           a.Causa_Rechazo,        a.Fecha_importacion
         From   DB_GEN_DES.dbo.PolDiaError a
         Where   Datepart(yyyy, fecha_mov) = @w_anio
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



