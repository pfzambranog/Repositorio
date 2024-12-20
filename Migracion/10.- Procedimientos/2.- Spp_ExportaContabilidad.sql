Use SisArrendaCredito
Go

---- ==========================================================================================================================================================
---- Descripción            : SP que exporta las pólizas contables
---- Modifico               : Zayra Mtz Candia
---- Versión                : 1.1
---- Fecha de Actualizacion : 30/12/2021
---- Descripcion del Cambio : Se cambio la posicion de EXECUTE para SET, ya que no se esta ejecutando
---- ==========================================================================================================================================================
---- ==========================================================================================================================================================
---- Descripción            : SP que exporta las pólizas contables
---- Modifico               : Zayra Mtz Candia
---- Versión                : 1.2
---- Fecha de Actualizacion : 09/02/2022
---- Descripcion del Cambio : Se agrega LOG
---- ==========================================================================================================================================================
---- ==========================================================================================================================================================
---- Descripción            : SP que exporta las pólizas contables
---- Modifico               : Zayra Mtz Candia
---- Versión                : 1.3
---- Fecha de Actualizacion : 10/01/2023
---- Descripcion del Cambio : Se cambia forma de insercion de Referencia_Exporta
---- ==========================================================================================================================================================
---- Ver 1.0.4 (Emma Aidé Solís Castañeda) Task 17901. Se modifican fechas Inicio y final para procesar. (26/Junio/2023)
---- Ver 1.0.5 (Emma Aidé Solís Castañeda) Task 18225. Se modifica proceso para obtener folio con respecto al mes y se valida si existe, sino se obtiene el mínimo menos 1. (06/Julio/2023)
---- Ver 1.0.6 (Emma Aidé Solís Castañeda) Task 18225. Se agrega validación para asignar los folios si ya se encuentran en MovDia.
---- Ver 1.0.7 (Emma Aidé Solís Castañeda) Task 19740. Se modifica generación de folio de acuerdo a los meses correspondientes. (20230822)
---- V1.0.8     Zayra Martinez Candia      TASK 40231. 30/08/2024. Se cambia longitud de campo Documento, para que no trunque los datos del mismo.
---- V1.0.9     Pedro Felipe Zambrano.     TASK,       08/10/2024.

-- Declare @PnEstatus Int, @PsMensaje Varchar(250) Execute Spp_ExportaContabilidad '2024-09-30', 1, @PnEstatus Output, @PsMensaje Output Select @PnEstatus, @PsMensaje

Create Or Alter Procedure dbo.Spp_ExportaContabilidad
  (@PdFechaProceso       Date,
   @PnIdUsuarioAct       Smallint,
   @PnEstatus            Integer       = 0     Output ,
   @PsMensaje            Varchar(250)  = Null  Output)
As

Declare
   @w_FechaInicio                Date,
   @w_FechaFin                   Date,
   @w_Error                      Integer,
   @w_sql                        Varchar(Max),
   @w_numPolizas                 Integer,
   @w_operacion                  Integer,
   @w_Desc_Error                 Varchar(250),
   @w_ultActual                  Datetime,
   @w_usuario                    Varchar(   10),
   @w_ipAct                      Varchar(   30),
   @w_Referencia                 Varchar(    6),
   @w_referencia2                Varchar(   20),
   @w_poliza                     Varchar(    6),
   @w_FechaContable              Date,
   @w_fechaCaptura               Date,
   @w_Concepto                   Varchar(  255),
   @w_Cargos                     Numeric(18, 2),
   @w_Abonos                     Numeric(18, 2),
   @w_TCons                      Integer,
   @w_secuencia                  Integer,
   @w_secuencia2                 Integer,
   @w_linea                      Integer,
   @w_tipo                       Varchar(    3),
   @w_documento                  Varchar(   255),  --ZCMC TASK 40231
   @w_TipoContabPro              Varchar(    3),
   @w_Status                     Tinyint,
   @w_Mes_Mov                    Varchar(    3),
   @w_FuenteDatos                Varchar(  100),
