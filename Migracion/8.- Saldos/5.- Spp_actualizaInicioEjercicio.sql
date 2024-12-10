/*

-- Declare
   -- @PnAnio                Smallint            = 2024,
   -- @PnMes                 Tinyint             = 13,
   -- @PnEstatus             Integer             = 0,
   -- @PsMensaje             Varchar( 250)       = ' ' ;
-- Begin

   -- Execute dbo.Spp_actualizaInicioEjercicio @PnAnio      = @PnAnio,
                                            -- @PnMes       = @PnMes,
                                            -- @PnEstatus   = @PnEstatus Output,
                                            -- @PsMensaje   = @PsMensaje Output;

   -- Select @PnEstatus, @PsMensaje
   -- Return
-- End
-- Go

--

-- Objeto:        Spp_actualizaInicioEjercicio.
-- Objetivo:      Mueve los saldos acumulados del ejercicio en cierre al Histórico
-- Fecha:         16/09/2024
-- Programador:   Pedro Zambrano
-- Versión:       1


*/

Create Or Alter Procedure dbo.Spp_actualizaInicioEjercicio
  (@PnAnio                Smallint,
   @PnMes                 Tinyint,
   @PnEstatus             Integer             = 0   Output,
   @PsMensaje             Varchar( 250)       = ' ' Output)
As

Declare
   @w_Error             Integer,
   @w_linea             Integer,
   @w_operacion         Integer,
   @w_idlogInic         Integer,
   @w_idlogFin          Integer,
   @w_idEstatus         Tinyint,
   @w_sucursable        Tinyint,
   @w_anioProximo       Smallint,
   @w_mesProximo        Smallint,
   @w_mesFin            Smallint,
   @w_fechaCaptura      Datetime,
   @w_desc_error        Varchar(250),
   @w_referencia        Varchar( 20),
   @w_idusuario         Varchar(Max),
   @w_ipAct             Varchar( 30),
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
          @w_fechaCaptura    = Getdate(),
          @w_error           = 0,
          @w_desc_error      = Char(32),
          @w_sucursable      = Isnull(dbo.Fn_BuscaResultadosParametros(12, 'valor'), 0),
          @w_ipAct           = dbo.Fn_BuscaDireccionIP();

--
-- Registro de inicio de proceso.
--

   Insert dbo.logCierreInicioEjercicioTbl
  (Ejercicio, mes, descripcion, ipAct)
   Select @PnAnio, @PnMes, 'Inicio del Proceso de Cierre', @w_ipAct;
   Set @w_idlogInic = @@Identity

