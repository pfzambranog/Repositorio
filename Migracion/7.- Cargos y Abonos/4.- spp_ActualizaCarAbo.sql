/*
-- Declare
   -- @PnEjercicio      Integer        = 2024,
   -- @PnMes            Integer        = 7,
   -- @PsCondicion      Varchar(500)   = ' And Cast(P.Fecha_Mov As Date) Between ' + Char(39) + '2024-07-01' + Char(39) + ' And ' + Char(39) + '2024-07-31' + Char(39),
   -- @PnEstatus        Integer        = 0,
   -- @PsMensaje        Varchar(250)   = ' ';
-- Begin
   -- Execute dbo.spp_ActualizaCarAbo @PnEjercicio = @PnEjercicio,
                                   -- @PnMes       = @PnMes,
                                   -- @PsCondicion = @PsCondicion,
                                   -- @PnEstatus   = @PnEstatus  Output,
                                   -- @PsMensaje   = @PsMensaje  Output;

   -- Select @PnEstatus, @PsMensaje
   -- Return
-- End
-- Go

-- Fecha: 28/Noviembre/2022
-- Autor: Desconocido
-- Task: N/A
-- Observaciones: Proceso que realiza actualizacion de cargos y abonos por proceso de acuerdo a condiciones.

-- MODIFICACIONES:
-- V1.0. [Zayra Mtz. Candia].[28Nov2022]. Se agregar correcciones y validacioes a las polizas, principalmente en sucursal, region, sector e importes 0.
            -- Ademas la actualizacion a los auxiliares corporativo, en el centro de costos 5555.
*/


Create Or Alter Procedure dbo.spp_ActualizaCarAbo
  (@PnEjercicio      Integer,
   @PnMes            Integer,
   @PsCondicion      Varchar(500),
   @PnEstatus        Integer      = 0   Output,
   @PsMensaje        Varchar(250) = ' ' Output)
As

-- Declaración de Variables --

Declare
   @intMes                   Integer,
   @mesCer                   Integer,
   @w_linea                  Integer,
   @mes                      Varchar(3)    ,
   @w_sql                    NVarchar(1500),
   @w_param                  Nvarchar( 750),
   @w_comilla                Char(1),
   @w_fechaProceso           Datetime,
--
   @w_Poliza                 Sysname,
   @w_ControlCarAbo          Sysname,
   @w_Control                Sysname,
   @w_movimientos            Sysname,
   @w_Cat                    Sysname,
   @w_CatAux                 Sysname,
   @w_CatRep                 Sysname,
   @w_CatAuxRep              Sysname,


-- INICIALIZAN VARIABLES PARA WHILE --

   @w_Error                  Integer,
   @w_mesCer                 Integer,
   @w_desc_error             Varchar(250)  ,
   @w_minId                  Integer,
   @w_maxId                  Integer,
   @w_CountSucRegError       Integer,
   @w_idEstatus              Integer,
   @w_operacion              Integer,
   @w_CountSucRegErrorOUT    Integer;

Begin
   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    On
   Set Ansi_Warnings On
   Set Ansi_Padding  On

    --Definir las variables con el nombre de la tabla y año--

   Select  @w_ControlCarAbo = 'ControlCargoAbonoTbl',
           @w_Control       = 'Control',
           @w_movimientos   = 'movimientosAnio',
           @w_Poliza        = 'polizaAnio',
           @w_catRep        = 'catalogoReporteTbl',
           @w_catAuxRep     = 'catalogoAuxReporteTbl',
           @w_operacion     = 9999,
		   @w_comilla       = Char(39),
           @w_fechaProceso  = Getdate(),
           @PnEstatus       = 0,
           @PsMensaje       = Null;
--
-- Validaciones
--

   Select  Top 1 @w_idEstatus = idEstatus
   From    dbo.ejercicios With (Nolock)
   Where   ejercicio = @PnEjercicio;
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

---=================================================================================
-- ZCMC/CHUR 28/Nov/2022. Inicia Modificación.
-- 1. Elimina registros que cargan y abonan cantidades en 0.00
---=================================================================================

   Set @w_sql = Concat('Delete dbo.', @w_movimientos,       ' ',
                       'Where  Ejercicio = ', @PnEjercicio, ' ',
                       'And    mes       = ', @PnMes,       ' ',
                       'And    importe   = 0.00');


   Begin Try
      Execute(@w_sql)
   End Try

  Begin Catch
     Select  @w_Error      = @@Error,
             @w_linea      = Error_line(),
             @w_desc_error = Substring (Error_Message(), 1, 200)

  End Catch

  If IsNull(@w_error, 0) <> 0
     Begin
        Select @PnEstatus = @w_Error,
               @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

        Insert Into dbo.Bitacora_CargosAbonos
       (mensaje, idError, mensajeError, ultactual )
        Select 'ERROR Delete Importes 0.00', @w_error, @PsMensaje, @w_fechaProceso;


        Set Xact_Abort Off
        Return
     End

