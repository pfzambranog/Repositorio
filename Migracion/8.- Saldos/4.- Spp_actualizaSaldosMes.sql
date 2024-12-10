/*

-- Declare
   -- @PnAnio                Smallint            = 2024,
   -- @PnMes                 Tinyint             = 8,
   -- @PnEstatus             Integer             = 0,
   -- @PsMensaje             Varchar( 250)       = ' ' ;
-- Begin

   -- Execute dbo.Spp_actualizaSaldosMes @PnAnio      = @PnAnio,
                                      -- @PnMes       = @PnMes,
                                      -- @PnEstatus   = @PnEstatus Output,
                                      -- @PsMensaje   = @PsMensaje Output;

   -- Select @PnEstatus, @PsMensaje
   -- Return
-- End
-- Go

--

-- Objeto:        Spp_actualizaSaldosMes.
-- Objetivo:      Actualiza los saldos contables de un mes al momento del cierre.
-- Fecha:         27/08/2024
-- Programador:   Pedro Zambrano
-- Versión:       1


*/

Create Or Alter Procedure dbo.Spp_actualizaSaldosMes
  (@PnAnio                Smallint,
   @PnMes                 Tinyint,
   @PsUsuario             Varchar(  10)       = Null,
   @PnEstatus             Integer             = 0   Output,
   @PsMensaje             Varchar( 250)       = ' ' Output)
As

Declare
   @w_Error             Integer,
   @w_linea             Integer,
   @w_operacion         Integer,
   @w_idEstatus         Tinyint,
   @w_desc_error        Varchar(250),
   @w_referencia        Varchar( 20),
   @w_idusuario         Varchar(  Max),
   @w_anioAnterior      Smallint,
   @w_mesAnterior       Smallint,
   @w_anioProximo       Smallint,
   @w_mesProximo        Smallint,
   @w_mesFin            Smallint,
   @w_fechaCaptura      Datetime,
   @w_usuario           Nvarchar(  20),
   @w_sql               NVarchar(1500),
   @w_param             NVarchar( 750),
   @w_comilla           Char(1);

Begin
   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off

   Select @PnEstatus         = 0,
          @PsMensaje         = Null,
          @w_operacion       = 9999,
          @w_fechaCaptura    = Getdate();

--
-- Obtención del usuario de la aplicación para procesos batch.
--

   If @PsUsuario Is Null
      Begin
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
      End
   Else
      Begin
         Set @w_usuario = @PsUsuario
      End

--
-- Validaciones
--

   Select  Top 1 @w_idEstatus = idEstatus
   From    dbo.ejercicios With (Nolock)
   Where   ejercicio = @PnAnio;
   If @@Rowcount = 0
      Begin
         Select @PnEstatus  = 8021,
                @PsMensaje =  'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

         Set Xact_Abort Off
         Return
      End

   If @w_idEstatus != 1
      Begin
         Select @PnEstatus  = 8022,
                @PsMensaje =  'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

         Set Xact_Abort Off
         Return
      End

   If Not Exists ( Select Top 1 1
                   From   dbo.catCriteriosTbl Whith (Nolock)
                   Where  criterio = 'mes'
                   And    valor    = @PnMes)
      Begin
         Select @PnEstatus  = 8023,
                @PsMensaje =  'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

         Set Xact_Abort Off
         Return
      End

   Select @w_idEstatus = idEstatus
   From   dbo.control With (Nolock)
   Where  ejercicio = @PnAnio
   And    mes       = @PnMes;
   If @@Rowcount = 0
      Begin
         Select @PnEstatus  = 8024,
                @PsMensaje =  'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

         Set Xact_Abort Off
         Return
      End

   If @w_idEstatus != 1
      Begin
         Select @PnEstatus  = 8025,
                @PsMensaje =  'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

         Set Xact_Abort Off
         Return
      End

--
-- Se ubica el último ejercicio y mes Cerrado
--

   Select @w_anioAnterior = Max(ejercicio)
   From   dbo.control With (Nolock)
   Where  idEstatus = 2;

   Select @w_mesAnterior = Max(mes)
   From   dbo.control With (Nolock)
   Where  ejercicio = @w_anioAnterior
   And    idEstatus = 2;

   Select @w_mesFin = Max(valor)
   From   dbo.catCriteriosTbl Whith (Nolock)
   Where  criterio = 'mes';

