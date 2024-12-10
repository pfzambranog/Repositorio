/*
-- Declare
   -- @PdFechaInicial       Date         = '2024-12-01',
   -- @PdFechaFinal         Date         = '2024-12-31',
   -- @PnEjercicio          Smallint     = 2024,
   -- @PnMes                Tinyint      = 13,
   -- @PsReferencia         Varchar( 20) = 'PDI00001',
   -- @PdFechaMov           Date         = '2024-12-31',
   -- @PnConsulta           Tinyint      = 3,
   -- @PnSalida             Tinyint      = 1,
   -- @PnEstatus            Integer      = 0,
   -- @PsMensaje            Varchar(250) = Null

-- Begin
   -- Execute dbo.Spc_cifrasCargosAbonos @PdFechaInicial = @PdFechaInicial,
                                      -- @PdFechaFinal   = @PdFechaFinal,
                                      -- @PnEjercicio    = @Pnejercicio,
                                      -- @PnMes          = @PnMes,
                                      -- @PsReferencia   = @PsReferencia,
                                      -- @PdFechaMov     = @PdFechaMov,
                                      -- @PnConsulta     = @PnConsulta,
                                      -- @PnSalida       = @PnSalida,
                                      -- @PnEstatus      = @PnEstatus    Output,
                                      -- @PsMensaje      = @PsMensaje    Output;
   -- If @PnEstatus != 0
      -- Begin
         -- Select @PnEstatus, @PsMensaje
      -- End

   -- Return;

-- End
-- Go


-- Version:     V1
-- Fecha:       09-Agosto-2024
-- Programador: Pedro Zambrano.
-- Objetivo:    Realizar consultas para la pantalla de cargos y abonos.
--

*/


Create Or Alter Procedure dbo.Spc_cifrasCargosAbonos
  (@PdFechaInicial       Date,
   @PdFechaFinal         Date,
   @PnEjercicio          Smallint     = Null,
   @PnMes                Tinyint      = Null,
   @PsReferencia         Varchar( 20) = Null,
   @PdFechaMov           Date         = Null,
   @PnConsulta           Tinyint      = 1,          -- 1 = Totales. 2 = Polizas Descuadradas, 3 = detalle de póliza,  4 = Emisión de Reporte de errores, 5 = Actualización.
   @PnSalida             Tinyint      = 1,          -- 1 = Tipo Tabla. 2 = Json
   @PnEstatus            Integer      = 0    Output,
   @PsMensaje            Varchar(250) = Null Output)
As

Declare
   @w_desc_error                         Varchar ( 250),
   @w_Error                              Integer,
   @w_linea                              Integer,
   @w_valodaCC                           Tinyint,
   @w_sql                                Nvarchar(1500),
   @w_param                              NVarchar( 750),
   @w_comilla                            Char(1),
   @w_guion                              Char(1),
   @w_usuario                            Varchar (  10),
   @w_anio                               Smallint,
   @w_length                             Smallint,
   @w_mes                                Tinyint,
   @w_operacion                          Integer,
   @w_idUsuarioAct                       Integer,
   @w_registros                          Integer,
   @w_mesAnioInicio                      Integer,
   @w_mesAnioFin                         Integer,
   @w_TotCar                             Decimal (18, 2),
   @w_TotAbo                             Decimal (18, 2),
   @w_diferencia                         Decimal (18, 2),
   @w_lang                               Varchar( 20),
   @w_mesProc                            Varchar(  3),
   @w_mensaje                            Varchar(750),
   @w_condicion                          Varchar(500),
   @w_insertErrores                      Varchar(Max),
   @w_tablaErrores                       Sysname;

Begin
   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off