--
   @w_ejercicio                  Integer,
   @w_mes                        Integer,
   @w_chmes                      Varchar(3);

Begin

   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off

   Select @PnEstatus      = dbo.Fn_ValidaUsuarioActivo (@PnIdUsuarioAct),
          @PsMensaje      = ' ',
          @w_operacion    = 9999,
          @w_sql          = dbo.Fn_BuscaResultadosParametros( 411, 'cadena'),
          @w_usuario      = dbo.Fn_BuscaCodigoUsuario(@PnIdUsuarioAct),
          @w_ultActual    = Getdate(),
          @w_fechaCaptura = Cast(@w_ultActual As Date),
          @w_FechaFin     = DateAdd(dd, 1, @PdFechaProceso),
          @w_ipAct        = dbo.Fn_BuscaDireccionIP(),
          @w_Status       = 2,
          @w_Mes_Mov      = Substring(Upper(Format(@PdFechaProceso, 'MMM', 'es-es')), 1, 3),
          @w_FuenteDatos  = 'SISARRENDACREDITO';

--
-- Validación de Usuario.
--

   If @PnEstatus != 0
      Begin
         Set @PsMensaje = 'Error.: ' + dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus)

    -- Registro en log

         Insert Into dbo.LogExportacionPolizas
         (Fecha, Descripcion, hora_terminacion)
         Select @w_ultActual, @PsMensaje, Getdate();

         Set Xact_Abort Off
         Return
      End

   If Isdate(@w_sql) = 1
      Begin
         Set @w_FechaInicio = Cast(@w_sql As Date);
      End
   Else
      Begin
         Select @PnEstatus = 9999,
                @PsMensaje = 'Error: El Parámetro 411 no es una fecha válida.';

         Insert Into dbo.LogExportacionPolizas
         (Fecha, Descripcion, hora_terminacion)
         Select @w_ultActual, @PsMensaje, Getdate();

         Set Xact_Abort    Off
         Return
      End

   --1) El tipo de poliza igual al cabecero                                            --Ok
   --2) Que cuadren cargos y abonos del cabecero vs cargos y abonos del detalle        --OK
   --3) Que todas las polizas traigan centro de costos                                 --OK
   --4) Que todas las polizas traigan fecha menor o igual al proceso de fin de dia     --OK
   --5) Que no traigan nulos                                                           --OK
   --6) Validar que todas las polizas traigan usuario                                  --OK
   --7) Validar que el detalle, todas las polizas traigan cuenta contable              --OK
   --8) Validar que el detalle, que todas las polizas auxiliar en la cuenta contable   --OK

   -- Registro en log

   Insert Into dbo.LogExportacionPolizas
   (Fecha, Descripcion, hora_terminacion)
   Select @w_ultActual, 'Validacion 1 (INICIO)', Getdate();

   --Validacion 1 (INICIO)
     -- 1) Se Actualiza poliza_mov con los datos del tipo de poliza incorrecto y correcto.

   Update pm
   Set    PM.TipoPoliza = tp.TipoContabPro
   From   dbo.poliza_mov pm With (Nolock)
   Join   dbo.tipoPoliza tp With (Nolock)
   On     pm.TipoPoliza   = tp.Tipo
   Where  Fecha_Mov Between @w_FechaInicio And @w_FechaFin;

   --Validacion 1 (TERMINO)

   --Validacion 2 (INICIO)

   -- Registro en log

   Insert Into dbo.LogExportacionPolizas
  (Fecha, Descripcion, hora_terminacion)
   Select @w_ultActual, 'Dif Cargos y Abonos', Getdate();

   --2) Que cuadren cargos y abonos del cabecero vs cargos y abonos del detalle

   Update dbo.Poliza
   Set    Referencia_Exporta = 'Dif Cargos y Abonos'
   Where  fechaContable Between @w_FechaInicio And @PdFechaProceso
   And    Referencia_Exporta is Null
   And    trim(Referencia) + '-' + trim(Convert(Varchar, FechaContable, 112)) In
         (Select trim(Datos.Referencia) + '-' + trim(Convert(Varchar, Datos.FechaContable, 112))
          From  (Select a.Referencia, a.FechaContable,
                        Round((Sum(Case When a.Clave = 'D'
                                        Then a.Importe  / 100.00
                                        Else -a.Importe / 100.00
                                   End)), 2) as Diferencia
                 From   dbo.poliza_mov     a With (Nolock)
                 Join   dbo.poliza         b With (Nolock)
                 On     b.FechaContable = a.FechaContable
                 And    b.referencia    = a.referencia
                 Where  b.Referencia_Exporta Is Null
                 Group by a.Referencia, a.FechaContable) Datos
          Join   dbo.poliza pol With (Nolock)
          On     Datos.FechaContable = pol.FechaContable
          And    Datos.Referencia    = pol.Referencia
          Where  Diferencia <> 0);

   --Validacion 2 (TERMINO)


   --Validacion 3 (INICIO)

   -- Registro en log

   Insert Into dbo.LogExportacionPolizas
  (Fecha, Descripcion, hora_terminacion)
   Select @w_ultActual, 'Sin Centro de Costos', Getdate();

   Update dbo.Poliza
   Set    Referencia_Exporta = 'Sin Centro de Costos'
   From   dbo.Poliza a With (Nolock)
   Where  a.fechaContable Between @w_FechaInicio And @PdFechaProceso
   And    a.Referencia_Exporta is Null
   And    trim(a.Referencia) + '-' + trim(convert(Varchar, a.FechaContable, 112)) In
         (Select trim(Referencia) + '-' + trim(convert(Varchar, FechaContable, 112))
          From   dbo.Poliza_mov With (Nolock)
          Where  FechaContable = a.FechaContable
          And    referencia    = a.referencia
          And   (len(Sucursal_id) < 7
          Or     len(Region_id)   < 4));

   --Validacion 3 (TERMINO)

   --Validacion 4 (INICIO)
     --OK, el proceso se ejecuta unicamente con las polizas con fecha menor o igual, a la fecha del parametro
   --Validacion 4 (INICIO)

   --Validacion 5 (INICIO)
   -- Registro en log

   Insert Into dbo.LogExportacionPolizas
  (Fecha, Descripcion, hora_terminacion)
   Select @w_ultActual, 'Sin Concepto', Getdate();

   Update dbo.Poliza
   Set    Concepto = Upper(Concepto)
   From   dbo.poliza With  (Index (IX_poliza_FechaContable_poliza) nolock)
   Where  fechaContable Between @w_FechaInicio And @PdFechaProceso;

   Update dbo.Poliza
   Set    Referencia_Exporta = 'Sin Concepto'
   From   dbo.poliza With  (Index (IX_poliza_FechaContable_poliza) nolock)
   Where  fechaContable Between @w_FechaInicio And @PdFechaProceso
   And    Concepto           Is Null
   And    Referencia_Exporta Is Null;

   --Validacion 5 (TERMINO)

   --Validacion 7 (INICIO)

   -- Registro en log

   Insert Into dbo.LogExportacionPolizas
  (Fecha, Descripcion, hora_terminacion)
   Select @w_ultActual, 'Sin Cta Contable', Getdate();

   Update dbo.Poliza
   Set    Referencia_Exporta = 'Sin Cta Contable'
   From   dbo.Poliza     a With (Nolock)
   Join   dbo.Poliza_mov b With (Nolock)
   On     b.FechaContable = a.FechaContable
   And    b.Referencia    = a.Referencia
   Where  b.FechaContable Between @w_FechaInicio And @PdFechaProceso
   And   (b.llave = ''
   or     b.llave = 'PROV SIN AUX');

   --Validacion 7 (TERMINO)

   --Validacion 8 (INICIO)

   -- Registro en log

   Insert Into dbo.LogExportacionPolizas
  (Fecha, Descripcion, hora_terminacion)
   Select @w_ultActual, 'Ctas sin auxiliar', Getdate();

   Update dbo.Poliza
   Set    Referencia_Exporta = 'Ctas sin auxiliar'
   From   dbo.Poliza     a With (Nolock)
   Join   dbo.Poliza_mov b With (Nolock)
   On     b.FechaContable       = a.FechaContable
   And    b.Referencia          = a.Referencia
   Where  b.FechaContable Between @w_FechaInicio And @PdFechaProceso
   And    b.Llave               = ''


   Select @w_numPolizas = count(1)
   From    dbo.poliza     a With(Nolock)
   Join    dbo.tipoPoliza b With(Nolock)
   On      b.tipo                = Substring(a.referencia, 1, 2)
   And     b.TipoContabilizacion = 1
   Where   a.FechaContable Between @w_FechaInicio And @PdFechaProceso
   And     a.cargos              = a.abonos
   And     a.cargos             != 0
   And     a.Referencia_Exporta Is Null;
   
   Set @w_numPolizas = Isnull(@w_numPolizas, 0);

   Insert Into dbo.LogExportacionPolizas
   (Fecha, Descripcion, hora_terminacion)
   Select @w_ultActual, Concat('Incia cursores, se procesaran ', @w_numPolizas, ' polizas'), Getdate();

