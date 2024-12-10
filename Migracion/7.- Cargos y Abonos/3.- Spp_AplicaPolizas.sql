/*

-- Declare
   -- @PnAnio                Smallint            = 2024,
   -- @PnIdMes               Tinyint             = 7,
   -- @PnMesCer              Integer             = 7,
   -- @PsCondicion           Varchar(500)        = ' And Cast(P.Fecha_Mov As Date) Between ' + Char(39) + '2024-07-31' + + Char(39) + ' And ' + Char(39) + '2024-07-31' + Char(39),
   -- @PnEstatus             Integer             = 0,
   -- @PsMensaje             Varchar( 250)       = ' ' ;
-- Begin

   -- Execute dbo.Spp_AplicaPolizas @PnAnio      = @PnAnio,
                                 -- @PnIdMes     = @PnIdMes,
                                 -- @PnMesCer    = @PnMesCer,
                                 -- @PsCondicion = @PsCondicion,
                                 -- @PnEstatus   = @PnEstatus Output,
                                 -- @PsMensaje   = @PsMensaje Output;

   -- Select @PnEstatus, @PsMensaje
   -- Return
-- End
-- Go

*/

/*
-- Fecha: 24/Noviembre/2022
-- Autor: Desconocido
-- Task: N/A
-- Observaciones: Proceso que realiza actualizacion de cargos y abonos por proceso de acuerdo a condiciones.

-- MODIFICACIONES:
-- V1.0. [Zayra Mtz. Candia].[24Nov2022]. Se quita comentario a la linea 82, donde estaba comentado la variable de la condicion.

-- Fecha:         17/08/20
-- Programador:   Pedro Zambrano
-- Observaciones: Se hace reingreniería al proceso de aplicación de pólizas a cargos y abonos.
-- Pro Original:  sp_poliza.

*/

Create Or Alter Procedure dbo.Spp_AplicaPolizas
   (@PnAnio              Smallint,
    @PnIdMes             Tinyint,
    @PnMesCer            Integer           = 0,
    @PsCondicion         Varchar(500),
    @PnEstatus           Integer           = 0    Output,
    @PsMensaje           Varchar( 250)     = ' '  Output)
As

Declare
    @w_Error             Integer,
    @w_linea             Integer,
    @w_operacion         Integer,
    @w_sucursal          Integer,
    @w_region            Integer,
    @w_minIdF            Integer,
    @w_maxIdF            Integer,
    @w_countReg          Integer,
    @w_comilla           Char(1),
    @w_clave             Char(1),
    @w_moneda_id         Varchar(  2),
    @w_desc_error        Varchar(250),
    @w_sql               Varchar(Max),
    @w_llave             Varchar( 16),
    @w_nivel             varchar(  2),
    @w_sector            Varchar(  2),
    @w_NCta              Varchar( 16),
    @w_Aux               Varchar( 16),
    @w_ctaMayor          Varchar( 16),
    @w_SubCta            Varchar( 16),
    @w_SSubCta           Varchar( 16),
    @w_SSSubCta          Varchar( 16),
    @w_Ceros             Varchar( 16),
    @w_importe           Decimal(18, 2),
    @w_poliza            Sysname,
    @w_movimientos       Sysname,
    @w_catalogo          Sysname,
    @w_catalagoAux       Sysname,
    @w_catReporte        Sysname,
    @w_catAuxReporte     Sysname,
    @w_idEstatus         Tinyint,
    @w_fechaCaptura      Datetime,
--
    @w_consulta          Nvarchar(1500),
    @w_param             NVarchar( 750),
    @w_existe            Integer;

Begin
   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off

   Select @PnEstatus         = 0,
          @PsMensaje         = Null,
          @w_operacion       = 9999,
          @w_minIdF          = 0,
          @w_countReg        = 0,
          @w_comilla         = Char(39),
          @w_Ceros           = Replicate('0', 16),
          @w_fechaCaptura    = Getdate(),
          @w_poliza          = 'PolizaAnio',
          @w_movimientos     = 'MovimientosAnio',
          @w_catalogo        = 'catalogo',
          @w_catalagoAux     = 'catalogoAuxiliar',
          @w_catReporte      = 'catalogoReporteTbl',
          @w_catAuxReporte   = 'catalogoAuxReporteTbl';

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
                   And    valor    = @PnIdMes)
      Begin
         Select @PnEstatus  = 8023,
                @PsMensaje =  'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

         Set Xact_Abort Off
         Return
      End

--
-- Creación de Tabla Temporal
--

   If Object_Id('tempdb..#tmpFilter') Is Null
      Begin
         Create Table #tmpFilter
        (Id               Integer identity(1,1) Not Null Primary key,
         Llave            Varchar(16),
         Importe          Decimal(18, 2),
         Clave            Char(1),
         Sector_id        Varchar(2),
         Sucursal_id      Integer,
         Region_id        Integer,
         moneda_id        Varchar( 2),
         Index tmpFilterIdxo1 (llave))
      End



-- Depuración de Catálogos.

   Set @w_sql = 'Update dbo.' + @w_catalogo + ' ' +
                'Set    CarExt        = 0, ' +
                       'CarProceso    = 0, ' +
                       'AboExt        = 0, ' +
                       'AboProceso    = 0 '  +
                'Where Ejercicio   = ' + Cast(@PnAnio      As Varchar) + ' ' +
                'And   Mes         = ' + Cast(@PnIdMes     As Varchar)

   Begin Try
      Execute (@w_sql)
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

         Insert Into dbo.Bitacora_CargosAbonos
        (mensaje, idError, mensajeError, ultactual )
         Select 'ERROR 4', @w_error,     @w_desc_error, getdate();

         Set Xact_Abort Off
         Return
      End

