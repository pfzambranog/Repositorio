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

Create Or Alter  Procedure dbo.Spp_actualizaSaldosMes
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
   Sant         Decimal        Not Null Default 0,
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
   Sant         Decimal        Not Null Default 0,
   Car          Decimal(18, 2) Not Null,
   Abo          Decimal(18, 2) Not Null,
   CarProceso   Decimal(18, 2) Not Null,
   AboProceso   Decimal(18, 2) Not Null,
   Ejercicio    Smallint       Not Null,
   mes          Tinyint        Not Null,
   Index TempCatalogoAuxIdx01 Unique (llave, moneda,
         Sucursal_id, Region_id, ejercicio, mes, Niv));

--
-- Inicio de Proceso.
--


   Begin Transaction

--
-- Se inicializa los saldos de Catalogo
--

      Begin Try
         Delete dbo.Catalogo
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
-- Se actualiza el saldo anterior de Catalogo
--

      Begin Try
         Insert Into dbo.Catalogo
         (Llave,        Moneda,     Niv,        Descrip,
          SAnt,         Car,        Abo,        SAct,
          FecCap,       CarProceso, AboProceso, SAntProceso,
          CarExt,       AboExt,     SProm,      SPromAnt,
          Nivel_sector, SProm2,     Sprom2Ant,  Ejercicio,
          Mes)
          Select Llave,          Moneda,       Niv,          Descrip,
                 SAct,           0 Car,        0 Abo,        SAct,
                 FecCap,         0 CarProceso, 0 AboProceso, 0 SAntProceso,
                 0 CarExt,       0 AboExt,     0 SProm,      0 SPromAnt,
                 1 Nivel_sector, 0 SProm2,     0 Sprom2Ant,  @PnAnio,
                 @PnMes
          From   dbo.CatalogoAuxiliar a With (Nolock)
          Where  ejercicio   = @w_anioAnterior
          And    mes         = @w_mesAnterior
          And    Sucursal_id = 0
          And    Niv         = 1;

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
-- Se Inicializa los saldos del mes de Catalogo Auxiliar.
--

      Begin Try
         Delete dbo.CatalogoAuxiliar
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
-- Se Actualiza el saldo anterior del mes de Catalogo Auxiliar.
--

      Begin Try
         Insert Into dbo.CatalogoAuxiliar
        (Llave,       Moneda,     Niv,         Sector_id,
         Sucursal_id, Region_id,  Descrip,     SAnt,
         Car,         Abo,        SAct,        FecCap,
         CarProceso,  AboProceso, SAntProceso, CarExt,
         AboExt,      SProm,      SPromAnt,    SProm2,
         SProm2Ant,   ejercicio,  mes)
         Select Llave,         Moneda,       Niv,           Sector_id,
                Sucursal_id,   Region_id,    Descrip,       SAct,
                0 Car,         0 Abo,        SAct,          FecCap,
                0 CarProceso,  0 AboProceso, 0 SAntProceso, 0 CarExt,
                0 AboExt,      0 SProm,      0 SPromAnt,    0 SProm2,
                0 SProm2Ant,   @PnAnio,      @PnMes
         From   dbo.CatalogoAuxiliar a With (Nolock index(catalogoAuxiliarIdx01))
         Where  ejercicio    = @w_anioAnterior
         And    mes          = @w_mesAnterior;

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
         Select Concat(Substring(a.llave, 1, 10), Replicate(0, 6)), a.Moneda, 2 Niv,
                Sum(a.car), Sum(a.Abo), Sum(a.CarProceso), Sum(a.AboProceso),
                a.ejercicio, a.mes
         From   #TempCatalogo a
         Where  a.Niv         = 1
         Group  By Concat(Substring(a.llave, 1, 10), Replicate(0, 6)), a.Moneda, a.ejercicio, a.mes
         Union
         Select Concat(Substring(a.llave, 1, 8), Replicate(0, 8)), a.Moneda, 3 Niv,
                Sum(a.car), Sum(a.Abo), Sum(a.CarProceso), Sum(a.AboProceso),
                a.ejercicio, a.mes
         From   #TempCatalogo a
         Where  a.Niv          = 1
         Group  By Concat(Substring(a.llave, 1, 8), Replicate(0, 8)), a.Moneda, a.ejercicio, a.mes
         Union
         Select Concat(Substring(a.llave, 1, 6), Replicate(0, 10)), a.Moneda, 4 Niv,
                Sum(a.car), Sum(a.Abo), Sum(a.CarProceso), Sum(a.AboProceso),
                a.ejercicio, a.mes
         From   #TempCatalogo a
         Where  a.Niv           = 1
         Group  By Concat(Substring(a.llave, 1, 6), Replicate(0, 10)), a.Moneda, a.ejercicio, a.mes
         Union
         Select Concat(Substring(a.llave, 1, 4), Replicate(0, 12)), a.Moneda, 5 Niv,
                Sum(a.car), Sum(a.Abo), Sum(a.CarProceso), Sum(a.AboProceso),
                a.ejercicio, a.mes
         From   #TempCatalogo a
         Where  a.Niv           = 1
         Group  By Concat(Substring(a.llave, 1, 4), Replicate(0, 12)), a.Moneda, a.ejercicio, a.mes
         Union
         Select Concat(Substring(a.llave, 1, 2), Replicate(0, 14)), a.Moneda, 6 Niv,
                Sum(a.car), Sum(a.Abo), Sum(a.CarProceso), Sum(a.AboProceso),
                a.ejercicio, a.mes
         From   #TempCatalogo a
         Where  a.Niv           = 1
         Group  By Concat(Substring(a.llave, 1, 2), Replicate(0, 14)), a.Moneda, a.ejercicio, a.mes
         Union
         Select Concat(Substring(a.llave, 1, 1), Replicate(0, 15)), a.Moneda, 7 Niv,
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
         Where  a.ejercicio      = @PnAnio
         And    a.mes            = @PnMes
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
            Rollback Transaction

            Select @PnEstatus = @w_error,
                   @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

            Set Xact_Abort Off
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
            Rollback Transaction

            Select @PnEstatus = @w_error,
                   @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

            Set Xact_Abort Off
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
         And    b.Sucursal_id = a.Sucursal_id
         And    b.Region_id   = a.Region_id
         And    b.ejercicio   = a.ejercicio
         And    b.mes         = a.mes
         Where  a.ejercicio   = @PnAnio
         And    a.mes         = @PnMes;

         Insert Into dbo.CatalogoAuxiliar
        (Llave,       Moneda,     Niv,         Sector_id,
         Sucursal_id, Region_id,  Descrip,     SAnt,
         Car,         Abo,        SAct,        FecCap,
         CarProceso,  AboProceso, SAntProceso, CarExt,
         AboExt,      SProm,      SPromAnt,    SProm2,
         SProm2Ant,   ejercicio,  mes)
         Select Llave,       Moneda,     Niv,           Sector_id,
                Sucursal_id, Region_id,  ' ' Descrip,   0 SAnt,
                Car,         Abo,        0 SAct,        @w_fechaCaptura FecCap,
                CarProceso,  AboProceso, 0 SAntProceso, 0 CarExt,
                0 AboExt,    0 SProm,    0 SPromAnt,    0 SProm2,
                0 SProm2Ant, @PnAnio,    @PnMes
         From   #TempCatalogoAux a
         Where  Not Exists ( Select Top 1 1
                             From   dbo.CatalogoAuxiliar With (Nolock)
                             Where  ejercicio   = a.ejercicio
                             And    mes         = a.mes
                             And    llave       = a.llave
                             And    moneda      = a.moneda
                             And    Sucursal_id = a.Sucursal_id
                             And    Region_id   = a.Region_id)


         Update dbo.CatalogoAuxiliar
         Set    car        = (Select Sum(b.car)
                              From   dbo.CatalogoAuxiliar b With (Nolock)
                              Where  b.llave        = a.llave
                              And    b.moneda       = a.moneda
                              And    b.ejercicio    = a.ejercicio
                              And    b.mes          = a.mes
                              And    b.Sucursal_id != 0),                            
                abo        = (Select Sum(b.Abo)
                              From   dbo.CatalogoAuxiliar b With (Nolock)
                              Where  b.llave        = a.llave
                              And    b.moneda       = a.moneda
                              And    b.ejercicio    = a.ejercicio
                              And    b.mes          = a.mes
                              And    b.Sucursal_id != 0)   
         From   dbo.CatalogoAuxiliar      a With (Nolock index(catalogoAuxiliarIdx01))
         Where  a.ejercicio    = @PnAnio
         And    a.mes          = @PnMes
         And    a.Sucursal_id  = 0;
         

         Insert Into dbo.CatalogoAuxiliar
        (Llave,       Moneda,     Niv,         Sector_id,
         Sucursal_id, Region_id,  Descrip,     SAnt,
         Car,         Abo,        SAct,        FecCap,
         CarProceso,  AboProceso, SAntProceso, CarExt,
         AboExt,      SProm,      SPromAnt,    SProm2,
         SProm2Ant,   ejercicio,  mes)
         Select Llave,         Moneda,       Niv,           '00' Sector_id,
                0 Sucursal_id, 0 Region_id,  Max(Descrip),  Sum(SAnt),
                Sum(Car),         Sum(Abo),        Sum(SAct),        @w_fechaCaptura FecCap,
                Sum(CarProceso),  Sum(AboProceso), Sum(SAntProceso), Sum(carExt),
                Sum(AboExt),      Sum(SProm),      Sum(SPromAnt),    Sum(SProm2),
                Sum(SProm2Ant),   @PnAnio,    @PnMes
         From   dbo.CatalogoAuxiliar      a With (Nolock index(catalogoAuxiliarIdx01))
         Where  a.ejercicio     = @PnAnio
         And    a.mes           = @PnMes
         And    a.Sucursal_id  != 0
         And    Not Exists      ( Select Top 1 1
                                  From   dbo.CatalogoAuxiliar      b With (Nolock index(catalogoAuxiliarIdx01))
                                  Where  b.ejercicio    = a.ejercicio
                                  And    b.mes          = a.mes
					              And    b.llave        = a.llave
                                  And    b.Sucursal_id  = 0)
         Group By Llave, Moneda, Niv;

                  
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

      Begin Try
         Delete dbo.CatalogoAuxiliar
         Where  ejercicio = @PnAnio
         And    mes       = @PnMes
         And    Sant      = 0
         And    car       = 0
         And    Abo       = 0
         And    Sact      = 0;
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
         Update dbo.CatalogoAuxiliar
         Set    Descrip = b.Descripcion
         From   dbo.CatalogoAuxiliar a
         Join   dbo.CatalogoConsolidado b
         On     b.numerodecuenta = a.llave
         And    b.moneda_id      = a.moneda
         Where  a.ejercicio      = @PnAnio
         And    a.mes            = @PnMes
         And    a.descrip        = '';
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
-- Depuración del Cabecero de los movimientos contables
--

      If Exists ( Select Top 1 1
                  From   dbo.PolizaAnio With (Nolock)
                  Where  ejercicio = @PnAnio
                  And    mes       = @PnMes)
         Begin
            Begin Try
               Delete dbo.MovimientosAnio
               Where  ejercicio = @PnAnio
               And    mes       = @PnMes;

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