--
-- 2. Se corrigen el sector_id, en caso de venir con un solo 0.
--

   Set @w_sql = Concat('Update dbo.', @w_movimientos,       '  ',
                       'Set    sector_id = ', @w_comilla,  '00', @w_comilla, ' ',
                       'Where  Ejercicio = ', @PnEjercicio, ' ',
                       'And    mes       = ', @PnMes,       ' ',
                       'And    sector_id = ', @w_comilla ,  '0',  @w_comilla);

   Begin Try
      Execute(@w_sql)
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_linea      = Error_line(),
              @w_desc_error = Substring (Error_Message(), 1, 200)

   End Catch

   If IsNull(@w_error, 0) <> 0
      Begin
         Select @PnEstatus = @w_Error,
                @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

         Insert Into dbo.Bitacora_CargosAbonos
        (mensaje, idError, mensajeError, ultactual )
         Select 'ERROR Update Movdia Sector', @w_error, @PsMensaje, @w_fechaProceso;

         Set Xact_Abort Off
         Return
      End

--
-- 3. Cambiar auxiliares corporativos a centro de costos 5555000, 5555,
--    en corformidad con la tabla de auxiliaresCorporativos
--

   Set @w_sql = Concat('Update dbo.', @w_movimientos,       '  ',
                       'Set    Sucursal_id = 5555000, ',
                               'Region_id  = 5555 ',
                       'From   dbo.', @w_movimientos,       ' a With (Nolock) ',
                       'Where  Ejercicio = ', @PnEjercicio, ' ',
                       'And    mes       = ', @PnMes,       ' ',
                       'And    Exists    ( Select Top 1 1 ',
                                          'From   dbo.AuxiliaresCorporativos With (Nolock) ',
                                          'Where  llave = a.llave )');

   Begin Try
      Execute(@w_sql)
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_linea      = Error_line(),
              @w_desc_error = Substring (Error_Message(), 1, 200)

   End Catch

   If IsNull(@w_error, 0) <> 0
      Begin
         Select @PnEstatus = @w_Error,
                @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

         Insert Into dbo.Bitacora_CargosAbonos
        (mensaje, idError, mensajeError, ultactual )
         Select 'ERROR Update Sucursal y Region de AuxiliaresCorporativos', @w_error, @PsMensaje, @w_fechaProceso;


         Set Xact_Abort Off
         Return
      End

--
-- 4. Valida centro de costo para todas las polizas,
--

   Select @w_sql   = Concat('Select @o_cantidad = count (1) ',
                            'From   dbo.' + @w_movimientos + ' a With (Nolock) ' +
                            'Where  Ejercicio  = ', @PnEjercicio, ' ',
                            'And    mes        = ', @PnMes,       ' ',
                            'And    Not Exists ( Select Top 1 1 ',
                                                 'From   dbo.Area_o_Region With(Nolock) ',
                                                 'Where  Region_id   = a.region_id ',
                                                 'And    Sucursal_id = a.Sucursal_id) '),
          @w_param = '@o_cantidad Integer Output';

    Begin Try
       Execute Sp_executesql @w_sql, @w_param, @o_cantidad = @w_CountSucRegError Output;
    End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_linea      = Error_line(),
              @w_desc_error = Substring (Error_Message(), 1, 200)

   End Catch

   If IsNull(@w_error, 0) <> 0
      Begin
         Select @PnEstatus = @w_Error,
                @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

         Insert Into dbo.Bitacora_CargosAbonos
        (mensaje, idError, mensajeError, ultactual )
         Select 'ERROR al contar registros con Sucursal o region inexistente', @w_error, @PsMensaje, @w_fechaProceso;


         Set Xact_Abort Off
         Return
      End

   If @w_CountSucRegError > 0
      Begin
         Insert Into dbo.Bitacora_CargosAbonos
        (mensaje, idError, mensajeError, ultActual )
         Select Concat ('ERROR ', @w_CountSucRegError, ' Registros con Sucursal o region inexistente'),
                  9999, Char(32),  @w_fechaProceso;

         Set Xact_Abort Off
         Return

      End

--
--- ZCMC/CHUR 28/Nov/2022. Termina Modificación.
--

--
-- Inicio de Proceso.
--

-- Extrae el Período en proceso

   Select @w_mesCer   = Max(mes)
   From   dbo.control With (Nolock)
   Where  ejercicio = @PnEjercicio
   And    idEstatus = 1;
   