--
-- Creación de Tablas Temporales
--

  Create Table #TempCatalogo
  (Secuencia    Integer        Not Null Identity(1, 1) Primary key,
   Llave        Varchar(20)    Not Null,
   Moneda       Varchar( 2)    Not Null,
   Niv          Smallint       Not Null,
   Car          Decimal(18, 2) Not Null,
   Abo          Decimal(18, 2) Not Null,
   CarProceso   Decimal(18, 2) Not Null,
   AboProceso   Decimal(18, 2) Not Null,
   Ejercicio    Smallint       Not Null,
   mes          Tinyint        Not Null,
   Index TempCatalogoIdx01 Unique (llave, moneda, ejercicio, mes, Niv));

  Create Table #TempCatalogoAux
  (Secuencia    Integer        Not Null Identity(1, 1) Primary key,
   Llave        Varchar(20)    Not Null,
   Moneda       Varchar( 2)    Not Null,
   Niv          Smallint       Not Null,
   Sector_id    Integer        Not Null,
   Sucursal_id  Integer        Not Null,
   Region_id    Integer        Not Null,
   Car          Decimal(18, 2) Not Null,
   Abo          Decimal(18, 2) Not Null,
   CarProceso   Decimal(18, 2) Not Null,
   AboProceso   Decimal(18, 2) Not Null,
   Ejercicio    Smallint       Not Null,
   mes          Tinyint        Not Null,
   Index TempCatalogoAuxIdx01 Unique (llave, moneda, Sector_id,
         Sucursal_id, Region_id, ejercicio, mes, Niv));

--
-- Inicio de Proceso.
--


   Begin Transaction

--
-- Se actualiza los saldos de Catalogo
--

      Begin Try
         Update dbo.Catalogo
         Set    CarProceso = 0,
                AboProceso = 0,
                car        = 0,
                abo        = 0,
                sprom      = 0,
                sAct       = Sant
         Where  ejercicio = @PnAnio
         And    mes       = @PnMes;
      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End Catch

      If IsNull(@w_error, 0) <> 0
         Begin
            Rollback Transaction

            Select @PnEstatus = @w_error,
                   @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

            Set Xact_Abort Off
            Goto Salida
         End


--
-- Se actualiza los saldos de Catalogo Auxiliar.
--
      Begin Try
         Update dbo.CatalogoAuxiliar
         Set    CarProceso = 0,
                AboProceso = 0,
                car        = 0,
                abo        = 0,
                sprom      = 0,
                sAct       = Sant
         From   dbo.CatalogoAuxiliar With (Nolock index(catalogoAuxiliarIdx01))
         Where  ejercicio = @PnAnio
         And    mes       = @PnMes;
      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End Catch

      If IsNull(@w_error, 0) <> 0
         Begin
            Rollback Transaction

            Select @PnEstatus = @w_error,
                   @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

            Set Xact_Abort Off
            Goto Salida
         End

--
-- Traspaso de Polizas Anio a Poliza.
--

      Begin Try
         Insert Into dbo.poliza
        (Referencia, Fecha_mov, Fecha_Cap,       Concepto,
         Cargos,     Abonos,    TCons,           Usuario,
         TipoPoliza, Documento, Usuario_cancela, Fecha_Cancela,
         Status,     Mes_Mov,   TipoPolizaConta, FuenteDatos,
         ejercicio,  mes)
         Select Referencia, Fecha_Mov, Fecha_Cap,       Concepto,
                Cargos,     Abonos,    TCons,           Usuario,
                TipoPoliza, Documento, Usuario_cancela, Fecha_Cancela,
                Status,     Mes_Mov,   TipoPolizaConta, FuenteDatos,
                Ejercicio,  Mes
         From   dbo.polizaAnio a With (Nolock)
         Where  ejercicio  = @PnAnio
         And    mes        = @PnMes
         And    Not Exists ( Select Top 1 1
                             From   dbo.poliza With (Nolock Index (IX_FK_PolizaFk03))
                             Where  Ejercicio  = a.ejercicio
                             And    mes        = a.mes
                             And    fecha_mov  = a.fecha_mov
                             And    Referencia = a.Referencia);
      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End Catch

      If IsNull(@w_error, 0) <> 0
         Begin
            Rollback Transaction

            Select @PnEstatus = @w_error,
                   @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

            Set Xact_Abort Off
            Goto Salida
         End