--
-- Obtención del usuario de la aplicación para procesos batch.
--

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
         Select @PnEstatus = @w_error,
                @PsMensaje = @w_desc_error;

         Insert dbo.logCierreInicioEjercicioTbl
        (Ejercicio, mes, descripcion, idError, mensajeError, ipAct)
         Select @PnAnio, @PnMes, 'Búsqueda de Usuario Bath', @w_error, @PsMensaje, @w_ipAct;
         Set @w_idlogFin = @@Identity

         Goto Salida
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

         Insert dbo.logCierreInicioEjercicioTbl
        (Ejercicio, mes, descripcion, idError, mensajeError, usuario, ipAct)
         Select @PnAnio, @PnMes, 'Consulta a la tabla ejercicios', @PnEstatus, @PsMensaje, @w_usuario, @w_ipAct;
         Set @w_idlogFin = @@Identity

         Goto Salida
      End

   If @w_idEstatus != 3
      Begin
         Select @PnEstatus  = 8022,
                @PsMensaje =  'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

         Insert dbo.logCierreInicioEjercicioTbl
        (Ejercicio, mes, descripcion, idError, mensajeError, usuario, ipAct)
         Select @PnAnio, @PnMes, 'Consulta a la tabla ejercicios', @PnEstatus, @PsMensaje, @w_usuario, @w_ipAct;
         Set @w_idlogFin = @@Identity

         Goto Salida
      End

   If Not Exists ( Select Top 1 1
                   From   dbo.catCriteriosTbl Whith (Nolock)
                   Where  criterio = 'mes'
                   And    valor    = @PnMes)
      Begin
         Select @PnEstatus  = 8023,
                @PsMensaje =  'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

         Insert dbo.logCierreInicioEjercicioTbl
        (Ejercicio, mes, descripcion, idError, mensajeError, usuario, ipAct)
         Select @PnAnio, @PnMes, 'Consulta a la tabla catCriteriosTbl',@PnEstatus, @PsMensaje, @w_usuario, @w_ipAct;
         Set @w_idlogFin = @@Identity

         Goto Salida
      End

   Select @w_idEstatus = idEstatus
   From   dbo.control With (Nolock)
   Where  ejercicio = @PnAnio
   And    mes       = @PnMes;
   If @@Rowcount = 0
      Begin
         Select @PnEstatus  = 8024,
                @PsMensaje =  'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

         Insert dbo.logCierreInicioEjercicioTbl
        (Ejercicio, mes, descripcion, idError, mensajeError, usuario, ipAct)
         Select @PnAnio, @PnMes, 'Consulta a la tabla control', @PnEstatus, @PsMensaje, @w_usuario, @w_ipAct;
         Set @w_idlogFin = @@Identity

         Goto Salida
      End

   If @w_idEstatus != 1
      Begin
         Select @PnEstatus  = 8025,
                @PsMensaje =  'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

         Insert dbo.logCierreInicioEjercicioTbl
        (Ejercicio, mes, descripcion, idError, mensajeError, usuario, ipAct)
         Select @PnAnio, @PnMes, 'Consulta a la tabla control', @PnEstatus, @PsMensaje, @w_usuario, @w_ipAct;
         Set @w_idlogFin = @@Identity

         Goto Salida
      End

--
-- Se ubica el último mes de proceso
--

   Select @w_mesFin = Max(valor)
   From   dbo.catCriteriosTbl Whith (Nolock)
   Where  criterio = 'mes';

   If @w_mesFin != @PnMes
      Begin
         Select @PnEstatus  = 8031,
                @PsMensaje =  'Error.: ' + (dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus))

         Insert dbo.logCierreInicioEjercicioTbl
        (Ejercicio, mes, descripcion, idError, mensajeError, usuario, ipAct)
         Select @PnAnio, @PnMes, 'Validación del mes Final del Ejercicio', @PnEstatus, @PsMensaje, @w_usuario, @w_ipAct;
         Set @w_idlogFin = @@Identity

         Goto Salida
      End
--

   Select @w_mesProximo  = 0,
          @w_anioProximo = @PnAnio + 1;

--

--
-- Inicio de Proceso.
--


   Begin Transaction