-- Limpiar Cargos y Abonos del Catalogo para el ejercicio y mes.


   If @Pnmes = @w_mesCer
      Begin
         Set @w_sql = Concat('Update dbo.Catalogo ',
                             'Set    CarExt        = 0, ',
                             '       AboExt        = 0, ',
                             '       CarProceso    = 0, ',
                             '       AboProceso    = 0  ',
                             'Where  ejercicio   = ', @PnEjercicio, ' ',
                             'And    mes         = ', @PnMes)
      
         Begin Try
           Execute(@w_sql)
         End Try
      
         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_linea      = Error_line(),
                    @w_desc_error = Substring (Error_Message(), 1, 200)
      
         End Catch
      
         If IsNull(@w_error, 0) <> 0
            Begin
               Select @PnEstatus = @w_Error,
                      @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);
      
               Insert Into dbo.Bitacora_CargosAbonos
              (mensaje, idError, mensajeError, ultactual )
               Select 'ERROR', @w_error, @PsMensaje, @w_fechaProceso;
      
      
               Set Xact_Abort Off
               Return
            End
      
      -- Limpiar Cargos y Abonos del para el ejercicio y mes.
      
         Set @w_sql = Concat('Update dbo.CatalogoAuxiliar ',
                             'Set    CarExt        = 0, ',
                             '       AboExt        = 0, ',
                             '       CarProceso    = 0, ',
                             '       AboProceso    = 0  ',
                             'Where  ejercicio   = ', @PnEjercicio, ' ',
                             'And    mes         = ', @PnMes)
      
         Begin Try
           Execute(@w_sql)
         End Try
         
         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_linea      = Error_line(),
                    @w_desc_error = Substring (Error_Message(), 1, 200)
      
         End Catch
      
         If IsNull(@w_error, 0) <> 0
            Begin
               Select @PnEstatus = @w_Error,
                      @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);
      
               Insert Into dbo.Bitacora_CargosAbonos
              (mensaje, idError, mensajeError, ultactual )
               Select 'ERROR', @w_error, @PsMensaje, @w_fechaProceso;
      
      
               Set Xact_Abort Off
               Return
            End
      End
      
   Execute dbo.Spp_AplicaPolizas @PnAnio      = @PnEjercicio,
                                 @PnIdMes     = @PnMes,
                                 @PnMesCer    = @w_mesCer,
                                 @PsCondicion = @PsCondicion,
                                 @PnEstatus   = @PnEstatus Output,
                                 @PsMensaje   = @PsMensaje Output;


   If IsNull(@PnEstatus, 0) <> 0
      Begin
         Set Xact_Abort Off
         Return
      End

-- Modifica el PnEstatus de VIGENTE a PROCESADA en el proceso de cargos y abonos
-- PnEstatus VIGENTE ES CON VALOR 0
-- PnEstatus PROCESADA ES CON VALOR 2

   Set @w_sql = Concat('Update m  ', 
                       'Set    m.status = 2 ',
                       'From   dbo.' + @w_Poliza + '      m With (Nolock) ',
                       'Join   dbo.' + @w_movimientos + ' p With (Nolock) ',
                       'On     p.Fecha_Mov  = p.Fecha_Mov  ',
                       'And    p.Referencia = p.Referencia ',
                       'And    p.ejercicio  = m.ejercicio ',
                       'And    p.mes        = m.mes ',
                       'Where  1  = 1 ', @PsCondicion)
 
   Begin Try
     Execute(@w_sql)
   End Try
   
   Begin Catch
      Select  @w_Error      = @@Error,
              @w_linea      = Error_line(),
              @w_desc_error = Substring (Error_Message(), 1, 200)

   End Catch

   If IsNull(@w_error, 0) <> 0
      Begin
         Select @PnEstatus = @w_Error,
                @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

         Insert Into dbo.Bitacora_CargosAbonos
        (mensaje, idError, mensajeError, ultactual)
         Select 'ERROR 5', @w_error, @PsMensaje, @w_fechaProceso;


         Set Xact_Abort Off
         Return
      End  
  
   Set   @PsMensaje = 'PROCESO DE CARGOS Y ABONOS REALIZADO CON ÉXITO'

   Insert Into Bitacora_CargosAbonos
  (mensaje, idError, mensajeError, ultactual)
   Select @PsMensaje, @PnEstatus, Char(32), @w_fechaProceso;
--

   Set Xact_Abort Off
   Return

End
Go

--
-- Comentarios.
--

Declare
   @w_valor          Varchar(1500) = 'Proceso que realiza actualizacion de cargos y abonos por proceso de acuerdo a condiciones..',
   @w_procedimiento  Varchar( 100) = 'spp_ActualizaCarAbo'


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