/*

-- Declare
   -- @PnAnio                Smallint            = 2023,
   -- @PnMes                 Tinyint             = 13,
   -- @PsUsuario             Varchar(  20)       = Null,
   -- @PnEstatus             Integer             = 0,
   -- @PsMensaje             Varchar( 250)       = ' ' ;
-- Begin

   -- Execute dbo.Spp_generaAsientoAjusteCierreAnio @PnAnio      = @PnAnio,
                                                 -- @PnMes       = @PnMes,
                                                 -- @PsUsuario   = @PsUsuario,
                                                 -- @PnEstatus   = @PnEstatus Output,
                                                 -- @PsMensaje   = @PsMensaje Output;

   -- Select @PnEstatus, @PsMensaje
   -- Return
-- End
-- Go

--

-- Objeto:        Spp_generaAsientoAjusteCierreAnio.
-- Objetivo:      Genera asiento de Ajuste de fin de ejericio.
-- Fecha:         05/11/2024
-- Programador:   Pedro Zambrano


*/

Create Or Alter Procedure dbo.Spp_generaAsientoAjusteCierreAnio
  (@PnAnio                Smallint,
   @PnMes                 Tinyint,
   @PsUsuario             Varchar(20)         = Null,
   @PnEstatus             Integer             = 0   Output,
   @PsMensaje             Varchar( 250)       = ' ' Output)
As
Declare
   @w_Error             Integer,
   @w_linea             Integer,
   @w_operacion         Integer,
   @w_registro          Integer,
   @w_Region_id         Integer,
   @w_Sucursal_id       Integer,
   @w_idEstatus         Tinyint,
   @w_sector_id         Varchar(    2),
   @w_desc_error        Varchar(  250),
   @w_referencia        Varchar(   20),
   @w_idusuario         Varchar(  Max),
   @w_tipoPoliza        Varchar(    3),
   @w_Mes_Mov           Varchar(    3),
   @w_scta              Varchar(    4),
   @w_numPoliza         Varchar(   20),
   @w_llave             Varchar(   20),
   @w_usuario           Varchar(  20),
   @w_filtro            Varchar(  Max),
   @w_sql               Varchar(  Max),
   @w_anioAnterior      Smallint,
   @w_mesAnterior       Smallint,
   @w_anioProximo       Smallint,
   @w_mesProximo        Smallint,
   @w_mesFin            Smallint,
   @w_idAuxiliar        Smallint,
   @w_fechaIni          Date,
   @w_fechaFin          Date,
   @w_Fecha_Mov         Date,
   @w_fechaCaptura      Datetime,
   @w_importeDebe       Decimal(18, 2),
   @w_importeHaber      Decimal(18, 2),
   @w_importeSaldo      Decimal(18, 2),
   @w_importeCar        Decimal(18, 2),
   @w_importeAbo        Decimal(18, 2),
   @w_consulta          NVarchar(1500),
   @w_param             NVarchar( 750),
   @w_comilla           Char(1),
   @w_clave             Char(1),
   @w_sucursable        Tinyint,
   @w_perAnt            Bit,
   @w_tabla             Sysname;

Begin
   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off

   Select @PnEstatus         = 0,
          @PsMensaje         = Null,
          @w_operacion       = 9999,
          @w_perAnt          = 0,
          @w_fechaCaptura    = Getdate(),
          @w_comilla         = Char(39),
          @w_tipoPoliza      = 'PDI',
          @w_tabla           = 'CatalogoAuxiliar',
          @w_fecha_Mov       = Eomonth(Convert(Date, Concat('01/', @PnMes -1, '/', @PnAnio), 103)),
          @w_sucursable      = Isnull(dbo.Fn_BuscaResultadosParametros(12, 'valor'), 0);

--
-- Obtención del usuario de la aplicación para procesos batch.
--

   If @PsUsuario Is Null
      Begin
         Select @w_idusuario = parametroChar
         From   dbo.conParametrosGralesTbl
         Where  idParametroGral = 6;

         Select @w_consulta   = Concat('Select @o_usuario = dbo.Fn_Desencripta_cadena (', @w_idusuario, ')'),
                @w_param      = '@o_usuario    Nvarchar(20) Output';

         Begin Try
            Execute Sp_executeSql @w_consulta, @w_param, @o_usuario = @w_usuario Output
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

   If @w_idEstatus = 0
      Begin
         Select @PnEstatus  = 8025,
                @PsMensaje =  'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

         Set Xact_Abort Off
         Return
      End