-- Comienza el codigo original del proceso

--
-- Consulta y Validaciones de Datos y Parámetros
--

  -- Registro en log

   Insert Into dbo.LogExportacionPolizas
  (Fecha, Descripcion, hora_terminacion)
   Select @w_ultActual, 'Consulta y Validaciones de Datos y Parámetros', Getdate();

   Declare
      C_Detalle Cursor For
      Select  a.Referencia,       a.FechaContable,  a.Concepto, a.Cargos / 100.00,
              a.Abonos / 100.00,  a.TCons,          b.tipo,     a.documento,
              b.TipoContabPro, a.poliza
      From    dbo.poliza     a With(Nolock)
      Join    dbo.tipoPoliza b With(Nolock)
      On      b.tipo                = Substring(a.referencia, 1, 2)
      And     b.TipoContabilizacion = 1
      Where   a.FechaContable Between @w_FechaInicio And @PdFechaProceso
      And     a.cargos              = a.abonos
      And     a.cargos             != 0
      And     a.Referencia_Exporta Is Null
      Order   By 1;

   Begin Transaction

      Open   C_Detalle
      While  @@Fetch_status < 1
      Begin
         Fetch C_Detalle Into @w_Referencia,    @w_FechaContable,  @w_Concepto, @w_Cargos,
                              @w_Abonos,        @w_TCons,          @w_tipo,     @w_documento,
                              @w_TipoContabPro, @w_poliza
         If @@Fetch_Status <> 0
            Begin
               Break
            End

      -- ==============================================================================================================================
      -- SE CAMBIA FORMA DE OBTENER LA SECUENCIA PARA LA REFERENCIA_EXPORTA Y REFERENCIA EN TABLA MOVDIA DE DB_GEN_DES [ZCMC10012023]
      --===============================================================================================================================

         Select @w_secuencia = Max(Substring(Referencia_exporta, 4, 7))
         From   dbo.poliza With (Nolock)
         Where (Referencia_exporta                  Is Not Null
         And    Referencia_exporta                  != 'Ctas sin auxiliar'
         And    Referencia_exporta                  != 'Dif Cargos y Abonos')
         And    Substring(Referencia_exporta, 1, 3)  = @w_TipoContabPro
         And    Cast(FechaContable As Date)          = @w_FechaContable;

         Select @w_secuencia   = Isnull(@w_secuencia, 0) + 1,
                @w_Referencia2 = Concat(@w_TipoContabPro, Format(@w_secuencia, '00000')),
                @w_ejercicio   = DatePart(yy, @w_FechaContable),
                @w_mes         = DatePart(mm, @w_fechaContable),
                @w_chMes       = Substring(Upper(Format(@w_fechaContable, 'MMM', 'es-es')), 1, 3);

         Begin Try
            Insert Into DB_Siccorp_DES.dbo.PolDia
           (Referencia, Fecha_Mov, Fecha_Cap,       Concepto,
            Cargos,     Abonos,    TCons,           Usuario,
            TipoPoliza, Documento, Usuario_cancela, Fecha_Cancela,
            Status,     Mes_Mov,   TipoPolizaConta, FuenteDatos,
            Ejercicio,  Mes)
            Select @w_Referencia2,   @w_FechaContable, @w_fechaCaPtura,   @w_Concepto,
                   @w_Cargos,        @w_Abonos,        @w_TCons,          @w_Usuario,
                   @w_TipoContabPro, @w_Documento,     Null,              Null,
                   @w_Status,        @w_chMes,         @w_tipo,           @w_FuenteDatos,
                   @w_ejercicio,     @w_mes
         End Try

         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_linea      = Error_line(),
                    @w_desc_error = Concat(Substring (Error_Message(), 1, 220), ' Linea: ', @w_linea); 
         End  Catch

         If Isnull(@w_Error, 0) <> 0
            Begin
               Select @PnEstatus = @w_error,
                      @PsMensaje = 'Error.:  DB_Siccorp_DES.dbo.PolDia ' + @w_desc_error

               Rollback Transaction

    -- Registro en log

               Insert Into dbo.LogExportacionPolizas
              (Fecha, Descripcion, hora_terminacion)
               Select @w_ultActual, @PsMensaje, Getdate();

               Close      C_Detalle
               Deallocate C_Detalle

               Set Xact_Abort Off
               Return
            End

         Begin Try
            Insert Into DB_Siccorp_DES.dbo.MovDia
           (Referencia,      Cons,             Moneda,        Fecha_mov,
            Llave,           Concepto,         Importe,       Documento,
            Clave,           FecCap,           Sector_id,     Sucursal_id,
            Region_id,       Importe_Cargo,    Importe_Abono, Descripcion,
            TipoPolizaConta, ReferenciaFiscal, Fecha_Doc,     Ejercicio,
            Mes)
            Select @w_Referencia2, Cons,            '00'  Moneda,       @w_FechaContable,
                   Llave,          Concepto,         Importe / 100.00,  Documento,
                   Clave,          @w_fechaCaptura,  Null Sector,       Sucursal_id,
                   Region_id,      Case When Clave = 'D'
                                        Then Importe / 100.00
                                        Else 0
                                   End,              Case When Clave != 'D'
                                                          Then Importe / 100.00
                                                          Else 0
                                                     End,               Descripcion,
                   TipoPoliza,     ReferenciaFiscal, Fecha_Doc,         @w_ejercicio,
                   @w_mes
            From    dbo.poliza_mov
            Where   poliza        = @w_poliza
            And     Referencia    = @w_Referencia
            And     FechaContable = @w_FechaContable
            And     importe      != 0

         End Try

         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_linea      = Error_line(),
                    @w_desc_error = Concat(Substring (Error_Message(), 1, 220), ' Linea: ', @w_linea); 
         End   Catch

         If Isnull(@w_Error, 0) <> 0
            Begin
               Select @PnEstatus = @w_error,
                      @PsMensaje = 'Error.: DB_Siccorp_DES.dbo.MovDia ' + @w_desc_error

               Rollback Transaction

     --  Registro en log

               Insert Into dbo.LogExportacionPolizas
              (Fecha, Descripcion, hora_terminacion)
               Select @w_ultActual, @PsMensaje, Getdate();

               Close      C_Detalle
               Deallocate C_Detalle
               Set Xact_Abort Off
               Return
            End

         Begin Try
            Insert Into DB_Siccorp_DES.dbo.Relacionimp
           (Referencia, Fecha_Mov,   Fecha_Cap,        NewReferencia,
            Usuario,    FuenteDatos, FechaImportacion, Ejercicio,
            mes)
            Select @w_Referencia2,   @w_FechaContable, @w_fechaCaPtura, Null,
                   @w_usuario,       @w_FuenteDatos,   Null,            @w_ejercicio,
                   @w_mes;
         End Try

         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_linea      = Error_line(),
                    @w_desc_error = Concat(Substring (Error_Message(), 1, 220), ' Linea: ', @w_linea); 
         End   Catch

         If Isnull(@w_Error, 0) <> 0
            Begin
               Select @PnEstatus = @w_error,
                      @PsMensaje = 'Error.: DB_Siccorp_DES.dbo.Relacionimp ' + @w_desc_error

               Rollback Transaction

         -- Registro en log
               Insert Into dbo.LogExportacionPolizas
              (Fecha, Descripcion, hora_terminacion)
               Select @w_ultActual, @PsMensaje, Getdate();

               Close      C_Detalle
               Deallocate C_Detalle
               Set Xact_Abort Off
               Return
            End

         Begin Try
            Update dbo.Poliza
            Set    Referencia_Exporta = @w_Referencia2
            Where  referencia         = @w_Referencia
            And    fechaContable      = @w_FechaContable
         End Try

         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_linea      = Error_line(),
                    @w_desc_error = Concat(Substring (Error_Message(), 1, 220), ' Linea: ', @w_linea); 
         End   Catch

         If Isnull(@w_Error, 0) <> 0
            Begin
               Select @PnEstatus = @w_error,
                      @PsMensaje = 'Error.:  Actualizando dbo.PolDia ' + @w_desc_error

               Rollback Transaction

       -- Registro en log

               Insert Into dbo.LogExportacionPolizas
              (Fecha, Descripcion, hora_terminacion)
               Select @w_ultActual, @PsMensaje, Getdate();

               Close      C_Detalle
               Deallocate C_Detalle
               Set Xact_Abort Off
               Return
            End

      End
      Close      C_Detalle
      Deallocate C_Detalle