--
-- Inicialización de Variables.
--

   Select @PnEstatus             = 0,
          @PsMensaje             = Null,
          @w_operacion           = 9999,
          @w_registros           = 0,
          @w_comilla             = Char(39),
          @w_guion               = Char(45),
          @w_lang                = @@language,
          @w_mes                 = Isnull(@PnMes,       DatePart(mm, @PdFechaInicial)),
          @w_anio                = Isnull(@PnEjercicio, DatePart(yy, @PdFechaInicial)),
          @w_mesAnioInicio       = Cast(Format(@PdFechaInicial, 'yyyyMM') As Integer),
          @w_mesAnioFin          = Cast(Format(@PdFechaFinal,   'yyyyMM') As Integer),
          @w_valodaCC            = dbo.Fn_BuscaResultadosParametros(209, 'Valor'),
          @w_length              = dbo.Fn_BuscaResultadosParametros(351, 'Valor'),
          @w_mesProc             = dbo.Fn_BuscaMes(@w_mes),
          @w_tablaErrores        = 'MovimientosErrores',
          @w_insertErrores       = Concat('Insert into dbo.', @w_tablaErrores,
                                    ' (ejercicio,   mes,       Referencia, Fecha_mov,
                                       Concepto,    Moneda,    Llave,      Importe,
                                       Clave,       Cons,      Documento,  Sector_id,
                                       Sucursal_id, Region_id, FecCap,     Mens_Error,
                                       idError)'),
          @w_condicion           = ' And  Cast(p.Fecha_mov As Date) Between ' + @w_comilla + Cast(@PdFechaInicial As Varchar) + @w_comilla + ' ' +
                                                                      ' And ' + @w_comilla + Cast(@PdFechaFinal   As Varchar) + @w_comilla;


--
-- Validación del tipo de consulta.
--

   If Isnull(@PnConsulta, 0) Not Between 1 And 5
      Begin
         Select @PnEstatus = 8171,
                @PsMensaje =  'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

         Set Xact_Abort Off
         Return
      End

--
-- Validación de los Parámetros de Fecha.
--

   If @PdFechaInicial Is Null Or
      @PdFechaFinal   Is Null
      Begin
         Select @PnEstatus = 8160,
                @PsMensaje = 'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

         Set Xact_Abort    Off
         Return
      End

   If @PdFechaInicial > @PdFechaFinal
      Begin
         Select @PnEstatus = 8161,
                @PsMensaje = 'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

         Set Xact_Abort    Off
         Return
      End

   If @w_mesAnioInicio != @w_mesAnioFin
      Begin
         Select @PnEstatus = 8162,
                @PsMensaje = 'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

         Set Xact_Abort    Off
         Return
      End

--
-- Validación de los Parámetros de la Póliza.
--

   If @PnConsulta = 3
      Begin
         If @PsReferencia Is Null Or
            @PdFechaMov   Is Null
            Begin
               Select @PnEstatus = 8162,
                      @PsMensaje = 'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

               Set Xact_Abort    Off
               Return
            End
      End


--
-- Inicio de Proceso
--

--
-- Creación de tablas Temporales.
--

   Create Table #TotalPeriodo
   (secuencia    Integer         Not Null Identity (1, 1) Primary Key,
    totCar       Decimal (18, 2) Not Null Default 0.00,
    totAbo       Decimal (18, 2) Not Null Default 0.00,
    diferencia   Decimal (18, 2) Not Null Default 0.00)

   Create Table #tempCuentas
   (secuencia    Integer     Not Null Identity (1, 1) Primary Key,
    tipoCuenta   Char(1)     Not Null Default 'D',
    Llave        Varchar(20)     Null,
    Moneda       Varchar( 2)     Null,
    Sucursal_id  Integer         Null Default 0,
    Region_id    Integer         Null,
    Index tempCuentasIdx01 (tipoCuenta, Llave, Moneda, Sucursal_id, Region_id));

   Create Table #TempCuentasInexistentes
  (secuencia    Integer     Not Null Identity (1, 1) Primary Key,
   Llave        Varchar(20)     Null,
   Moneda       Varchar( 2)     Null,
   Sucursal_id  Integer         Null Default 0,
   Region_id    Integer         Null,
   Index tempCuentasIdx01 (Llave));