-- Depuración de Catálogos Auxiliares.

   Set @w_sql = 'Update dbo.' + @w_catalagoAux + ' ' +
                'Set    CarExt        = 0, ' +
                       'CarProceso    = 0, ' +
                       'AboExt        = 0, ' +
                       'AboProceso    = 0 '  +
                'Where Ejercicio   = ' + Cast(@PnAnio      As Varchar) + ' ' +
                'And   Mes         = ' + Cast(@PnIdMes     As Varchar)

   Begin Try
      Execute (@w_sql)
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

         Insert Into dbo.Bitacora_CargosAbonos
        (mensaje, idError, mensajeError, ultactual )
         Select 'ERROR 5', @w_error,     @w_desc_error, getdate();

         Set Xact_Abort Off
         Return
      End

-- Inicio del proceso de generacion de polizas

   Set @w_sql = 'Select m.Llave, Round(Sum(m.Importe),2,0), m.Clave, m.Sector_id, m.Sucursal_id, m.Region_id, m.moneda ' +
                'From   dbo.' + @w_poliza      + ' p With (Nolock) ' +
                'Join   dbo.' + @w_movimientos + ' m With (Nolock) ' +
                'On     m.Referencia              = p.Referencia ' +
                'And    Cast(m.fecha_Mov As Date) = Cast(p.fecha_mov As Date) '+
                'And    m.ejercicio               = p.ejercicio '+
                'And    m.mes                     = p.mes ' +
                'Where  1 = 1 ' + @PsCondicion + ' ' +
                'And    p.ejercicio               = ' + Cast(@PnAnio  As Varchar) + ' ' +
                'And    p.mes                     = ' + Cast(@PnIdMes As Varchar) + ' ' +
                'Group By m.Llave, m.Moneda, m.Clave, m.Sector_id, m.Sucursal_id, m.Region_id, m.moneda '

   Begin Try
      Insert Into #tmpFilter
     (Llave, Importe, Clave, Sector_id, Sucursal_id, Region_id, moneda_id)
      Execute (@w_sql)
      Set @w_maxIdF = @@Identity
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

         Insert Into dbo.Bitacora_CargosAbonos
        (mensaje, idError, mensajeError, ultactual )
         Select 'ERROR 6', @w_error,     @w_desc_error, getdate();

         Set Xact_Abort Off
         Return
      End

   While @w_minIdF <= @w_maxIdF
   Begin
      Set @w_minIdF += 1

      Select @w_llave      = Llave,
             @w_importe    = Importe,
             @w_sector     = Sector_id,
             @w_sucursal   = Sucursal_id,
             @w_clave      = Clave,
             @w_region     = Region_id,
             @w_moneda_id  = moneda_id
      From   #tmpFilter
      Where  Id = @w_minIdF
      If @@Rowcount = 0
         Begin
            Break
         End

      Select @w_Aux      = Substring  (@w_llave, 11, 6)                  ,
             @w_NCta     = Substring  (@w_llave,  7, 2)                  , -- Valor 00
             @w_SSSubCta = Concat(Left(@w_llave, 10), Right(@w_Ceros,6)) , -- Variable que se encarga de la SSSubCta--
             @w_SSubCta  = Concat(Left(@w_llave, 8) , Right(@w_Ceros,8)) , -- Variable que se encarga de la SSubCta--
             @w_SubCta   = Concat(Left(@w_llave, 6) , Right(@w_Ceros,10)), -- Variable que se encarga de la SubCta--
             @w_ctaMayor = Concat(Left(@w_llave, 4) , Right(@w_Ceros,12))  -- Variable que se encarga de la Cta Mayor


-- COMPARACION DEL MES EN CURSO Y MES CERRADO--
-- Si el mes en curso es igual al mes cerrado, solo se va actualizar los catalogos contables.
-- Catálogo Consolidado, Catalogo y Catalogo Auxiliar.