--
-- Alta de los movimientos de las pólizas.
--

      Begin Try
         Insert Into dbo.movimientos
        (Referencia,      Cons,             Moneda,        Fecha_mov,
         Llave,           Concepto,         Importe,       Documento,
         Clave,           FecCap,           Sector_id,     Sucursal_id,
         Region_id,       Importe_Cargo,    Importe_Abono, Descripcion,
         TipoPolizaConta, ReferenciaFiscal, Fecha_Doc,     Ejercicio,
         mes)
         Select Referencia,      Cons,             Moneda,        Fecha_mov,
                Llave,           Concepto,         Importe,       Documento,
                Clave,           FecCap,           Sector_id,     Sucursal_id,
                Region_id,       Importe_Cargo,    Importe_Abono, Descripcion,
                TipoPolizaConta, ReferenciaFiscal, Fecha_Doc,     Ejercicio,
                mes
         From   dbo.MovimientosAnio a With (Nolock)
         Where  ejercicio   = @PnAnio
         And    mes         = @PnMes
         And    Not Exists ( Select Top 1 1
                             From   dbo.movimientos With (Nolock index (IX_FK_MovimientosFk01))
                             Where  Referencia = a.Referencia
                             And    Cons       = a.cons
                             And    fecha_mov  = a.fecha_mov
                             And    Ejercicio  = a.ejercicio
                             And    mes        = a.mes)
      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End Catch

      If IsNull(@w_error, 0) <> 0
         Begin
            Rollback Transaction

            Select @PnEstatus = @w_error,
                   @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

            Set Xact_Abort Off
            Goto Salida
         End