--
-- Se valida si existe el catálogo para el mes a procesar.
--

   If @w_sucursable      = 2
      Begin
         If @w_perAnt = 0
            Begin
               If Not Exists (Select Top 1 1
                        From   dbo.CatalogoAuxiliar With (Nolock)
                        Where  Ejercicio = @PnAnio
                        And    mes       = @PnMes)
                  Begin
                     Select @PnEstatus  = 8026,
                            @PsMensaje =  'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

                     Set Xact_Abort Off
                     Return
                  End
            End
         Else
            Begin
               If Not Exists (Select Top 1 1
                              From   dbo.CatalogoAuxiliarHist With (Nolock)
                              Where  Ejercicio = @PnAnio
                              And    mes       = @PnMes)
                  Begin
                     Select @PnEstatus  = 8026,
                            @PsMensaje =  'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

                     Set Xact_Abort Off
                     Return
                  End
            End
      End

   If Not Exists (Select Top 1 1
                  From   dbo.Catalogo With (Nolock)
                  Where  Ejercicio = @PnAnio
                  And    mes       = @PnMes)
      Begin
         Select @PnEstatus  = 8026,
                @PsMensaje =  'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

         Set Xact_Abort Off
         Return
      End

--
-- Se valida si es el último periodo ejercicio
--

   Select @w_mesFin = Max(valor)
   From   dbo.catCriteriosTbl Whith (Nolock)
   Where  criterio = 'mes';

   If @w_mesFin != @PnMes
      Begin
         Select @PnEstatus  = 8027,
                @PsMensaje =  'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

         Set Xact_Abort Off
         Return
      End

   Select @w_Mes_Mov = Upper(Substring(descripcion, 1, 3))
   From   dbo.catCriteriosTbl Whith (Nolock)
   Where  criterio = 'mes'
   And    valor    = @PnMes;

--
-- Fin de Validaciones
--

--
-- Se obtiene la cuenta auxiliar de resultados.
--

   Select @w_idAuxiliar = parametroNumber
   From   dbo.conParametrosGralesTbl With (Nolock)
   Where  idParametroGral = 8

   Select @w_llave = CuentaInterna
   From   dbo.Cuentas_predeterminadas With (Nolock)
   Where  id = @w_idAuxiliar;

--
-- Se valida que la cuenta Este relacionado a todas las Areas.
--

   If @w_sucursable = 2
      Begin
         If @w_perAnt = 0
            Begin
               If Not Exists (Select top 1 1
                              From   dbo.CatalogoAuxiliar c With (Nolock)
                              Where  c.Ejercicio = @PnAnio
                              And    c.mes       = @PnMes
                              And    c.Llave     = @w_llave)
                  Begin
                     Select @PnEstatus  = 8030,
                            @PsMensaje =  'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

                     Set Xact_Abort Off
                     Return
                  End
            End
         Else
            Begin
               If Not Exists (Select top 1 1
                              From   dbo.CatalogoAuxiliarHist c With (Nolock)
                              Where  c.Ejercicio = @PnAnio
                              And    c.mes       = @PnMes
                              And    c.Llave     = @w_llave)
                  Begin
                     Select @PnEstatus  = 8030,
                            @PsMensaje =  'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

                     Set Xact_Abort Off
                     Return
                  End
            End
      End

--
--
--


   If Not Exists ( Select Top 1 1
                   From   dbo.Catalogo With (Nolock)
                   Where  Ejercicio = @PnAnio
                   And    mes       = @PnMes
                   And    llave     = @w_llave)
      Begin
         Select @PnEstatus  = 8029,
                @PsMensaje =  'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

         Set Xact_Abort Off
         Return
      End

--
-- Obtener los mayores de las cuentas de resultado.
--

   Declare
      C_Cuentas Cursor For
      Select Substring(c.llave, 1, 4),
             Row_number () Over (Order By Substring(c.llave, 1, 4) )
      From   dbo.Rangos a With (NolocK)
      Join   dbo.SubRangos b
      On     b.Rango_id = a.Rango_id
      Join   dbo.Catalogo c
      On     Substring(c.llave, 1, 4) Between b.Llave_final And b.Llave_final
      Where  a.Naturaleza_id In ('IN', 'EG')
      And    c.ejercicio = @PnAnio
      Group  By Substring(c.llave, 1, 4);

   Begin
      Open  C_Cuentas
      While @@Fetch_Status < 1
      Begin
         Fetch C_Cuentas Into @w_scta, @w_registro
         If @@Fetch_Status != 0
            Begin
               Break
            End

         If @w_registro = 1
            Begin
               Set @w_filtro = Concat(' And Substring(llave, 1, 4) In ( ', @w_comilla, @w_scta, @w_comilla)
            End
         Else
            Begin
               Set @w_filtro = Concat(@w_filtro, ', ', @w_comilla, @w_scta, @w_comilla)
            End

      End
      Close      C_CUentas
      Deallocate C_CUentas
   End

   Set @w_filtro = @w_filtro + ')'