-- INICIO DE LA COMPARACION DEL MES, CUANDO CUMPLE CON LA CONDICION

      If @PnIdMes = @PnMesCer
         Begin
         --COMPARACION DE CLAVE SEA IGUAL A C
         --En SICCORP se manejan dos tipos de Clave.
         --El primer tipo es C corresponde a CARGO.

            If @w_sucursal = 0
               Begin
                  Set @w_sql = 'Update dbo.' + @w_catalogo + ' '       +
                               'Set ' + Case When @w_clave = 'C'
                                             Then + ' CarExt        = CarExt + '     + Convert(Varchar, @w_importe) + ', ' +
                                                    ' CarProceso    = CarProceso + ' + Convert(Varchar, @w_importe) + ' '
                                             Else + ' AboExt        = AboExt + '     + Convert(Varchar, @w_importe) + ', '         +
                                                    ' AboProceso    = AboProceso + ' + Convert(Varchar, @w_importe) + ' '
                                        End

                  Set @w_sql = @w_sql   + 'Where Llave       = ' + @w_comilla  + @w_llave        + @w_comilla + ' ' +
                                          'And   Moneda      = ' + Cast(@w_moneda_id As Varchar) + ' ' +
                                          'And   Ejercicio   = ' + Cast(@PnAnio      As Varchar) + ' ' +
                                          'And   Mes         = ' + Cast(@PnIdMes     As Varchar) + ' ';


                  Begin Try
                     Execute(@w_sql)
                  End Try

                  Begin Catch
                     Select @w_Error      = @@Error,
                            @w_linea      = Error_line(),
                            @w_desc_error = Substring (Error_Message(), 1, 200)
                  End Catch

                  If IsNull(@w_error, 0) <> 0
                     Begin
                        Select @PnEstatus = @w_error,
                               @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

                        Insert Into dbo.Bitacora_CargosAbonos
                        (mensaje, idError, mensajeError, ultActual )
                        Values ('ERROR 9', @w_error, @w_desc_error, getdate());

                        Set Xact_Abort Off
                        Return
                     End
               End

            Set @w_sql = 'Update ' + @w_catalagoAux + ' '                                                               +
                         'Set ' + Case When @w_clave = 'C'
                                       Then ' CarExt        = CarExt + '     + Convert(Varchar, @w_importe) + ', ' +
                                            ' CarProceso    = CarProceso + ' + Convert(Varchar, @w_importe) + ' '
                                       Else ' AboExt        = AboExt + '     + Convert(Varchar, @w_importe) + ', '     +
                                            ' AboProceso    = AboProceso + ' + Convert(Varchar, @w_importe) + ' '
                                       End

            Set @w_sql = @w_sql + 'Where Llave       = ' + @w_comilla + @w_llave       + @w_comilla    + ' ' +
                                  'And   Moneda      = ' + @w_comilla + @w_moneda_id   + @w_comilla    + ' ' +
                                  'And   Sucursal_id = ' + Convert(Varchar, @w_sucursal)               + ' ' +
                                  'And   Sector_id   = ' + @w_comilla + @w_sector      + @w_comilla    + ' ' +
                                  'And   Region_id   = ' + Convert(Varchar, @w_region)                 + ' ' +
                                  'And   Ejercicio   = ' + Convert(Varchar, @PnAnio)                   + ' ' +
                                  'And   mes         = ' + Convert(Varchar, @PnIdMes)

            Begin Try
               Execute(@w_sql)
            End Try

            Begin Catch

               Select @w_error      = Error_Number(),
                      @w_linea      = Error_line(),
                      @w_desc_error = Error_Message()
            End Catch

            If IsNull(@w_error, 0) <> 0
               Begin
                  Select @PnEstatus = @w_error,
                         @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

                  Insert Into dbo.Bitacora_CargosAbonos
                  (mensaje, idError, mensajeError, ultactual)
                  Values ('ERROR 11', @w_error, @w_desc_error, getdate());

                  Set Xact_Abort Off
                  Return
               End

-- Actualiza los saldos de la subcta y cuenta mayor correspondiente, en el catalogoo.

            If @w_sucursal = 0
               Begin
                  Set @w_sql =  'Update dbo.' + @w_catalogo + ' '                                                     +
                                'Set ' + Case When @w_clave = 'C'
                                              Then 'CarExt     = CarExt + '     + Convert(Varchar, @w_importe) + ', ' +
                                                   'CarProceso = CarProceso + ' + Convert(Varchar, @w_importe) + ' '
                                              Else 'AboExt     = AboExt     + ' + Convert(Varchar, @w_importe) + ', ' +
                                                   'AboProceso = AboProceso + ' + Convert(Varchar, @w_importe) + ' '
                                         End
                  
                  Set @w_sql = @w_sql + 'Where Niv      = 0 '                                                         +
                                        'And   Llave   In (' + Case When @w_NCta = '00'
                                                                    Then @w_comilla + @w_SubCta   + @w_comilla + ', ' +
                                                                         @w_comilla + @w_ctaMayor + @w_comilla
                                                                    Else @w_comilla + @w_SSSubCta + @w_comilla + ', ' +
                                                                         @w_comilla + @w_SSubCta  + @w_comilla + ', ' +
                                                                         @w_comilla + @w_SubCta   + @w_comilla +' , ' +
                                                                         @w_comilla + @w_ctaMayor      + @w_comilla
                                                               End + ') ' +
                                        'And   Moneda      = ' + @w_comilla + @w_moneda_id  + @w_comilla + ' ' +
                                        'And   Ejercicio   = ' + Convert(Varchar, @PnAnio)               + ' ' +
                                        'And   mes         = ' + Convert(Varchar, @PnIdMes)
                  
                  Begin Try
                     Execute(@w_sql)
                  End Try
                  
                  Begin Catch
                     Select @w_error      = Error_Number(),
                            @w_linea      = Error_line(),
                            @w_desc_error = Error_Message()
                  
                  End Catch
                  
                  If IsNull(@w_error, 0) <> 0
                     Begin
                        Select @PnEstatus = @w_error,
                               @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);
                  
                            Insert Into dbo.Bitacora_CargosAbonos
                            (mensaje, idError, mensajeError, ultactual )
                            Values ('ERROR 12', @w_error, @w_desc_error, @w_fechaCaptura);
                  
                            Set Xact_Abort Off
                            Return
                     End
               End

         End

-- CUANDO NO CUMPLE CON LA CONDICION DE LOS MESES QUE SEAN IGUALES--
-- SI el mes en curso NO es igual al mes cerrado, se va actualizar los catalogos contables y
--    se realiza un registro de los importes en las tablas de registros.
-- Catalogo Contable CATMESAÑO y Catalogo Auxiliar CATAUXMESAÑO, correspondiente al mes.

      Else
         Begin
