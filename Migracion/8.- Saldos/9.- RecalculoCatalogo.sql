--
-- Objetivo:    Script de recalculo de los saldos contables
--
-- Fecha:       24-dic-2024.
-- Programdor:  Pedro Zambrano
-- Version:     1
--

Declare
   @w_tabla                   Sysname,
   @w_ejercicio               Smallint,
   @w_error                   Integer,
   @PnEstatus                 Integer,
   @w_registros               Integer,
   @w_secuencia               Integer,
   @w_linea                   Integer,
   @w_mes                     Tinyint,
   @w_mesMax                  Tinyint,
   @w_comilla                 Char(1),
   @w_idusuario               Varchar(  Max),
   @w_desc_error              Varchar(  750),
   @PsMensaje                 Varchar(  750),
   @w_usuario                 Nvarchar(  20),
   @w_sql                     NVarchar(1500),
   @w_param                   NVarchar( 750),
   @w_ultactual               Datetime,
   @w_x                       Bit,
   @w_inicio                  Bit;

Begin
   Set Nocount       On
   Set Xact_Abort    On

   Select @w_mes       = 0,
          @w_comilla   = Char(39),
          @w_registros = 0,
          @w_secuencia = 0,
          @w_inicio    = 1,
          @w_ultactual = Getdate(),
          @PnEstatus   = 0,
          @PsMensaje   = Char(32);

   Select @w_mesMax    = Max(valor)
   From   catCriteriosTbl
   Where  criterio = 'mes'
   And    idEstatus = 1;

   Select @w_idusuario = parametroChar
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 6;

   Select @w_sql   = Concat('Select @o_usuario = dbo.Fn_Desencripta_cadena (', @w_idusuario, ')'),
          @w_param = '@o_usuario    Nvarchar(20) Output';

   Execute Sp_executeSql @w_sql, @w_param, @o_usuario = @w_usuario Output

--
-- Generacion de Tabla temporal
--

   Create table #tempControl
   (secuencia   Integer  Not Null Identity (1, 1) Primary Key,
    ejercicio   Smallint Not Null,
    mes         Tinyint  Not Null);

   Create Table #TempCatalogo
  (Llave        Varchar(20)    Not Null,
   Moneda       Varchar( 2)    Not Null,
   Niv          Smallint       Not Null,
   Descrip      Varchar(100)   Not Null,
   Sant         Decimal        Not Null Default 0,
   Car          Decimal(18, 2) Not Null,
   Abo          Decimal(18, 2) Not Null,
   CarProceso   Decimal(18, 2) Not Null,
   AboProceso   Decimal(18, 2) Not Null,
   Ejercicio    Smallint       Not Null,
   mes          Tinyint        Not Null,
   Index TempCatalogoIdx01 Unique (llave, moneda, ejercicio, mes, Niv));

--
-- Inicio de Proceso
--

   Insert Into #tempControl
   (ejercicio, mes)
   Select Distinct ejercicio, mes
   From   dbo.CatalogoAuxiliar With (Nolock)
   Union
   Select Distinct ejercicio, mes
   From   dbo.CatalogoAuxiliarHist With (Nolock)
   Order  By 1, 2;
   Set @w_registros = @@Rowcount

   If @w_registros = 0
      Begin
         Select  @PnEstatus = 9999,
                 @PsMensaje = 'Error: No hay Periodos definidos en la tabla control.'

         Set  Xact_Abort Off
         Goto Salida
      End


   While @w_secuencia < @w_registros
   Begin
      Set @w_secuencia = @w_secuencia + 1;

      Select @w_ejercicio = ejercicio,
             @w_mes       = mes
      From   #tempControl
      Where  secuencia = @w_secuencia;
      If @@Rowcount = 0
         Begin
            Break
         End

      Begin Try
         Insert Into #TempCatalogo
        (Llave,     Moneda, Niv,        Sant,
         Car,       Abo,    CarProceso, AboProceso,
         Ejercicio, mes,    Descrip)
         Select Llave,     Moneda, Niv,        Sant,
                Car,       Abo,    CarProceso, AboProceso,
                Ejercicio, mes,    descrip
         From   dbo.CatalogoAuxiliar With (Nolock)
         Where  Ejercicio    = @w_ejercicio
         And    mes          = @w_mes
         And    sucursal_id  = 0
         Union
         Select Llave,     Moneda, Niv,        Sant,
                Car,       Abo,    CarProceso, AboProceso,
                Ejercicio, mes,    Descrip
         From   dbo.CatalogoAuxiliarHist With (Nolock)
         Where  Ejercicio    = @w_ejercicio
         And    mes          = @w_mes
         And    sucursal_id  = 0;

      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End Catch

      If IsNull(@w_error, 0) <> 0
         Begin

            Select @PnEstatus = @w_error,
                   @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

            Set Xact_Abort Off
            Goto Salida
         End

      Insert Into #TempCatalogo
     (Llave,     Moneda, Niv,        Sant,
      Car,       Abo,    CarProceso, AboProceso,
      Ejercicio, mes,    Descrip)
      Select Concat(Substring(llave, 1, 10), Replicate(0, 6)),
             Moneda,    0 Niv,                  Sum(Sant),
             Sum(Car),  Sum(Abo),  Sum(CarProceso), Sum(AboProceso),
             Ejercicio, mes,       Isnull((Select Top 1 descripcion
                                           From   dbo.CatalogoConsolidado With (Nolock)
                                           Where  numerodecuenta = Concat(Substring(llave, 1, 10), Replicate(0, 6))
                                           And    moneda_id      = a.moneda), Char(32))
      From   #TempCatalogo a
      Group  By Concat(Substring(llave, 1, 10), Replicate(0, 6)),
                Moneda, Ejercicio, mes;

      Begin Try
         Delete dbo.Catalogo
         Where  ejercicio = @w_ejercicio
         And    mes       = @w_mes;
      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End Catch

      If IsNull(@w_error, 0) <> 0
         Begin

            Select @PnEstatus = @w_error,
                   @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

            Set  Xact_Abort Off
            Goto Salida
         End

      Begin Try
         Insert Into dbo.Catalogo
        (Llave,       Moneda,      Niv,     Descrip,    SAnt,
         Car,         Abo,         SAct,    CarProceso, AboProceso,
         Ejercicio,   Mes)
         Select Llave,     Moneda,  Niv,                     Descrip,     SAnt,
                Car,       Abo,     a.SAnt + a.Car - a.abo,  CarProceso,  AboProceso,
                Ejercicio, mes
         From   #TempCatalogo a

      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End Catch

      If IsNull(@w_error, 0) <> 0
         Begin

            Select @PnEstatus = @w_error,
                   @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

            Set  Xact_Abort Off
            Goto Salida
         End

      Truncate Table #TempCatalogo;

   End;

Salida:

   If @PnEstatus = 0
      Begin
         Set @PsMensaje = 'Proceso Terminado Ok'
      End

   Drop Table #tempControl
   Drop Table #TempCatalogo

   Select @PnEstatus Error, @PsMensaje Mensaje

   Set Xact_Abort    On
   Return

End
Go
