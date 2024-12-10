/*

-- Declare
   -- @PnAnio                Smallint            = 2023,
   -- @PnMes                 Tinyint             = 13,
   -- @PnEstatus             Integer             = 0,
   -- @PsMensaje             Varchar( 250)       = ' ' ;
-- Begin

   -- Execute dbo.Spp_AjustaSaldosMes @PnAnio      = @PnAnio,
                                   -- @PnMes       = @PnMes,
                                   -- @PnEstatus   = @PnEstatus Output,
                                   -- @PsMensaje   = @PsMensaje Output;

   -- Select @PnEstatus, @PsMensaje
   -- Return
-- End
-- Go

--

-- Objeto:        Spp_AjustaSaldosMes.
-- Objetivo:      Ajusta los saldos contables posterior al cierre.
-- Fecha:         04/11/2024
-- Programador:   Pedro Zambrano
-- Versión:       1


*/

Create Or Alter Procedure Spp_AjustaSaldosMes
  (@PnAnio                Smallint,
   @PnMes                 Tinyint,
   @PsUsuario             Varchar( 20)        = Null,
   @PnEstatus             Integer             = 0      Output,
   @PsMensaje             Varchar( 250)       = ' '    Output)
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
   @w_comilla           Char(1),
   @w_sucursable        Tinyint,
   @w_anio              Smallint,
   @w_mes               Tinyint,
   @w_anioProc          Smallint,
   @w_mesProc           Tinyint,
   @w_mesMin            Tinyint,
   @w_mesMax            Tinyint,
   @w_perAnt            Bit,
   @w_registros         Integer,
   @w_regCat            Integer,
   @w_regCatAux         Integer,
   @w_registro          Integer,
   @w_secuencia         Integer,
   @w_secCat            Integer,
   @w_secCatAux         Integer,
   @w_Sector_id         Integer,
   @w_Sucursal_id       Integer,
   @w_Region_id         Integer,
   @w_idAuxiliar        Smallint,
   @w_tabla             Sysname,
   @w_Llave             Varchar(20),
   @w_Moneda            Varchar( 2),
   @w_scta              Varchar(    4),
   @w_Car               Decimal(18, 2),
   @w_Abo               Decimal(18, 2);

Begin
   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off

   Select @PnEstatus         = 0,
          @PsMensaje         = Null,
          @w_operacion       = 9999,
          @w_perAnt          = 0,
          @w_registros       = 0,
          @w_regCat          = 0,
          @w_regCatAux       = 0,
          @w_secuencia       = 0,
          @w_secCat          = 0,
          @w_secCatAux       = 0,
          @w_anio            = @PnAnio,
          @w_mes             = @PnMes,
          @w_tabla           = 'CatalogoAuxiliar',
          @w_fechaCaptura    = Getdate(),
          @w_sucursable      = Isnull(dbo.Fn_BuscaResultadosParametros(12, 'valor'), 0);

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
         Set @w_usuario = @PsUsuario;
      End