--
-- Búsqueda de Totales del Período por Aplicar.
--

   Insert Into #TotalPeriodo
  (totCar, TotAbo)
   Select Isnull(Sum(Case When m.Clave = 'C'
                     Then m.Importe
                     Else 0
                 End), 0),
          Isnull(Sum(Case When m.Clave = 'A'
                         Then m.Importe
                         Else 0
                     End), 0)
   From   dbo.movimientosAnio m With (Nolock)
   Join   dbo.PolizaAnio      p With (Nolock)
   On     p.referencia = m.referencia
   And    p.fecha_mov  = m.fecha_mov
   And    p.ejercicio  = m.ejercicio
   And    p.mes        = m.mes
   Where  Cast(p.fecha_mov As Date) Between @PdFechaInicial  And @PdFechaFinal
   And    p.ejercicio  = @w_anio
   And    p.mes        = @w_mes;
   Set @w_registros = @@Rowcount

   If  @w_registros = 0
      Begin
         Select @PnEstatus = 8172,
                @PsMensaje = 'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

         Set Xact_Abort    Off
         Return
      End

   Update #TotalPeriodo
   Set    Diferencia = TotCar - TotAbo;

   Select @w_TotCar     = totCar,
          @w_TotAbo     = totAbo,
          @w_diferencia = diferencia
   From   #TotalPeriodo;

   Set @w_diferencia = Isnull(@w_TotCar, 0) - Isnull(@w_TotAbo, 0)

   If @PnConsulta = 1
      Begin
         Select Isnull(@w_TotCar, 0) Cargo, Isnull(@w_TotAbo, 0) Abono, @w_diferencia Diferencia;

         If @w_diferencia != 0
            Begin
               Select @PnEstatus = 8163,
                      @PsMensaje = 'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))
            End

         Set Xact_Abort    Off
         Return
      End


   If @PnConsulta = 2
      Begin
         If @w_diferencia = 0
            Begin
               Select @PnEstatus = 8166,
                      @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus);

               Set Xact_Abort    Off
               Return
            End

         Set @w_sql = 'Select p.referencia, p.fecha_mov, m.concepto, Sum(m.Importe_Cargo) Cargo,
                              Sum(m.Importe_Abono) Abono,
                              Sum(Abs(m.Importe_Cargo) - Abs(m.Importe_Abono)) Diferencia, p.usuario, p.fuenteDatos ' +
                      'From   dbo.movimientosAnio m With (Nolock) ' +
                      'Join   dbo.polizaAnio      p With (Nolock) ';

         Set @w_sql =  @w_sql + 'On     p.referencia = m.referencia
                                 And    p.fecha_mov  = m.fecha_mov
                                 And    p.ejercicio  = m.ejercicio
                                 And    p.mes        = m.mes
                                 Where  p.ejercicio  = ' + Cast(@w_anio As Varchar) + '
                                 And    p.mes        = ' + Cast(@w_mes  As Varchar) + @w_condicion + '
                                 Group  By p.referencia, p.fecha_mov, M.concepto, p.usuario, p.fuenteDatos
                                 Having Sum(Abs(importe_Cargo)) - Sum(Abs(Importe_Abono)) = 0.00
                                 Order by p.fuenteDatos, p.usuario, p.referencia, p.fecha_mov'

         If @PnSalida = 2
            Begin
               Set @w_sql =  @w_sql + ' For Json Path, root(' + @w_comilla + 'Reporte' + @w_comilla + ')'
            End

         Begin Try
            Execute (@w_sql);
         End   Try

         Begin Catch
            Select  @w_Error   = @@Error,
                    @w_linea   = Error_line(),
                    @w_mensaje = Substring (Error_Message(), 1, 200)

         End   Catch

         If Isnull(@w_Error, 0) <> 0
            Begin
               Select @PnEstatus = @w_Error,
                      @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_mensaje, 'en Línea ', @w_linea);

               Set Xact_Abort Off
               Return
            End

         Select @PnEstatus = 8165,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus);


         Set Xact_Abort    Off
         Return

      End

   If @PnConsulta = 3
      Begin
         Set @w_sql = Concat('Select ', @w_comilla, 'movimientosAnio', @w_comilla, ' tablaPoliza, ',
                                     'b.tipoPoliza, b.Referencia polizaAnio, Cast(b.fecha_mov as Date) fecha_mov, ',
                                     'b.documento referencia, b.Concepto, a.Moneda, ',
                                     'Concat(Substring(a.llave, 1, 4), Char(45), ',
                                            'Substring(a.llave, 5, 2), Char(45), ',
                                            'Substring(a.llave, 7, 2), Char(45), ',
                                            'Substring(a.llave, 9, 2), ',
                                            'Substring(a.llave, 11,  6)) CuentaAuxiliar, ',
                                     'a.Importe_Cargo Cargo, a.Importe_Abono Abono, ',
                                     '(Select Sum(Isnull(Abs(Importe_Cargo), 0) - Isnull(Abs(Importe_Abono), 0)) ',
                                      'From   dbo.movimientosAnio With (nolock) ',
                                      'Where  Referencia  = a.Referencia ',
                                      'And    fecha_mov   = a.fecha_mov) diferenciaSaldo, ',
                                     'a.Documento, ',
                                     'a.ReferenciaFiscal, a.Fecha_Doc ',
                              'From  dbo.movimientosAnio  a With (Nolock) ',
                              'Join  dbo.polizaAnio       b With (Nolock) ',
                              'On    b.Referencia  = a.Referencia ',
                              'And   b.fecha_mov   = a.fecha_mov ',
                              'And   b.ejercicio   = a.ejercicio ',
                              'And   b.mes         = a.mes ',
                              'Where b.referencia = ', @w_comilla, @PsReferencia, @w_comilla, ' ',
                              'And   b.fecha_mov  = ', @w_comilla, @PdFechaMov,   @w_comilla, ' ');

         If @PnSalida = 2
            Begin
               Set @w_sql =  @w_sql + ' For Json Path, root(' + @w_comilla + 'Reporte' + @w_comilla + ')'
            End

         Begin Try
            Execute (@w_sql)
            Set @w_registros = @@Rowcount
         End   Try

         Begin Catch
            Select  @w_Error   = @@Error,
                    @w_linea   = Error_line(),
                    @w_mensaje = Substring (Error_Message(), 1, 200)

         End   Catch

         If Isnull(@w_Error, 0) <> 0
            Begin
               Select @PnEstatus = @w_Error,
                      @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_mensaje, 'en Línea ', @w_linea);

               Set Xact_Abort Off
               Return
           End

         If  @w_registros = 0
             Begin
                Select @PnEstatus = 8170,
                       @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion,  @PnEstatus);

                Set Xact_Abort    Off
                Return
             End
         Set Xact_Abort Off
         Return

    End