--
-- Generación de nuevo ejercicio y mes
--
      Begin Try
         Update dbo.ejercicios
         Set    idEstatus = 2
         Where  ejercicio = @PnAnio;
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

            Insert dbo.logCierreInicioEjercicioTbl
           (Ejercicio, mes, descripcion, idError, mensajeError, usuario, ipAct)
            Select @PnAnio, @PnMes, 'Actualizando la tabla ejercicios', @PnEstatus, @PsMensaje, @w_usuario, @w_ipAct;
            Set @w_idlogFin = @@Identity
         
            Set Xact_Abort Off
            Goto Salida
         End

      Begin Try
         Update dbo.control
         Set    idEstatus    = 2,
                FechaProceso = @w_fechaCaptura,
                usuario      = @w_usuario
         Where  ejercicio = @PnAnio
         And    Mes       = @PnMes;
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

            Insert dbo.logCierreInicioEjercicioTbl
           (Ejercicio, mes, descripcion, idError, mensajeError, usuario, ipAct)
            Select @PnAnio, @PnMes, 'Actualizando la tabla control', @PnEstatus, @PsMensaje, @w_usuario, @w_ipAct;
            Set @w_idlogFin = @@Identity
         
            Set Xact_Abort Off
            Goto Salida
         End

      If Not Exists ( Select Top 1 1
                      From   dbo.Ejercicios With (Nolock)
                      Where  ejercicio = @w_anioProximo)
         Begin
            Begin Try
               Insert Into dbo.ejercicios
               (ejercicio, idEstatus)
               Select @w_anioProximo, 1
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

                  Insert dbo.logCierreInicioEjercicioTbl
                 (Ejercicio, mes, descripcion, idError, mensajeError, usuario, ipAct)
                  Select @PnAnio, @PnMes, 'Actualizando la tabla Ejercicios', @PnEstatus, @PsMensaje, @w_usuario, @w_ipAct;
                  Set @w_idlogFin = @@Identity

                  Set Xact_Abort Off
                  Goto Salida
               End

        End
      Else
         Begin
            Begin Try
               Update dbo.ejercicios
               Set    idEstatus = 1
               Where  ejercicio = @w_anioProximo
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

                  Insert dbo.logCierreInicioEjercicioTbl
                 (Ejercicio, mes, descripcion, idError, mensajeError, usuario, ipAct)
                  Select @PnAnio, @PnMes, 'Actualizando la tabla Ejercicios. ', @PnEstatus, @PsMensaje, @w_usuario, @w_ipAct;
                  Set @w_idlogFin = @@Identity

                  Set Xact_Abort Off
                  Goto Salida
               End
         End

      If Not Exists ( Select Top 1 1
                      From   dbo.control With (Nolock)
                      Where  ejercicio = @w_anioProximo
                      And    mes       = @w_mesProximo)
         Begin
            Begin Try
               Insert Into dbo.control
               (Ejercicio, Mes, idEstatus, FechaProceso,
                usuario)
               Select @w_anioProximo, @w_mesProximo, 1, @w_fechaCaptura,
                      @w_usuario
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

                  Insert dbo.logCierreInicioEjercicioTbl
                 (Ejercicio, mes, descripcion, idError, mensajeError, usuario, ipAct)
                  Select @PnAnio, @PnMes, 'Alta a la tabla control', @w_error, @PnEstatus, @PsMensaje, @w_ipAct;
                  Set @w_idlogFin = @@Identity

                  Set Xact_Abort Off
                  Goto Salida
               End
         End
      Else
         Begin
            Begin Try

               Update dbo.control
               Set    idEstatus    = 1,
                      FechaProceso = @w_fechaCaptura,
                      usuario      = @w_usuario
               Where  ejercicio = @w_anioProximo
               And    mes       = @w_mesProximo
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

                  Insert dbo.logCierreInicioEjercicioTbl
                 (Ejercicio, mes, descripcion, idError, mensajeError, usuario, ipAct)
                  Select @PnAnio, @PnMes, 'Actualizando la tabla control', @PnEstatus, @PsMensaje, @w_usuario, @w_ipAct;
                  Set @w_idlogFin = @@Identity
         
                  Set Xact_Abort Off
                  Goto Salida
               End
         End

--
-- Depuración de los movimientos contables del Período en el Histórico. Para actualizar el nuevo ejercicio.
--

      If Exists ( Select Top 1 1
                  From   dbo.MovimientosHist With (Nolock)
                  Where  ejercicio = @PnAnio)
         Begin
            Begin Try
               Delete dbo.MovimientosHist
               Where  ejercicio = @PnAnio;

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

                  Insert dbo.logCierreInicioEjercicioTbl
                 (Ejercicio, mes, descripcion, idError, mensajeError, usuario, ipAct)
                  Select @PnAnio, @PnMes, 'Inicializando la Tabla MovimientosHist', @PnEstatus, @PsMensaje, @w_usuario, @w_ipAct;
                  Set @w_idlogFin = @@Identity
         
                  Set Xact_Abort Off
                  Goto Salida
               End
         End

--
-- Depuración del Cabecero detalle de los movimientos contables del Período en el Histórico. Para actualizar el nuevo ejercicio.
--

      If Exists ( Select Top 1 1
                  From   dbo.PolizaHist With (Nolock)
                  Where  ejercicio = @PnAnio)
         Begin
            Begin Try
               Delete dbo.PolizaHist
               Where  ejercicio = @PnAnio;

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

                  Insert dbo.logCierreInicioEjercicioTbl
                 (Ejercicio, mes, descripcion, idError, mensajeError, usuario, ipAct)
                  Select @PnAnio, @PnMes, 'Inicializando la Tabla PolizaHist', @PnEstatus, @PsMensaje, @w_usuario, @w_ipAct;
                  Set @w_idlogFin = @@Identity
         
                  Set Xact_Abort Off
                  Goto Salida
               End
         End

