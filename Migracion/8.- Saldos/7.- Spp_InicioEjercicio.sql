/*

-- Declare
   -- @PnEstatus             Integer             = 0,
   -- @PsMensaje             Varchar( 250)       = ' ' ;
-- Begin

   -- Execute dbo.Spp_InicioEjercicio @PnEstatus   = @PnEstatus Output,
                                   -- @PsMensaje   = @PsMensaje Output;

   -- Select @PnEstatus, @PsMensaje
   -- Return
-- End
-- Go

--

-- Objeto:        Spp_InicioEjercicio.
-- Objetivo:      Valida parámetros para la ejecución del procedimiento que mueve los saldos acumulados del ejercicio en cierre al Histórico
-- Fecha:         19/09/2024
-- Programador:   Pedro Zambrano
-- Versión:       1


*/

Create Or Alter Procedure dbo.Spp_InicioEjercicio
  (@PsUsuario             Varchar(  10)       = Null,
   @PnEstatus             Integer             = 0   Output,
   @PsMensaje             Varchar( 250)       = ' ' Output)
As

Declare
   @w_anio                Smallint,
   @w_mes                 Tinyint,
   @w_fechaIniProc        Date,
   @w_fechaFinProc        Date,
   @w_fechaProc           Date,
   @w_parametro           Varchar(Max),
   @w_desc_error          Varchar(250),
   @w_operacion           Integer,
   @w_idlogIni            Integer,
   @w_idlogFin            Integer,
   @w_error               Integer,
   @w_linea               Integer,
--
   @w_idusuario           Varchar(  Max),
   @w_usuario             Varchar(   10),
   @w_consulta            NVarchar(1500),
   @w_param               NVarchar( 750);

Begin
   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off

   Select @PnEstatus         = 0,
          @w_Error           = 0,      
          @PsMensaje         = Null,
          @w_operacion       = 9999,
          @w_fechaProc       = Getdate();

--
-- Búsqueda del rango de la fecha de proceso.
--

   Select @w_parametro = parametroChar
   From   dbo.conParametrosGralesTbl With (Nolock)
   Where  idParametroGral = 10;
   If @@Rowcount = 0
      Begin
         Select @PnEstatus = 139,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus);

         Set Xact_Abort    Off
         Return
      End

   Begin Try
      Select @w_fechaIniProc = Convert(Date, Concat(Substring(@w_parametro, 1, 2), '/',
                                                    Substring(@w_parametro, 3, 2), '/',
                                                    DatePart(yyyy, @w_fechaProc)), 103),
             @w_fechaFinProc = Convert(Date, Concat(Substring(@w_parametro, 6, 2), '/',
                                                    Substring(@w_parametro, 8, 2), '/',
                                                    DatePart(yyyy, @w_fechaProc)), 103);
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

         Set Xact_Abort    Off
         Return
      End

   If @w_fechaProc  Not Between @w_fechaIniProc And @w_fechaFinProc
      Begin
         Select @w_fechaProc hoy, @w_fechaIniProc Ini, @w_fechaFinProc Fin

         Set Xact_Abort    Off
         Return
      End

   Select @w_anio = ejercicio
   From   dbo.ejercicios  With (Nolock)
   Where  idEstatus = 3;
   If @@Rowcount = 0
      Begin
         Select @PnEstatus = 140,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus);

         Set Xact_Abort    Off
         Return
      End

   Select @w_mes = mes
   From   dbo.control a With (Nolock)
   Where  ejercicio = @w_anio
   And    mes       = (Select Max(mes)
                       From   dbo.control With (Nolock)
                       Where  ejercicio = a.ejercicio);
   If @@Rowcount = 0
      Begin
         Select @PnEstatus = 141,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus);;

         Set Xact_Abort    Off
         Return
      End;

--
-- Búsqueda del usuario de Proceso Batch.
--

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

   If Isnull(@w_error, 0) != 0
      Begin
         Select @w_error, @w_desc_error;

         Set Xact_Abort    Off
         Return
      End

--
-- Inicio Proceso
--

   Execute dbo.Spp_actualizaInicioEjercicio @PnAnio      = @w_anio,
                                            @PnMes       = @w_mes,
                                            @PnEstatus   = @PnEstatus Output,
                                            @PsMensaje   = @PsMensaje Output;


   Select @w_idlogIni = Case When IsNumeric(dbo.Fn_splitStringColumna(@PsMensaje, '-', 1)) = 0
                             Then 0
                             Else dbo.Fn_splitStringColumna(@PsMensaje, '-', 1)
                        End,
          @w_idlogFin = Case When IsNumeric(dbo.Fn_splitStringColumna(@PsMensaje, '-', 2)) = 0
                             Then 0
                             Else dbo.Fn_splitStringColumna(@PsMensaje, '-', 2)
                        End;

   If  @w_idlogIni != 0 And
       @w_idlogFin != 0
       Begin
          Set @w_parametro = (Select CodigoMotivoCorreo = 'CierrePeriodo',
                                     codigoGrupo        = 'GrupoCierre',
                                     Ejercicio          = @w_anio,
                                     mes                = @w_mes,
                                     idlogIni           = @w_idlogIni,
                                     idlogFin           = @w_idlogFin
                              For json Path)
   
          Execute Spp_notificaResultadoCierre @PsIdParametro  = @w_parametro,
                                              @PsIdUsuarioAct = @w_usuario,
                                              @PnEstatus      = @PnEstatus Output,
                                              @PsMensaje      = @PsMensaje Output;
       End

   Set Xact_Abort    Off
   Return

End
Go

--
-- Comentarios.
--

Declare
   @w_valor          Varchar(1500) = 'Valida parámetros para la ejecución del procedimiento que mueve los saldos acumulados del ejercicio en cierre al Histórico.',
   @w_procedimiento  Varchar( 100) = 'Spp_InicioEjercicio'


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