-- ELSE SI LOS MESES NO SON IGUALES
-- SI NO EXISTE, SE UTILIZA EN LA SENTENCIA Insert,
-- PARA AÑADIR UN ELEMENTO, EVITANDOAÑADIR REGISTROS DUPLICADOS

            If @w_sucursal = 0
               Begin
                  Set @w_sql = 'Update ' + @w_catalogo     + ' '                                                     +
                               'Set ' + Case When @w_clave = 'C'
                                             Then 'CarExt     = CarExt + '     + Convert(Varchar, @w_importe) + ', ' +
                                                  'CarProceso = CarProceso + ' + Convert(Varchar, @w_importe) + ' '
                                             Else 'AboExt     = AboExt + '     + Convert(Varchar, @w_importe) + ', ' +
                                                  'AboProceso = AboProceso + ' + Convert(Varchar, @w_importe) + ' '
                                        End
                  
                  Set @w_sql = @w_sql   + 'Where Llave       = ' + @w_comilla  + @w_llave        + @w_comilla + ' ' +
                                          'And   Moneda      = ' + Cast(@w_moneda_id As Varchar) + ' ' +
                                          'And   Ejercicio   = ' + Cast(@PnAnio      As Varchar) + ' ' +
                                          'And   Mes         = ' + Cast(@PnIdMes     As Varchar);
                  
                  Begin try
                     Execute (@w_sql)
                  End Try
                  
                  Begin Catch
                     Select @w_error      = Error_Number(),
                            @w_linea      = Error_line(),
                            @w_desc_error = Error_Message()
                  
                  End Catch
                  
                  If IsNull(@w_error, 0) <> 0
                     Begin
                        Select @PnEstatus = @w_error,
                               @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);
                  
                        Insert Into dbo.Bitacora_CargosAbonos
                        (mensaje, idError, mensajeError, ultactual )
                        Values ('ERROR 14 ', @w_error, @w_desc_error, @w_fechaCaptura);
                  
                        Set Xact_Abort Off
                        Return
                     End
                End

