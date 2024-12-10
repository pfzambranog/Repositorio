  
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
  
---- Execute Spp_ExportaContabilidad '2022-12-31', 1, 0, null  
  
Create   Procedure dbo.Spp_ExportaContabilidad  
  (@PdFechaProceso       Date,  
   @PnIdUsuarioAct       Smallint,  
   @PnEstatus            Integer       = 0     Output ,  
   @PsMensaje            Varchar(250)  = Null  Output)  
As  
  
Declare  
   @w_FechaInicio         Date,  
   @w_FechaFin            Date,  
   @w_Error               Integer,  
   @w_operacion           Integer,  
   @w_Desc_Error          Varchar(250),  
   @w_sql                 Varchar(Max);  
  
--Begin  
   Set Nocount       On  
   Set Xact_Abort    On  
   Set Ansi_Nulls    Off  
  
   Select  @PnEstatus      = 0,  
           @PsMensaje      = ' ',  
           @w_operacion    = 9999,  
           @w_sql          = dbo.Fn_BuscaResultadosParametros( 411, 'cadena'),  
           @w_FechaFin     = DateAdd(dd, 1, @PdFechaProceso);  
  
   If Isdate(@w_sql) = 1  
      Begin  
         Set @w_FechaInicio = Cast(@w_sql As Date);  
      End  
   Else  
      Begin  
         Select @PnEstatus = 9999,  
                @PsMensaje = 'Error: El Parámetro 411 no es una fecha válida.';  
         Set Xact_Abort    Off  
         Return  
      End  
  
   --1) El tipo de poliza igual al cabecero                                            --Ok  
   --2) Que cuadren cargos y abonos del cabecero vs cargos y abonos del detalle        --OK  
   --3) Que todas las polizas traigan centro de costos                       --OK  
   --4) Que todas las polizas traigan fecha menor o igual al proceso de fin de dia     --OK  
   --5) Que no traigan nulos                                                           --OK  
   --6) Validar que todas las polizas traigan usuario                                  --OK  
   --7) Validar que el detalle, todas las polizas traigan cuenta contable              --OK  
   --8) Validar que el detalle, que todas las polizas auxiliar en la cuenta contable   --OK  
  
   --Registro en log  
  
   Insert Into dbo.LogExportacionPolizas  
   (Fecha, Descripcion, hora_terminacion)  
   Select Getdate(), 'Validacion 1 (INICIO)', Getdate();  
  
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
     
   --Registro en log  
  
   Insert Into dbo.LogExportacionPolizas  
   (Fecha, Descripcion, hora_terminacion)  
   Select Getdate(), 'Dif Cargos y Abonos', Getdate();  
  
   --2) Que cuadren cargos y abonos del cabecero vs cargos y abonos del detalle  
    Update Poliza Set Referencia_Exporta = 'Dif Cargos y Abonos' Where Referencia_Exporta is null and Ltrim(Rtrim(Referencia)) + '-' + Ltrim(Rtrim(convert(char,FechaContable,112))) in  
    (  
    Select Ltrim(Rtrim(Datos.Referencia)) + + '-' + Ltrim(Rtrim(convert(char,Datos.FechaContable,112)))  from (  
    Select  a.Referencia,  
      a.FechaContable,  
      sum(Case When a.Clave = 'D' Then (a.Importe/100) else 0 end) as Cargo,  
      sum(Case When a.Clave = 'C' Then (a.Importe/100) else 0 end) as Abono,  
      round((sum(Case When a.Clave = 'D' Then (a.Importe/100) else 0 end) - sum(Case When a.Clave = 'C' Then (a.Importe/100) else 0 end)),2) as Diferencia  
    From    poliza_mov     a  
    Where   1 = 1  
    and     a.FechaContable <= @PdFechaProceso  
    And     a.Referencia in (Select  a.Referencia From poliza a Where a.FechaContable <= @PdFechaProceso And a.Referencia_Exporta Is Null)  
    Group by a.Referencia,  
    a.FechaContable  
 ) Datos join  poliza pol  
 on Datos.Referencia = pol.Referencia and Datos.FechaContable = pol.FechaContable  
 Where Diferencia <> 0  
    )  
   --Validacion 2 (TERMINO)  
  
  
   --Validacion 3 (INICIO)  
  
   --Registro en log  
  
   Insert Into dbo.LogExportacionPolizas  
  (Fecha, Descripcion, hora_terminacion)  
   Select Getdate(), 'Sin Centro de Costos', Getdate();  
  
  Update Poliza Set Referencia_Exporta = 'Sin Centro de Costos' Where Referencia_Exporta is null and Ltrim(Rtrim(Referencia)) + '-' + Ltrim(Rtrim(convert(char,FechaContable,112))) in (  
  Select Ltrim(Rtrim(Referencia)) + '-' + Ltrim(Rtrim(convert(char,FechaContable,112))) from Poliza_mov Where FechaContable <= @PdFechaProceso and len(Sucursal_id) < 7  
  union all  
  Select Ltrim(Rtrim(Referencia)) + + '-' + Ltrim(Rtrim(convert(char,FechaContable,112))) from Poliza_mov Where FechaContable <= @PdFechaProceso and len(Region_id) < 4  
  )  
   --Validacion 3 (TERMINO)  
  
   --Validacion 4 (INICIO)  
     --OK, el proceso se ejecuta unicamente con las polizas con fecha menor o igual, a la fecha del parametro  
   --Validacion 4 (INICIO)  
  
   --Validacion 5 (INICIO)  
   --Registro en log  
   Insert Into dbo.LogExportacionPolizas  
   (Fecha, Descripcion, hora_terminacion)  
   Select Getdate(), 'Sin Concepto', Getdate();  
  
  Set dateformat dmy;  
  Update Poliza Set Concepto = Upper(Concepto) Where FechaContable <= @PdFechaProceso  
  Update Poliza Set Referencia_Exporta = 'Sin Concepto' Where Concepto is null and Referencia_Exporta is null and FechaContable <= @PdFechaProceso  
   --Validacion 5 (TERMINO)  
  
  
   --Validacion 7 (INICIO)  
   --Registro en log  
    Insert Into dbo.LogExportacionPolizas  
   (Fecha, Descripcion, hora_terminacion)  
   Select Getdate(), 'Sin Cta Contable', Getdate();  
  
  Set dateformat dmy;  
  Update Poliza Set Referencia_Exporta = 'Sin Cta Contable' Where Poliza in (Select Poliza from Poliza_mov Where FechaContable = @PdFechaProceso and llave = '' or llave = 'PROV SIN AUX') and FechaContable in (Select FechaContable from Poliza_mov Where Fe
chaContable = @PdFechaProceso and llave = '' or llave = 'PROV SIN AUX')  
   --Validacion 7 (TERMINO)  
  
  
   --Validacion 8 (INICIO)  
   --Registro en log  
   Insert Into dbo.LogExportacionPolizas  
   (Fecha, Descripcion, hora_terminacion)  
   Select Getdate(), 'Ctas sin auxiliar', Getdate();  
  
  
  Update Poliza Set Referencia_Exporta = 'Ctas sin auxiliar'  
         Where Poliza in (Select Poliza from Poliza_Mov Where FechaContable = @PdFechaProceso and Llave = '')  
    and FechaContable in (Select FechaContable from Poliza_Mov Where FechaContable = @PdFechaProceso and Llave = '')  
   --Validacion 8 (TERMINO)  
   Declare  
   @w_numPolizas            int,  
   @w_numPolizasProcesadas  varchar(250)  
  
   SET @w_numPolizas = (Select count(*)  
   From    poliza     a  
   Join    tipoPoliza b  
   On      b.tipo                = Substring(a.referencia, 1, 2)  
   And     b.TipoContabilizacion = 1  
   And     a.cargos              = a.abonos  
   And     a.cargos             != 0  
   And     a.FechaContable      <= @PdFechaProceso  
   And     a.Referencia_Exporta Is Null  
   )  
  
   SET @w_numPolizasProcesadas = (Select convert (varchar(250),@w_numPolizas ))  
  
   Insert Into dbo.LogExportacionPolizas  
   (Fecha, Descripcion, hora_terminacion)  
   Select Getdate(), 'Incian cursores, se procesaran ' + @w_numPolizasProcesadas + ' polizas' , Getdate();  
  
   --Aqui comienza el codigo original del proceso  
  
  