--
-- Borrado de datos de la tabla de errores.
--

   Set @w_sql = Concat('Delete ', @w_tablaErrores, Char(32),
                       'From   ', @w_tablaErrores, ' p ',
                       'Where  1 = 1 ', @w_condicion);
   Begin Try
      Execute (@w_sql)
   End   Try

   Begin Catch
      Select  @w_Error   = @@Error,
              @w_linea   = Error_line(),
              @w_mensaje = Substring (Error_Message(), 1, 200)

   End   Catch

   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_Error,
                @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_mensaje, 'en Línea ', @w_linea);

         Set Xact_Abort Off
         Return
     End

--
-- Validaciones de la póliza, para emisión de reporte de pólizas con errores.
--

   Set @w_mensaje = 'Error en Longitud de la cuenta';

   Set @w_sql = Concat(@w_insertErrores,
                    ' Select p.ejercicio,   p.mes,       p.Referencia,  p.fecha_mov, m.Concepto, m.Moneda, m.Llave,
                             m.Importe,     m.Clave,     m.Cons,        Substring(Substring(m.Documento, 1, 20), 1, 20), m.Sector_id,
                             m.Sucursal_id, m.Region_id, m.fecCap, ',
                             @w_comilla, @w_mensaje, @w_comilla, ', 1 ',
                    ' From   dbo.movimientosAnio m With (Nolock)
                      Join   dbo.polizaAnio      P With (Nolock)
                      On     Cast(p.fecha_mov As Date) = Cast(m.fecha_mov As Date)
                      And    p.Referencia              = m.Referencia
                      And    p.ejercicio               = m.ejercicio
                      And    p.mes                     = m.mes
                      Where  1 = 1 ', @w_condicion,
                    ' And   Len(m.llave) != ', @w_length)

   Begin Try
      Execute (@w_sql)
      Set @w_registros = @@Rowcount;
   End   Try

   Begin Catch
      Select  @w_Error   = @@Error,
              @w_linea   = Error_line(),
              @w_mensaje = Substring (Error_Message(), 1, 200)

   End   Catch

   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_Error,
                @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_mensaje, 'en Línea ', @w_linea);

         Set Xact_Abort Off
         Return
      End

   Set @w_mensaje = 'Error Clave';

   Set @w_sql = Concat(@w_insertErrores,
              ' Select p.ejercicio,   p.mes,       p.Referencia,  p.fecha_mov, m.Concepto, m.Moneda, m.Llave,
                       m.Importe,     m.Clave,     m.Cons,        Substring(m.Documento, 1, 20), m.Sector_id,
                       m.Sucursal_id, m.Region_id, m.fecCap, ',
                       @w_comilla, @w_mensaje, @w_comilla, ', 2 ',
              ' From   dbo.movimientosAnio m With (Nolock)
                Join   dbo.polizaAnio P With (Nolock)
                On     Cast(p.fecha_mov As Date) = Cast(m.fecha_mov As Date)
                And    p.Referencia              = m.Referencia
                And    p.ejercicio               = m.ejercicio
                And    p.mes                     = m.mes
                Where  1 = 1 ', @w_condicion,
              ' And    Isnull(m.Clave, ',@w_comilla, 'X', @w_comilla, ') Not In  (', @w_comilla, 'C', @w_comilla, ', ',
                                                                                           @w_comilla, 'A', @w_comilla, ')');
   Begin Try
      Execute (@w_sql)
      Set @w_registros = @w_registros + @@Rowcount;
   End   Try

   Begin Catch
      Select  @w_Error   = @@Error,
              @w_linea   = Error_line(),
              @w_mensaje = Substring (Error_Message(), 1, 200)

   End   Catch


   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_Error,
                @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_mensaje, 'en Línea ', @w_linea);

         Set Xact_Abort Off
         Return
      End


   Set @w_mensaje = 'Error en Importe';

   Set @w_sql = Concat(@w_insertErrores,
                     ' Select p.ejercicio,   p.mes,      p.Referencia, p.fecha_mov, m.Concepto, m.Moneda, m.Llave,
                             m.Importe,     m.Clave,     m.Cons,        Substring(m.Documento, 1, 20), m.Sector_id,
                             m.Sucursal_id, m.Region_id, m.fecCap, ',
                             @w_comilla, @w_mensaje, @w_comilla, ', 3 ',
                    ' From   dbo.movimientosAnio m With (Nolock)
                      Join   dbo.polizaAnio P With (Nolock)
                      On     Cast(p.fecha_mov As Date) = Cast(m.fecha_mov As Date)
                      And    p.Referencia              = m.Referencia
                      And    p.ejercicio               = m.ejercicio
                      And    p.mes                     = m.mes
                      Where  1 = 1 ', @w_condicion,
                    ' And    Isnull(m.Importe, 0) = 0');
   Begin Try
      Execute (@w_sql)
      Set @w_registros = @w_registros + @@Rowcount;
   End   Try

   Begin Catch
      Select  @w_Error   = @@Error,
              @w_linea   = Error_line(),
              @w_mensaje = Substring (Error_Message(), 1, 200)

   End   Catch

   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_Error,
                @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_mensaje, 'en Línea ', @w_linea);

         Set Xact_Abort Off
         Return
      End

   Set @w_mensaje = 'No existe cuenta auxiliar en el catálogo dbo.CatalogoAuxiliar ';

   Set @w_sql = Concat(@w_insertErrores,
                    ' Select p.ejercicio,   p.mes,       p.Referencia,  p.fecha_mov, m.Concepto, m.Moneda, m.Llave,
                             m.Importe,     m.Clave,     m.Cons,        Substring(m.Documento, 1, 20), m.Sector_id,
                             m.Sucursal_id, m.Region_id, m.fecCap, ',
                             @w_comilla, @w_mensaje, @w_comilla, ', 4 ',
                    ' From   dbo.movimientosAnio m With (Nolock)
                      Join   dbo.polizaAnio      P With (Nolock)
                      On     Cast(p.fecha_mov As Date) = Cast(m.fecha_mov As Date)
                      And    p.Referencia              = m.Referencia
                      And    p.ejercicio               = m.ejercicio
                      And    p.mes                     = m.mes
                      Where  1 = 1 ', @w_condicion,
                    ' And    Not Exists ( Select Top 1 1 ',
                                        ' From   dbo.CatalogoAuxiliar With (Nolock) ',
                                        ' Where  Llave       = m.llave',
                                        ' And    Moneda      = m.moneda',
                                        ' And    Sector_id   = m.Sector_id',
                                        ' And    Sucursal_id = m.Sucursal_id)');

   Begin Try
      Execute (@w_sql)
      Set @w_registros = @w_registros + @@Rowcount;
   End   Try

   Begin Catch
      Select  @w_Error   = @@Error,
              @w_linea   = Error_line(),
              @w_mensaje = Substring (Error_Message(), 1, 200)

   End   Catch

   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_Error,
                @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_mensaje, 'en Línea ', @w_linea);

         Set Xact_Abort Off
         Return
      End

   If @PnConsulta = 4
      Begin
         If @w_registros = 0
            Begin
               Select @PnEstatus = 8167,
                      @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus);

               Set Xact_Abort Off
               Return
            End

         Select @PnEstatus = 8168,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus);

         Set @w_sql = Concat('Select ejercicio, mes, Referencia, Cast(Fecha_mov as Date) fecha, ',
                                     'Concat(Substring(llave, 1, 4), Char(45), ',
                                            'Substring(llave, 5, 2), Char(45), ',
                                            'Substring(llave, 7, 2), Char(45), ',
                                            'Substring(llave, 9, 2), ',
                                            'Substring(llave, 11,  6)) CuentaAuxiliar, ',
                                     'Sucursal_id sucursal, region_id region,',
                                     'Sector_id sector, Mens_Error Mensaje, idError ',
                             'From ' , @w_tablaErrores , ' p With (Nolock) ',
                            ' Where  1 = 1 ', @w_condicion)

         If @PnSalida = 2
            Begin
               Set @w_sql =  @w_sql + ' For Json Path, root(' + @w_comilla + 'Reporte' + @w_comilla + ')'
            End

         Begin Try
            Execute (@w_sql)
         End   Try

         Begin Catch
            Select  @w_Error   = @@Error,
                    @w_linea   = Error_line(),
                    @w_mensaje = Substring (Error_Message(), 1, 200)

         End   Catch

         If Isnull(@w_Error, 0) <> 0
            Begin
               Select @PnEstatus = @w_Error,
                      @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_mensaje, 'en Línea ', @w_linea);

               Set Xact_Abort Off
               Return
            End

         Set Xact_Abort Off
         Return

      End


   If @PnConsulta = 5
      Begin
         Select @PnEstatus             = 0,
                @PsMensaje             = Null;

         Execute dbo.spp_ActualizaCarAbo @PnEjercicio = @w_anio,
                                         @PnMes       = @w_mes,
                                         @PsCondicion = @w_condicion,
                                         @PnEstatus   = @PnEstatus  Output,
                                         @PsMensaje   = @PsMensaje  Output;

         Set Xact_Abort Off
         Return
      End

  Set @w_mensaje = '';