--
-- Depuración del Catálogo en el Histórico. Para actualizar el nuevo ejercicio.
--

      If Exists ( Select Top 1 1
                  From   dbo.CatalogoAuxiliarHist With (Nolock)
                  Where  ejercicio = @PnAnio)
         Begin
            Begin Try
               Delete dbo.CatalogoAuxiliarHist
               Where  ejercicio = @PnAnio;

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

                  Insert dbo.logCierreInicioEjercicioTbl
                 (Ejercicio, mes, descripcion, idError, mensajeError, usuario, ipAct)
                  Select @PnAnio, @PnMes, 'Inicializando la Tabla CatalogoAuxiliarHist', @PnEstatus, @PsMensaje, @w_usuario, @w_ipAct;
                  Set @w_idlogFin = @@Identity
         
                  Set Xact_Abort Off
                  Goto Salida
               End
         End
--
-- Alta de Cabecero de los movimientos contables del Período en el Histórico
--

      Begin Try
         Insert Into dbo.polizaHist
         (Referencia,      Fecha_mov,     Fecha_Cap, Concepto,   Cargos,
          Abonos,          TCons,         Usuario,   TipoPoliza, Documento,
          Usuario_cancela, Fecha_Cancela, Status,    Mes_Mov,    TipoPolizaConta,
          FuenteDatos,     ejercicio,     mes)
         Select Referencia,      Fecha_mov,     Fecha_Cap, Concepto,   Cargos,
                Abonos,          TCons,         Usuario,   TipoPoliza, Documento,
                Usuario_cancela, Fecha_Cancela, Status,    Mes_Mov,    TipoPolizaConta,
                FuenteDatos,     ejercicio,     mes
         From   dbo.poliza With (Nolock)
         Where  Ejercicio = @PnAnio;

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

            Insert dbo.logCierreInicioEjercicioTbl
           (Ejercicio, mes, descripcion, idError, mensajeError, usuario, ipAct)
            Select @PnAnio, @PnMes, 'Alta a la Tabla polizaHist', @PnEstatus, @PsMensaje, @w_usuario, @w_ipAct;
            Set @w_idlogFin = @@Identity
         
            Set Xact_Abort Off
            Goto Salida
         End

--
-- Alta del detalle de los movimientos contables del Período en el Histórico
--

      Begin Try
         Insert Into dbo.movimientosHist
         (Referencia,  Cons,            Moneda,           Fecha_mov,     Llave,
          Concepto,    Importe,         Documento,        Clave,         FecCap,
          Sector_id,   Sucursal_id,     Region_id,        Importe_Cargo, Importe_Abono,
          Descripcion, TipoPolizaConta, ReferenciaFiscal, Fecha_Doc,     Ejercicio,
          mes)
         Select Referencia,  Cons,            Moneda,           Fecha_mov,     Llave,
                Concepto,    Importe,         Documento,        Clave,         FecCap,
                Sector_id,   Sucursal_id,     Region_id,        Importe_Cargo, Importe_Abono,
                Descripcion, TipoPolizaConta, ReferenciaFiscal, Fecha_Doc,     Ejercicio,
                mes
         From   dbo.movimientos With (Nolock)
         Where  Ejercicio = @PnAnio;

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

            Insert dbo.logCierreInicioEjercicioTbl
           (Ejercicio, mes, descripcion, idError, mensajeError, usuario, ipAct)
            Select @PnAnio, @PnMes, 'Alta a la Tabla movimientosHist', @PnEstatus, @PsMensaje, @w_usuario, @w_ipAct;
            Set @w_idlogFin = @@Identity
                     
            Set Xact_Abort Off
            Goto Salida
         End