Declare  
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
   @w_secuencia2     Integer,  
   @w_tipo                       Varchar(    3),  
   @w_documento                  Varchar(   255),--ZCMC TASK 40231  
   @w_TipoContabPro              Varchar(    3),  
   @w_Status                     Tinyint,  
   @w_Mes_Mov                    Varchar(    3),  
   @w_FuenteDatos                Varchar(  100)  
  
Begin  
  
   Set Nocount       On  
   Set Xact_Abort    On  
   Set Ansi_Nulls    Off  
   Set Ansi_Warnings On  
   Set Ansi_Padding  On  
  
   Select @PnEstatus             = 0,  
          @PsMensaje             = Null,  
          @w_operacion           = 9999,  
          @w_ultActual           = Getdate(),  
          @w_fechaCaptura        = Cast(@w_ultActual As Date),  
          @w_ipAct               = dbo.Fn_BuscaDireccionIP(),  
          @w_Status              = 2,  
          @w_Mes_Mov             = Upper(Format(@PdFechaProceso, 'MMM', 'es-es')),  
          @w_FuenteDatos         = 'SISARRENDACREDITO',  
          @w_usuario             = dbo.Fn_BuscaCodigoUsuario(@PnIdUsuarioAct)  
  
--  
-- Consulta y Validaciones de Datos y Parámetros  
--  
  --Registro en log  
   Insert Into dbo.LogExportacionPolizas  
   (Fecha, Descripcion, hora_terminacion)  
   Select Getdate(), 'Consulta y Validaciones de Datos y Parámetros', Getdate();  
  
   Select @PnEstatus = dbo.Fn_ValidaUsuarioActivo (@PnIdUsuarioAct)  
  
   If @PnEstatus != 0  
      Begin  
         Set @PsMensaje = 'Error.: ' + dbo.Fn_Busca_MensajeError(@w_operacion, @PnEstatus)  
  
    --Registro en log  
  
         Insert Into dbo.LogExportacionPolizas  
         (Fecha, Descripcion, hora_terminacion)  
         Select Getdate(), @PsMensaje, Getdate();  
  
         Set Xact_Abort Off  
         Return  
      End  
  
   Begin Transaction  
  
  Declare  
   C_Detalle Cursor For  
   Select  a.Referencia,       a.FechaContable,  a.Concepto, a.Cargos / 100.00,  
           a.Abonos / 100.00,  a.TCons,          b.tipo,     a.documento,  
           b.TipoContabPro, a.poliza  
   From    poliza     a  
   Join    tipoPoliza b  
   On      b.tipo                = Substring(a.referencia, 1, 2)  
   And     b.TipoContabilizacion = 1  
   And     a.cargos              = a.abonos  
   And     a.cargos             != 0  
   And     (a.FechaContable      > @w_FechaInicio AND a.FechaContable < @w_FechaFin)  
   And     a.Referencia_Exporta Is Null  
   Order   By 1  
  
      Open   C_Detalle  
      While  @@Fetch_status < 1  
      Begin  
         Fetch C_Detalle Into @w_Referencia,    @w_FechaContable,  @w_Concepto, @w_Cargos,  
        @w_Abonos, @w_TCons,          @w_tipo,     @w_documento,  
 @w_TipoContabPro, @w_poliza  
  
         If @@Fetch_Status <> 0  
            Begin  
               Break  
            End  
   -- ==============================================================================================================================  
   -- SE CAMBIA FORMA DE OBTENER LA SECUENCIA PARA LA REFERENCIA_EXPORTA Y REFERENCIA EN TABLA MOVDIA DE DB_GEN_DES [ZCMC10012023]  
   --===============================================================================================================================  
         --Select @w_secuencia = Max(Substring(Referencia, 4, 7))  
         --From   DB_GEN_DES.dbo.MovDia  
         --Where  Substring(Referencia, 1, 3) = @w_TipoContabPro  
         --And    Fecha_mov                   = @w_FechaContable  
         --Select @w_secuencia   = Isnull(@w_secuencia, 0) + 1,  
         --       @w_Referencia2 = Concat(@w_TipoContabPro, Format(@w_secuencia, '00000'))  
   --===============================================================================================================================  
  
    Select @w_secuencia = Max(Substring(Referencia_exporta, 4, 7))  
    From   poliza  
    Where  (Referencia_exporta IS NOT NULL AND Referencia_exporta != 'Ctas sin auxiliar' AND Referencia_exporta != 'Dif Cargos y Abonos')  
    And    Substring(Referencia_exporta, 1, 3) = @w_TipoContabPro  
    And    (CAST(FechaContable AS DATE)      > EOMONTH(@w_FechaContable,-1) AND CAST(FechaContable AS DATE) <= EOMONTH(@w_FechaContable))  
    Select @w_secuencia   = Isnull(@w_secuencia, 0) + 1,  
     @w_Referencia2 = Concat(@w_TipoContabPro, Format(@w_secuencia, '00000'))  
  
         Begin Try  
            Insert Into DB_GEN_DES.dbo.MovDia  
           (Referencia, Fecha_mov, Fecha_Cap,       Concepto,  
            Cargos,     Abonos,    TCons,           Usuario,  
            TipoPoliza, Documento, Usuario_cancela, Fecha_Cancela,  
            Status,     Mes_Mov,   TipoPolizaConta, FuenteDatos,  
            Causa_Rechazo)  
            Select @w_Referencia2,   @w_FechaContable, @w_fechaCaPtura,   @w_Concepto,  
                   @w_Cargos,        @w_Abonos,        @w_TCons,          @w_Usuario,  
                   @w_TipoContabPro, substring(@w_Documento,1,30),     Null,              Null Fecha_Cancela,  
                   @w_Status,        Case When Month(@w_FechaContable) =  1 Then 'ENE'  
                              When Month(@w_FechaContable) =  2 Then 'FEB'  
            When Month(@w_FechaContable) =  3 Then 'MAR'  
            When Month(@w_FechaContable) =  4 Then 'ABR'  
            When Month(@w_FechaContable) =  5 Then 'MAY'  
            When Month(@w_FechaContable) =  6 Then 'JUN'  
            When Month(@w_FechaContable) =  7 Then 'JUL'  
            When Month(@w_FechaContable) =  8 Then 'AGO'  
            When Month(@w_FechaContable) =  9 Then 'SEP'  
            When Month(@w_FechaContable) = 10 Then 'OCT'  
            When Month(@w_FechaContable) = 11 Then 'NOV'  
            When Month(@w_FechaContable) = 12 Then 'DIC' ELSE '' End,       @w_tipo,           @w_FuenteDatos,  
                   Null  
         End Try  
  
         Begin Catch  
            Select  @w_Error      = @@Error,  
                    @w_desc_error = Substring (Error_Message(), 1, 230)  
   Print @w_desc_error  
         End  Catch  
  
         If Isnull(@w_Error, 0) <> 0  
            Begin  
               Select @PnEstatus = @w_error,  
                      @PsMensaje = 'Error.:  DB_GEN_DES.dbo.MovDia ' + @w_desc_error  
  
       --Registro en log  
               Rollback Transaction  
               Insert Into dbo.LogExportacionPolizas  
              (Fecha, Descripcion, hora_terminacion)  
               Select Getdate(), @PsMensaje, Getdate();  
  
               Close      C_Detalle  
               Deallocate C_Detalle  
               Set Xact_Abort Off  
               Return  
            End  
  
         Begin Try  
            Insert Into DB_GEN_DES.dbo.PolDia  
            (Referencia,      Cons,             Moneda,        Fecha_mov,  
             Llave,           Concepto,       Importe,       Documento,  
             Clave,           FecCap,           Sector_id,     Sucursal_id,  
             Region_id,       Importe_Cargo,    Importe_Abono, Descripcion,  
             TipoPolizaConta, ReferenciaFiscal, Fecha_Doc,     Causa_Rechazo)  
            Select  @w_Referencia2, Cons,         '00'    Moneda,       @w_FechaContable,  
                    Llave,      Concepto,         Importe / 100.00, substring(Documento,1,30),  
                    Clave,      @w_fechaCaptura,  Null Sector,      Sucursal_id,  
                    Region_id,  Case When Clave = 'D'  
                                     Then Importe / 100.00  
                                     Else 0  
                                End,              Case When Clave != 'D'  
                                                       Then Importe / 100.00  
                                                      Else 0  
                                                  End,           Descripcion,  
                    TipoPoliza, ReferenciaFiscal, Fecha_Doc,     Null  
            From    poliza_mov  
            Where   poliza        = @w_poliza  
            And     Referencia    = @w_Referencia  
            And     FechaContable = @w_FechaContable  
            And     importe      != 0  
  
         End Try  
  
         Begin Catch  
            Select  @w_Error      = @@Error,  
                    @w_desc_error = Substring (Error_Message(), 1, 230)  
         End   Catch  
  
         If Isnull(@w_Error, 0) <> 0  
            Begin  
               Select @PnEstatus = @w_error,  
                      @PsMensaje = 'Error.: DB_GEN_DES.dbo.PolDia ' + @w_desc_error  
  
       --Registro en log  
               Rollback Transaction  
               Insert Into dbo.LogExportacionPolizas  
               (Fecha, Descripcion, hora_terminacion)  
               Select Getdate(), @PsMensaje, Getdate();  
  
               Close      C_Detalle  
               Deallocate C_Detalle  
               Set Xact_Abort Off  
               Return  
            End  
  
         Begin Try  
            Update Poliza  
            Set    Referencia_Exporta = @w_Referencia2  
            Where  referencia    = @w_Referencia  
            And    poliza        = @w_poliza  
            And    fechaContable = @w_FechaContable  
         End Try  
  
         Begin Catch  
            Select  @w_Error      = @@Error,  
                    @w_desc_error = Substring (Error_Message(), 1, 230)  
         End   Catch  
  
         If Isnull(@w_Error, 0) <> 0  
            Begin  
               Select @PnEstatus = @w_error,  
                      @PsMensaje = 'Error.: DB_GEN_DES.dbo.PolDia ' + @w_desc_error  
  
               Rollback Transaction  
  
       --Registro en log  
  
               Insert Into dbo.LogExportacionPolizas  
               (Fecha, Descripcion, hora_terminacion)  
               Select Getdate(), @PsMensaje, Getdate();  
  
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
   Select  Substring(a.Referencia, 1, 2),  a.FechaContable,          Concat(upper(b.descripcion), ' DEL ', Convert(Char(10), a.FechaContable, 103)),  
           Sum(a.Cargos) / 100.00,         Sum(a.Abonos) / 100.00,   b.tipo,                        Max(a.documento), b.TipoContabPro,  
           Sum(TCons)  
   From    poliza     a  
   Join    tipoPoliza b  
   On      b.tipo                = Substring(a.referencia, 1, 2)  
   And     b.TipoContabilizacion = 2  
   And     a.cargos              = a.abonos  
   And     a.cargos             != 0  
   And     a.FechaContable      <= @PdFechaProceso  
   And     a.Referencia_Exporta Is Null  
   Group   By Substring(a.Referencia, 1, 2),  a.FechaContable, Concat(upper(b.descripcion), ' DEL ', Convert(Char(10), a.FechaContable, 103)),  
           b.tipo,                            b.TipoContabPro  
   Order   By 1  
  
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
         From   DB_GEN_DES.dbo.MovDia  
         Where  Substring(Referencia, 1, 3) = @w_TipoContabPro  
         And    Fecha_mov                   = @w_FechaContable  
    Select @w_secuencia   = Isnull(@w_secuencia, 0) + 1,  
                @w_Referencia2 = Concat(@w_TipoContabPro, Format(@w_secuencia, '00000'))  
  
         Begin Try  
            Insert Into DB_GEN_DES.dbo.MovDia  
           (Referencia, Fecha_mov, Fecha_Cap,       Concepto,  
            Cargos,     Abonos,    TCons,           Usuario,  
            TipoPoliza, Documento, Usuario_cancela, Fecha_Cancela,  
            Status,     Mes_Mov,   TipoPolizaConta, FuenteDatos,  
            Causa_Rechazo)  
            Select @w_Referencia2,   @w_FechaContable, @w_fechaCaPtura,   @w_Concepto,  
                   @w_Cargos,        @w_Abonos,        @w_TCons,          @w_Usuario,  
                   @w_TipoContabPro, substring(@w_Documento,1,30),     Null,              Null Fecha_Cancela,  
                   @w_Status,        @w_Mes_Mov,       @w_Tipo,           @w_FuenteDatos,  
                   Null  
         End Try  
  
         Begin Catch  
            Select  @w_Error      = @@Error,  
                    @w_desc_error = Substring (Error_Message(), 1, 230)  
         End   Catch  
  
         If Isnull(@w_Error, 0) <> 0  
            Begin  
               Select @PnEstatus = @w_error,  
                      @PsMensaje = 'Error.:  DB_GEN_DES.dbo.MovDia ' + @w_desc_error  
  
               Rollback Transaction  
  
       --Registro en log  
               Insert Into dbo.LogExportacionPolizas  
              (Fecha, Descripcion, hora_terminacion)  
               Select Getdate(), @PsMensaje, Getdate();  
  
               Close      C_Detalle2  
               Deallocate C_Detalle2  
               Set Xact_Abort Off  
               Return  
            End  
  
         Begin Try  
            Insert Into DB_GEN_DES.dbo.PolDia  
            (Referencia,      Cons,             Moneda,        Fecha_mov,  
             Llave,           Concepto,         Importe,       Documento,  
             Clave,           FecCap,           Sector_id,     Sucursal_id,  
             Region_id,       Importe_Cargo,    Importe_Abono, Descripcion,  
             TipoPolizaConta, ReferenciaFiscal, Fecha_Doc,     Causa_Rechazo)  
            Select  @w_Referencia2, Row_Number() Over(Order By Referencia, Fecha_mov), '00' Moneda, @w_FechaContable,  
                    Llave,     Concepto,         Importe / 100.00, substring(Documento,1,30),  
                    Clave,          @w_fechaCaptura,  Null Sector,      Sucursal_id,  
                    Region_id,      Case When Clave = 'D'  
                    Then Importe / 100.00  
                                         Else 0  
                                    End,       Case When Clave != 'D'  
                                                           Then Importe / 100.00  
                                                           Else 0  
                                                      End,           Descripcion,  
                    TipoPoliza, ReferenciaFiscal, Fecha_Doc,     Null  
            From    poliza_mov  
            Where   Substring(Referencia, 1, 2)    = Substring(@w_Referencia, 1, 2)  
            And     FechaContable                  = @w_FechaContable  
            And     importe                       != 0  
  
         End Try  
  
         Begin Catch  
            Select  @w_Error      = @@Error,  
                    @w_desc_error = Substring (Error_Message(), 1, 230)  
         End   Catch  
  
         If Isnull(@w_Error, 0) <> 0  
            Begin  
               Select @PnEstatus = @w_error,  
                      @PsMensaje = 'Error.: DB_GEN_DES.dbo.PolDia ' + @w_desc_error  
  
  
       --Registro en log  
               Insert Into dbo.LogExportacionPolizas  
              (Fecha, Descripcion, hora_terminacion)  
               Select Getdate(), @PsMensaje, Getdate();  
  
               Rollback Transaction  
               Close      C_Detalle2  
               Deallocate C_Detalle2  
               Set Xact_Abort Off  
               Return  
            End  
  
         Begin Try  
            Update Poliza  
            Set    Referencia_Exporta = @w_Referencia2  
            Where  Substring(Referencia, 1, 2)    = Substring(@w_Referencia, 1, 2)  
            And    fechaContable                  = @w_FechaContable  
         End Try  
  
         Begin Catch  
            Select  @w_Error  = @@Error,  
                    @w_desc_error = Substring (Error_Message(), 1, 230)  
         End   Catch  
  
         If Isnull(@w_Error, 0) <> 0  
            Begin  
               Select @PnEstatus = @w_error,  
                      @PsMensaje = 'Error.: DB_GEN_DES.dbo.PolDia ' + @w_desc_error  
  
               Rollback Transaction  
  
       --Registro en log  
               Insert Into dbo.LogExportacionPolizas  
              (Fecha, Descripcion, hora_terminacion)  
               Select Getdate(), @PsMensaje, Getdate();  
  
               Close      C_Detalle2  
               Deallocate C_Detalle2  
               Set Xact_Abort Off  
               Return  
            End  
  
      End  
      Close      C_Detalle2  
      Deallocate C_Detalle2  
  
   --Registro en log  
  
   Insert Into dbo.LogExportacionPolizas  
  (Fecha, Descripcion, hora_terminacion)  
   Select Getdate(), 'Ejecuta Spp_ExportaPolizasSET', Getdate();  
  
   Execute Spp_ExportaPolizasSET @PdFechaProceso;  
  
   --Registro en log  
  
   Insert Into dbo.LogExportacionPolizas  
   (Fecha, Descripcion, hora_terminacion)  
   Select Getdate(), 'Regresa de ejecución de Spp_ExportaPolizasSET', Getdate();  
  
   Commit Transaction  
  
   --Registro en log  
   Insert Into dbo.LogExportacionPolizas  
   (Fecha, Descripcion, hora_terminacion)  
   Select Getdate(), 'Termina proceso, guarda transaccion', Getdate();  
  
   Return  
  
End  