--
-- Se obtiene la cuenta auxiliar de resultados.
--

   Select @w_idAuxiliar = parametroNumber
   From   dbo.conParametrosGralesTbl With (Nolock)
   Where  idParametroGral = 8;

   Select @w_llave = CuentaInterna
   From   dbo.Cuentas_predeterminadas With (Nolock)
   Where  id = @w_idAuxiliar;


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

   If @w_idEstatus = 0
      Begin
         Select @PnEstatus  = 8022,
                @PsMensaje =  'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

         Set Xact_Abort Off
         Return
      End

   If @w_idEstatus = 2
      Begin
         Select @w_perAnt   = 1,
                @w_tabla    = 'CatalogoAuxiliarHist'
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

   Select @w_mesMin = Min(Valor),
          @w_mesMax = Max(Valor)
   From   dbo.catCriteriosTbl Whith (Nolock)
   Where  criterio = 'mes'

   Select @w_anioProc = ejercicio,
          @w_mesProc  = mes
   From   dbo.control With (Nolock)
   Where  idEstatus = 1
   If @@Rowcount = 0
      Begin
         Select @PnEstatus  = 8024,
                @PsMensaje =  'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

         Set Xact_Abort Off
         Return
      End

   If Not Exists ( Select Top  1 1
                   From   dbo.polizaAnio a With (Nolock)
                   Where  ejercicio  = @PnAnio
                   And    mes        = @PnMes)
      Begin
         Select @PnEstatus  = 138,
                @PsMensaje =  'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

         Set Xact_Abort Off
         Return
      End

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
   Ejercicio    Smallint       Not Null,
   mes          Tinyint        Not Null,
   Index TempCatalogoIdx01 Unique (ejercicio, mes, Niv, llave, moneda));

  Create Table #TempCatalogoAux
  (Secuencia    Integer        Not Null Identity(1, 1) Primary key,
   Llave        Varchar(20)    Not Null,
   Moneda       Varchar(20)    Not Null,
   Niv          Smallint       Not Null,
   Sector_id    Integer        Not Null,
   Sucursal_id  Integer        Not Null,
   Region_id    Integer        Not Null,
   Car          Decimal(18, 2) Not Null,
   Abo          Decimal(18, 2) Not Null,
   Ejercicio    Smallint       Not Null,
   mes          Tinyint        Not Null,
   Index TempCatalogoAuxIdx01 Unique (ejercicio, mes, Niv, llave, moneda, Sector_id,
         Sucursal_id, Region_id));

   Create Table #TempPeriodos
  (secuencia      Integer Not Null Identity (1, 1) Primary Key,
   ejercicio      Integer Not Null,
   mes            Integer Not Null);

   Create Table #TempCuentasResult
  (secuencia      Integer    Not Null Identity (1, 1) Primary Key,
   cuenta         Varchar(4) Not Null)

--
-- Inicio de proceso
--

--
-- Consulta las cuentas de Resultados
--

   Insert #TempCuentasResult
  (cuenta)
   Select Substring(c.llave, 1, 4)
   From   dbo.Rangos a With (NolocK)
   Join   dbo.SubRangos b
   On     b.Rango_id = a.Rango_id
   Join   dbo.Catalogo c
   On     Substring(c.llave, 1, 4) Between b.Llave_final And b.Llave_final
   Where  a.Naturaleza_id In ('IN', 'EG')
   And    c.ejercicio = @PnAnio
   Group  By Substring(c.llave, 1, 4);

--
-- Buscar los periodos a actualizar.
--

   While @w_anio <= @w_anioProc
   Begin
      While @w_mes <= @w_mesMax
      Begin
         Insert Into #TempPeriodos
         (ejercicio, mes)
         Select @w_anio, @w_mes

         Select @w_registros = @w_registros + 1,
                @w_mes       = @w_mes + 1;

         If @w_anio = @w_anioProc And
            @w_mes  = @w_mesProc
            Begin
               Break
            End

      End

      Select @w_anio = @w_anio + 1,
             @w_mes  = @w_mesMin;

   End

