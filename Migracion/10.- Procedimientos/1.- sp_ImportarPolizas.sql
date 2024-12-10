Use DB_Siccorp_DES
Go


--NOTA: IMPORTANTE este SP no se puede compilar en QA, por lo que nunca se debe reemplazar de QA hacia Preproducción.

-- Modificaciones:
-- V.0.1 Zayra Martinez Candia 18/05/2021. Se agrega validación, para el ejercicio.
-- V.0.2 Zayra Martinez Candia 07/03/2022. se comenta temporalmente delete de tabla RelacionImp (Se quita el comentario)
-- V.0.3 Zayra Martinez Candia 15/03/2022. Se agrega validacion adicional para que las polizas no se dupliquen
-- V.0.4 Zayra Martinez Candia 12/07/2022. Se corrige filtros de update para actualizar campo [no_poliza_compensa] de SET_DALTON
-- V.0.5 Zayra Martinez Candia 12/10/2022. Se agrega una nuevo campo en tablas de relacion para poder rastrear mejor las polizas y se quita validacion que no permitia reprocesar polizas
-- V.0.6 Zayra Martinez Candia 15/02/2023. Se agrega filtro a la validación de duplicidad de movdia2022
-- V.0.7 Zayra Martinez Candia 15/02/2023. Se moddica validacion de duplicidad de movdia2022 y mes
-- V.0.8 Erik González   11/01/2024. Se actualiza SP para funcionar solo en el año que se especifica
-- V.0.9 Erik González   01/03/2024. Se actualiza SP. Se agrega transacción y ROLLBACK en caso de error. También se agrega la sentencia With(Nolock) para los selects

-- V.0.10 Pedro Zambrano 28/09/2024. Se realiza reingenieria a fin de que se adapte a la nueva BD
--                                   Se Actualiza el campo referencia a 20.

-- exec sp_ImportarPolizas 2024

Create or Alter Procedure dbo.sp_ImportarPolizas
  (@PnEjercicio   Smallint,
   @PnEstatus     Integer      = 0   Output,
   @PsMensaje     Varchar(250) = ' ' Output)
As

--INICIALIZA VARIABLES --
--Variables para el proceso del filtro de polizas.

Declare
   @w_Error               Integer,
   @w_Desc_Error          Varchar(250),
   @w_mensaje             Varchar(250),
   @w_Abono               Char(1),
   @w_Cargo               Char(1),
   @w_totalCargo          Decimal(18, 2),
   @w_totalAbono          Decimal(18, 2),
   @w_minId               Integer,
   @w_maxId               Integer,
   @w_Referencia          Varchar(10),
   @w_TipoPol             Varchar(3),
   @w_TipoPolPDI          Varchar(3),
   @w_TipoPolPEG          Varchar(3),
   @w_TipoPolPIN          Varchar(3),
   @w_Fecha_Mov           Date,
   @w_Mes_Mov             Nvarchar(3),
   @w_NewRef              Varchar(10),
   @w_Ejercicio           Integer,
   @w_ContPol             Nvarchar(50),
   @w_Contador            Integer,
   @w_MovDia              Sysname,
   @w_PolDia              Sysname,
   @w_ContNoPol           Integer,
   @wz_Ejercicio          Varchar(4),
   @w_registros           Integer,
   @w_secuencia           Integer,
   @w_contPDI             Integer,
   @w_contPEG             Integer,
   @w_contPIN             Integer,
   @w_ConsReferencia      Varchar(20),
   @w_consecutivo         Integer,
   @w_ConsReferenciaInt   Integer,
   @w_para392             Integer,
   @w_instalado           Integer,
--
   @w_linea               Integer,
   @w_operacion           Integer,
   @w_comilla             Char(1),
   @w_fechaIni            Date,
   @w_fechaFin            Date,
   @w_fechaAct            Datetime,
   @w_mes                 Tinyint,
--
   @w_idusuario           Varchar(  Max),
   @w_usuario             Nvarchar(  20),
   @w_sql                 NVarchar(1500),
   @w_param               NVarchar( 750),
   @w_registrosImp        Integer;

Begin
   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off
   Set Ansi_Warnings On
   Set Ansi_Padding  On