--
-- Consulta a los movimientos del período para el catálogo contable.
--

      Begin Try
         Insert Into  #TempCatalogo
        (Llave, Moneda,      Niv,          Car,
         Abo,   CarProceso,  AboProceso,   ejercicio,
         mes)
         Select a.Llave, a.moneda, 1 Niv,
                Sum(Case When Clave = 'C'
                         Then Importe
                         Else 0
                    End),
                Sum(Case When Clave = 'A'
                         Then Importe
                         Else 0
                    End),
                Sum(Case When Clave = 'C'
                         Then Importe
                         Else 0
                    End),
                Sum(Case When Clave  = 'A'
                         Then Importe
                         Else 0
                    End), a.ejercicio, a.mes
         From   dbo.Movimientos      a With (Nolock)
         Join   dbo.Catalogo         b With (Nolock)
         On     b.ejercicio      = a.ejercicio
         And    b.mes            = a.mes
         And    b.llave          = a.llave
         And    b.moneda         = a.moneda
         Where  a.ejercicio      = @PnAnio
         And    a.mes            = @PnMes
         Group  By  a.Llave, a.moneda, a.ejercicio, a.mes;
      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End Catch

      If IsNull(@w_error, 0) <> 0
         Begin
            Rollback Transaction

            Select @PnEstatus = @w_error,
                   @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

            Set Xact_Abort Off
            Goto Salida
         End

      Begin Try
         Insert Into  #TempCatalogo
        (Llave, Moneda,      Niv,          Car,
         Abo,   CarProceso,  AboProceso,   ejercicio,
         mes)
         Select Concat(Substring(a.llave, 1, 12), Replicate(0, 4)), a.Moneda, 2 Niv,
                Sum(a.car), Sum(a.Abo), Sum(a.CarProceso), Sum(a.AboProceso),
                a.ejercicio, a.mes
         From   #TempCatalogo a
         Join   dbo.Catalogo b With (Nolock)
         On     b.llave     = Concat(Substring(a.llave, 1, 12), Replicate(0, 4))
         And    b.moneda    = a.moneda
         And    b.ejercicio = a.ejercicio
         And    b.mes       = a.mes
         Where  b.ejercicio = @PnAnio
         And    b.mes       = @PnMes
         And    a.Niv       = 1
         Group  By Substring(a.llave, 1, 12), a.Moneda, a.ejercicio, a.mes
         Union
         Select Concat(Substring(a.llave, 1, 10), Replicate(0, 6)), a.Moneda, 3 Niv,
                Sum(a.car), Sum(a.Abo), Sum(a.CarProceso), Sum(a.AboProceso),
                a.ejercicio, a.mes
         From   #TempCatalogo a
         Join   dbo.Catalogo  b With (Nolock)
         On     b.llave       = Concat(Substring(a.llave, 1, 10), Replicate(0, 6))
         And    b.moneda      = a.moneda
         And    b.ejercicio   = a.ejercicio
         And    b.mes         = a.mes
         Where  b.ejercicio   = @PnAnio
         And    b.mes         = @PnMes
         And    a.Niv         = 1
         Group  By Substring(a.llave, 1, 10), a.Moneda, a.ejercicio, a.mes
         Union
         Select Concat(Substring(a.llave, 1, 8), Replicate(0, 8)), a.Moneda, 4 Niv,
                Sum(a.car), Sum(a.Abo), Sum(a.CarProceso), Sum(a.AboProceso),
                a.ejercicio, a.mes
         From   #TempCatalogo a
         Join   dbo.Catalogo  b With (Nolock)
         On     b.llave        = Concat(Substring(a.llave, 1, 8), Replicate(0, 8))
         And    b.moneda       = a.moneda
         And    b.ejercicio    = a.ejercicio
         And    b.mes          = a.mes
         Where  b.ejercicio    = @PnAnio
         And    b.mes          = @PnMes
         And    a.Niv          = 1
         Group  By Substring(a.llave, 1, 8), a.Moneda, a.ejercicio, a.mes
         Union
         Select Concat(Substring(a.llave, 1, 6), Replicate(0, 10)), a.Moneda, 5 Niv,
                Sum(a.car), Sum(a.Abo), Sum(a.CarProceso), Sum(a.AboProceso),
                a.ejercicio, a.mes
         From   #TempCatalogo a
         Join   dbo.Catalogo  b With (Nolock)
         On     b.llave         = Concat(Substring(a.llave, 1, 6), Replicate(0, 10))
         And    b.moneda        = a.moneda
         And    b.ejercicio     = a.ejercicio
         And    b.mes           = a.mes
         Where  b.ejercicio     = @PnAnio
         And    b.mes           = @PnMes
         And    a.Niv           = 1
         Group  By Substring(a.llave, 1, 6), a.Moneda, a.ejercicio, a.mes
         Union
         Select Concat(Substring(a.llave, 1, 4), Replicate(0, 12)), a.Moneda, 6 Niv,
                Sum(a.car), Sum(a.Abo), Sum(a.CarProceso), Sum(a.AboProceso),
                a.ejercicio, a.mes
         From   #TempCatalogo a
         Join   dbo.Catalogo  b With (Nolock)
         On     b.llave         = Concat(Substring(a.llave, 1, 4), Replicate(0, 12))
         And    b.moneda        = a.moneda
         And    b.ejercicio     = a.ejercicio
         And    b.mes           = a.mes
         Where  b.ejercicio     = @PnAnio
         And    b.mes           = @PnMes
         And    a.Niv           = 1
         Group  By Substring(a.llave, 1, 4), a.Moneda, a.ejercicio, a.mes
         Union
         Select Concat(Substring(a.llave, 1, 2), Replicate(0, 14)), a.Moneda, 7 Niv,
                Sum(a.car), Sum(a.Abo), Sum(a.CarProceso), Sum(a.AboProceso),
                a.ejercicio, a.mes
         From   #TempCatalogo a
         Join   dbo.Catalogo  b With (Nolock)
         On     b.llave         = Concat(Substring(a.llave, 1, 2), Replicate(0, 14))
         And    b.moneda        = a.moneda
         And    b.mes           = a.mes
         Where  b.ejercicio     = @PnAnio
         And    b.mes           = @PnMes
         And    a.Niv           = 1
         Group  By Substring(a.llave, 1, 2), a.Moneda, a.ejercicio, a.mes
         Union
         Select Concat(Substring(a.llave, 1, 1), Replicate(0, 15)), a.Moneda, 8 Niv,
                Sum(a.car), Sum(a.Abo), Sum(a.CarProceso), Sum(a.AboProceso),
                a.ejercicio, a.mes
         From   #TempCatalogo a
         Join   dbo.Catalogo  b With (Nolock)
         On     b.llave         = Concat(Substring(a.llave, 1, 1), Replicate(0, 15))
         And    b.moneda        = a.moneda
         And    b.mes           = a.mes
         Where  b.ejercicio     = @PnAnio
         And    b.mes           = @PnMes
         And    a.Niv           = 1
         Group  By Substring(a.llave, 1, 1), a.Moneda, a.ejercicio, a.mes
      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End Catch

      If IsNull(@w_error, 0) <> 0
         Begin
            Rollback Transaction

            Select @PnEstatus = @w_error,
                   @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

            Set Xact_Abort Off
            Goto Salida
         End