--Inserta en la tabla CATAUXREPAÑO, la cta, sucursal y region correspondiente saldo cero, en el mes en curso.

            Set @w_sql = 'If Not Exists (Select Top 1 1 '          +
                                        'From   dbo.' + @w_catAuxReporte + ' With (Nolock) '             +
                                        'Where  Ejercicio   = ' + Cast(@PnAnio  As Varchar)              + ' ' +
                                        'And    mes         = ' + Cast(@PnIdMes As Varchar)              + ' '  +
                                        'And    Llave       = ' + @w_comilla + @w_llave     + @w_comilla + ' '  +
                                        'And    Moneda_id   = ' + @w_comilla + @w_moneda_id + @w_comilla + ' '  +
                                        'And    Sector_id   = ' + @w_comilla + @w_sector + @w_comilla    + ' '  +
                                        'And    Sucursal_id = ' + Convert(Varchar, @w_sucursal)          + ' '  +
                                        'And    Region_id   = ' + Convert(Varchar, @w_region)            + ') ' +
                            'Begin '                                                                     +
                               'Insert Into dbo.' + @w_catAuxReporte + ' '                               +
                              '(Ejercicio, Mes,       Llave,       moneda_id, '                          +
                               'nivel,     Sector_id, Sucursal_id, Region_id, '                          +
                               'SAct,      FecCap) '                                                     +
                               'Select ' + Cast(@PnAnio As Varchar)  + ', ' + Cast(@PnIdMes As Varchar)  + ', ' +
                                           @w_comilla + @w_llave     + @w_comilla                        + ', ' +
                                           @w_comilla + @w_moneda_id + @w_comilla + ', 1 nivel, '        +
                                           @w_comilla + @w_sector    + @w_comilla                        + ', ' +                                                                                                             +
                                           Cast(@w_sucursal As Varchar)                                  + ', ' +
                                           Cast(@w_region   As Varchar)                                  + ', ' +
                                           Cast(@w_importe  As Varchar)                                  + ', ' +
                                           @w_comilla + Cast(@w_fechaCaptura As Varchar) + @w_comilla    + ' '  +                                              +
                            'End '                                                                       +
                         'Else '                                                                         +
                            'Begin  '                                                                    +
                               'Update  dbo.' + @w_catAuxReporte                                         + ' '  +
                               'Set   SAct = SAct + ' + Case When @w_clave = 'C'
                                                             Then Convert(Varchar, @w_importe)
                                                             Else Convert(Varchar, -@w_importe)
                                                         End                                             + ' '   +
                               'Where  Ejercicio   = ' + Cast(@Pnanio  As Varchar)                       + ' '   +
                               'And    mes         = ' + Cast(@PnIdMes As Varchar)                       + ' '   +
                               'And    Llave       = ' + @w_comilla + @w_llave     + @w_comilla          + ' '   +
                               'And    Moneda_id   = ' + @w_comilla + @w_moneda_id + @w_comilla          + ' '   +
                               'And    Sector_id   = ' + @w_comilla + @w_sector    + @w_comilla          + ' '   +
                               'And    Sucursal_id = ' + Convert(Varchar, @w_sucursal)                   + ' '   +
                               'And    Region_id   = ' + Convert(Varchar, @w_region)                     + ' '   +
                        'End '

            Begin try
               Execute (@w_sql)
            End Try

            Begin Catch
               Select @w_error      = Error_Number(),
                      @w_linea      = Error_line(),
                      @w_desc_error = Error_Message()

            End Catch

            If IsNull(@w_error, 0) <> 0
               Begin
                  Select @PnEstatus = @w_error,
                         @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

                  Insert Into dbo.Bitacora_CargosAbonos
                  (mensaje, idError, mensajeError, ultactual )
                  Values ('ERROR 16 ', @w_error, @w_desc_error, @w_fechaCaptura);

                  Set Xact_Abort Off
                  Return
               End

            Set @w_sql = 'Update dbo.' + @w_catalagoAux                                               + ' '                                            +
                         'Set ' + Case When @w_clave = 'C'
                                       Then 'CarExt     = CarExt + '     + Convert(Varchar, @w_importe) + ', ' +
                                            'CarProceso = CarProceso + ' + Convert(Varchar, @w_importe)
                                       Else 'AboExt     = AboExt + '     + Convert(Varchar, @w_importe) + ', ' +
                                            'AboProceso = AboProceso + ' + Convert(Varchar, @w_importe)
                                  End + ' '

            Set @w_sql = @w_sql + 'Where Llave       = ' + @w_comilla + @w_llave      + @w_comilla + ' ' +
                                  'And   Moneda      = ' + @w_comilla + @w_moneda_id  + @w_comilla + ' ' +
                                  'And   Sucursal_id = ' + Convert(Varchar, @w_sucursal)           + ' ' +
                                  'And   Sector_id   = ' + @w_comilla + @w_Sector     + @w_comilla + ' ' +
                                  'And   Region_id   = ' + Convert(Varchar, @w_region)             + ' ' +
                                  'And   Ejercicio   = ' + Convert(Varchar, @PnAnio)               + ' ' +
                                  'And   mes         = ' + Convert(Varchar, @PnIdMes)

            Begin try
               Execute (@w_sql)
            End Try

            Begin Catch
               Select @w_error      = Error_Number(),
                      @w_linea      = Error_line(),
                      @w_desc_error = Error_Message()

            End Catch

            If IsNull(@w_error, 0) <> 0
               Begin
                  Select @PnEstatus = @w_error,
                         @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

                  Insert Into dbo.Bitacora_CargosAbonos
                  (mensaje, idError, mensajeError, ultactual )
                  Values ('ERROR 17 ', @w_error, @w_desc_error, @w_fechaCaptura);

                  Set Xact_Abort Off
                  Return
               End

            Set @w_sql = 'If Not Exists (Select Top 1 1 '                                                  +
                                        'From   dbo.' + @w_catAuxReporte + ' With (Nolock) '               +
                                        'Where  Ejercicio   = '   + Cast(@PnAnio  As Varchar)              + ' ' +
                                        'And    mes         = '   + Cast(@PnIdMes As Varchar)              + ' '  +
                                        'And    Llave       = '   + @w_comilla + @w_llave     + @w_comilla + ' '  +
                                        'And    Moneda_id   = '   + @w_comilla + @w_moneda_id + @w_comilla + ' '  +
                                        'And    Sector_id   = '   + @w_comilla + '00' + @w_comilla         + ' '  +
                                        'And    Sucursal_id = 0 '                                          +
                                        'And    Region_id   = 0) '                                         +
                            'Begin  '                                                                                                                       +
                               'Insert Into dbo.' + @w_catAuxReporte + ' '                                +
                              '(Ejercicio, Mes,       Llave,       moneda_id, '                          +
                               'nivel,     Sector_id, Sucursal_id, Region_id, '                          +
                               'SAct,      FecCap) '                                                     +
                               'Select ' + Cast(@PnAnio As Varchar) + ', ' + Cast(@PnIdMes As Varchar)   + ', ' +
                                           @w_comilla + @w_llave  + @w_comilla                           + ', ' +
                                           @w_comilla + @w_moneda_id + @w_comilla  + ', 1 nivel, '       +
                                           @w_comilla + '00' + @w_comilla                                + ', ' +                                                                                                             +
                                           '0 sucursal, 0 region, '                                      + ' '  +
                                           Cast(@w_importe  As Varchar)                                  + ', ' +
                                           @w_comilla + Cast(@w_fechaCaptura As Varchar) + @w_comilla    + ' '  +                                              +
                            'End '                                                                       +
                         'Else '                                                                         +
                            'Begin  '                                                                    +
                               'Update  dbo.' + @w_catAuxReporte                                         + ' '  +
                               'Set   SAct = SAct + ' + Case When @w_clave = 'C'
                                                             Then Convert(Varchar, @w_importe)
                                                             Else Convert(Varchar, -@w_importe)
                                                         End + ' ' +
                               'Where  Ejercicio   = ' + Cast(@Pnanio  As Varchar)                       + ' '   +
                               'And    mes         = ' + Cast(@PnIdMes As Varchar)                       + ' '   +
                               'And    Llave       = ' + @w_comilla + @w_llave     + @w_comilla          + ' '   +
                               'And    Moneda_id   = ' + @w_comilla + @w_moneda_id + @w_comilla          + ' '   +
                               'And    Sector_id   = ' + @w_comilla + '00' + @w_comilla                  + ' '  +
                               'And    Sucursal_id = 0 '                                                 +
                               'And    Region_id   = 0 '                                                 +
                        'End '

            Begin try
               Execute (@w_sql)
            End Try

            Begin Catch
               Select @w_error      = Error_Number(),
                      @w_linea      = Error_line(),
                      @w_desc_error = Error_Message()

            End Catch

            If IsNull(@w_error, 0) <> 0
               Begin
                  Select @PnEstatus = @w_error,
                         @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

                  Insert Into dbo.Bitacora_CargosAbonos
                  (mensaje, idError, mensajeError, ultactual )
                  Values ('ERROR 18 ', @w_error, @w_desc_error, @w_fechaCaptura);

                  Set Xact_Abort Off
                  Return
               End