--
-- Se declara el cursor para obtener la Región y asignar el comprobante por región.
--

   If @w_sucursable = 2
      Begin
         Set @w_sql = 'Declare
                          C_Region_id  Cursor For ' +
                          'Select Region_id, Sucursal_id, Sector_id '      +
                          'From   dbo.Rangos a With (NolocK) ' +
                          'Join   dbo.SubRangos b '            +
                          'On     b.Rango_id = a.Rango_id '    +
                          'Join   dbo.' + @w_tabla +  ' c '     +
                          'On     Substring(c.llave, 1, 4) Between b.Llave_final And b.Llave_final ' +
                          'Where  a.Naturaleza_id In (' + @w_comilla + 'IN' + @w_comilla + ', ' +
                                                          @w_comilla + 'EG' + @w_comilla + ') ' +
                          'And    Ejercicio = ' + Cast(@PnAnio As Varchar) + ' ' +
                          'And    mes       = ' + Cast(@PnMes  As Varchar) + ' ' +
                          'And    SAct     != 0 ' +
                          'Group  By Region_id, Sucursal_id, Sector_id ' +
                          'Order  By 1, 2';
      End
   Else
      Begin
         Set @w_sql = 'Declare
                          C_Region_id  Cursor For ' +
                          'Select 0, 0, 0 ';
      End


--
-- Inicio de Proceso.
--

   Begin Transaction

      Execute (@w_sql)

      Open C_Region_id
      While @@Fetch_status < 1
      Begin
         Fetch C_Region_id Into @w_Region_id, @w_Sucursal_id, @w_sector_id
         If @@Fetch_status != 0
            Begin
               Break
            End

         If @w_sucursable = 2
            Begin
               If @w_perAnt = 0
                  Begin
                     If Not Exists (Select top 1 1
                                    From   dbo.CatalogoAuxiliar c
                                    Where  c.Llave       = @w_llave
                                    And    c.Sucursal_id = Sucursal_id
                                    And    c.Region_id   = @w_Region_id
                                    And    c.Ejercicio   = @PnAnio
                                    And    c.mes         = @PnMes)
                        Begin
                           Rollback Transaction

                           Select @PnEstatus  = 8029,
                                  @PsMensaje =  'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

                           Close      C_Region_id
                           Deallocate C_Region_id

                           Set Xact_Abort Off
                           Goto Salida
                        End
                  End
               Else
                  Begin
                     If Not Exists (Select top 1 1
                                    From   dbo.CatalogoAuxiliarHist c
                                    Where  c.Llave       = @w_llave
                                    And    c.Sucursal_id = Sucursal_id
                                    And    c.Region_id   = @w_Region_id
                                    And    c.Ejercicio   = @PnAnio
                                    And    c.mes         = @PnMes)
                        Begin
                           Rollback Transaction

                           Select @PnEstatus  = 8029,
                                  @PsMensaje =  'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

                           Close      C_Region_id
                           Deallocate C_Region_id

                           Set Xact_Abort Off
                           Goto Salida
                        End
                  End
            End

--
-- Se obtiene el numero de la póliza por Región.
--

         Select @w_numPoliza = Max(Substring(referencia, 4, 5))
         From   dbo.polizaAnio With (Nolock)
         Where  Substring(referencia, 1, 3) = @w_tipoPoliza
         And    ejercicio    = @PnAnio
         And    mes          = @PnMes;
         If @w_numPoliza Is Null
            Begin
               Set @w_numPoliza = '00000'
            End

         Select @w_numPoliza = Format(Cast(@w_numPoliza As Integer) + 1, '00000'),
                @w_numPoliza = @w_tipoPoliza + @w_numPoliza

--
-- Actualización de las pólizas (cabecero).
--

         Begin Try
            Insert Into dbo.polizaAnio
           (Referencia, Fecha_Mov, Fecha_Cap, Concepto,
            Cargos,     Abonos,    TCons,     Usuario,
            TipoPoliza, Documento, Usuario_cancela, Fecha_Cancela,
            Status,     Mes_Mov,   TipoPolizaConta, FuenteDatos,
            Ejercicio,  Mes)
            Select @w_numPoliza, @w_fecha_Mov, @w_fechaCaptura,
                   Concat('Póliza de cierre de ejercicio ',@PnAnio),
                   0 Cargos,        0 Abonos,    0 Tcons,         @w_usuario,
                   @w_tipoPoliza,   Char(32),    Null,            Null,
                   1,               @w_Mes_Mov,  Null,            Null,
                   @PnAnio,         @PnMes
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

               Close      C_Region_id
               Deallocate C_Region_id

               Set Xact_Abort Off
               Goto Salida
            End