--
-- ALta a los movimientos del período para el catálogo Auxiliar
--

      Begin Try
         Insert Into  #TempCatalogoAux
        (Llave,       Moneda,     Niv,       Sector_id,
         Sucursal_id, Region_id,  Car,       Abo,
         CarProceso,  AboProceso, ejercicio, mes)
         Select a.Llave,       a.moneda,    1 Niv,         a.Sector_id,
                a.Sucursal_id, a.Region_id,
                Sum(Case When Clave = 'C'
                         Then Importe
                         Else 0
                    End),
                Sum(Case When Clave = 'A'
                         Then Importe
                         Else 0
                    End),
                Sum(Case When Clave = 'C'
                         Then Importe
                         Else 0
                    End),
                Sum(Case When Clave = 'A'
                         Then Importe
                         Else 0
                    End), a.ejercicio, a.mes
         From   dbo.Movimientos         a With (Nolock)
         Join   dbo.catalogoAuxiliar    b With (Nolock)
         On     b.llave          = a.llave
         And    b.moneda         = a.moneda
         And    b.Sucursal_id    = a.Sucursal_id
         And    b.Region_id      = a.Region_id
         And    b.ejercicio      = a.ejercicio
         And    b.mes            = a.mes
         Where  b.ejercicio      = @PnAnio
         And    b.mes            = @PnMes
         Group  By  a.Llave,     a.moneda,      a.Sector_id, a.Sucursal_id,
                    a.Region_id, a.ejercicio,   a.mes;
      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End Catch

      If IsNull(@w_error, 0) <> 0
         Begin
            Rollback Transaction

            Select @PnEstatus = @w_error,
                   @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

            Set Xact_Abort Off
            Goto Salida
         End

      Begin Try
         Insert Into  #TempCatalogoAux
        (Llave,       Moneda,     Niv,       Sector_id,
         Sucursal_id, Region_id,  Car,       Abo,
         CarProceso,  AboProceso, ejercicio, mes)
         Select Concat(Substring(a.llave, 1, 12), Replicate(0, 4)), a.Moneda, 2 Niv, a.Sector_id,
                a.Sucursal_id, a.Region_id,
                Sum(a.car),  Sum(a.Abo), Sum(a.carProceso), Sum(a.AboProceso),
                a.ejercicio, a.mes
         From   #TempCatalogoAux       a
         Join   dbo.CatalogoAuxiliar   b With (Nolock)
         On     b.llave          = Concat(Substring(a.llave, 1, 12), Replicate(0, 4))
         And    b.moneda         = a.moneda
         And    b.Sucursal_id    = a.Sucursal_id
         And    b.Region_id      = a.Region_id
         And    b.ejercicio      = a.ejercicio
         And    b.mes            = a.mes
         Where  b.ejercicio      = @PnAnio
         And    b.mes            = @PnMes
         And    a.Niv            = 1
         Group  By Substring(a.llave, 1, 12), a.Moneda,    a.Sector_id,
                a.Sucursal_id, a.Region_id,   a.ejercicio, a.mes
         Union
         Select Concat(Substring(a.llave, 1, 10), Replicate(0, 6)), a.Moneda, 3 Niv, a.Sector_id,
                a.Sucursal_id, a.Region_id,
                Sum(a.car),  Sum(a.Abo), Sum(a.carProceso), Sum(a.AboProceso),
                a.ejercicio, a.mes
         From   #TempCatalogoAux     a
         Join   dbo.CatalogoAuxiliar b With (Nolock)
         On     b.llave                 = Concat(Substring(a.llave, 1, 10), Replicate(0, 6))
         And    b.moneda                = a.moneda
         And    b.Sucursal_id           = a.Sucursal_id
         And    b.Region_id             = a.Region_id
         And    b.ejercicio             = a.ejercicio
         And    b.mes                   = a.mes
         Where  b.ejercicio             = @PnAnio
         And    b.mes                   = @PnMes
         And    a.Niv                   = 1
         Group  By Substring(a.llave, 1, 10), a.Moneda, a.Sector_id,
                a.Sucursal_id, a.Region_id, a.ejercicio, a.mes
         Union
         Select Concat(Substring(a.llave, 1, 8), Replicate(0, 8)), a.Moneda, 4 Niv, a.Sector_id,
                a.Sucursal_id, a.Region_id,
                Sum(a.car),  Sum(a.Abo), Sum(a.carProceso), Sum(a.AboProceso),
                a.ejercicio, a.mes
         From   #TempCatalogoAux        a
         Join   dbo.CatalogoAuxiliar    b With (Nolock)
         On     b.llave                 = Concat(Substring(a.llave, 1, 8), Replicate(0, 8))
         And    b.moneda                = a.moneda
         And    b.Sucursal_id           = a.Sucursal_id
         And    b.Region_id             = a.Region_id
         And    b.ejercicio             = a.ejercicio
         And    b.mes                   = a.mes
         Where  b.ejercicio             = @PnAnio
         And    b.mes                   = @PnMes
         And    a.Niv                   = 1
         Group  By Substring(a.llave, 1, 8), a.Moneda,    a.Sector_id,
                a.Sucursal_id, a.Region_id,      a.ejercicio, a.mes
         Union
         Select Concat(Substring(a.llave, 1, 6), Replicate(0, 10)), a.Moneda, 5 Niv, a.Sector_id,
                a.Sucursal_id, a.Region_id,
                Sum(a.car),    Sum(a.Abo), Sum(a.carProceso), Sum(a.AboProceso),
                a.ejercicio,   a.mes
         From   #TempCatalogoAux         a
         Join   dbo.CatalogoAuxiliar     b With (Nolock)
         On     b.llave                 = Concat(Substring(a.llave, 1, 6), Replicate(0, 12))
         And    b.moneda                = a.moneda
         And    b.Sucursal_id           = a.Sucursal_id
         And    b.Region_id             = a.Region_id
         And    b.ejercicio             = a.ejercicio
         And    b.mes                   = a.mes
         Where  b.ejercicio             = @PnAnio
         And    b.mes                   = @PnMes
         And    a.Niv                   = 1
         Group  By Substring(a.llave, 1, 6), a.Moneda, a.Sector_id,
                a.Sucursal_id, a.Region_id, a.ejercicio, a.mes
         Union
         Select Concat(Substring(a.llave, 1, 4), Replicate(0, 12)), a.Moneda, 6 Niv, a.Sector_id,
                a.Sucursal_id, a.Region_id,
                Sum(a.car),    Sum(a.Abo), Sum(a.carProceso), Sum(a.AboProceso),
                a.ejercicio,   a.mes
         From   #TempCatalogoAux      a
         Join   dbo.CatalogoAuxiliar  b With (Nolock)
         On     b.llave                 = Concat(Substring(a.llave, 1, 4), Replicate(0, 12))
         And    b.moneda                = a.moneda
         And    b.Sucursal_id           = a.Sucursal_id
         And    b.Region_id             = a.Region_id
         And    b.ejercicio             = a.ejercicio
         And    b.mes                   = a.mes
         Where  b.ejercicio             = @PnAnio
         And    b.mes                   = @PnMes
         And    a.Niv                   = 1
         Group  By Substring(a.llave, 1, 4), a.Moneda, a.Sector_id,
                a.Sucursal_id, a.Region_id, a.ejercicio, a.mes
         Union
         Select Concat(Substring(a.llave, 1, 2), Replicate(0, 14)), a.Moneda, 7 Niv, a.Sector_id,
                a.Sucursal_id, a.Region_id,
                Sum(a.car),    Sum(a.Abo), Sum(a.carProceso), Sum(a.AboProceso),
                a.ejercicio,   a.mes
         From   #TempCatalogoAux     a
         Join   dbo.CatalogoAuxiliar b With (Nolock)
         On     b.llave                 = Concat(Substring(a.llave, 1, 2), Replicate(0, 14))
         And    b.moneda                = a.moneda
         And    b.Sucursal_id           = a.Sucursal_id
         And    b.Region_id             = a.Region_id
         And    b.ejercicio             = a.ejercicio
         And    b.mes                   = a.mes
         Where  b.ejercicio             = @PnAnio
         And    b.mes                   = @PnMes
         And    a.Niv                   = 1
         Group  By Substring(a.llave, 1, 2), a.Moneda,    a.Sector_id,
                a.Sucursal_id, a.Region_id,  a.ejercicio, a.mes
         Union
         Select Concat(Substring(a.llave, 1, 1), Replicate(0, 15)), a.Moneda, 8 Niv, a.Sector_id,
                a.Sucursal_id, a.Region_id,
                Sum(a.car),    Sum(a.Abo), Sum(a.carProceso), Sum(a.AboProceso),
                a.ejercicio,   a.mes
         From   #TempCatalogoAux      a
         Join   dbo.CatalogoAuxiliar  b With (Nolock)
         On     b.llave                 = Concat(Substring(a.llave, 1, 1), Replicate(0, 15))
         And    b.moneda                = a.moneda
         And    b.Sucursal_id           = a.Sucursal_id
         And    b.Region_id             = a.Region_id
         And    b.ejercicio             = a.ejercicio
         And    b.mes                   = a.mes
         Where  b.ejercicio             = @PnAnio
         And    b.mes                   = @PnMes
         And    a.Niv                   = 1
         Group  By Substring(a.llave, 1, 1), a.Moneda,   a.Sector_id,
                a.Sucursal_id, a.Region_id, a.ejercicio, a.mes
      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End Catch

      If IsNull(@w_error, 0) <> 0
         Begin
            Rollback Transaction

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
         Set    CarProceso = b.CarProceso,
                AboProceso = b.AboProceso,
                car        = b.car,
                abo        = b.Abo
         From   dbo.Catalogo  a
         Join   #TempCatalogo b  With (Nolock)
         On     b.llave     = a.llave
         And    b.moneda    = a.moneda
         And    b.ejercicio = a.ejercicio
         And    b.mes       = a.mes
         Where  a.ejercicio = @PnAnio
         And    a.mes       = @PnMes

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
            Rollback Transaction

            Select @PnEstatus = @w_error,
                   @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

            Set Xact_Abort Off
            Goto Salida
         End