--         Actualiza los saldos de la cta, sucursal y region correspondiente, en el catalogo auxiliar del mes en curso.'

            Set @w_sql = 'Update  dbo.' + @w_catalagoAux + ' '                                          +
                         'Set ' + Case When @w_clave = 'C'
                                       Then 'CarExt     = CarExt     + ' + Convert(Varchar, @w_importe) + ', ' +
                                            'CarProceso = CarProceso + ' + Convert(Varchar, @w_importe)
                                       Else 'AboExt     = AboExt     + ' + Convert(Varchar, @w_importe) + ', ' +
                                            'AboProceso = AboProceso + ' + Convert(Varchar, @w_importe)
                                  End + ' '

            Set @w_sql = @w_sql + 'Where ejercicio   = ' + Cast(@PnAnio  As VarChar)              + ' ' +
                                  'And   mes         = ' + Cast(@PnIdMes As Varchar)              + ' ' +
                                  'And   Llave       = ' + @w_comilla + @w_llave     + @w_comilla + ' ' +
                                  'And   Moneda      = ' + @w_comilla + @w_moneda_id + @w_comilla + ' ' +
                                  'And   Sector_id   = ' + @w_comilla + '00'         + @w_comilla + ' ' +
                                  'And   Sucursal_id =  0 '                                       +
                                  'And   Region_id   =  0 '

            Begin try
               Execute (@w_sql)
            End Try

            Begin Catch
               Select @w_error      = Error_Number(),
                      @w_linea      = Error_line(),
                      @w_desc_error = Error_Message()

            End Catch

            If IsNull(@w_error, 0) <> 0
               Begin
                  Select @PnEstatus = @w_error,
                         @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

                  Insert Into dbo.Bitacora_CargosAbonos
                  (mensaje, idError, mensajeError, ultactual )
                  Values ('ERROR 19 ', @w_error, @w_desc_error, @w_fechaCaptura);

                  Set Xact_Abort Off
                  Return
               End

-- catalogoReporte

--
-- cuenta contable. Nivel 1.
--

            Set @w_sql = 'If Not Exists ( Select Top 1 1 '  +
                                         'From   dbo.' + @w_catReporte + ' With (Nolock) '                 +
                                         'Where  ejercicio = '    + Cast(@PnAnio      As Varchar)          + ' ' +
                                         'And    mes       = '    + Cast(@PnIdMes     As Varchar)          + ' ' +
                                         'And    Llave     = '    + @w_comilla + @w_llave     + @w_comilla + ' ' +
                                         'And    moneda_id = '    + @w_comilla + @w_moneda_id + @w_comilla + ' ' +
                                         'And    nivel     = 1) ' +
                            'Begin ' +
                               'Insert Into dbo.' + @w_catReporte                 +
                               '(Ejercicio, Mes, Llave, moneda_id, nivel, SAct) ' +
                               'Select ' + Cast(@PnAnio      As Varchar) + ', '   +
                                           Cast(@PnIdMes     As Varchar) + ', '   +
                                           @w_comilla + @w_llave     + @w_comilla + ', ' +
                                           @w_comilla + @w_moneda_id + @w_comilla + ', 1, ' +
                                           Cast(@w_importe As Varchar)            + ' ' +
                            'End '                                                                                              +
                         'Else '                                                                                                +
                            'Begin ' +
                               'Update dbo.' + @w_catReporte   + ' ' +
                               'Set   SAct   = SAct  + ' +
                                                          Case When @w_clave = 'C'
                                                            Then Cast(@w_importe  As Varchar)
                                                            Else Cast(-@w_importe As Varchar)
                                                          End + ' ' +
                               'Where  ejercicio = '   + Cast(@PnAnio      As Varchar)          + ' ' +
                               'And    mes       = '   + Cast(@PnIdMes     As Varchar)          + ' ' +
                               'And    Llave     = '   + @w_comilla + @w_llave     + @w_comilla + ' ' +
                               'And    moneda_id = '   + @w_comilla + @w_moneda_id + @w_comilla + ' ' +
                           'End'

            Begin try
               Execute (@w_sql)
            End Try

            Begin Catch
               Select @w_error      = Error_Number(),
                      @w_linea      = Error_line(),
                      @w_desc_error = Error_Message()

            End Catch

            If IsNull(@w_error, 0) <> 0
               Begin
                  Select @PnEstatus = @w_error,
                         @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

Select @w_sql
                  Insert Into dbo.Bitacora_CargosAbonos
                  (mensaje, idError, mensajeError, ultactual )
                  Values ('ERROR 20', @w_error, @w_desc_error, @w_fechaCaptura);

                  Set Xact_Abort Off
                  Return
               End

         End -- Fin del else


   End -- fin del while


-- Consolidación del Catalogo Reportes