-- Inicializamos Variables

   Select  @PnEstatus      = 0,
           @PsMensaje      = ' ',
           @w_operacion    = 9999,
           @w_Abono        = 'C',
           @w_Cargo        = 'D',
           @w_consecutivo  = 0,
           @w_minId        = 0,
           @w_comilla      = Char(39),
           @w_TipoPolPDI   = 'PDI',
           @w_TipoPolPEG   = 'PEG',
           @w_TipoPolPIN   = 'PIN',
           @w_fechaIni     = Convert(Date, '01/01/' + Cast(@PnEjercicio As Varchar), 103),
           @w_fechaFin     = Convert(Date, '31/12/' + Cast(@PnEjercicio As Varchar), 103),
           @w_fechaAct     = Getdate(),
           @w_MovDia       = 'MovimientosAnio',
           @w_PolDia       = 'polizaAnio',
           @w_para392      = dbo.Fn_BuscaResultadosParametros( 392, 'valor'),
           @w_instalado    = dbo.Fn_BuscaResultadosParametros( 393, 'valor');

--
-- Búqueda de Parametros
--

   Select @w_idusuario = parametroChar
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 9;

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

         Set Xact_Abort    Off
         Return
      End

   If Not Exists ( Select Top 1 1 
                   From    dbo.PolDia P With(Nolock)
                   Where   p.Fecha_mov Between @w_fechaIni And @w_fechaFin
                   And     p.ejercicio       = @PnEjercicio)
      Begin
         Select @PnEstatus = 8172,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus)


         Set Xact_Abort    Off
         Return
      End
      
   Select @w_secuencia = Max($Identity)
   From   dbo.RelacionImp a With(Nolock)
   Set @w_secuencia = Isnull(@w_secuencia, 0)

--
-- Creación de Tablas Temporales
--

-- Crear tabla temporal para obtener cargos y abonos

   Create Table #tmpDiferencia
  (Consecutivo         Integer        Not Null Identity (1, 1) Primary Key,
   ejercicio           Integer        Not Null,
   mes                 Integer        Not Null,
   Referencia          Varchar(20)    Not Null,
   Fecha_Mov           Datetime       Not Null,
   Cargo               Decimal(18, 2) Not Null,
   Abono               Decimal(18, 2) Not Null,
   Diferencia          Decimal(18, 2) Not Null Default 0,
   Index tmpDiferenciaIdx01 Unique (ejercicio, mes, Referencia, Fecha_Mov));


-- Crear tabla TmpPoliza

   Create Table #tmpPoliza
  (Id                  Integer Identity(1,1) Not Null Primary key,
   Referencia          Varchar(20),
   NewReferencia       Varchar(20),
   Fecha_mov           Date,
   Fecha_Cap           Date,
   Concepto            Varchar(255),
   Cargos              Decimal(18, 2),
   Abonos              Decimal(18, 2),
   TCons               Integer,
   Usuario             Varchar(10),
   TipoPoliza          Varchar(3),
   Documento           Varchar(255),
   Usuario_cancela     Varchar(10),
   Fecha_cancela       Datetime,
   Status              smallint,
   Mes_Mov             Varchar(3),
   Ejercicio           Smallint,
   mes                 Tinyint,
   TipoPolizaConta     Varchar(3),
   FuenteDatos         Varchar(250),
   Index tmptmpPolizaIdx01 Unique (ejercicio, mes, Referencia, Fecha_Mov))

--Crear tabla tmpMovientos

   Create Table #tmpMovimientos
  (Id                  Integer        Not Null Identity(1,1)  Primary key,
   Referencia          Varchar( 20)   Not Null,
   NewReferencia       Varchar( 20)   Not Null Default Char(32),
   Cons                Integer,
   Moneda              Varchar(  2)   Not Null Default '00',
   Fecha_mov           Date           Not Null Default Getdate(),
   Llave               Varchar( 16),
   Concepto            Varchar(255),
   Importe             Decimal(18, 2) Not Null,
   Documento           Varchar(255),
   Clave               Char(1),
   FecCap              Date,
   Sector_id           Varchar(  2),
   Sucursal_id         Integer,
   Region_id           Integer,
   Importe_Cargo       Decimal(18, 2) Not Null Default 0.00,
   Importe_Abono       Decimal(18, 2) Not Null Default 0.00,
   Descrip             Varchar(150),
   TipoPolizaConta     Varchar(  3),
   ReferenciaFiscal    Varchar( 50),
   Fecha_Doc           Date,
   ejercicio           Smallint       Not Null,
   mes                 Tinyint        Not Null,
   Index tmpMovimientosIdx01 (ejercicio, mes, referencia, fecha_mov, Llave) )

  --Crear tabla temporal para obtener cargos y abonos

   Create Table #tmpCarAbo
  (Moneda              Varchar(2),
   totCar              Decimal(18, 2),
   totAbo              Decimal(18, 2))