--
-- Actualización del catálogo Auxiliar.
--

      Begin Try
         Update dbo.CatalogoAuxiliar
         Set    CarProceso = b.CarProceso,
                AboProceso = b.AboProceso,
                car        = b.car,
                abo        = b.Abo
         From   dbo.CatalogoAuxiliar      a With (Nolock index(catalogoAuxiliarIdx01))
         Join   #TempCatalogoAux          b
         On     b.llave       = a.llave
         And    b.moneda      = a.moneda
         And    b.Sector_id   = a.Sector_id
         And    b.Sucursal_id = a.Sucursal_id
         And    b.Region_id   = a.Region_id
         And    b.ejercicio   = a.ejercicio
         And    b.mes         = a.mes
         Where  a.ejercicio   = @PnAnio
         And    a.mes         = @PnMes;

         Update dbo.CatalogoAuxiliar
         Set    sAct       = a.SAnt + a.Car - a.abo
         From   dbo.CatalogoAuxiliar a With (Nolock index(catalogoAuxiliarIdx01))
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
             Rollback Transaction

             Select @PnEstatus = @w_error,
                    @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

             Set Xact_Abort Off
             Goto Salida
          End

--
-- Actualización del catálogo del mes con los valores reportados del período.
--

      Begin Try
         Update dbo.catalogo
         Set    SAnt        = a.SAnt        + b.SAct,
                SAct        = a.SAct        + b.SAct,
                SAntProceso = a.SAntProceso + b.SAct
         From   dbo.catalogo           a With (Nolock)
         Join   dbo.catalogoReporteTbl b With (Nolock)
         On     b.ejercicio = a.ejercicio
         And    b.mes       = a.mes
         And    b.Llave     = a.llave
         And    b.mes       = a.mes
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
            Rollback Transaction

            Select @PnEstatus = @w_error,
                   @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

            Set Xact_Abort Off
            Goto Salida
         End