--
-- Consulta a los movimientos de ajustes.
--

   Insert Into  #TempCatalogo
  (Llave, Moneda,      Niv,          Car,
   Abo,   ejercicio,   mes)
   Select a.Llave, a.moneda, 1 Niv,
          Sum(Case When Clave = 'C'
                   Then Importe
                   Else 0
              End),
          Sum(Case When Clave = 'A'
                   Then Importe
                   Else 0
              End), a.ejercicio, a.mes
   From   dbo.MovimientosAnio   a With (Nolock)
   Where  a.ejercicio      = @PnAnio
   And    a.mes            = @PnMes
   Group  By  a.Llave, a.moneda, a.ejercicio, a.mes;
   Set @w_regCat = @@Rowcount

   Begin Try
      Insert Into  #TempCatalogo
     (Llave, Moneda,      Niv,          Car,
      Abo,   ejercicio,   mes)
      Select Concat(Substring(a.llave, 1, 12), Replicate(0, 4)), a.Moneda, 2 Niv, Sum(a.car),
             Sum(a.Abo),      a.ejercicio, a.mes
      From   #TempCatalogo a
      Where  a.ejercicio = @PnAnio
      And    a.mes       = @PnMes
      And    a.Niv       = 1
      Group  By Substring(a.llave, 1, 12), a.Moneda, a.ejercicio, a.mes
      Union
      Select Concat(Substring(a.llave, 1, 10), Replicate(0, 6)), a.Moneda, 3 Niv, Sum(a.car),
             Sum(a.Abo),      a.ejercicio, a.mes
      From   #TempCatalogo a
      Where  a.ejercicio   = @PnAnio
      And    a.mes         = @PnMes
      And    a.Niv         = 1
      Group  By Substring(a.llave, 1, 10), a.Moneda, a.ejercicio, a.mes
      Union
      Select Concat(Substring(a.llave, 1, 8), Replicate(0, 8)), a.Moneda, 4 Niv, Sum(a.car),
             Sum(a.Abo), a.ejercicio, a.mes
      From   #TempCatalogo a
      Where  a.ejercicio    = @PnAnio
      And    a.mes          = @PnMes
      And    a.Niv          = 1
      Group  By Substring(a.llave, 1, 8), a.Moneda, a.ejercicio, a.mes
      Union
      Select Concat(Substring(a.llave, 1, 6), Replicate(0, 10)), a.Moneda, 5 Niv, Sum(a.car),
             Sum(a.Abo),      a.ejercicio, a.mes
      From   #TempCatalogo a
      Where  a.ejercicio     = @PnAnio
      And    a.mes           = @PnMes
      And    a.Niv           = 1
      Group  By Substring(a.llave, 1, 6), a.Moneda, a.ejercicio, a.mes
      Union
      Select Concat(Substring(a.llave, 1, 4), Replicate(0, 12)), a.Moneda, 6 Niv, Sum(a.car),
             Sum(a.Abo),      a.ejercicio, a.mes
      From   #TempCatalogo a
      Where  a.ejercicio     = @PnAnio
      And    a.mes           = @PnMes
      And    a.Niv           = 1
      Group  By Substring(a.llave, 1, 4), a.Moneda, a.ejercicio, a.mes
      Union
      Select Concat(Substring(a.llave, 1, 2), Replicate(0, 14)), a.Moneda, 7 Niv, Sum(a.car),
             Sum(a.Abo), a.ejercicio, a.mes
      From   #TempCatalogo a
      Where  a.ejercicio     = @PnAnio
      And    a.mes           = @PnMes
      And    a.Niv           = 1
      Group  By Substring(a.llave, 1, 2), a.Moneda, a.ejercicio, a.mes
      Union
      Select Concat(Substring(a.llave, 1, 1), Replicate(0, 15)), a.Moneda, 8 Niv, Sum(a.car),
             Sum(a.Abo),      a.ejercicio, a.mes
      From   #TempCatalogo a
      Where  a.ejercicio     = @PnAnio
      And    a.mes           = @PnMes
      And    a.Niv           = 1
      Group  By Substring(a.llave, 1, 1), a.Moneda, a.ejercicio, a.mes
      Set @w_regCat = @w_regCat + @@Rowcount

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

   If @w_sucursable = 2
      Begin
         Insert Into  #TempCatalogoAux
        (Llave,     Moneda, Niv,  Sector_id, Sucursal_id,
         Region_id, Car,    Abo,  ejercicio, mes)
         Select a.Llave, a.moneda, 1 Niv, Sector_id, Sucursal_id,
                Region_id,
                Sum(Case When Clave = 'C'
                         Then Importe
                         Else 0
                    End),
                Sum(Case When Clave = 'A'
                         Then Importe
                         Else 0
                    End), a.ejercicio, a.mes
         From   dbo.MovimientosAnio   a With (Nolock)
         Where  a.ejercicio      = @PnAnio
         And    a.mes            = @PnMes
         Group  By a.Llave, a.moneda,    Sector_id, Sucursal_id,
                Region_id,  a.ejercicio, a.mes;

         Set    @w_regCatAux =  @@Rowcount

      Begin Try
         Insert Into  #TempCatalogoAux
        (Llave,       Moneda,     Niv,       Sector_id,
         Sucursal_id, Region_id,  Car,       Abo,
         ejercicio, mes)
         Select Concat(Substring(a.llave, 1, 12), Replicate(0, 4)), a.Moneda, 2 Niv, a.Sector_id,
                a.Sucursal_id, a.Region_id,       Sum(a.car),       Sum(a.Abo),
                a.ejercicio,   a.mes
         From   #TempCatalogoAux       a
         Where  a.ejercicio      = @PnAnio
         And    a.mes            = @PnMes
         And    a.Niv            = 1
         Group  By Substring(a.llave, 1, 12), a.Moneda,    a.Sector_id,
                a.Sucursal_id, a.Region_id,   a.ejercicio, a.mes
         Union
         Select Concat(Substring(a.llave, 1, 10), Replicate(0, 6)), a.Moneda, 3 Niv, a.Sector_id,
                a.Sucursal_id, a.Region_id,       Sum(a.car),       Sum(a.Abo),
                a.ejercicio,   a.mes
         From   #TempCatalogoAux     a
         Where  a.ejercicio      = @PnAnio
         And    a.mes            = @PnMes
         And    a.Niv            = 1
         Group  By Substring(a.llave, 1, 10), a.Moneda, a.Sector_id,
                a.Sucursal_id, a.Region_id, a.ejercicio, a.mes
         Union
         Select Concat(Substring(a.llave, 1, 8), Replicate(0, 8)), a.Moneda, 4 Niv, a.Sector_id,
                a.Sucursal_id, a.Region_id,       Sum(a.car),       Sum(a.Abo),
                a.ejercicio,   a.mes
         From   #TempCatalogoAux        a
         Where  a.ejercicio             = @PnAnio
         And    a.mes                   = @PnMes
         And    a.Niv                   = 1
         Group  By Substring(a.llave, 1, 8), a.Moneda,    a.Sector_id,
                a.Sucursal_id, a.Region_id,      a.ejercicio, a.mes
         Union
         Select Concat(Substring(a.llave, 1, 6), Replicate(0, 10)), a.Moneda, 5 Niv, a.Sector_id,
                a.Sucursal_id, a.Region_id,      Sum(a.car),        Sum(a.Abo),
                a.ejercicio,   a.mes
         From   #TempCatalogoAux         a
         Where  a.ejercicio             = @PnAnio
         And    a.mes                   = @PnMes
         And    a.Niv                   = 1
         Group  By Substring(a.llave, 1, 6), a.Moneda, a.Sector_id,
                a.Sucursal_id, a.Region_id, a.ejercicio, a.mes
         Union
         Select Concat(Substring(a.llave, 1, 4), Replicate(0, 12)), a.Moneda, 6 Niv, a.Sector_id,
                a.Sucursal_id, a.Region_id,      Sum(a.car),        Sum(a.Abo),
                a.ejercicio,   a.mes
         From   #TempCatalogoAux      a
         Where  a.ejercicio             = @PnAnio
         And    a.mes                   = @PnMes
         And    a.Niv                   = 1
         Group  By Substring(a.llave, 1, 4), a.Moneda, a.Sector_id,
                a.Sucursal_id, a.Region_id, a.ejercicio, a.mes
         Union
         Select Concat(Substring(a.llave, 1, 2), Replicate(0, 14)), a.Moneda, 7 Niv, a.Sector_id,
                a.Sucursal_id, a.Region_id,      Sum(a.car),        Sum(a.Abo),
                a.ejercicio,   a.mes
         From   #TempCatalogoAux     a
         Where  a.ejercicio             = @PnAnio
         And    a.mes                   = @PnMes
         And    a.Niv                   = 1
         Group  By Substring(a.llave, 1, 2), a.Moneda,    a.Sector_id,
                a.Sucursal_id, a.Region_id,  a.ejercicio, a.mes
         Union
         Select Concat(Substring(a.llave, 1, 1), Replicate(0, 15)), a.Moneda, 8 Niv, a.Sector_id,
                a.Sucursal_id, a.Region_id,      Sum(a.car),        Sum(a.Abo),
                a.ejercicio,   a.mes
         From   #TempCatalogoAux      a
         Where  a.ejercicio             = @PnAnio
         And    a.mes                   = @PnMes
         And    a.Niv                   = 1
         Group  By Substring(a.llave, 1, 1), a.Moneda,   a.Sector_id,
                a.Sucursal_id, a.Region_id, a.ejercicio, a.mes

         Set    @w_regCatAux = @w_regCatAux + @@Rowcount
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

      End

   Begin Transaction
      If @w_perAnt = 1
         Begin