--
-- Insert de los movimientos de la póliza Final.
--

         If @w_sucursable = 2
            Begin
               Set @w_sql = 'Select ' + @w_comilla + @w_numPoliza + @w_comilla + ', Row_number () Over (Order By llave ), Moneda, ' + @w_comilla + Cast(@w_Fecha_Mov As Varchar) + @w_comilla + ', ' +
                                    'Llave,    Concat(' + @w_comilla + 'Ajuste Cierre ejercicio ' + @w_comilla + ',' + Cast(@PnAnio As Varchar) + '), Abs(Sact),   Char(32), ' +
                                    'Case When Sact < 0 '                              +
                                         'Then '  + @w_comilla + 'C' + @w_comilla + ' ' +
                                         'Else '  + @w_comilla + 'A' + @w_comilla + ' ' +
                                    'End Clave, ' + @w_comilla + Cast(@w_fechaCaptura As Varchar) + @w_comilla + ', ' +
                                    'Sector_id,     Sucursal_id, Region_id, ' +
                                    'Case When Sact < 0 ' +
                                         'Then Abs(SAct) ' +
                                         'Else 0 '    +
                                    'End  Importe_Cargo, ' +
                                    'Case When Sact > 0 '  +
                                         'Then Abs(SAct) '      +
                                         'Else 0 '         +
                                    'End Importe_Abono, Concat(' + @w_comilla + 'Cierre ejercicio ' + @w_comilla + ', ' + Cast(@PnAnio As Varchar)+ '), ' +
                                    'Null TipoPolizaConta, Null ReferenciaFiscal, Null Fecha_Doc, Ejercicio, ' +
                                    'mes ' +
                            'From   dbo.' + @w_tabla + ' a With (Nolock) ' +
                            'Where  ejercicio = '   + Cast(@PnAnio As Varchar) + ' ' +
                            'And    mes       = '   + Cast(@PnMes  As Varchar) + ' ' +
                            'And    niv       = 1 ' +
                            'And    region_id = '   + Cast(@w_Region_id As Varchar) + ' ' +
                            'And    Sact     != 0 ' + @w_filtro;
            End
         Else
            Begin
               Set @w_sql = 'Select ' + @w_comilla + @w_numPoliza + @w_comilla + ', Row_number () Over (Order By llave ), Moneda, ' + @w_comilla + Cast(@w_Fecha_Mov As Varchar) + @w_comilla + ', ' +
                                    'Llave,    Concat(' + @w_comilla + 'Cierre ejercicio ' + @w_comilla + ',' + Cast(@PnAnio As Varchar) + '), Abs(Sact),   Char(32), ' +
                                    'Case When Sact < 0 '                              +
                                         'Then '  + @w_comilla + 'C' + @w_comilla + ' ' +
                                         'Else '  + @w_comilla + 'A' + @w_comilla + ' ' +
                                    'End Clave, ' + @w_comilla + Cast(@w_fechaCaptura As Varchar) + @w_comilla + ', ' +
                                    @w_comilla + '00' + @w_comilla + ' Sector_id,     0 Sucursal_id, 0 Region_id, ' +
                                    'Case When Sact < 0 ' +
                                         'Then Abs(SAct) ' +
                                         'Else 0 '    +
                                    'End  Importe_Cargo, ' +
                                    'Case When Sact > 0 '  +
                                         'Then Abs(SAct) '      +
                                         'Else 0 '         +
                                    'End Importe_Abono, Concat(' + @w_comilla + 'Cierre ejercicio ' + @w_comilla + ', ' + Cast(@PnAnio As Varchar)+ '), ' +
                                    'Null TipoPolizaConta, Null ReferenciaFiscal, Null Fecha_Doc, Ejercicio, ' +
                                    'mes ' +
                            'From   dbo.Catalogo a With (Nolock) ' +
                            'Where  ejercicio = '   + Cast(@PnAnio As Varchar) + ' ' +
                            'And    mes       = '   + Cast(@PnMes  As Varchar) + ' ' +
                            'And    niv       = 1 ' +
                            'And    Sact     != 0 ' + @w_filtro;
            End

         Begin Try
            Insert Into dbo.MovimientosAnio
           (Referencia,      Cons,             Moneda,        Fecha_mov,
            Llave,           Concepto,         Importe,       Documento,
            Clave,           FecCap,           Sector_id,     Sucursal_id,
            Region_id,       Importe_Cargo,    Importe_Abono, Descripcion,
            TipoPolizaConta, ReferenciaFiscal, Fecha_Doc,     Ejercicio,
            mes)
            Execute (@w_sql)
            Set @w_registro = @@Rowcount;
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

               Close      C_Region_id
               Deallocate C_Region_id
               Set Xact_Abort Off
               Goto Salida
            End

         If @w_registro = 0
            Begin
               Rollback Transaction

               Select @PnEstatus = 8172,
                      @PsMensaje = dbo.Fn_Busca_MensajeError (@w_operacion, @PnEstatus);

               Close      C_Region_id
               Deallocate C_Region_id
               Set Xact_Abort Off
               Goto Salida
            End