--
-- Actualización del catálogo Auxiliar, con los valores reportados.
--

      Begin Try
         Update dbo.CatalogoAuxiliar
         Set    SAnt        = a.SAnt        + b.SAct,
                SAct        = a.SAct        + b.SAct,
                SAntProceso = a.SAntProceso + b.SAct
         From   dbo.CatalogoAuxiliar      a With (Nolock)
         Join   dbo.catalogoAuxReporteTbl b With (Nolock)
         On     b.llave       = a.llave
         And    b.moneda_id   = a.moneda
         And    b.Sector_id   = a.Sector_id
         And    b.Sucursal_id = a.Sucursal_id
         And    b.Region_id   = a.Region_id
         And    b.ejercicio   = a.ejercicio
         And    b.mes         = a.mes
         Where  a.ejercicio   = @PnAnio
         And    a.mes         = @PnMes;

      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End Catch

      If IsNull(@w_error, 0) <> 0
         Begin
            Rollback Transaction

            Select @PnEstatus = @w_error,
                   @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

            Set Xact_Abort Off
            Goto Salida
         End

--
-- Depuración del detalle de los movimientos contables
--

      If Exists ( Select Top 1 1
                  From   dbo.MovimientosAnio With (Nolock)
                  Where  ejercicio = @PnAnio
                  And    mes       = @PnMes)
         Begin
            Begin Try
               Delete dbo.MovimientosAnio
               Where  ejercicio = @PnAnio
               And    mes       = @PnMes;

            End Try

            Begin Catch
               Select  @w_Error      = @@Error,
                       @w_linea      = Error_line(),
                       @w_desc_error = Substring (Error_Message(), 1, 200)

            End Catch

            If IsNull(@w_error, 0) <> 0
               Begin
                  Rollback Transaction

                  Select @PnEstatus = @w_error,
                         @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

                  Set Xact_Abort Off
                  Goto Salida
               End

         End