--
-- Se consulta si hay movimientos en catReportes a fin de consolidar el arbol.
--

   Select @w_consulta = Concat('Select @o_existe = Count(1) ',
                               'From   dbo.', @w_catReporte, ' With (Nolock) ',
                               'Where  ejercicio = ', @PnAnio,  ' ',
                               'And    mes       = ', @PnIdMes),
          @w_param    = '@o_existe   Integer Output';

   Begin Try
      Execute Sp_ExecuteSQL @w_consulta, @w_param, @o_existe = @w_existe Output
   End   Try

         Begin Catch
            Select @w_error      = Error_Number(),
                   @w_linea      = Error_line(),
                   @w_desc_error = Error_Message()

         End Catch

         If IsNull(@w_error, 0) <> 0
            Begin
               Select @PnEstatus = @w_error,
                      @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

               Insert Into dbo.Bitacora_CargosAbonos
               (mensaje, idError, mensajeError, ultactual )
               Values ('ERROR 21', @w_error, @w_desc_error, @w_fechaCaptura);

               Set Xact_Abort Off
               Return
            End

   If @w_existe != 0
      Begin
         Set @w_sql = Concat('Delete dbo.', @w_catReporte,    ' ',
                             'Where  ejercicio = ', @PnAnio,  ' ',
                             'And    mes       = ', @PnIdMes, ' ' +
                             'And    nivel    != 1 ')

         Begin try
            Execute (@w_sql)
         End Try

         Begin Catch
            Select @w_error      = Error_Number(),
                   @w_linea      = Error_line(),
                   @w_desc_error = Error_Message()

         End Catch

         If IsNull(@w_error, 0) <> 0
            Begin
               Select @PnEstatus = @w_error,
                      @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

               Insert Into dbo.Bitacora_CargosAbonos
               (mensaje, idError, mensajeError, ultactual )
               Values ('ERROR 21', @w_error, @w_desc_error, @w_fechaCaptura);

               Set Xact_Abort Off
               Return
            End

--
-- Actualizando Cuenta Mayor
--

         Set @w_sql = Concat('Insert Into  dbo.', @w_catReporte, '  ',
                            '(Ejercicio, Mes, Llave, moneda_id,  ', ' ',
                             'nivel,     SAct, FecCap)  ',         ' ',
                             'Select Ejercicio, Mes,      Concat(Substring(llave, 1, 4), Replicate(0, 12)), moneda_id, ',
                                    '0,         Sum(SAct), Max(FecCap) ',
                             'From   dbo.', @w_catReporte, ' With (NoLock) ',
                             'Where  ejercicio = ', @PnAnio,  ' ',
                             'And    mes       = ', @PnIdMes, ' ',
                             'And    nivel     = 1 ',
                             'Group  BY Ejercicio, Mes, Concat(Substring(llave, 1, 4), Replicate(0, 12)), moneda_id ')

         Begin try
            Execute (@w_sql)
         End Try

         Begin Catch
            Select @w_error      = Error_Number(),
                   @w_linea      = Error_line(),
                   @w_desc_error = Error_Message()

         End Catch

         If IsNull(@w_error, 0) <> 0
            Begin
               Select @PnEstatus = @w_error,
                      @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

               Insert Into dbo.Bitacora_CargosAbonos
               (mensaje, idError, mensajeError, ultactual )
               Values ('ERROR 22', @w_error, @w_desc_error, @w_fechaCaptura);

               Set Xact_Abort Off
               Return
            End

--
-- Actualizando SubCta
--

         Set @w_sql = Concat('Insert Into  dbo.', @w_catReporte, '  ',
                            '(Ejercicio, Mes, Llave, moneda_id,  ', ' ',
                             'nivel,     SAct, FecCap)  ',         ' ',
                             'Select Ejercicio, Mes,      Concat(Substring(llave, 1, 6), Replicate(0, 10)), moneda_id, ',
                                    '0,         Sum(SAct), Max(FecCap) ',
                             'From   dbo.', @w_catReporte, ' a ',
                             'Where  ejercicio = ', @PnAnio,  ' ',
                             'And    mes       = ', @PnIdMes, ' ',
                             'And    nivel     = 1 ',
                             'And    Substring(Llave, 5, 2) != ', @w_comilla , '00', @w_comilla, ' ' ,
                             'Group  BY Ejercicio, Mes, Concat(Substring(llave, 1, 6), Replicate(0, 10)), moneda_id ')

         Begin try
            Execute (@w_sql)
         End Try

         Begin Catch
            Select @w_error      = Error_Number(),
                   @w_linea      = Error_line(),
                   @w_desc_error = Error_Message()

         End Catch

         If IsNull(@w_error, 0) <> 0
            Begin
               Select @PnEstatus = @w_error,
                      @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

               Insert Into dbo.Bitacora_CargosAbonos
               (mensaje, idError, mensajeError, ultactual )
               Values ('ERROR 23', @w_error, @w_desc_error, @w_fechaCaptura);

               Set Xact_Abort Off
               Return
            End

--
-- Actualizando SSubCta
--

         Set @w_sql = Concat('Insert Into  dbo.', @w_catReporte, '  ',
                            '(Ejercicio, Mes, Llave, moneda_id,  ', ' ',
                             'nivel,     SAct, FecCap)  ',         ' ',
                             'Select Ejercicio, Mes,       Concat(Substring(llave, 1, 8), Replicate(0, 8)), moneda_id, ',
                                    '0,         Sum(SAct), Max(FecCap) ',
                             'From   dbo.catalogoReporteTbl ',
                             'Where  ejercicio = ', @PnAnio,  ' ',
                             'And    mes       = ', @PnIdMes, ' ',
                             'And    nivel     = 1 ',
                             'And    Substring(Llave, 7, 2) != ', @w_comilla , '00', @w_comilla, ' ' ,
                             'Group  BY Ejercicio, Mes, Concat(Substring(llave, 1, 8), Replicate(0, 8)), moneda_id ')

         Begin try
            Execute (@w_sql)
         End Try

         Begin Catch
            Select @w_error      = Error_Number(),
                   @w_linea      = Error_line(),
                   @w_desc_error = Error_Message()

         End Catch

         If IsNull(@w_error, 0) <> 0
            Begin
               Select @PnEstatus = @w_error,
                      @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

               Insert Into dbo.Bitacora_CargosAbonos
               (mensaje, idError, mensajeError, ultactual )
               Values ('ERROR 24', @w_error, @w_desc_error, @w_fechaCaptura);

               Set Xact_Abort Off
               Return
            End