--
-- Consulta de los Cargos y Abonos del período.
--

         Select @w_importeDebe  = Sum(Case When clave = 'C'
                                           Then Importe
                                           Else 0
                                      End),
                @w_importeHaber = Sum(Case When clave = 'A'
                                           Then Importe
                                           Else 0
                                      End)
         From   dbo.MovimientosAnio With (Nolock)
         Where  Referencia    = @w_numPoliza
         And    Fecha_mov     = @w_fecha_Mov
         And    ejercicio     = @PnAnio
         And    mes           = @PnMes;

--
-- Se calcula la Utilidad / Perdida del periodo.
--


         Set @w_importeSaldo = @w_importeDebe - @w_importeHaber

         If @w_importeSaldo < 0
            Begin
               Select @w_clave      = 'C',
                      @w_importeCar = @w_importeSaldo,
                      @w_importeAbo = 0;
            End;
         Else
            Begin
               Select @w_clave      = 'A',
                      @w_importeCar = 0,
                      @w_importeAbo = @w_importeSaldo;
            End;

         Set @w_registro = @w_registro + 1

         Insert Into dbo.MovimientosAnio
        (Referencia,      Cons,             Moneda,        Fecha_mov,
         Llave,           Concepto,         Importe,       Documento,
         Clave,           FecCap,           Sector_id,     Sucursal_id,
         Region_id,       Importe_Cargo,    Importe_Abono, Descripcion,
         TipoPolizaConta, ReferenciaFiscal, Fecha_Doc,     Ejercicio,
         mes)
         Select @w_numPoliza, @w_registro,               '00',             @w_Fecha_Mov,
                @w_llave,     Concat('Ajuste Cierre ejercicio', @PnAnio),  Abs(@w_importeSaldo), Char(32),
                @w_clave,     @w_fechaCaptura,           @w_sector_id,  @w_Sucursal_id,
                @w_Region_id, @w_importeCar,             @w_importeAbo, Concat('Ajuste Cierre ejercicio ', @PnAnio),
                Null,         Null,                      Null,          @PnAnio,
                @PnMes;

         Select @w_importeDebe  = Sum(Case When clave = 'C'
                                           Then Importe
                                           Else 0
                                      End),
                @w_importeHaber = Sum(Case When clave = 'A'
                                           Then Importe
                                           Else 0
                                      End),
                @w_registro     = Count(1)
         From   dbo.MovimientosAnio With (Nolock)
         Where  Referencia    = @w_numPoliza
         And    Fecha_mov     = @w_fecha_Mov
         And    ejercicio     = @PnAnio
         And    mes           = @PnMes;

         Begin Try
            Update dbo.PolizaAnio
            Set    Cargos = @w_importeDebe,
                   Abonos = @w_importeHaber,
                   TCons  = @w_registro,
                   status = Case When @w_importeDebe = @w_importeHaber
                                 Then 2
                                 Else 3
                            End
            From   dbo.PolizaAnio
            Where  Referencia    = @w_numPoliza
            And    Fecha_Mov     = @w_fecha_Mov
            And    ejercicio     = @PnAnio
            And    mes           = @PnMes;

         End Try

         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_linea      = Error_line(),
                    @w_desc_error = Substring (Error_Message(), 1, 230)
         End   Catch

         If Isnull(@w_Error, 0) <> 0
            Begin
               Select @PnEstatus = @w_error,
                      @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

               Set Xact_Abort Off
               Return

            End
      End

      Close      C_Region_id
      Deallocate C_Region_id

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
   @w_valor          Varchar(1500) = 'Genera asiento de Ajuste de fin de ejericio.',
   @w_procedimiento  Varchar( 100) = 'Spp_generaAsientoAjusteCierreAnio'


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