--
-- Depuración del Cabecero de los movimientos contables
--

      If Exists ( Select Top 1 1
                  From   dbo.PolizaAnio With (Nolock)
                  Where  ejercicio = @PnAnio
                  And    mes       = @PnMes)
         Begin
            Begin Try
               Delete dbo.PolizaAnio
               Where  ejercicio = @PnAnio
               And    mes       = @PnMes;

            End Try

            Begin Catch
               Select  @w_Error      = @@Error,
                       @w_linea      = Error_line(),
                       @w_desc_error = Substring (Error_Message(), 1, 200)

            End Catch

            If IsNull(@w_error, 0) <> 0
               Begin
                  Rollback Transaction

                  Select @PnEstatus = @w_error,
                         @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

                  Set Xact_Abort Off
                  Goto Salida
               End

         End

--
-- Fin del proceso.
--

   Commit Transaction

   Set @PsMensaje = 'Aplicación de Saldo realizado con éxito!'

Salida:

   Set Xact_Abort Off
   Return

End
Go

--
-- Comentarios.
--

Declare
   @w_valor          Varchar(1500) = 'Actualiza los saldos contables de un mes.',
   @w_procedimiento  Varchar( 100) = 'Spp_actualizaSaldosMes'


If Not Exists (Select Top 1 1
               From   sys.extended_properties a
               Join   sysobjects  b
               On     b.xtype   = 'P'
               And    b.name    = @w_procedimiento
               And    b.id      = a.major_id)

   Begin
      Execute  sp_addextendedproperty @name       = N'MS_Description',
                                      @value      = @w_valor,
                                      @level0type = 'Schema',
                                      @level0name = N'Dbo',
                                      @level1type = 'Procedure',
                                      @level1name = @w_procedimiento;

   End
Else
   Begin
      Execute sp_updateextendedproperty @name       = 'MS_Description',
                                        @value      = @w_valor,
                                        @level0type = 'Schema',
                                        @level0name = N'Dbo',
                                        @level1type = 'Procedure',
                                        @level1name = @w_procedimiento
   End
Go
