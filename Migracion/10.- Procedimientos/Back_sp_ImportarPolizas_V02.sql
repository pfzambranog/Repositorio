  
/*  
--NOTA: IMPORTANTE este SP no se puede compilar en QA, por lo que nunca se debe reemplazar de QA hacia Preproducción.  
  
Modificaciones:  
V.0.1 Zayra Martinez Candia 18/05/2021. Se agrega validación, para el ejercicio.    
V.0.2 Zayra Martinez Candia 07/03/2022. se comenta temporalmente delete de tabla RelacionImp (Se quita el comentario)  
V.0.3 Zayra Martinez Candia 15/03/2022. Se agrega validacion adicional para que las polizas no se dupliquen  
V.0.4 Zayra Martinez Candia 12/07/2022. Se corrige filtros de update para actualizar campo [no_poliza_compensa] de SET_DALTON  
V.0.5 Zayra Martinez Candia 12/10/2022. Se agrega una nuevo campo en tablas de relacion para poder rastrear mejor las polizas y se quita validacion que no permitia reprocesar polizas  
V.0.6 Zayra Martinez Candia 15/02/2023. Se agrega filtro a la validación de duplicidad de movdia2022  
V.0.7 Zayra Martinez Candia 15/02/2023. Se moddica validacion de duplicidad de movdia2022 y mes  
V.0.8 Erik González   11/01/2024. Se actualiza SP para funcionar solo en el año que se especifica  
V.0.9 Erik González   01/03/2024. Se actualiza SP. Se agrega transacción y ROLLBACK en caso de error. También se agrega la sentencia WITH(NOLOCK) para los selects  
*/  
--exec [sp_ImportarPolizas] 2024  
  
CREATE       Procedure [dbo].[sp_ImportarPolizas]  
    @PnEjercicio Integer,  
       @PnEstatus   Integer      = 0   Output,  
       @PsMensaje   Varchar(250) = ' ' Output  
As  
--INICIALIZA VARIABLES --  
--Variables para el proceso del filtro de polizas.  
  
Declare  @w_sql          Nvarchar(max),  
   @w_Error   Integer,  
   @w_Desc_Error     Nvarchar(250),  
   --Varias para los qrys de descuadre   
   @w_Abono           char(1) = 'C',  
   @w_Cargo           char(1) = 'D',  
   @w_totalCargo      Money,  
   @w_totalAbono      Money,  
   @w_minId           Integer,  
   @w_maxId           Integer,  
   @w_Referencia      Varchar(10),  
   @w_TipoPol         Nvarchar(3),  
   @w_Fecha_Mov       Date,  
   @w_Mes_Mov         Nvarchar(3),     
   @w_NewRef          varchar(10),  
   @w_Ejercicio       Integer,  
   @w_ContPol         Nvarchar(50),  
   @w_Contador        Integer,  
   @w_MovDia          Nvarchar(50),  
   @w_PolDia          Nvarchar(50),  
   @w_ContPolizas     Integer,  
   @w_ContNoPol       Integer,    
   @wz_Ejercicio      Varchar(4),  
   @w_registros       Integer,  
   @w_secuencia       Integer,  
   @w_contPDI         Integer,  
   @w_contPEG         Integer,  
   @w_contPIN         Integer,  
   @w_ConsReferencia  varchar(16),  
   @w_consecutivo     int = 0,  
   @w_ConsReferenciaInt int,  
   @PnEjercicioStr varchar(8);  
Begin  
    Set Nocount       On  
    Set Xact_Abort    On  
    Set Ansi_Nulls    Off  
    Set Ansi_Warnings On  
    Set Ansi_Padding  On  
  