--
-- Cuentas Detalladas
--

   Set @w_sql = Concat('Insert Into #tempCuentas
                       (Llave, Moneda, Sucursal_id, Region_id)
                        Select m.Llave, m.Moneda, m.Sucursal_id, m.Region_id
                        From   dbo.polizaAnio      p With (Nolock)
                        Join   dbo.movimientosAnio m With (Nolock)
                        On     M.Referencia = P.Referencia
                        And    M.fecha_mov  = P.fecha_mov
                        And    m.ejercicio  = p.ejercicio
                        And    m.mes        = p.mes
                        Where  1 = 1 ', @w_condicion,  '
                        And    p.ejercicio  = ', @w_anio, '
                        And    p.mes        = ', @w_mes,
                       'And    p.Mes_Mov    = ', @w_comilla, @w_mesProc , @w_comilla, ' ',
                       'Group  By m.Llave, m.Moneda, m.Sucursal_id, m.Region_id');

   Begin Try
      Execute (@w_sql)
   End   Try

   Begin Catch
      Select  @w_Error   = @@Error,
              @w_linea   = Error_line(),
              @w_mensaje = Substring (Error_Message(), 1, 200)

   End   Catch

   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_Error,
                @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_mensaje, 'en Línea ', @w_linea);

         Set Xact_Abort Off
         Return
      End