--
-- Actualizando SSSubCta
--

         Set @w_sql = Concat('Insert Into  dbo.', @w_catReporte, '  ',
                            '(Ejercicio, Mes, Llave, moneda_id,  ', ' ',
                             'nivel,     SAct, FecCap)  ',         ' ',
                             'Select Ejercicio, Mes,       Concat(Substring(llave, 1, 10), Replicate(0, 6)), moneda_id, ',
                                    '0,         Sum(SAct), Max(FecCap) ',
                             'From   dbo.catalogoReporteTbl ',
                             'Where  ejercicio = ', @PnAnio,  ' ',
                             'And    mes       = ', @PnIdMes, ' ',
                             'And    nivel     = 1 ',
                             'And    Substring(Llave, 9, 2) != ', @w_comilla , '00', @w_comilla, ' ' ,
                             'Group  BY Ejercicio, Mes, Concat(Substring(llave, 1, 10), Replicate(0, 6)), moneda_id ')

         Begin try
            Execute (@w_sql)
         End Try

         Begin Catch
            Select @w_error      = Error_Number(),
                   @w_linea      = Error_line(),
                   @w_desc_error = Error_Message()

         End Catch

         If IsNull(@w_error, 0) <> 0
            Begin
               Select @PnEstatus = @w_error,
                      @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

               Insert Into dbo.Bitacora_CargosAbonos
               (mensaje, idError, mensajeError, ultactual )
               Values ('ERROR 25', @w_error, @w_desc_error, @w_fechaCaptura);

               Set Xact_Abort Off
               Return
            End

      End
-- Actualiza los saldos de la subcta correspondiente, en el catalogo del mes en curso.

   Set @w_sql = 'Update ' + @w_catalogo                                                         + '  ' +
                'Set ' + Case When @w_clave = 'C'
                              Then 'CarExt     = CarExt + '     + Convert(Varchar, @w_importe)  + ', '  +
                                   'CarProceso = CarProceso + ' + Convert(Varchar, @w_importe)  + '  '  +
                                   'Where Ejercicio = ' + Cast(@PnAnio  As Varchar)             + '  '  +
                                   'And   mes       = ' + Cast(@PnIdMes As Varchar)             + '  '  +
                                   'And   Moneda    = ' + Cast(@w_moneda_id As Varchar)         + '  '  +
                                   'And   Niv       = 0 '                                               +
                                   'And   Llave    ' +  Case When @w_NCta = '00'
                                                             Then ' In ( '+ @w_comilla + @w_SubCta   + @w_comilla + ', ' + @w_comilla + @w_ctaMayor + @w_comilla + ') '
                                                             Else ' In ( '+ @w_comilla + @w_SSSubCta + @w_comilla + ', ' + @w_comilla + @w_SSubCta  + @w_comilla + ', ' +
                                                                  '      '+ @w_comilla + @w_SubCta   + @w_comilla + ', ' + @w_comilla + @w_ctaMayor + @w_comilla + ') '
                                                        End
                              Else 'AboExt          = AboExt     + ' + Convert(Varchar, @w_importe) + ', '              +
                                   'AboProceso      = AboProceso + ' + Convert(Varchar, @w_importe) + ' '           +
                                   'Where Ejercicio = ' + Cast(@PnAnio  As Varchar)             + '  '  +
                                   'And   mes       = ' + Cast(@PnIdMes As Varchar)             +  ' '  +
                                   'And   Moneda    =  ' + Cast(@w_moneda_id As Varchar)           + '  '                   +
                                   'And   Niv       =  0  '                                                             +
                                   'And   Llave    ' + Case When @w_NCta = '00'
                                                            Then ' In( ' + @w_comilla + @w_SubCta   + @w_comilla + ', '   +
                                                                         + @w_comilla + @w_ctaMayor + @w_comilla + ') '
                                                            Else ' In( ' + @w_comilla + @w_SSSubCta + @w_comilla + ', '  +
                                                                      + @w_comilla + @w_SSubCta  + @w_comilla + ', '  +
                                                                      + @w_comilla + @w_SubCta   + @w_comilla + ', '  +
                                                                      + @w_comilla + @w_ctaMayor + @w_comilla + ')'
                                                       End
                         End

   Begin try
       Execute (@w_sql)
   End Try

   Begin Catch
      Select @w_error      = Error_Number(),
             @w_linea      = Error_line(),
             @w_desc_error = Error_Message()

   End Catch

   If IsNull(@w_error, 0) <> 0
      Begin
         Select @PnEstatus = @w_error,
                @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

         Insert Into dbo.Bitacora_CargosAbonos
         (mensaje, idError, mensajeError, ultactual )
         Values ('ERROR 26', @w_error, @w_desc_error, @w_fechaCaptura);

         Set Xact_Abort Off
         Return
      End


   Set Xact_Abort Off
   Return
End
Go

--
-- Comentarios.
--

Declare
   @w_valor          Varchar(1500) = 'Aplica las pólizas a fin de actualizar cargos y abonos.',
   @w_procedimiento  Varchar( 100) = 'Spp_AplicaPolizas'


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