-- Inicializamos Variables  
  
    Select  @PnEstatus   = 0,  
            @PsMensaje   = ' '  
  
 set @PnEjercicioStr = convert(varchar(8), @PnEjercicio)  
  
 -- V.0.8 Se agrega tabla temporal para almacenar resultados de Querys Dinámicos  
 If Object_Id('tempdb..#TmpInt') Is Not Null    
       Begin    
          Drop Table #TmpInt  
       End  
 create table #TmpInt(  
  entero int  
 )  
  
 --Crear tabla temporal para obtener cargos y abonos  
  
 If Object_Id('tempdb..#tmpDiferencia') Is Not Null    
       Begin    
          Drop Table #tmpDiferencia  
       End  
  
    Create Table #tmpDiferencia  
  (  
   Referencia Varchar(10),  
   Fecha_Mov  Datetime,  
   Cargo      Money,  
   Abono      Money,  
   Diferencia Money  
  )  
  
  --Crear tabla temporal para obtener el Contador  
   
 If Object_Id('tempdb..#tmpContPol') Is Not Null    
       Begin    
          Drop Table #tmpContPol  
       End  
    Create Table #tmpContPol  
    (  
     Id      Integer identity(1,1) Not Null Primary key,  
     ContPol       integer  
     )  
  
 --Crear tabla MovPoliza  
 If Object_Id('tempdb..#tmpMovPoliza') Is Not Null    
       Begin    
          Drop Table #tmpMovPoliza  
       End  
    Create Table #tmpMovPoliza  
    (  
     Id         Integer identity(1,1) Not Null Primary key,  
     Referencia       Varchar(10),  
  NewReferencia    Varchar(10),   
  Fecha_mov        Date,  
  Fecha_Cap        Date,  
  Concepto         Varchar(255),  
  Cargos           Money,  
  Abonos           Money,  
  TCons            Int,  
  Usuario          Varchar(10),  
  TipoPoliza       Varchar(3),  
  Documento        Varchar(30),  
  Usuario_cancela  Varchar(10),  
  Fecha_cancela    Datetime,  
  Status     smallint,  
  Mes_Mov          Varchar(3),  
  Ejercicio        Integer,  
  TipoPolizaConta  Varchar(3),  
  FuenteDatos      Varchar(250)  
     )  
  
  --Crear tabla MovDia   
 If Object_Id('tempdb..#tmpMovDia') Is Not Null    
       Begin    
          Drop Table #tmpMovDia  
       End  
    Create Table #tmpMovDia  
    (  
     Id         Integer identity(1,1) Not Null Primary key,    
  Fecha_mov        Date,    
  Documento        Varchar(30),    
  Importe_Cargo    Money,  
  Importe_Abono    Money  
     )  
  
  
   --Crear tabla PolPoliza   
 If Object_Id('tempdb..#tmpPolPoliza') Is Not Null    
       Begin    
          Drop Table #tmpPolPoliza  
       End  
    Create Table #tmpPolPoliza  
    (  
     Id         Integer identity(1,1) Not Null Primary key,  
     Referencia       Varchar(10),  
  NewReferencia    Varchar(10),  
  Cons             Int,  
  Moneda           Varchar(2),   
  Fecha_mov        Date,  
  Llave            Varchar(16),  
  Concepto         Varchar(255),  
  Importe          Money,  
  Documento        Varchar(30),  
  Clave            Varchar(1),  
  FecCap           Date,  
  Sector_id        Varchar(2),  
  Sucursal_id      Int,  
  Region_id        Int,  
  Importe_Cargo    Money,  
  Importe_Abono    Money,  
  Descrip          Varchar(150),  
  TipoPolizaConta  Varchar(3),  
  ReferenciaFiscal Varchar(50),  
  Fecha_Doc        Datetime  
     )  
  
  --Crear tabla temporal para obtener cargos y abonos  
  
 Create Table #tmpCarAbo  
 (  
  Moneda Varchar(4),  
  totCar Money,  
  totAbo Money  
 )  
  
  --ZCMC 21/09/2022. Se comentan Delete de las tablas de control y relacion.  
  Delete From DB_GEN_Des.dbo.ImportarPolError  
  --Delete From DB_GEN_Des.dbo.RelacionImp    
  --Delete From DB_GEN_DES.dbo.tmpControl  
  