--
-- Se incializa la tabla de log de errores
--

   Set @w_sql = 'Truncate Table logImportarPolErrorTbl'

   Begin Try
      Execute (@w_sql)
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_linea      = Error_line(),
              @w_desc_error = Substring (Error_Message(), 1, 200)

   End   Catch

   If Isnull(@w_error, 0) != 0
      Begin
         Select @w_error, @w_desc_error;

         Set Xact_Abort    Off
         Return
      End

--
-- Inicio proceso de validación.
--

   Begin Transaction

  -- 1. Validar polizas que no tienen cuenta contable llamado Llave

      Select @w_mensaje = 'No existe cuenta contable ';

      Begin Try
         Insert Into dbo.logImportarPolErrorTbl
        (Referencia, Fecha_mov,  Llave, mensajeError)
         Select Referencia, Fecha_Mov, '',  @w_mensaje
         From   dbo.MovDia With(Nolock)
         Where  fecha_mov   Between @w_fechaIni And @w_fechaFin
         And    ejercicio         = @PnEjercicio
         And    Isnull(Llave, '') = ''
         Group By Referencia, Fecha_Mov

      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End   Catch

      If Isnull(@w_error, 0) != 0
         Begin
            RollBack transaction
            Select @w_error, @w_desc_error;

            Set Xact_Abort    Off
            Return
         End

  -- 2. Valida el total de cargos y abonos del filtro de las polizas

      Begin Try
         Insert Into #tmpCarAbo
        (Moneda, totCar, totAbo)
         Select  m.Moneda, Sum(Case When m.Clave = @w_Cargo
                                    Then m.importe
                                    Else 0
                                End),
                           Sum(Case When m.Clave = @w_Abono
                                    Then m.importe
                                    Else 0
                               End)
         From    dbo.MovDia m With (Nolock)
         Join    dbo.PolDia P With(Nolock)
         On      p.Referencia      = m.Referencia
         And     p.Fecha_Mov       = m.Fecha_mov
         And     p.ejercicio       = m.ejercicio
         And     p.mes             = m.mes
         Where   m.Fecha_mov Between @w_fechaIni And @w_fechaFin
         And     m.ejercicio       = @PnEjercicio
         Group   By m.Moneda;

      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End   Catch

      If Isnull(@w_error, 0) != 0
         Begin
            RollBack transaction
            Select @w_error, @w_desc_error;

            Set Xact_Abort    Off
            Return
         End

      Select @w_totalCargo = totCar,
             @w_totalAbono = totAbo
      From   #tmpCarAbo

      If @w_totalCargo !=  @w_totalAbono
         Begin
            Begin Try
               Insert Into #tmpDiferencia
              (ejercicio, mes,   Referencia, Fecha_Mov,
               cargo,     abono, diferencia)
               Select p.Ejercicio, p.mes, p.Referencia, p.Fecha_Mov,
                      Sum(Case When m.Clave = @w_Cargo
                                            Then m.importe
                                            Else 0
                                        End),
                      Sum(Case When m.Clave = @w_Abono
                               Then m.importe
                               Else 0
                          End),
                      Sum(Case When m.Clave = @w_Cargo
                               Then m.importe
                               Else -m.importe
                          End) Diferencia
               From   dbo.MovDia M With(Nolock)
               Join   dbo.PolDia P With(Nolock)
               On      p.Referencia      = m.Referencia
               And     p.Fecha_Mov       = m.Fecha_mov
               And     p.ejercicio       = m.ejercicio
               And     p.mes             = m.mes
               Where   m.Fecha_mov Between @w_fechaIni And @w_fechaFin
               And     m.ejercicio       = @PnEjercicio
               Group By p.Ejercicio, p.mes, p.Referencia,  p.Fecha_Mov
               Having   ABS(Sum(Case When m.Clave = @w_Cargo
                                     Then m.importe
                                     Else -m.importe
                                 End)) != 0
               Order By Ejercicio, mes, Referencia

            End Try

            Begin Catch
               Select  @w_Error      = @@Error,
                       @w_linea      = Error_line(),
                       @w_desc_error = Substring (Error_Message(), 1, 200)

            End   Catch

            If Isnull(@w_error, 0) != 0
               Begin
                  RollBack transaction
                  Select @w_error, @w_desc_error;

                  Set Xact_Abort    Off
                  Return
               End

            Set @w_mensaje = 'Diferencia de Saldos '
            Begin Try
               Insert Into dbo.logImportarPolErrorTbl
              (Referencia, Fecha_mov,  Llave, mensajeError)
               Select Referencia, Fecha_Mov, '',  @w_mensaje
               From   #tmpDiferencia
            End Try

            Begin Catch
               Select  @w_Error      = @@Error,
                       @w_linea      = Error_line(),
                       @w_desc_error = Substring (Error_Message(), 1, 200)

            End   Catch

            If Isnull(@w_error, 0) != 0
               Begin
                  RollBack transaction
                  Select @w_error, @w_desc_error;

                  Set Xact_Abort    Off
                  Return
               End

         End  -- @w_totalCargo !=  @w_totalAbono

    -- Se agrega validacion para que no se dupliquen polizas

      Set @w_mensaje = 'La poliza ya existe en Movimientos';

      Begin Try
         Insert Into dbo.logImportarPolErrorTbl
        (Referencia, Fecha_mov,  Llave, mensajeError)
         Select Referencia, Fecha_Mov, '',  @w_mensaje
         From   dbo.PolDia a With (Nolock)
         Where  Exists ( Select Top 1 1
                         From   dbo.Poliza With (Nolock)
                         Where  Referencia      = a.Referencia
                         And    Fecha_Mov       = a.Fecha_mov
                         And    ejercicio       = a.ejercicio
                         And    mes             = a.mes)
      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End   Catch

      If Isnull(@w_error, 0) != 0
         Begin
            RollBack transaction
            Select @w_error, @w_desc_error;

            Set Xact_Abort    Off
            Return
         End

    -- Se agrega validacion de cuentaas contables válidas.

      Begin Try
         Set @w_mensaje = 'La Cuenta no existe en Catalogo Auxiliar'
         Insert Into dbo.logImportarPolErrorTbl
        (Referencia, Fecha_mov,  Llave, mensajeError)
         Select Referencia, Fecha_Mov, llave,  @w_mensaje
         From   dbo.MovDia a With (Nolock)
         Where  Not Exists ( Select Top 1 1
                             From   dbo.Catalogo With (Nolock)
                             Where  ejercicio       = a.ejercicio
                             And    mes             = a.mes
                             And    llave           = a.llave
                             And    moneda          = a.moneda)
      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End   Catch

      If Isnull(@w_error, 0) != 0
         Begin
            RollBack transaction
            Select @w_error, @w_desc_error;

            Set Xact_Abort    Off
            Return
         End

    --ZCMC 21/09/2022. Se cambia la obtencion del valor de la variable para el numero correcto de errores.

      Select @w_ContNoPol = Count (1)
      From (Select Distinct referencia, fecha_mov
            From   dbo.logImportarPolErrorTbl With(Nolock)
            Where  fecha_mov Between @w_fechaIni And @w_fechaFin) pol

 -- Actualizar las tablas Poldia con los errores encontrados durante el Proceso.

      Begin Try
         Update a
         Set    a.CausaRechazo = b.mensajeError
         From   dbo.polDia                 a With (Nolock)
         Join   dbo.logImportarPolErrorTbl b With (Nolock)
         On     b.Referencia = a.Referencia
         And    b.Fecha_Mov  = a.Fecha_Mov
         Where  a.ejercicio  = @PnEjercicio;

      End Try


      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End   Catch

      If Isnull(@w_error, 0) != 0
         Begin
            RollBack transaction
            Select @w_error, @w_desc_error;

            Set Xact_Abort    Off
            Return
         End

 -- Actualizar las tablas Movdia con los errores encontrados durante el Proceso.

      Begin Try
         Update a
         Set    a.idCausaRechazo = b.mensajeError
         From   dbo.MovDia                 a With (Nolock)
         Join   dbo.logImportarPolErrorTbl b With (Nolock)
         On     a.Referencia = b.Referencia
         And    a.Fecha_Mov  = b.Fecha_Mov
         Where  a.ejercicio  = @PnEjercicio;

      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End   Catch

      If Isnull(@w_error, 0) != 0
         Begin
            RollBack transaction
            Select @w_error, @w_desc_error;

            Set Xact_Abort    Off
            Return
         End


   --Agrega el Contenido del cabecero de la póliza

      Begin Try
         Insert Into #tmpPoliza
        (Referencia,    NewReferencia,   Fecha_Mov, Fecha_Cap,
         Concepto,      Cargos,          Abonos,    TCons,
         Usuario,       TipoPoliza,      Documento, Usuario_cancela,
         Fecha_cancela, Status,          Mes_Mov,   Ejercicio,
         mes,           TipoPolizaConta, FuenteDatos)
         Select  Referencia,    '',              Fecha_mov,  @w_fechaAct,
                 Concepto,      Cargos,          Abonos,     TCons,
                 @w_usuario,    TipoPoliza,      Documento,  Usuario_cancela,
                 Fecha_cancela, Status,          Mes_Mov,    Ejercicio,
                 mes,           TipoPolizaConta, FuenteDatos
         From   dbo.PolDia With(Nolock)
         Where  CausaRechazo Is NULL
         And    Ejercicio      = @PnEjercicio
         And    Fecha_Mov Between @w_fechaIni And @w_fechaFin
         Order  By Fecha_mov, TipoPolizaConta
         Set  @w_maxId = @@Identity
      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End   Catch

      If Isnull(@w_error, 0) != 0
         Begin
            RollBack transaction
            Select @w_error, @w_desc_error;

            Set Xact_Abort    Off
            Return
         End

   --Agrega el Contenido del detalle de la póliza

      Begin Try
          Insert Into #tmpMovimientos
         (Referencia,      Cons,             Moneda,        Fecha_Mov,
          Llave,           Concepto,         Importe,       Documento,
          Clave,           FecCap,           Sector_id,     Sucursal_id,
          Region_id,       Importe_Cargo,    Importe_Abono, Descrip,
          TipoPolizaConta, ReferenciaFiscal, Fecha_Doc,     ejercicio,
          mes)
          Select Referencia,      Cons,             Moneda, Fecha_mov,
                 Llave,           Concepto,         Importe, Documento,
                 (Case When  Clave = 'D' Then 'C' Else 'A' End) Clave, @w_fechaAct,
                 Isnull(Sector_id, '00'), Sucursal_id,
                 Region_id,       Importe_Cargo,    Importe_Abono, Descripcion,
                 TipoPolizaConta, ReferenciaFiscal, Fecha_Doc,     ejercicio,
                 mes
          From   dbo.movDia With(Nolock)
          Where  idCausaRechazo  Is Null
          And    Fecha_mov  Between @w_fechaIni And @w_fechaFin
          And    Ejercicio        = @PnEjercicio
          Order  By mes, Fecha_mov, TipoPolizaConta

      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End   Catch

      If Isnull(@w_error, 0) != 0
         Begin
            RollBack transaction
            Select @w_error, @w_desc_error;

            Set Xact_Abort    Off
            Return
         End

   --Ciclo para obtener datos del tipo de comprobante

      While @w_minId  < @w_maxId
      Begin
         Set @w_minId = @w_minId + 1;

         Select @w_Referencia  = Referencia,
                @w_Fecha_Mov   = Fecha_Mov,
                @w_Mes_Mov     = Mes_Mov,
                @w_TipoPol     = TipoPoliza,
                @w_Ejercicio   = Ejercicio,
                @w_mes         = mes
         From   #tmpPoliza
         Where  Id = @w_minId;
         If @@Rowcount = 0
            Begin
               Break
            End

         If @w_TipoPol = 'PDI'
            Begin
               Select @w_contPDI = contador
               From   dbo.ControlPoliza With (Nolock)
               Where  TipoComprobante = @w_TipoPolPDI
               And    Ejercicio       = @w_Ejercicio
               And    Mes             = @w_mes;
               If @@Rowcount = 0
                  Begin
                     Set @w_contPDI = 0
                  End

               Select @w_contPDI = @w_contPDI + 1,
                      @w_NewRef  = Concat(@w_TipoPol, Format(@w_contPDI, '000000'))
            End

         If @w_TipoPol = 'PEG'
            Begin
               Select @w_contPEG = contador
               From   dbo.ControlPoliza With (Nolock)
               Where  TipoComprobante = @w_TipoPolPEG
               And    Ejercicio       = @w_Ejercicio
               And    Mes             = @w_mes;
               If @@Rowcount = 0
                  Begin
                     Set @w_contPEG = 0
                  End

               Select @w_contPEG = @w_contPEG + 1,
                      @w_NewRef  = Concat(@w_TipoPol, Format(@w_contPEG, '000000'))
            End

         If @w_TipoPol = 'PIN'
            Begin
               Select @w_contPIN = contador
               From   dbo.ControlPoliza With (Nolock)
               Where  TipoComprobante = @w_TipoPolPIN
               And    Ejercicio       = @w_Ejercicio
               And    Mes             = @w_mes;
               If @@Rowcount = 0
                  Begin
                     Set @w_contPIN = 0
                  End

               Select @w_contPIN = @w_contPIN + 1,
                      @w_NewRef  = Concat(@w_TipoPol, Format(@w_contPIN, '000000'))
            End

         Update #tmpPoliza
         Set    NewReferencia = @w_NewRef
         Where  Id = @w_minId


    --Se agrega Validacion parametro para actualizacion en tabla de SET 14/05/2021

         If @w_para392 = 1
            Begin
               Set @w_sql = Concat('Update set_dalton.dbo.zmovdia ',
                                   'Set    no_poliza_compensa  = ', @w_comilla, @w_NewRef,     @w_comilla, ' ',
                                   'Where  referencia          = ', @w_comilla, @w_Referencia, @w_comilla, ' ',
                                   'And    FuenteDatos         = ', @w_comilla, 'SET',         @w_comilla);
               Begin Try
                  Execute (@w_sql)
               End Try

               Begin Catch
                  Select  @w_Error      = @@Error,
                          @w_linea      = Error_line(),
                          @w_desc_error = Substring (Error_Message(), 1, 200)

               End   Catch

               If Isnull(@w_error, 0) != 0
                  Begin
                     RollBack transaction
                     Select @w_error, @w_desc_error;

                     Set Xact_Abort    Off
                     Return
                  End

            End -- @w_para392 = 1

    --FIN DE ACTUALIZACION 14/05/2021

         Begin Try
            Update dbo.ControlPoliza
            Set    contador = Case When @w_TipoPol = 'PDI'
                                   Then @w_contPDI
                                   When @w_TipoPol = 'PEG'
                                   Then @w_contPEG
                                   When @w_TipoPol = 'PIN'
                                   Then @w_contPIN
                                   Else 0
                              End
            Where  TipoComprobante = @w_TipoPol;
         End Try

         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_linea      = Error_line(),
                    @w_desc_error = Substring (Error_Message(), 1, 200)

         End   Catch

         If Isnull(@w_error, 0) != 0
            Begin
               RollBack transaction
               Select @w_error, @w_desc_error;

               Set Xact_Abort    Off
               Return
            End

      End -- Fin Ciclo

      --Actualizar la nueva Referencia.

      Update a
      Set    NewReferencia = b.NewReferencia
      From   #tmpMovimientos a
      Join   #tmpPoliza      b
      On     b.ejercicio  = a.ejercicio
      And    b.mes        = a.mes
      And    b.Referencia = a.Referencia
      And    b.Fecha_Mov  = a.Fecha_Mov

       --Inserta en la tabla Relacion

      Begin Try
         Insert Into dbo.RelacionImp
        (Referencia, Fecha_Mov,   Fecha_Cap, NewReferencia,
         Usuario,    FuenteDatos, FechaImportacion, Ejercicio, mes)
         Select  Referencia, Fecha_Mov, Fecha_Cap, NewReferencia, Usuario, FuenteDatos, @w_fechaAct,
		         Ejercicio,  mes
         From    #tmpPoliza
         Order by Id
		 Set @w_registrosImp = @@Identity

      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End   Catch

      If Isnull(@w_error, 0) != 0
         Begin
            RollBack transaction
            Select @w_error, @w_desc_error;

            Set Xact_Abort    Off
            Return
         End

         ----Agrega el Contenido del cabecero de la póliza

      Begin Try
         Insert Into dbo.polizaAnio
        (Referencia, Fecha_Mov, Fecha_Cap,       Concepto,
         Cargos,     Abonos,    TCons,           Usuario,
         TipoPoliza, Documento, Usuario_cancela, Fecha_Cancela,
         Status,     Mes_Mov,   TipoPolizaConta, FuenteDatos,
         Ejercicio,  Mes)
         Select NewReferencia, Fecha_Mov, Fecha_Cap,       Concepto,
                Cargos,        Abonos,    TCons,           Usuario,
                TipoPoliza,    Documento, Usuario_cancela, Fecha_cancela,
                Status,        Mes_Mov,   TipoPolizaConta, FuenteDatos,
                ejercicio,     mes
         From   #tmpPoliza
      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End   Catch

      If Isnull(@w_error, 0) != 0
         Begin
            RollBack transaction
            Select @w_error, @w_desc_error;

            Set Xact_Abort    Off
            Return
         End

            --Agrega el Contenido al detalle de la póliza

      Begin Try
         Insert Into dbo.MovimientosAnio
        (Referencia,      Cons,             Moneda,        Fecha_mov,
         Llave,           Concepto,         Importe,       Documento,
         Clave,           FecCap,           Sector_id,     Sucursal_id,
         Region_id,       Importe_Cargo,    Importe_Abono, Descripcion,
         TipoPolizaConta, ReferenciaFiscal, Fecha_Doc,     Ejercicio,
         mes)
         Select NewReferencia, Cons,               Moneda,        Fecha_Mov,
                Llave,         Concepto,           Importe,       Documento,
                Clave,         FecCap,             Sector_id,     Sucursal_id,
                Region_id,     Importe_Cargo,      Importe_Abono, Descrip,
                TipoPolizaConta, ReferenciaFiscal, Fecha_Doc,     Ejercicio,
                Mes
         From   #tmpMovimientos
      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End   Catch

      If Isnull(@w_error, 0) != 0
         Begin
            RollBack transaction
            Select @w_error, @w_desc_error;

            Set Xact_Abort    Off
            Return
         End


          --ZCMC 21/09/2022. Se modifica tabla que controla la importacion, colocando la fecha de la ejecucion del SP

      Begin Try
         Insert Into dbo.controlImpPolTbl
        (Fecha_Mov, Polizas_Imp, polizas_no_imp)
         Select @w_fechaAct, @w_registrosImp, @w_ContNoPol
      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End   Catch

      If Isnull(@w_error, 0) != 0
         Begin
            RollBack transaction
            Select @w_error, @w_desc_error;

            Set Xact_Abort    Off
            Return
         End

        --Inserta en la tabla Relacion
        --CHUR/ZCMC 11/05/2021 Se descomentan las dos lineas del insert


 -- Actualizar Pólizas (Encabezado) con Errores.

      Begin Try
         Insert Into dbo.PolDiaError
        (Referencia, Fecha_Mov, Fecha_Cap,       Concepto,
         Cargos,     Abonos,    TCons,           Usuario,
         TipoPoliza, Documento, Usuario_cancela, Fecha_Cancela,
         Status,     Mes_Mov,   TipoPolizaConta, FuenteDatos,
         Ejercicio,  Mes,       Causa_Rechazo,   Fecha_importacion,
         UltActal)
         Select Referencia, Fecha_Mov, Fecha_Cap, Concepto,
                Cargos,     Abonos,    TCons,     Usuario,
                TipoPoliza, Documento, Usuario_cancela, Fecha_Cancela,
                Status,     Mes_Mov,   TipoPolizaConta, FuenteDatos,
                Ejercicio,  Mes,       CausaRechazo,    @w_fechaAct,
                @w_fechaAct
         From   dbo.PolDia With(Nolock)
         Where  CausaRechazo  Is not Null
         And    fecha_mov Between @w_fechaIni And @w_fechaFin
         And    Ejercicio       = @PnEjercicio;
      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End   Catch

      If Isnull(@w_error, 0) != 0
         Begin
            RollBack transaction
            Select @w_error, @w_desc_error;

            Set Xact_Abort    Off
            Return
         End

 -- Actualizar Pólizas (Encabezado) con Errores.

      Begin Try
         Insert Into dbo.MovDiaError
        (Referencia,      Cons,             Moneda,            Fecha_mov,
         Llave,           Concepto,         Importe,           Documento,
         Clave,           FecCap,           Sector_id,         Sucursal_id,
         Region_id,       Importe_Cargo,    Importe_Abono,     Descripcion,
         TipoPolizaConta, ReferenciaFiscal, Fecha_Doc,         Ejercicio,
         Mes,             Causa_Rechazo,    Fecha_importacion, UltActal)
         Select Referencia,      Cons,             Moneda,        Fecha_mov,
                Llave,           Concepto,         Importe,       Documento,
                Clave,           FecCap,           Sector_id,     Sucursal_id,
                Region_id,       Importe_Cargo,    Importe_Abono, Descripcion,
                TipoPolizaConta, ReferenciaFiscal, Fecha_Doc,     Ejercicio,
                Mes,             idCausaRechazo,   Null,          @w_fechaAct
         From   dbo.MovDia With(Nolock)
         Where  idCausaRechazo Is not Null
         And    fecha_mov Between @w_fechaIni And @w_fechaFin
         And    Ejercicio       = @PnEjercicio;
      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End   Catch

      If Isnull(@w_error, 0) != 0
         Begin
            RollBack transaction
            Select @w_error, @w_desc_error;

            Set Xact_Abort    Off
            Return
         End

     --Eliminar las tablas de MovDia

      Begin Try
         Delete dbo.MovDia
         Where (idCausaRechazo    Is Null
         Or     idCausaRechazo like '%La poliza ya existe%')
         And    fecha_mov   Between @w_fechaIni And @w_fechaFin
         And    Ejercicio         = @PnEjercicio;
      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End   Catch

      If Isnull(@w_error, 0) != 0
         Begin
            RollBack transaction
            Select @w_error, @w_desc_error;

            Set Xact_Abort    Off
            Return
         End

     --Eliminar las tablas de MovDia

      Begin Try
         Delete dbo.PolDia
         Where (CausaRechazo   Is Null
         Or     CausaRechazo like '%La poliza ya existe%')
         And    fecha_mov Between @w_fechaIni And @w_fechaFin
         And    Ejercicio       = @PnEjercicio;
      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End   Catch

      If Isnull(@w_error, 0) != 0
         Begin
            RollBack transaction
            Select @w_error, @w_desc_error;

            Set Xact_Abort    Off
            Return
         End

     While @w_secuencia <= @w_registrosImp
      Begin
         Set @w_secuencia = @w_secuencia + 1;
         Begin Try
            Insert Into dbo.Relacion_Poliza_Interna_Externa
           (Referencia, Fecha_Mov, Fecha_Cap, Referencia_Contable, Usuario, FuenteDatos)
            Select Referencia, Fecha_Mov, Fecha_Cap, NewReferencia, Usuario, FuenteDatos
            From   dbo.RelacionImp a With(Nolock)
            Where  idRelacion = @w_secuencia
            And    Not Exists (Select top 1 1
                               From   dbo.Relacion_Poliza_Interna_Externa b With(Nolock)
                               Where  b.Referencia = a.referencia
                               And    b.Fecha_Mov  = a.Fecha_Mov )

         End Try

         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_linea      = Error_line(),
                    @w_desc_error = Substring (Error_Message(), 1, 200)

         End   Catch

         If Isnull(@w_error, 0) != 0
            Begin
               RollBack transaction
               Select @w_error, @w_desc_error;

               Set Xact_Abort    Off
               Return
            End

        --ZCMC/MZB 12/10/2022. Se crea nuevo campo para relacionar polizas entre SICCORP Y SisArrendaCredito

        If @w_instalado = 1  -- Instalado SisArrendaCredito
           Begin
              Select @w_consecutivo = @w_consecutivo + 1,
                     @w_ConsReferencia = Concat (Format(Day(@w_fechaAct), '00'), Format(Month(@w_fechaAct), '00'), Year( @w_fechaAct ) % 100,
                                                 Format(@w_consecutivo,'00000'))

              Set @w_sql = Concat('Update a ' ,
                                  'Set    iddegasto = ', @w_ConsReferencia, ' ',
                                  'From   SisArrendaCredito.dbo.Poliza a With (Nolock) ',
                                  'Join   dbo.RelacionImp              b With (Nolock) ',
                                  'On     b.Referencia  = a.Referencia_Exporta Collate SQL_Latin1_General_CP1_CI_AS ',
                                  'And    Cast(b.fecha_mov As Date) = Cast(a.fechaContable As Date) ',
                                  'Where  b.IdRelacion  = ', @w_secuencia, ' ',
                                  'And    b.ejercicio   = ', @PnEjercicio, ' ',
                                  'And    Cast(b.fechaImportacion As Date) Between ', @w_comilla, Cast(@w_fechaIni As Date), @w_comilla ,
                                                                             ' And ', @w_comilla, Cast(@w_fechaFin As Date), @w_comilla);
              Begin Try
                 Execute (@w_sql)
              End   Try

              Begin Catch
                 Select  @w_Error      = @@Error,
                         @w_linea      = Error_line(),
                         @w_desc_error = Substring (Error_Message(), 1, 200)

              End   Catch

              If Isnull(@w_error, 0) != 0
                 Begin
                    RollBack transaction
                    Select @w_error, @w_desc_error;

                    Set Xact_Abort    Off
                    Return
                 End

           End

      End   -- @w_secuencia <= @w_registrosImp

   Commit transaction

   Print 'Ok'

   Set Xact_Abort    Off
   Return

End
Go