--
-- Tipo Contabilización 2
--

      Declare
         C_Detalle2 Cursor For
         Select  Substring(a.Referencia, 1, 2),  a.FechaContable,        Concat(upper(b.descripcion), ' DEL ', Convert(Char(10), a.FechaContable, 103)),
                 Sum(a.Cargos) / 100.00,         Sum(a.Abonos) / 100.00, b.tipo,                        Max(a.documento), b.TipoContabPro,
                 Sum(TCons)
         From    dbo.poliza     a With (Nolock)
         Join    dbo.tipoPoliza b With (Nolock)
         On      b.tipo                = Substring(a.referencia, 1, 2)
         And     b.TipoContabilizacion = 2
         And     a.cargos              = a.abonos
         And     a.cargos             != 0
         And     a.FechaContable Between @w_FechaInicio And @PdFechaProceso
         And     a.Referencia_Exporta Is Null
         Group   By Substring(a.Referencia, 1, 2),  a.FechaContable, Concat(upper(b.descripcion), ' DEL ', Convert(Char(10), a.FechaContable, 103)),
                 b.TipoContabPro, b.tipo
         Order   By 1;

      Begin
         Open   C_Detalle2
         While  @@Fetch_status < 1
         Begin
            Fetch C_Detalle2 Into @w_Referencia,    @w_FechaContable,  @w_Concepto,  @w_Cargos,
                                  @w_Abonos,        @w_tipo,           @w_documento, @w_TipoContabPro,
                                  @w_TCons

            If @@Fetch_Status <> 0
               Begin
                  Break
               End

            Select @w_secuencia = Max(Substring(Referencia, 4, 7))
            From   DB_Siccorp_DES.dbo.PolDia With (Nolock)
            Where  Substring(Referencia, 1, 3) = @w_TipoContabPro
            And    Fecha_mov                   = @w_FechaContable;

            Select @w_secuencia   = Isnull(@w_secuencia, 0) + 1,
                   @w_Referencia2 = Concat(@w_TipoContabPro, Format(@w_secuencia, '00000')),
                   @w_ejercicio   = DatePart(yy, @w_FechaContable),
                   @w_mes         = DatePart(mm, @w_fechaContable),
                   @w_chMes       = Substring(Upper(Format(@w_fechaContable, 'MMM', 'es-es')), 1, 3);

            Begin Try
               Insert Into DB_Siccorp_DES.dbo.PolDia
              (Referencia, Fecha_Mov, Fecha_Cap,       Concepto,
               Cargos,     Abonos,    TCons,           Usuario,
               TipoPoliza, Documento, Usuario_cancela, Fecha_Cancela,
               Status,     Mes_Mov,   TipoPolizaConta, FuenteDatos,
               Ejercicio,  Mes)
               Select @w_Referencia2,   @w_FechaContable, @w_fechaCaPtura,   @w_Concepto,
                      @w_Cargos,        @w_Abonos,        @w_TCons,          @w_Usuario,
                      @w_TipoContabPro, @w_Documento,     Null,              Null,
                      @w_Status,        @w_chMes,         @w_tipo,           @w_FuenteDatos,
                      @w_ejercicio,     @w_mes
            End Try

            Begin Catch
               Select  @w_Error      = @@Error,
                       @w_linea      = Error_line(),
                       @w_desc_error = Concat(Substring (Error_Message(), 1, 220), ' Linea: ', @w_linea); 
            End   Catch

            If Isnull(@w_Error, 0) <> 0
               Begin
                  Select @PnEstatus = @w_error,
                         @PsMensaje = 'Error.:  DB_Siccorp_DES.dbo.PolDia ' + @w_desc_error

                  Rollback Transaction

       --    Registro en log

                  Insert Into dbo.LogExportacionPolizas
                 (Fecha, Descripcion, hora_terminacion)
                  Select @w_ultActual, @PsMensaje, Getdate();

                  Close      C_Detalle2
                  Deallocate C_Detalle2
                  Set Xact_Abort Off
                  Return
               End

            Begin Try
               Insert Into DB_Siccorp_DES.dbo.MovDia
              (Referencia,      Cons,             Moneda,        Fecha_mov,
               Llave,           Concepto,         Importe,       Documento,
               Clave,           FecCap,           Sector_id,     Sucursal_id,
               Region_id,       Importe_Cargo,    Importe_Abono, Descripcion,
               TipoPolizaConta, ReferenciaFiscal, Fecha_Doc,     Ejercicio,
               Mes)
               Select @w_Referencia2, Row_Number() Over(Order By Referencia, Fecha_mov), '00'  Moneda,      @w_FechaContable,
                      Llave,          Concepto,                                          Importe / 100.00,  Documento,
                      Clave,          @w_fechaCaptura,  Null Sector,       Sucursal_id,
                      Region_id,      Case When Clave = 'D'
                                           Then Importe / 100.00
                                           Else 0
                                      End,              Case When Clave != 'D'
                                                             Then Importe / 100.00
                                                             Else 0
                                                        End,               Descripcion,
                      TipoPoliza,     ReferenciaFiscal, Fecha_Doc,         @w_ejercicio,
                      @w_mes
               From    dbo.poliza_mov With (Nolock)
               Where   poliza        = @w_poliza
               And     Referencia    = @w_Referencia
               And     FechaContable = @w_FechaContable
               And     importe      != 0;

            End Try

            Begin Catch
               Select  @w_Error      = @@Error,
                       @w_linea      = Error_line(),
                       @w_desc_error = Concat(Substring (Error_Message(), 1, 220), ' Linea: ', @w_linea); 
            End   Catch

            If Isnull(@w_Error, 0) <> 0
               Begin
                  Select @PnEstatus = @w_error,
                         @PsMensaje = 'Error.: DB_GEN_DES.dbo.PolDia ' + @w_desc_error


          -- Registro en log

                  Insert Into dbo.LogExportacionPolizas
                 (Fecha, Descripcion, hora_terminacion)
                  Select @w_ultActual, @PsMensaje, Getdate();

                  Rollback Transaction
                  Close      C_Detalle2
                  Deallocate C_Detalle2
                  Set Xact_Abort Off
                  Return
               End

            Begin Try
               Insert Into DB_Siccorp_DES.dbo.Relacionimp
              (Referencia, Fecha_Mov,   Fecha_Cap,        NewReferencia,
               Usuario,    FuenteDatos, FechaImportacion, Ejercicio,
               mes)
               Select @w_Referencia2,   @w_FechaContable, @w_fechaCaPtura, Null,
                      @w_usuario,       @w_FuenteDatos,   Null,            @w_ejercicio,
                      @w_mes;
            End Try

            Begin Catch
               Select  @w_Error      = @@Error,
                       @w_linea      = Error_line(),
                       @w_desc_error = Concat(Substring (Error_Message(), 1, 220), ' Linea: ', @w_linea); 
            End   Catch

            If Isnull(@w_Error, 0) <> 0
               Begin
                  Select @PnEstatus = @w_error,
                         @PsMensaje = 'Error.: DB_Siccorp_DES.dbo.Relacionimp ' + @w_desc_error

                  Rollback Transaction

            -- Registro en log
                  Insert Into dbo.LogExportacionPolizas
                 (Fecha, Descripcion, hora_terminacion)
                  Select @w_ultActual, @PsMensaje, Getdate();

                  Close      C_Detalle
                  Deallocate C_Detalle

                  Set Xact_Abort Off
                  Return
               End

            Begin Try
               Update dbo.Poliza
               Set    Referencia_Exporta = @w_Referencia2
               Where  Substring(Referencia, 1, 2)    = Substring(@w_Referencia, 1, 2)
               And    fechaContable                  = @w_FechaContable
            End Try

            Begin Catch
               Select  @w_Error  = @@Error,
                       @w_linea      = Error_line(),
                       @w_desc_error = Concat(Substring (Error_Message(), 1, 220), ' Linea: ', @w_linea); 
            End   Catch

            If Isnull(@w_Error, 0) <> 0
               Begin
                  Select @PnEstatus = @w_error,
                         @PsMensaje = 'Error.: DB_GEN_DES.dbo.PolDia ' + @w_desc_error

                  Rollback Transaction

          -- Registro en log
                  Insert Into dbo.LogExportacionPolizas
                 (Fecha, Descripcion, hora_terminacion)
                  Select @w_ultActual, @PsMensaje, Getdate();

                  Close      C_Detalle2
                  Deallocate C_Detalle2
                  Set Xact_Abort Off
                  Return
               End

         End

         Close      C_Detalle2
         Deallocate C_Detalle2
      End

   -- Registro en log

   Insert Into dbo.LogExportacionPolizas
  (Fecha, Descripcion, hora_terminacion)
   Select @w_ultActual, 'Ejecuta Spp_ExportaPolizasSET', Getdate();

   Execute Spp_ExportaPolizasSET @PdFechaProceso;

   -- Registro en log

   Insert Into dbo.LogExportacionPolizas
  (Fecha, Descripcion, hora_terminacion)
   Select @w_ultActual, 'Regresa de ejecución de Spp_ExportaPolizasSET', Getdate();

   Commit Transaction

   -- Registro en log

   Insert Into dbo.LogExportacionPolizas
  (Fecha, Descripcion, hora_terminacion)
   Select @w_ultActual, 'Termina proceso, guarda transaccion', Getdate();

   Set Xact_Abort Off
   Return

End
Go

--
-- Comentarios.
--

Declare
   @w_valor          Varchar(1500) = 'Procedimiento de exportación de las pólizas contables a Siccorp.',
   @w_procedimiento  Varchar( 100) = 'Spp_ExportaContabilidad'


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
