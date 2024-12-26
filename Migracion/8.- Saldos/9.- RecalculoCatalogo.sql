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
   @w_mes                     Tinyint,
   @w_mesMax                  Tinyint,
   @w_linea                   Integer,
   @w_comilla                 Char(1),
   @w_mensaje                 Varchar(  Max),
   @w_idusuario               Varchar(  Max),
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
          @w_ultactual = Getdate()

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
   From   dbo.catalogos With (Nolock)
   Order  By 1, 2;
   Set @w_registros = @@Rowcount
   If @w_registros = 0
      Begin
         Select  @PnEstatus = 9999,
                 @PsMensaje = 'Error: No hay Periodos definidos en la tabla control.'

         Set  Xact_Abort Off
         Goto Salida
      End

   While @secuencia < @w_registros
   Begin
      Set @w_secuencia = @w_secuencia + 1;

      Select ejercicio = @w_ejercicio,
             mes       = @w_mes
      From   #tempControl;
      Where  secuencia = @w_secuencia;
      If @@Rowcount = 0
         Begin
            Break
         End

      Begin Try
         Insert Into #TempCatalogo
        (Llave,     Moneda, Niv,        Sant,
         Car,       Abo,    CarProceso, AboProceso,
         Ejercicio, mes)
         Select Llave,     Moneda, Niv,        Sant,
                Car,       Abo,    CarProceso, AboProceso,
                Ejercicio, mes
         From   dbo.catAuxiliares With (Nolock)
         Where  Ejercicio    = @w_ejercicio
         And    mes          = @w_mes
         And    sucursal_id = 0;

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

      Begin Try
         Insert Into  #TempCatalogo
        (Llave,     Moneda, Niv,        Sant,
         Car,       Abo,    CarProceso,  AboProceso,
         ejercicio, mes)
         Select Concat(Substring(a.llave, 1, 10), Replicate(0, 6)), a.Moneda, 2 Niv, Sum(Sant),
                Sum(a.car), Sum(a.Abo), Sum(a.CarProceso), Sum(a.AboProceso),
                a.ejercicio, a.mes
         From   #TempCatalogo a
         Where  a.Niv         = 1
         Group  By Concat(Substring(a.llave, 1, 10), Replicate(0, 6)), a.Moneda, a.ejercicio, a.mes
         Union
         Select Concat(Substring(a.llave, 1, 8), Replicate(0, 8)), a.Moneda, 3 Niv, Sum(Sant),
                Sum(a.car), Sum(a.Abo), Sum(a.CarProceso), Sum(a.AboProceso),
                a.ejercicio, a.mes
         From   #TempCatalogo a
         Where  a.Niv          = 1
         Group  By Concat(Substring(a.llave, 1, 8), Replicate(0, 8)), a.Moneda, a.ejercicio, a.mes
         Union
         Select Concat(Substring(a.llave, 1, 6), Replicate(0, 10)), a.Moneda, 4 Niv, Sum(Sant),
                Sum(a.car), Sum(a.Abo), Sum(a.CarProceso), Sum(a.AboProceso),
                a.ejercicio, a.mes
         From   #TempCatalogo a
         Where  a.Niv           = 1
         Group  By Concat(Substring(a.llave, 1, 6), Replicate(0, 10)), a.Moneda, a.ejercicio, a.mes
         Union
         Select Concat(Substring(a.llave, 1, 4), Replicate(0, 12)), a.Moneda, 5 Niv, Sum(Sant),
                Sum(a.car), Sum(a.Abo), Sum(a.CarProceso), Sum(a.AboProceso),
                a.ejercicio, a.mes
         From   #TempCatalogo a
         Where  a.Niv           = 1
         Group  By Concat(Substring(a.llave, 1, 4), Replicate(0, 12)), a.Moneda, a.ejercicio, a.mes
         Union
         Select Concat(Substring(a.llave, 1, 2), Replicate(0, 14)), a.Moneda, 6 Niv, Sum(Sant),
                Sum(a.car), Sum(a.Abo), Sum(a.CarProceso), Sum(a.AboProceso),
                a.ejercicio, a.mes
         From   #TempCatalogo a
         Where  a.Niv           = 1
         Group  By Concat(Substring(a.llave, 1, 2), Replicate(0, 14)), a.Moneda, a.ejercicio, a.mes
         Union
         Select Concat(Substring(a.llave, 1, 1), Replicate(0, 15)), a.Moneda, 7 Niv, Sum(Sant),
                Sum(a.car), Sum(a.Abo), Sum(a.CarProceso), Sum(a.AboProceso),
                a.ejercicio, a.mes
         From   #TempCatalogo a
         Where  a.Niv           = 1
         Group  By Concat(Substring(a.llave, 1, 1), Replicate(0, 15)), a.Moneda, a.ejercicio, a.mes
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

      Begin Try
         Insert Into dbo.Catalogo
        (Llave,       Moneda,      Niv,     Descrip,    SAnt,
         Car,         Abo,         SAct,    CarProceso, AboProceso,
         Ejercicio,   Mes)
         Select Llave,     Moneda,  Niv,        ' ' Descrip, 0,
                Car,       Abo,     Car - Abo,  CarProceso,  AboProceso,
                Ejercicio, mes
         From   #TempCatalogo a
         Where  Not Exists ( Select Top 1 1
                             From   dbo.catalogo With (Nolock)
                             Where  ejercicio = a.ejercicio
                             And    mes       = a.mes
                             And    llave     = a.llave
                             And    moneda    = a.moneda
                             And    Niv       = a.Niv)

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
         Update dbo.Catalogo
         Set    sAct       = a.SAnt + a.Car - a.abo
         From   dbo.Catalogo a With (Nolock)
         Where  a.ejercicio = @PnAnio
         And    a.mes       = @PnMes


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
         Update dbo.Catalogo
         Set    Descrip = b.Descripcion
         From   dbo.Catalogo a
         Join   dbo.CatalogoConsolidado b
         On     b.numerodecuenta = a.llave
         And    b.moneda_id      = a.moneda
         Where  a.ejercicio      = @PnAnio
         And    a.mes            = @PnMes
         And    a.Descrip        = '';

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

--
-- Actualización del catálogo del período.
--

      Begin Try
         Update dbo.Catalogo
         Set    Sant       = b.Sant,
                car        = b.car,
                abo        = b.Abo,
                CarProceso = b.CarProceso,
                AboProceso = b.AboProceso
         From   dbo.Catalogo  a
         Join   #TempCatalogo b  With (Nolock)
         On     b.llave     = a.llave
         And    b.moneda    = a.moneda
         And    b.ejercicio = a.ejercicio
         And    b.mes       = a.mes
         Where  a.ejercicio = @w_ejercicio
         And    a.mes       = @w_mes

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


      Truncate Table #TempCatalogo;

   End;

Salida:

   Select @PnEstatus Error, @PsMensaje Mensaje

   Set Xact_Abort    On
   Return

End
Go