-------------------------------VAMOS A TRATAR DE HACER UN TRY CON ROLLBACK ----------------------------------------------------------------  
  
 BEGIN TRY  
  BEGIN transaction  
  
 -- 1. Validar polizas que no tienen cuenta contable llamado Llave   
   Set @w_sql  = 'Insert into DB_GEN_Des.dbo.ImportarPolError(Referencia, Fecha_Mov, Mensaje_Error) ' +  
     '  Select Referencia, Fecha_Mov, ''No existe cuenta contable ''      ' +  
     '  From DB_GEN_Des.dbo.PolDia WITH(NOLOCK)           ' +  
     '    Where Llave = ''''                   ' +  
     '    and YEAR(Fecha_mov) = ' + @PnEjercicioStr +          --Agergar condición de todo >= XXXX-01-01  
     '    Group By Referencia, Fecha_Mov             '   
     
   Exec ( @w_sql)  
  
 -- 2. Valida el total de cargos y abonos del filtro de las polizas  
   
       
  
 Set @w_sql = 'Select moneda, ' + @w_Cargo + ',' + @w_Abono + '                                      ' +  
    'From (                                                                                ' +  
      'Select    P.Moneda, P.Clave, SUM(p.Importe) Importe                           ' +  
      'From      DB_Gen_Des.dbo.MovDia M WITH(NOLOCK)            ' +  
      'Join      DB_Gen_Des.dbo.PolDia P WITH(NOLOCK)                               ' +  
      'On        P.Referencia =  M.Referencia                                        ' +  
      'And      P.Fecha_Mov  =  M.Fecha_mov                                         ' +  
      'Where YEAR(P.Fecha_mov) = ' + @PnEjercicioStr + ' ' + --Agergar condición de todo >= XXXX-01-01  
      'Group by P.Clave, P.Moneda) t                                                 ' +  
    'Pivot (Sum(t.importe) For t.clave In(' + @w_Cargo + ',' + @w_Abono + ')) As Pivote '  
   
 Begin Try   
 Insert into #tmpCarAbo  
 Execute (@w_sql)  
 End Try   
 Begin Catch  
 Select @w_error      = Error_Number(),  
    @w_desc_error = Error_Message()   
 End Catch    
     
 Select @w_totalCargo = totCar,  
  @w_totalAbono = totAbo  
 From   #tmpCarAbo  
  
  
  
  
 If @w_totalCargo !=  @w_totalAbono   
  Begin  
            Set @w_sql = 'Select M.Referencia, M.Fecha_Mov, Sum(P.Importe_cargo) TotCar,                        ' +  
                        '       Sum(Importe_abono) TotAbo, Sum(P.Importe_cargo)-Sum(Importe_abono) Diferencia  ' +  
      'From   DB_Gen_Des.dbo.MovDia M WITH(NOLOCK)                        ' +  
      'Join   DB_Gen_Des.dbo.PolDia P WITH(NOLOCK)                                          ' +  
      'On   P.Referencia =  M.Referencia                                                     ' +  
      'And  P.Fecha_Mov  =  M.Fecha_mov                                                      ' +  
      'Where YEAR(M.Fecha_mov) = ' + @PnEjercicioStr + ' ' + --Agergar condición de todo >= XXXX-01-01  
      'Group By M.Referencia,  M.Fecha_Mov               ' +  
      'Having   ABS(Sum(Importe_cargo)-Sum(Importe_abono)) != 0                              ' +  
      'Order By Referencia                                                                   '  
  
   Begin Try   
  
       Insert into #tmpDiferencia  
      Execute (@w_sql)  
      
   End Try   
   Begin Catch  
       Select @w_error      = Error_Number(),  
           @w_desc_error = Error_Message()   
   End Catch  
                
   If IsNull(@w_error, 0) <> 0  
   Begin   
      Select @PnEstatus = @w_error,  
        @PsMensaje = @w_desc_error   
    ROLLBACK transaction  
      Set Xact_Abort Off  
      Return  
   End   
  End  
             
    
 Set @w_sql  = 'Insert into DB_GEN_Des.dbo.ImportarPolError(Referencia, Fecha_Mov, Mensaje_Error) ' +  
     '  Select Referencia, Fecha_Mov, ''Diferencia de Saldos ''                ' +  
     '  From #tmpDiferencia'  
 Exec ( @w_sql)                
  
   -- V.0.1 ZCMC 18/05/2021 ** INICIA MODIFICACION  
   -- SE AGREGA VALIDACION PARA EL EJERCICIO, QUE NO SEA DIFERENTE.  
  
     
   --Set @w_sql  = 'Insert into DB_GEN_Des.dbo.ImportarPolError(Referencia, Fecha_Mov, Mensaje_Error)  ' +  
   --  '  Select Referencia, Fecha_Mov, ''El ejercicio es diferente al ejercicio actual ''' +  
   --  '  From DB_GEN_Des.dbo.MovDia                 ' +  
   --  '    Where YEAR(Fecha_Mov)<> '+ Cast (@PnEjercicio As Varchar(4))+'      ' +  
   --  '    Group By Referencia, Fecha_Mov              '   
   --print 'sql'  
   --Exec ( @w_sql) SE COMENTA FUNCION YA QUE TODO LO TRAE DEL MISMO AÑO (V.0.8)  
  
  
  
   --ZCMC 18/05/2021 ** TERMINA MODIFICACION  
  
   -- Se agrega validacion para que no se dupliquen polizas  
   Set @w_sql = ' Insert into DB_GEN_Des.dbo.ImportarPolError(Referencia, Fecha_Mov, Mensaje_Error)'+  
       ' select a.Referencia, a.fecha_mov,''La poliza ya existe en MovDia' + @PnEjercicioStr + ''''+  
       ' from  DB_GEN_DES.dbo.MovDia a WITH(NOLOCK)      '+  
       ' Join Ejercicio_des.dbo.MovDia' + @PnEjercicioStr + ' b WITH(NOLOCK)'+  
       ' On  a.fecha_mov = b.fecha_mov   '+  
       ' and a.documento = b.documento    '+  
       ' and a.cargos = b.cargos    '+  
       ' and a.abonos = b.abonos    '+  
       ' and a.concepto = b.concepto   '+  
       ' and   a.mes_mov  != ''Ene''    '+  
       'Where YEAR(a.Fecha_mov) = ' + @PnEjercicioStr + ' ' --Agergar condición de todo >= XXXX-01-01  
   Print 'sql'  
   Exec ( @w_sql)  
  
      -- Se agrega validacion para que no se dupliquen polizas con las del mes en curso  
   Set @w_sql = ' Insert into DB_GEN_Des.dbo.ImportarPolError(Referencia, Fecha_Mov, Mensaje_Error)'+  
       ' select a.Referencia, b.fecha_mov,''La poliza ya existe en MovEne' + @PnEjercicioStr + ''''+         
       ' from  DB_GEN_DES.dbo.movdia a WITH(NOLOCK)      '+  
       ' Join Ejercicio_des.dbo.MovEne' + @PnEjercicioStr + ' b WITH(NOLOCK) '+             
       ' On  a.fecha_mov = b.fecha_mov   '+  
       ' and a.documento = b.documento    '+  
       ' and a.cargos = b.cargos    '+  
       ' and a.abonos = b.abonos    '+  
       ' and a.concepto = b.concepto   '+  
       'Where YEAR(a.Fecha_mov) = ' + @PnEjercicioStr + ' '  
  
   Print 'sql'  
   Exec ( @w_sql)  
  
   --ZCMC 12102022. Se quita validacion, ya que los campos de la tabla, no permiten que se haga exportacion.  
   ----------------------      -- Se agrega validacion para que no se dupliquen polizas con las del mes en curso  
   ----------------------Set @w_sql = ' Insert into DB_GEN_Des.dbo.ImportarPolError(Referencia, Fecha_Mov, Mensaje_Error)'+  
   ----------------------    ' select Referencia, fecha_mov,''La poliza ya existe en Relacion_Poliza_Interna_Externa'''+  
   ----------------------    ' from  DB_GEN_DES.dbo.movdia              '+  
   ----------------------    ' where fecha_mov  in (select fecha_mov from DB_GEN_DES.dbo.dbo_Relacion_Poliza_Interna_Externa)     '+  
   ----------------------    ' and   Referencia in (select referencia from DB_GEN_DES.dbo.dbo_Relacion_Poliza_Interna_Externa ) '  
        
  
   ----------------------Print 'sql'  
   ----------------------Exec ( @w_sql)  
   
  --SE COMENTA 22072021  
   --Select * from DB_GEN_Des.dbo.ImportarPolError  
  
  -- select @w_ContNoPol = count(Id_error)  from DB_GEN_Des.dbo.ImportarPolError  
   --ZCMC 21/09/2022. Se cambia la obtencion del valor de la variable para el numero correcto de errores.  
   Select @w_ContNoPol = count (pol.referencia)  
   From (select distinct referencia, fecha_mov from DB_GEN_DES.[dbo].[ImportarPolError] WITH(NOLOCK) where YEAR(Fecha_mov) = @PnEjercicio  
   Group by referencia, fecha_mov) As pol  
  
     
   --Actualizar la nueva Referencia.  
   UPDATE A  
    SET A.Causa_Rechazo = B.Mensaje_Error  
    FROM DB_GEN_Des.dbo.MovDia A  
    INNER JOIN DB_GEN_Des.dbo.ImportarPolError B  
    On  A.Referencia = B.Referencia  
    And A.Fecha_Mov  = B.Fecha_Mov  
    where YEAR(A.Fecha_mov) = @PnEjercicio  
   UPDATE A  
    SET A.Causa_Rechazo = B.Mensaje_Error  
    FROM DB_GEN_Des.dbo.PolDia A  
    INNER JOIN DB_GEN_Des.dbo.ImportarPolError B  
    On  A.Referencia = B.Referencia  
    And A.Fecha_Mov  = B.Fecha_Mov  
    where YEAR(A.Fecha_mov) = @PnEjercicio  
  
  --Despues de validaciones vamos a importar las polizas correspondientes  
  
  --Agrega el Contenido del cabecero de la póliza  
            Insert into #tmpMovPoliza(Referencia, NewReferencia, Fecha_Mov, Fecha_Cap, Concepto, Cargos, Abonos, TCons, Usuario, TipoPoliza,   
           Documento, Usuario_cancela, Fecha_cancela, Status, Mes_Mov, Ejercicio, TipoPolizaConta, FuenteDatos)  
        Select   Referencia, '', Fecha_mov,  GetDate(), Concepto, Cargos, Abonos, TCons,'Contab', TipoPoliza,  
           Documento, Usuario_cancela, Fecha_cancela, Status, Mes_Mov, YEAR(Fecha_Mov), TipoPolizaConta, FuenteDatos  
        From DB_Gen_Des.dbo.MovDia WITH(NOLOCK)  
        Where Causa_Rechazo IS NULL  
         and YEAR(Fecha_mov) = @PnEjercicio  
        Order by Fecha_mov, TipoPolizaConta  
  
  --Agrega el Contenido del detalle de la póliza  
              Insert into #tmpPolPoliza(Referencia, NewReferencia, Cons, Moneda, Fecha_Mov, Llave, Concepto, Importe, Documento, Clave, FecCap, Sector_id,            
                    Sucursal_id, Region_id, Importe_Cargo, Importe_Abono, Descrip, TipoPolizaConta, ReferenciaFiscal, Fecha_Doc)   
        Select   Referencia, '',  Cons, Moneda, Fecha_mov, Llave, Concepto, Importe, Documento, (Case When  Clave = 'D' Then 'C' Else 'A' End) Clave, GetDate(), '00',   
                 Sucursal_id, Region_id, Importe_Cargo, Importe_Abono, Descripcion, TipoPolizaConta, ReferenciaFiscal, Fecha_Doc  
        From DB_Gen_Des.dbo.PolDia WITH(NOLOCK)  
        Where Causa_Rechazo IS NULL  
        and YEAR(Fecha_mov) = @PnEjercicio  
        Order by Fecha_mov, TipoPolizaConta  
       
      --Obtiene el min y max Id   
    Select @w_minId  = MIN(Id),  
     @w_maxId  = MAX(Id)  
    From   #tmpMovPoliza  
          
     --select @w_contPDI = contador from Ejercicio_DES.dbo.ContPol2024  
     --where tipo = 'PDI'  
     --and mes = 'Ene'  
  
     --select @w_contPEG = contador from Ejercicio_DES.dbo.ContPol2024  
     --where tipo = 'PEG'  
     --and mes = 'Ene'  
  
     --select @w_contPIN = contador from Ejercicio_DES.dbo.ContPol2024  
     --where tipo = 'PIN'  
     --and mes = 'Ene'  
  
  --Ciclo para obtener el mes  
  While @w_minId <= @w_maxId  
  Begin  
      
    Select @w_Referencia  = Referencia,  
      @w_Fecha_Mov   = Fecha_Mov,  
      @w_Mes_Mov     = Mes_Mov,  
      @w_TipoPol     = TipoPoliza,  
      @w_Ejercicio   = Ejercicio  
    From   #tmpMovPoliza  
    Where Id = @w_minId  
    Order by Fecha_mov, TipoPolizaConta  
  
    set @w_sql = 'select contador from Ejercicio_DES.dbo.ContPol' + @PnEjercicioStr + ' WITH(NOLOCK)   
     where tipo = ''PDI''  
     and mes = ''' + @w_Mes_Mov + ''''  
  
    insert into #TmpInt  
     exec(@w_sql);  
  
    select @w_contPDI = entero from #TmpInt  
    delete from #TmpInt  
  
    set @w_sql = 'select contador from Ejercicio_DES.dbo.ContPol' + @PnEjercicioStr + ' WITH(NOLOCK)  
     where tipo = ''PEG''  
     and mes = ''' + @w_Mes_Mov + ''''  
  
    insert into #TmpInt  
     exec(@w_sql)  
  
    select @w_contPEG = entero from #TmpInt  
    delete from #TmpInt  
  
    set @w_sql = 'select contador from Ejercicio_DES.dbo.ContPol' + @PnEjercicioStr + ' WITH(NOLOCK)  
     where tipo = ''PIN''  
     and mes = ''' + @w_Mes_Mov + ''''  
  
    insert into #TmpInt  
     exec(@w_sql)  
  
    select @w_contPIN = entero from #TmpInt  
    delete from #TmpInt  
        
  
    If @w_TipoPol = 'PDI'  
     Begin  
      Set @w_contPDI = @w_contPDI + 1  
  
      Set @w_NewRef  = Concat(@w_TipoPol, FORMAT(@w_contPDI, '000000'))    
     End  
    If @w_TipoPol = 'PEG'  
     Begin  
      Set @w_contPEG = @w_contPEG + 1  
  
      Set @w_NewRef  = Concat(@w_TipoPol, FORMAT(@w_contPEG, '000000'))    
     End  
    If @w_TipoPol = 'PIN'  
     Begin  
      Set @w_contPIN = @w_contPIN + 1  
  
      Set @w_NewRef  = Concat(@w_TipoPol, FORMAT(@w_contPIN, '000000'))    
     End  
  
  
    Update #tmpMovPoliza  
     Set    NewReferencia = @w_NewRef  
     Where  Id = @w_minId   
  
  
     --Se agrega Validacion parametro para actualizacion en tabla de SET 14/05/2021   
    IF (Select valor From SisArrendaCredito.dbo.Parametros WITH(NOLOCK) where ID = 392) = 1  
     Begin  
      Update set_dalton.dbo.zmovdia  
      Set    no_poliza_compensa  = @w_NewRef  
      Where  referencia = @w_Referencia          
      and FuenteDatos = 'SET'     
      --and    fecha_mov =   
      --and Causa_Rechazo IS NULL  [ZCMC12072022]. Se corrige filtros para update en BD. [set_Dalton]  
     End  
     --FIN DE ACTUALIZACION 14/05/2021  
    set @w_sql = 'Update ContPol' + @PnEjercicioStr + ' Set contador = ' + convert(varchar, @w_contPDI) + '   
    where Tipo = ''PDI''  
    and mes = ''' + @w_Mes_Mov + ''''  
  
    exec(@w_sql)  
  
    set @w_sql = 'Update ContPol' + @PnEjercicioStr + ' Set contador = ' + convert(varchar, @w_contPEG) + '   
    where Tipo = ''PEG''  
    and mes = ''' + @w_Mes_Mov + ''''  
  
    exec(@w_sql)  
  
    set @w_sql = 'Update ContPol' + @PnEjercicioStr + ' Set contador = ' + convert(varchar, @w_contPIN) + '   
    where Tipo = ''PIN''  
    and mes = ''' + @w_Mes_Mov + ''''  
  
    exec(@w_sql)  
  
    --Set @w_ContPol = CONCAT('ContPol', @w_Ejercicio)  
  
    --SE COMENTA  
    --SELECT @w_Mes_Mov  
  
     --Se obtiene el contador de la tabla ContPolAño, de acuerdo al mes de Cierre y el tipo de poliza  
     --Set @w_sql = 'Select Contador              '      +   
     --     'From      ' + @w_ContPol + '  '      +  
     --     'Where Tipo = ''' + @w_TipoPol  + '''   ' +  
     --     'And   Mes  = ''' + @w_Mes_Mov  + ''' '  
  
     --Insert Into #tmpContPol (ContPol)  
     --Execute (@w_sql)  
  
     --Select @w_Contador = ContPol + 1  
     --From #tmpContPol  
  
                    --Set @w_NewRef  = Concat(@w_TipoPol, FORMAT(@w_Contador, '000000'))             
           
     ----Actualiza el contador de poliza    
     --Set @w_sql = 'Update ' + @w_ContPol + '  '                                +  
  --        'Set   Contador = ' + Convert(varchar(30),@w_Contador) + ' ' +  
     --     'Where Tipo = ''' + @w_TipoPol  + '''   ' +  
     --     'And   Mes  = ''' + @w_Mes_Mov  + ''' '  
     --Begin Try   
     --  Execute (@w_sql)  
     --End Try   
     --Begin Catch  
     --Select @w_error      = Error_Number(),  
  --        @w_desc_error = Error_Message()   
     --End Catch  
                        
     --If IsNull(@w_error, 0) <> 0  
     --Begin   
  --       Select @PnEstatus = @w_error,  
  --        @PsMensaje = @w_desc_error   
  --       Set Xact_Abort Off  
     --Return  
     --End   
  
        
  
  -- Incremento del minimo Id  
  Set @w_minId = @w_minId + 1  
           
 End -- Ciclo   
  
    --Update ContPol2023 Set contador = @w_contPDI   
    --where Tipo = 'PDI'  
    --and mes = 'Ene'  
  
    --Update ContPol2023 Set contador = @w_contPEG   
    --where Tipo = 'PEG'  
    --and mes = 'Ene'  
  
    --Update ContPol2023 Set contador = @w_contPIN   
    --where Tipo = 'PIN'  
    --and mes = 'Ene'  
   
     --Actualizar la nueva Referencia.  
       UPDATE Pol  
        SET Pol.NewReferencia = Mov.NewReferencia  
        FROM #tmpPolPoliza Pol  
        INNER JOIN #tmpMovPoliza Mov  
        On  Pol.Referencia = Mov.Referencia  
        And Pol.Fecha_Mov  = Mov.Fecha_Mov  
  
      --Inserta en la tabla Relacion  
       Insert into DB_GEN_DES.dbo.RelacionImp(Referencia, Fecha_Mov, Fecha_Cap, NewReferencia, Usuario, FuenteDatos,FechaImportacion)  
       Select  Referencia, Fecha_Mov, Fecha_Cap, NewReferencia, Usuario, FuenteDatos, Getdate()  
       From #tmpMovPoliza  
       Order by Id  
  
  
       Select @w_MovDia = CONCAT('MovDia', @PnEjercicioStr),  
           @w_PolDia = CONCAT('PolDia', @PnEjercicioStr)  
  
        ----Agrega el Contenido del cabecero de la póliza  
         Set @w_sql = 'Insert into '+ @w_MovDia +'(Referencia, Fecha_Mov, Fecha_Cap, Concepto, Cargos, Abonos, TCons, Usuario, TipoPoliza,             ' +  
          '        Documento, Usuario_cancela, Fecha_cancela, Status, Mes_Mov, TipoPolizaConta, FuenteDatos)           ' +  
          ' Select   tmp.NewReferencia, tmp.Fecha_Mov as [fm], tmp.Fecha_Cap, tmp.Concepto, tmp.Cargos, tmp.Abonos, tmp.TCons, tmp.Usuario, tmp.TipoPoliza, tmp.Documento, tmp.Usuario_cancela, ' +  
          '  tmp.Fecha_cancela, tmp.Status, tmp.Mes_Mov, tmp.TipoPolizaConta, tmp.FuenteDatos                                                        ' +  
          ' From #tmpMovPoliza tmp                                                                                                          '  
  
          Begin Try  
            Execute(@w_sql)  
            End Try   
            Begin Catch  
            If @@ERROR != 0  
           Begin  
              Select @w_error      = Error_Number(),  
               @w_desc_error = Error_Message()   
                                    
           End  
            End Catch  
  
            If IsNull(@w_error, 0) <> 0  
            Begin   
            Select @PnEstatus = @w_error,  
             @PsMensaje = @w_desc_error  
           ROLLBACK transaction  
            Set Xact_Abort Off  
            Return  
            End  
         
  
           --Agrega el Contenido al detalle de la póliza  
  
        Set @w_sql = 'Insert into '+ @w_PolDia +'(Referencia, Cons, Moneda, Fecha_Mov, Llave, Concepto, Importe, Documento, Clave, FecCap, Sector_id,          ' +  
         '                            Sucursal_id, Region_id, Importe_Cargo, Importe_Abono, Descripcion, TipoPolizaConta, ReferenciaFiscal, Fecha_Doc) ' +  
         '         Select NewReferencia, Cons, Moneda, Fecha_Mov, Llave, Concepto, Importe, Documento, Clave, FecCap, Sector_id,           ' +  
         '                            Sucursal_id, Region_id, Importe_Cargo, Importe_Abono, Descrip, TipoPolizaConta, ReferenciaFiscal, Fecha_Doc  ' +  
         '                    From    #tmpPolPoliza                                                                                                '  
  
  
           Begin Try  
           Execute(@w_sql)  
           End Try   
           Begin Catch  
           If @@ERROR != 0  
          Begin  
             Select @w_error      = Error_Number(),  
              @w_desc_error = Error_Message()   
                                    
          End  
           End Catch  
  
           If IsNull(@w_error, 0) <> 0  
           Begin   
           Select @PnEstatus = @w_error,  
            @PsMensaje = @w_desc_error   
          ROLLBACK transaction  
          Set Xact_Abort Off  
          Return  
           End  
  
         select @w_ContPolizas = count(Id_Rel)  from DB_GEN_Des.dbo.RelacionImp WITH(NOLOCK)  
         --ZCMC 21/09/2022. Se modifica tabla que controla la importacion, colocando la fecha de la ejecucion del SP  
         Insert into DB_GEN_DES.dbo.tmpControl(Fecha_Mov,Polizas_Imp,polizas_no_imp) values (getdate(),@w_ContPolizas,@w_ContNoPol)  
  
         
       --Inserta en la tabla Relacion  
       --CHUR/ZCMC 11/05/2021 Se descomentan las dos lineas del insert  
  
    -- Comentada porque presuponemos que éste sript realentizaba el SP. Se reemplaza con otro select  
    --Set @w_secuencia = (select min(Id_Rel) From DB_GEN_DES.dbo.RelacionImp  
    --where fechaImportacion >= convert(date,getdate(),23))  
  
    select @w_secuencia = RI.Id_Rel From DB_GEN_DES.dbo.RelacionImp RI WITH(NOLOCK)  
    Inner join DB_GEN_DES..MovDia MD WITH(NOLOCK) ON RI.Referencia = MD.Referencia and RI.Fecha_Mov = MD.Fecha_Mov AND MD.Causa_Rechazo IS NULL  
    where fechaImportacion >= convert(date,getdate(),23)  
  
    Select @w_registros = Max(Id_Rel)  
    From   DB_GEN_DES.dbo.RelacionImp WITH(NOLOCK)  
  
    --Eliminar las tablas de MovDia   
    Insert into DB_GEN_DES.dbo.[MovDiaError] (Referencia,Fecha_mov,Fecha_Cap,Concepto,Cargos,Abonos,TCons,Usuario,TipoPoliza,Documento,Usuario_cancela,Fecha_Cancela,Status,Mes_Mov,TipoPolizaConta,FuenteDatos,Causa_Rechazo,Fecha_importacion)  
    Select *,Getdate() From DB_GEN_DES.dbo.MovDia WITH(NOLOCK) Where Causa_Rechazo Is not Null and YEAR(Fecha_mov) = @PnEjercicio --or Causa_Rechazo like '%La poliza ya existe%'  
  
    Insert into DB_GEN_DES.dbo.[PolDiaError] (Referencia,Cons,Moneda,Fecha_mov,Llave,Concepto,Importe,Documento,Clave,FecCap,Sector_id,Sucursal_id,Region_id,Importe_Cargo,Importe_Abono,Descripcion,TipoPolizaConta,ReferenciaFiscal,Fecha_Doc,Causa_Rechazo,F
echa_importacion)  
    Select *,Getdate() From DB_GEN_DES.dbo.PolDia WITH(NOLOCK) Where Causa_Rechazo Is not Null and YEAR(Fecha_mov) = @PnEjercicio --or Causa_Rechazo like '%La poliza ya existe%'  
  
  
    Delete From DB_GEN_DES.dbo.MovDia Where (Causa_Rechazo Is Null or Causa_Rechazo like '%La poliza ya existe%') and YEAR(Fecha_mov) = @PnEjercicio  
    Delete From DB_GEN_DES.dbo.PolDia Where (Causa_Rechazo Is Null or Causa_Rechazo like '%La poliza ya existe%') and YEAR(Fecha_mov) = @PnEjercicio  
  
  
    Begin Try   
  
      While @w_secuencia <= @w_registros  
      Begin  
  
       --Set @w_secuencia = @w_secuencia + 1;            
  
       Insert into DB_GEN_DES.dbo.dbo_Relacion_Poliza_Interna_Externa(Referencia, Fecha_Mov, Fecha_Cap, Referencia_Contable, Usuario, FuenteDatos)  
       Select Referencia, Fecha_Mov, Fecha_Cap, NewReferencia, Usuario, FuenteDatos   
       From   DB_GEN_DES.dbo.RelacionImp a WITH(NOLOCK)  
       WHERE  Id_Rel = @w_secuencia  
       And    not exists(select top 1 1  
                        from DB_GEN_DES.dbo.dbo_Relacion_Poliza_Interna_Externa b WITH(NOLOCK)  
            where b.Referencia = a.referencia  
            And   b.Fecha_Mov  = a.Fecha_Mov ) -- Order by Id_Rel  
  
       select @w_consecutivo = substring (max(llave),7,6)   
       from  DB_GEN_DES.dbo.RelacionImp  WITH(NOLOCK)  
       where fechaImportacion >= convert(date,getdate(),23)  
  
       if (@w_consecutivo is null)  
       Begin  
        SET @w_consecutivo = 1  
       End  
       else   
       Begin  
        SET @w_consecutivo = @w_consecutivo + 1  
       End   
  
       --ZCMC/MZB 12/10/2022. Se crea nuevo campo para relacionar polizas entre SICCORP Y SisArrendaCredito            
  
       select @w_ConsReferencia = concat (day(getdate()), month(getdate()),YEAR( GETDATE() ) % 100,format(@w_consecutivo,'00000'))  
  
       update DB_GEN_DES.dbo.RelacionImp Set llave = @w_ConsReferencia  
       where Id_Rel = @w_secuencia  
            
       Update a Set iddegasto = @w_ConsReferencia  
       From SisArrendaCredito.dbo.Poliza a  
       JOIN DB_GEN_DES.dbo.RelacionImp b    
       ON a.Referencia_Exporta collate SQL_Latin1_General_CP1_CI_AS = b.Referencia collate SQL_Latin1_General_CP1_CI_AS  
       AND  a.fechaContable = b.fecha_mov  
       WHERE Id_Rel = @w_secuencia  
       and fechaImportacion >= convert(date,getdate(),23)  
  
       Set @w_secuencia = @w_secuencia + 1;  
  
      End  
    End Try   
    Begin Catch  
     If @@ERROR != 0  
      Begin  
       Select @w_error      = Error_Number(),  
         @w_desc_error = Error_Message()   
                                    
      End  
    End Catch  
  
    If IsNull(@w_error, 0) <> 0  
    Begin   
     Select @PnEstatus = @w_error,  
      @PsMensaje = @w_desc_error   
     ROLLBACK transaction  
     Set Xact_Abort Off  
     Return  
    End  
  
 COMMIT transaction  
 END TRY  
 BEGIN CATCH  
  DECLARE   
   @ErrorMessage NVARCHAR(4000),  
   @ErrorSeverity INT,  
   @ErrorState INT;  
  SELECT   
   @ErrorMessage = ERROR_MESSAGE(),  
   @ErrorSeverity = ERROR_SEVERITY(),  
   @ErrorState = ERROR_STATE();  
  RAISERROR (  
   @ErrorMessage,  
   @ErrorSeverity,  
   @ErrorState      
   );  
  ROLLBACK transaction  
 END CATCH  
  
  
  
 drop table #tmpMovDia  
 drop table #tmpCarAbo  
 drop table #tmpContPol  
 drop table #tmpDiferencia  
 drop table #tmpMovPoliza  
 drop table #tmpPolPoliza  
 drop table #TmpInt  
  
 print 'Ok'  
   
End  
  
   
  
  
  