--
-- Cuentas Corporativas
--

   Insert Into #tempCuentas
  (tipoCuenta, Llave, Moneda, Region_id)
   Select Distinct 'C', Llave, Moneda, Region_id
   From   #tempCuentas;

   Set @w_sql = Concat('Insert Into #tempCuentas
                       (tipoCuenta, Llave, Moneda, Sucursal_id, Region_id)
                        Select ', @w_comilla, 'T', @w_comilla, ', m.Llave, m.Moneda, m.Sucursal_id, m.Region_id
                        From   dbo.polizaAnio      p With (Nolock)
                        Join   dbo.movimientosAnio m With (Nolock)
                        On     M.Referencia = P.Referencia
                        And    M.fecha_mov  = P.fecha_mov
                        And    m.ejercicio  = p.ejercicio
                        And    m.mes        = p.mes
                        Where  1 = 1 ', @w_condicion,
                      ' And    p.ejercicio  = ', @w_anio, '
                        And    p.mes        = ', @w_mes,
                       'Group  By m.Llave, m.Moneda, m.Sucursal_id, m.Region_id');

   Begin Try
      Execute (@w_sql)
   End   Try

   Begin Catch
      Select  @w_Error   = @@Error,
              @w_linea   = Error_line(),
              @w_mensaje = Substring (Error_Message(), 1, 200)

   End   Catch

   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_Error,
                @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_mensaje, 'en Línea ', @w_linea);

         Set Xact_Abort Off
         Return
      End