--
-- Traspaso de Polizas Anio a Poliza.
--

            Begin Try
               Insert Into dbo.PolizaHist
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
                                   From   dbo.PolizaHist With (Nolock)
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
               Insert Into dbo.MovimientosHist
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
                                   From   dbo.MovimientosHist With (Nolock Index (IX_FK_MovimientosHistFk01))
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

         End
      Else
         Begin

--
-- Traspaso de Polizas Anio a Poliza.
--

            Begin Try
               Insert Into dbo.Poliza
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
                                   From   dbo.Poliza With (Nolock)
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
               Insert Into dbo.Movimientos
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
                                   From   dbo.Movimientos With (Nolock Index (PK_Movimientos))
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

         End

      While  @w_secuencia < @w_registros
      Begin
         Set @w_secuencia = @w_secuencia + 1
         Select @w_anioProc = ejercicio,
                @w_mesProc  = mes
         From   #TempPeriodos
         Where  secuencia = @w_secuencia
         If @@Rowcount = 0
            Begin
               Break
            End


         Set @w_secCat = 0
         While @w_secCat < @w_regCat
         Begin
            Set @w_secCat = @w_secCat + 1
            Select @w_Llave  = Llave,
                   @w_Moneda = moneda,
                   @w_Car    = car,
                   @w_Abo    = abo
            From   #TempCatalogo
            Where secuencia = @w_secCat;
            If @@Rowcount = 0
               Begin
                  Break
               End

            If Not Exists ( Select Top 1 1
                            From   dbo.Catalogo With (Nolock)
                            Where  ejercicio = @w_anioProc
                            And    mes       = @w_mesProc
                            And    llave     = @w_Llave
                            And    moneda    = @w_moneda)
               Begin
                  Rollback Transaction

                  Select @PnEstatus = @w_error,
                         @PsMensaje = Concat('Error.: La cuenta contable ', @w_llave, ' No existe en Catalogos para el períoodo; ', @w_anioProc, '-', Format(@w_mesProc, '00'));

                  Set Xact_Abort Off
                  Goto Salida
               End

            If Exists (Select Top 1 1
	                   From   #TempCuentasResult
                       Where  cuenta = Substring(@w_Llave, 1, 4))
               Begin
                  Goto Siguiente
               End


            If @PnAnio = @w_anioProc And
               @PnMes  = @w_mesProc
               Begin
                  Begin Try
                     Update dbo.catalogo
                     Set    Car  = Car  + @w_Car,
                            Abo  = Abo  + @w_Abo,
                            SAct = SAnt + (Car + @w_Car) - (Abo + @w_Abo)
                     Where  ejercicio = @w_anioProc
                     And    mes       = @w_mesProc
                     And    llave     = @w_Llave
                     And    moneda    = @w_moneda;
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
            Else
               Begin
                  Begin Try
                     Update dbo.catalogo
                     Set    SAnt = SAnt + @w_Car - @w_Abo,
                            SAct = SAct + @w_Car - @w_Abo
                     Where  ejercicio = @w_anioProc
                     And    mes       = @w_mesProc
                     And    llave     = @w_Llave
                     And    moneda    = @w_moneda;
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

         End

         If @w_sucursable != 2
            Begin
               Goto Siguiente;
            End

         Set @w_secCatAux = 0
         While @w_secCatAux < @w_regCatAux
         Begin
            Set @w_secCatAux      = @w_secCatAux + 1
            Select @w_Llave       = Llave,
                   @w_Moneda      = moneda,
                   @w_Sector_id   = Sector_id,
                   @w_sucursal_id = Sucursal_id,
                   @w_Region_id   = Region_id,
                   @w_Car         = car,
                   @w_Abo         = abo
            From   #TempCatalogoAux
            Where secuencia = @w_secCat;
            If @@Rowcount = 0
               Begin
                  Break
               End

            If @w_perAnt = 0
               Begin
                  If Exists (Select Top 1 1
	                         From   #TempCuentasResult
                             Where  cuenta = Substring(@w_Llave, 1, 4))
                     Begin
                        Goto Siguiente
                     End

                  If Not Exists ( Select Top 1 1
                                  From   dbo.CatalogoAuxiliar With (Nolock)
                                  Where  ejercicio   = @w_anioProc
                                  And    mes         = @w_mesProc
                                  And    llave       = @w_Llave
                                  And    moneda      = @w_moneda
                                  And    Sector_id   = @w_Sector_id
                                  And    Sucursal_id = @w_sucursal_id
                                  And    Region_id   = @w_Region_id)
                     Begin
                        Rollback Transaction

                        Select @PnEstatus = 9999,
                               @PsMensaje = Concat('Error.: La cuenta contable ', @w_llave, ' No existe en Catalogos Históricos para el períoodo; ', @w_anioProc, '-', Format(@w_mesProc, '00'));

                        Set Xact_Abort Off
                        Goto Salida
                     End


                  If @PnAnio = @w_anio And
                     @PnMes  = @w_mes
                     Begin
                        Begin Try
                           Update dbo.CatalogoAuxiliar
                           Set    Car  = Car  + @w_Car,
                                  Abo  = Abo  + @w_Abo,
                                  SAct = SAnt + (Car + @w_Car) - (Abo + @w_Abo)
                           Where  ejercicio   = @w_anioProc
                           And    mes         = @w_mesProc
                           And    llave       = @w_Llave
                           And    moneda      = @w_moneda
                           And    Sector_id   = @w_Sector_id
                           And    Sucursal_id = @w_sucursal_id
                           And    Region_id   = @w_Region_id;
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
                  Else
                     Begin
                        Begin Try
                           Update dbo.CatalogoAuxiliar
                           Set    SAnt = SAnt + @w_Car - @w_Abo,
                                  SAct = SAct + @w_Car - @w_Abo
                           Where  ejercicio   = @w_anioProc
                           And    mes         = @w_mesProc
                           And    llave       = @w_Llave
                           And    moneda      = @w_moneda
                           And    Sector_id   = @w_Sector_id
                           And    Sucursal_id = @w_sucursal_id
                           And    Region_id   = @w_Region_id;
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
               End
            Else
               Begin
                  If Exists (Select Top 1 1
	                         From   #TempCuentasResult
                             Where  cuenta = Substring(@w_Llave, 1, 4))
                     Begin
                        Goto Siguiente
                     End

                  If Not Exists ( Select Top 1 1
                                  From   dbo.CatalogoAuxiliarHist With (Nolock)
                                  Where  ejercicio   = @w_anioProc
                                  And    mes         = @w_mesProc
                                  And    llave       = @w_Llave
                                  And    moneda      = @w_moneda
                                  And    Sector_id   = @w_Sector_id
                                  And    Sucursal_id = @w_sucursal_id
                                  And    Region_id   = @w_Region_id)
                     Begin
                        Rollback Transaction

                        Select @PnEstatus = 9998,
                               @PsMensaje = Concat('Error.: La cuenta contable ', @w_llave, ' No existe en Catalogos Históricos para el períoodo; ', @w_anioProc, '-', Format(@w_mesProc, '00'));

                        Set Xact_Abort Off
                        Goto Salida
                     End


                  If @PnAnio = @w_anio And
                     @PnMes  = @w_mes
                     Begin
                        Begin Try
                           Update dbo.CatalogoAuxiliarHist
                           Set    Car  = Car  + @w_Car,
                                  Abo  = Abo  + @w_Abo,
                                  SAct = SAnt + (Car + @w_Car) - (Abo + @w_Abo)
                           Where  ejercicio   = @w_anioProc
                           And    mes         = @w_mesProc
                           And    llave       = @w_Llave
                           And    moneda      = @w_moneda
                           And    Sector_id   = @w_Sector_id
                           And    Sucursal_id = @w_sucursal_id
                           And    Region_id   = @w_Region_id;
                           Select @@Rowcount Hist
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
                  Else
                     Begin
                        Begin Try
                           Update dbo.CatalogoAuxiliarHist
                           Set    SAnt = SAnt + @w_Car - @w_Abo,
                                  SAct = SAct + @w_Car - @w_Abo
                           Where  ejercicio   = @w_anioProc
                           And    mes         = @w_mesProc
                           And    llave       = @w_Llave
                           And    moneda      = @w_moneda
                           And    Sector_id   = @w_Sector_id
                           And    Sucursal_id = @w_sucursal_id
                           And    Region_id   = @w_Region_id;
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
               End

         End

Siguiente:

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

Salida:

   Set Xact_Abort Off
   Return

End
Go

--
-- Comentarios.
--

Declare
   @w_valor          Varchar(1500) = 'Ajusta los saldos contables posterior al cierre',
   @w_procedimiento  Varchar( 100) = 'Spp_AjustaSaldosMes'


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