--
-- Alta del Catálogo Auxiliar del Período en el Histórico
--

      Begin Try
         Insert Into dbo.CatalogoAuxiliarHist
         (Llave,       Moneda,     Niv,         Sector_id,
          Sucursal_id, Region_id,  Descrip,     SAnt,
          Car,         Abo,        SAct,        FecCap,
          CarProceso,  AboProceso, SAntProceso, CarExt,
          AboExt,      SProm,      SPromAnt,    SProm2,
          SProm2Ant,   ejercicio,  mes)
         Select Llave,       Moneda,     Niv,         Sector_id,
                Sucursal_id, Region_id,  Descrip,     SAnt,
                Car,         Abo,        SAct,        FecCap,
                CarProceso,  AboProceso, SAntProceso, CarExt,
                AboExt,      SProm,      SPromAnt,    SProm2,
                SProm2Ant,   ejercicio,  mes
         From   dbo.CatalogoAuxiliar With (Nolock)
         Where  Ejercicio = @PnAnio

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

            Insert dbo.logCierreInicioEjercicioTbl
           (Ejercicio, mes, descripcion, idError, mensajeError, usuario, ipAct)
            Select @PnAnio, @PnMes, 'Alta a la Tabla CatalogoAuxiliarHist', @PnEstatus, @PsMensaje, @w_usuario, @w_ipAct;
            Set @w_idlogFin = @@Identity
         
            Set Xact_Abort Off
            Goto Salida
         End


--
-- Depuración del detalle de los movimientos contables del Período Cerrado.
--

      Begin Try
         Delete dbo.movimientos
         Where  Ejercicio = @PnAnio;

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

            Insert dbo.logCierreInicioEjercicioTbl
           (Ejercicio, mes, descripcion, idError, mensajeError, usuario, ipAct)
            Select @PnAnio, @PnMes, 'Depurando la Tabla movimientos', @PnEstatus, @PsMensaje, @w_usuario, @w_ipAct;
            Set @w_idlogFin = @@Identity
         
            Set Xact_Abort Off
            Goto Salida
         End

--
-- Depuración del cabecero de los movimientos contables del Período Cerrado.
--

      Begin Try
         Delete dbo.poliza
         Where  Ejercicio = @PnAnio;

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

            Insert dbo.logCierreInicioEjercicioTbl
           (Ejercicio, mes, descripcion, idError, mensajeError, usuario, ipAct)
            Select @PnAnio, @PnMes, 'Depurando la Tabla poliza', @PnEstatus, @PsMensaje, @w_usuario, @w_ipAct;
            Set @w_idlogFin = @@Identity
         
            Set Xact_Abort Off
            Goto Salida
         End

--
-- Depuración del catálogo auxiliar del Período Cerrado.
--

      Begin Try
         Delete dbo.CatalogoAuxiliar
         Where  Ejercicio = @PnAnio;

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

            Insert dbo.logCierreInicioEjercicioTbl
           (Ejercicio, mes, descripcion, idError, mensajeError, usuario, ipAct)
            Select @PnAnio, @PnMes, 'Depurando la Tabla CatalogoAuxiliar', @PnEstatus, @PsMensaje, @w_usuario, @w_ipAct;
            Set @w_idlogFin = @@Identity
         
            Set Xact_Abort Off
            Goto Salida
         End

--
-- Fin del proceso.
--

   Commit Transaction

   Select @PsMensaje = 'Traspaso realizado con éxito!',
          @PnEstatus = 0

Salida:

   Insert dbo.logCierreInicioEjercicioTbl
  (Ejercicio, mes, descripcion, idError, mensajeError, usuario, ipAct)
   Select @PnAnio, @PnMes, 'Fin de Proceso', @PnEstatus, @PsMensaje, @w_usuario, @w_ipAct;
   Set @w_idlogFin = @@Identity

   Select @PnEstatus = 0,
          @PsMensaje = Concat(Format(@w_idlogInic, Replicate('0', 10)), '-', Format(@w_idlogFin, Replicate('0', 10)))

   Set Xact_Abort Off
   Return

End
Go

--
-- Comentarios.
--

Declare
   @w_valor          Varchar(1500) = 'Mueve los saldos acumulados del ejercicio en cierre al Histórico.',
   @w_procedimiento  Varchar( 100) = 'Spp_actualizaInicioEjercicio'


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