--


   Set @w_sql = Concat('Insert Into #TempCuentasInexistentes
                       (Llave, Moneda, Sucursal_id, Region_id)
                        Select Distinct Llave, Moneda, Sucursal_id, Region_id
                        From   #tempCuentas a
                        Where  tipoCuenta = ', @w_comilla, 'T', @w_comilla,
                      ' And    Not Exists ( Select Top 1 1
                                            From   dbo.CatalogoAuxiliar With (Nolock) ',
                                          ' Where  Llave       = a.llave
                                            And    Moneda      = a.moneda
                                            And    Sucursal_id = a.Sucursal_id
                                            And    Region_id   = a.region_id
                                            And    ejercicio   = ', @w_anio,
                                          ' And    mes         = ', @w_mes, ')');

   Begin Try
      Execute (@w_sql)
   End   Try

   Begin Catch
      Select  @w_Error   = @@Error,
              @w_linea   = Error_line(),
              @w_mensaje = Substring (Error_Message(), 1, 200)

   End   Catch

   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_Error,
                @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_mensaje, 'en Línea ', @w_linea);

         Set Xact_Abort Off
         Return
      End

--
--
--
   Set Xact_Abort    Off
   Return

End
Go

--
-- Comentarios.
--

Declare
   @w_valor          Varchar(1500) = 'Realizar consultas para la pantalla de cargos y abonos.',
   @w_procedimiento  Varchar( 100) = 'Spc_cifrasCargosAbonos'


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

