USE [Ejercicio_DES]
GO
/****** Object:  StoredProcedure [dbo].[sp_ActCarAbo]    Script Date: 17/08/2024 02:59:52 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Fecha: 28/Noviembre/2022
Autor: Desconocido
Task: N/A
Observaciones: Proceso que realiza actualizacion de cargos y abonos por proceso de acuerdo a condiciones.

MODIFICACIONES:
V1.0. [Zayra Mtz. Candia].[28Nov2022]. Se agregar correcciones y validacioes a las polizas, principalmente en sucursal, region, sector e importes 0.
									   Ademas la actualizacion a los auxiliares corporativo, en el centro de costos 5555.
*/



ALTER Procedure [dbo].[sp_ActCarAbo]
       @anio      Int,
       @condicion Nvarchar(500),
       @Estatus   Integer      = 0   Output,
       @Mensaje   Varchar(250) = ' ' Output
As
-- INICIALIZAN VARIABLES --
Declare
        @qry            Nvarchar(1000),
        @qryMesCur      Nvarchar(80)  ,
        @intMes         Int           ,
        @mes            Varchar(3)    ,
        @qryMesCer      Nvarchar(1000),
        @parDefC        Nvarchar(50)  ,
        @parDefC2       Nvarchar(50)  ,
        @mesCer         Int           ,
        @ControlCarAbo  Nvarchar(50)  ,
        @Control        Nvarchar(50)  ,
        @PolDia         Nvarchar(50)  ,
        @MovDia         Nvarchar(50)  ,
        @Cat            Nvarchar(50)  ,
        @CatAux         Nvarchar(50)  ,
        @CatRep         Nvarchar(50)  ,
        @CatAuxRep      Nvarchar(50)  ,
        @qryMsn         Nvarchar(200) ,
-- INICIALIZAN VARIABLES PARA RECORRIDO --
        @CountReg       Int           ,
        @IdPol          Int = 1       ,
        @CountMes       Int           ,
        @IdMes          Int = 1       ,
-- INICIALIZAN VARIABLES PARA WHILE --
        @Llave          Nvarchar(16)  ,
        @Sucursal       Int           ,
        @Region         Int           ,
        @Sector         Nvarchar(2)   ,
        @Clave          Nvarchar(1)   ,
        @Importe        Money         ,
        @Moneda         Nvarchar(2)   ='00' ,
        @SAct           Money = 0     ,
        @Ceros          Nvarchar(16)  = '0000000000000000',
        @SubCta         Nvarchar(16)  ,
        @SSubCta        Nvarchar(16)  ,
        @SSSubCta       Nvarchar(16)  ,
        @Cta            Nvarchar(16)  ,
        @NCta           Nvarchar(4)   ,
        @w_mesCer0      Nvarchar(3)   ,
        @w_cons         Nvarchar(3)   ,
        @w_nomMes       Varchar(3)    , 
        @w_comilla      Char(1)       ,
        @w_sql          NVarchar(500)  ,
        @w_error        Integer       ,
        @w_desc_error   Varchar(250)  ,
        @w_nombreMes    Varchar(15), 
        @w_nivel        Varchar(2), 
        @w_Aux          Varchar(7),
        @w_minId        INt,
        @w_maxId        Int, 
        @w_minIdF       Int,
        @w_maxIdF       Int,
		@w_CountSucRegError Int,
		@w_CountSucRegErrorOUT Int,
		@ParmDefinition nvarchar(500)

Begin
    Set Nocount       On
    Set Xact_Abort    On
    Set Ansi_Nulls    On
    Set Ansi_Warnings On
    Set Ansi_Padding  On

    --Definir las variables con el nombre de la tabla y año--   
    Select  @ControlCarAbo = Concat('ControlCarAbo',@anio),
            @Control       = Concat('Control'      ,@anio),
            @PolDia        = Concat('PolDia'       ,@anio),
            @MovDia        = Concat('MovDia'       ,@anio), 
            @CatRep        = Concat('CatRep'       ,@anio),
            @CatAuxRep     = Concat('CatAuxRep'    ,@anio),
            @w_comilla     = Char(39),
            @Estatus       = 0,
            @Mensaje       = Null

---=================================================================================
-- ZCMC/CHUR 28/Nov/2022. Inicia Modificación.
-- 1. Elimina registros que cargan y abonan cantidades en 0.00

	Set @w_sql = ' delete from ' + @PolDia + ' ' +
	             ' where importe = 0.00'
    
          
    Begin Try 
		Execute(@w_sql)
    End Try 

    Begin Catch					 				
        Select @w_error      = Error_Number(),
               @w_desc_error = Error_Message() 
    End Catch
    
    If IsNull(@w_error, 0) <> 0
       Begin 				    		

          Select @Estatus = @w_error,
                 @Mensaje = @w_desc_error 
	
		   INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )
		   VALUES ('ERROR Delete Importes 0.00',@w_error, @w_desc_error, getdate());

           Set Xact_Abort Off
           Return
       End

--2. Se corrigen el sector_id, en caso de venir con un solo 0.

	Set @w_sql = ' Update ' + @PolDia + ' Set sector_id = ''00'' ' +
	             ' Where sector_id = ''0'''
    
          
    Begin Try 
		Execute(@w_sql)
    End Try 

    Begin Catch					 				
        Select @w_error      = Error_Number(),
               @w_desc_error = Error_Message() 
    End Catch
    
    If IsNull(@w_error, 0) <> 0
       Begin 				    		

          Select @Estatus = @w_error,
                 @Mensaje = @w_desc_error 
	
		   INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )
		   VALUES ('ERROR Update POLDIANIO Sector ',@w_error, @w_desc_error, getdate());

           Set Xact_Abort Off
           Return
       End

--3. Cambiar auxiliares corporativos a centro de costos 5555000, 5555, en corformidad con la tabla de auxiliaresCorporativos

	Set @w_sql = ' Update ' + @PolDia + ' Set Sucursal_id = 5555000, Region_id = 5555 ' +
	             ' Where llave in (select llave from AuxiliaresCorporativos)'
    
          
    Begin Try 
		Execute(@w_sql)
    End Try 

    Begin Catch					 				
        Select @w_error      = Error_Number(),
               @w_desc_error = Error_Message() 
    End Catch
    
    If IsNull(@w_error, 0) <> 0
       Begin 				    		

          Select @Estatus = @w_error,
                 @Mensaje = @w_desc_error 
	
		   INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )
		   VALUES ('ERROR Update AuxiliaresCorporativos ',@w_error, @w_desc_error, getdate());

           Set Xact_Abort Off
           Return
       End

--4. Valida centro de costo para todas las polizas, 

	Set @w_sql = ' select @w_CountSucRegErrorOUT = count (*) from ' + @PolDia + ' ' +
				 ' where (sucursal_id not in (	SELECT  concat ([Region_id], ''000'') sucursal_id '+										
								' FROM [DB_GEN_DES].[dbo].[Area o Region] ' +
								' WHERE [Region_id] != 0 AND  [Region_id] != 1111) ' +
								' or Region_id not in (		SELECT [Region_id] ' +
								' FROM [DB_GEN_DES].[dbo].[Area o Region] ' +
								' WHERE [Region_id] != 0 AND  [Region_id] != 1111)) AND FECHA_MOV BETWEEN ''20221001'' and ''20221031'''
	SET @ParmDefinition = N'@w_CountSucRegErrorOUT int OUTPUT';
          
    Begin Try 
		
		EXECUTE sp_executesql @w_sql,@ParmDefinition, @w_CountSucRegErrorOUT = @w_CountSucRegError OUTPUT;

		Select  @w_CountSucRegError w_CountSucRegError

    End Try 

    Begin Catch					 				
        Select @w_error      = Error_Number(),
               @w_desc_error = Error_Message() 
    End Catch
    
    If IsNull(@w_error, 0) <> 0
       Begin 				    		

          Select @Estatus = @w_error,
                 @Mensaje = @w_desc_error 
	
		   INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )
		   VALUES ('ERROR al contar registros con Sucursal o region inexistente',@w_error, @w_desc_error, getdate());

           Set Xact_Abort Off
           Return
       End
	
	If @w_CountSucRegError > 0 
		Begin
		
		   INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )
		   VALUES ( CONCAT ('ERROR ', @w_CountSucRegError,' Registros con Sucursal o region inexistente'),@w_error, @w_desc_error, getdate());

           Set Xact_Abort Off
           Return

		End


-- ZCMC/CHUR 28/Nov/2022. Termina Modificación. 
--==================================================================================

    --Sentencia que muestra la tabla ControlCarAboAÑO
    Set    @qryMesCur = N'SELECT Mes FROM '+@ControlCarAbo

    --DECLARA VARIABLE TABLA--Declarar Tablas 

     If Object_Id('tempdb..#tmpFilter') Is Not Null  
        Begin  
           Drop Table #tmpFilter  
        End
     Create Table #tmpFilter
     (
      Id          Integer identity(1,1) Not Null Primary key,
      Llave       Nvarchar (16),
      Importe     Money,
      Clave       Nvarchar(1),
      Sector_id   Nvarchar(2),
      Sucursal_id Integer,
      Region_id   Integer
      )


    If Object_Id('tempdb..#tmpMes') Is Not Null  
       Begin  
          Drop Table #tmpMes  
       End
    Create Table #tmpMes
    (
     Id      Integer identity(1,1) Not Null Primary key,
     IntMes  Integer
     )

        --Inserta la informacion del query dinamico.
     Begin Try 
        Insert Into #tmpMes (IntMes)
        Execute (@qryMesCur)

     End Try 
     Begin Catch 	   

       Select  @w_error = ERROR_NUMBER(),
               @w_desc_error = ERROR_MESSAGE()

	   INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )
	   VALUES ('ERROR 1',@w_error, @w_desc_error, getdate());

       Return 
     End Catch 

    --Extrae el ultimo cerrado
    --QUERY DINAMICO, DONDE EXTRAE EL VALOR CORRESPONDIENTE A TRAVES DE UNA VARIABLE OUT.
    --DONDE INICIALIZAMOS LA VARIABLE OUT

    Select @qrymesCer = 'Select @mesCerOUT = Substring(nueCat,4,3)' + 
                        'From ' + @Control + ' ' + 
                        'Order By Cons asc ',
           @parDefC   = '@mesCerOUT Nvarchar(3) Output '
    
    Execute sp_executesql @qryMesCer, 
                          @parDefC, 
                          @mesCerOUT = @w_mesCer0 OUTPUT

    Set @mesCer = dbo.Fn_BuscaNumMes(@w_mesCer0)

    --PROCESO PARA RECORRER LA TABLA CUANDO EXISTA MAS DE UN REGISTRO--
    --INICIO DEL PROCESO WHILE--
    --Los meses que se encuentran en ControlCarAboAÑO
    Set Language Spanish
--    Begin Transaction 

    Select @w_minId = Min(id),
           @w_maxId = Max(id)
    From   #tmpMes
   
    While (@w_minId <= @w_maxId)    --INICIO DEL CICLO
           Begin 
                Select @intMes = IntMes 
                 From   #tmpMes 
                 Where  Id = @w_minId

                 Set @mes = dbo.Fn_BuscaMes(@intMes)
                 
                 Select @CatAux = Concat('CatAux', @mes, @anio),
                        @Cat    = Concat('Cat'   , @mes, @anio)
                        
                 --Limpiar Cargos y Abonos del Catalogo Actual
                 Set @w_sql = 'Update ' + @Cat + ' '  + 
                             'Set CarExt        = 0, '   + 
                             '    AboExt        = 0, '   +
                             '    CarProceso    = 0, '   +
                             '    AboProceso    = 0  '   + 
                             'Where CarProceso != 0 ' + 
                             'Or    AboProceso != 0 '
                 
                 Begin Try 
                   Execute(@w_sql)
                 End Try 
                 Begin Catch					 				
                     Select @w_error      = Error_Number(),
                            @w_desc_error = Error_Message() 
                 End Catch
                 
                 If IsNull(@w_error, 0) <> 0
                    Begin 				    		

                       Select @Estatus = @w_error,
                              @Mensaje = @w_desc_error 
					   
					   INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )
					   VALUES ('ERROR',@w_error, @w_desc_error, getdate());

                       Set Xact_Abort Off
                       Return
                    End
                 --Limpiar Cargos y Abonos del Catalogo Auxiliar Actual
                 Set @w_sql = 'Update ' + @CatAux  + ' ' +  
                             'Set CarExt        = 0, '   + 
                             '    AboExt        = 0, '   + 
                             '    CarProceso    = 0, '   +
                             '    AboProceso    = 0 '    + 
                             'Where CarProceso != 0 '    + 
                             'Or    AboProceso != 0 '
                 
                 Begin Try
                   Execute(@w_sql)
                 End Try
                 Begin Catch
                    Select @w_error      = Error_Number(),
                           @w_desc_error = Error_Message()
                 End Catch

                 If IsNull(@w_error, 0) <> 0
                    Begin 	   

                       Select @Estatus = @w_error,
                              @Mensaje = @w_desc_error
						
					   INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )
					   VALUES ('ERROR 2',@w_error, @w_desc_error, getdate());	
						 
                       Set Xact_Abort Off
                       Return
                    End
         

                 Begin Try
				 print 'Entra a ejecutar el SP'
                      Execute Sp_polizas @PnAnio      = @anio,
                                         @PsCondicion = @condicion, 
                                         @PsMes       = @mes, 
                                         @PsMovDia    = @MovDia, 
                                         @PsPolDia    = @PolDia,
                                         @PsLlave     = @Llave, 
                                         @PnImporte   = @Importe, 
                                         @PsClave     = @Clave,
                                         @PsSector    = @Sector,
                                         @PnSucursal  = @Sucursal,
                                         @PnRegion    = @Region,
                                         @PnIdPol     = @IdPol,
                                         @PsCeros     = @Ceros,
                                         @PnIntMes    = @intMes,
                                         @PsNCta      = @NCta,
                                         @PsSubCta    = @SubCta,
                                         @PsSSubCta   = @SSubCta,
                                         @PsSSSubCta  = @SSSubCta,
                                         @PsCat       = @Cat,
                                         @PsCatAux    = @CatAux,
                                         @PsCatRep    = @CatRep,
                                         @PsCatAuxRep = @CatAuxRep,
                                         @PnSAct      = @SAct,
                                         @PsCta       = @Cta,
                                         @PsMoneda    = @Moneda,
                                         @PnmesCer    = @mesCer,
                                         @PnCountReg  = @CountReg,
                                         @PnEstatus   = @w_error      Output,
                                         @PsMensaje   = @w_desc_error Output
                 End Try

                 Begin Catch
                    Select @w_error      = Error_Number(),
                           @w_desc_error = Error_Message()
                 End Catch

                 If IsNull(@w_error, 0) <> 0
                    Begin   
					   
                       Select @Estatus = @w_error,
                              @Mensaje = @w_desc_error 

					   INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )
					   VALUES ('ERROR 3',@w_error, @w_desc_error, getdate());

                       Set Xact_Abort Off
                       Return
                    End
           PRINT 'TERMINA PROCEDIMIENTO DE POLIZAS '       
           -- TERMINA PROCEDIMIENTO DE POLIZAS                      
           --CONTADOR DEL CICLO DE LOS MESES--

            --FIN DEL CICLO DEL PROCESO DE LOS MESES--  

      Set @w_minId += 1

    End   
	PRINT 'Modifica el estatus de VIGENTE a PROCESADA en el proceso de cargos y abonos'      
    --Modifica el estatus de VIGENTE a PROCESADA en el proceso de cargos y abonos
    --ESTATUS VIGENTE ES CON VALOR 0 
    --ESTATUS PROCESADA ES CON VALOR 2 
    Set @w_sql = 'Update M  ' + 
                 'Set M.STATUS = 2 ' + 
                 'From ' + @MovDia + ' AS M ' +
                 'Join ' + @PolDia + ' AS P ' +
                 'On  M.Fecha_Mov = P.Fecha_Mov ' +
                 'And M.Referencia = P.Referencia ' + @condicion

    Begin Try 
      Execute(@w_sql)
    End Try 
    Begin Catch
	   
       Select @w_error      = Error_Number(),
              @w_desc_error = Error_Message() 
	  
	   INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )
	   VALUES ('ERROR 4',@w_error, @w_desc_error, getdate());

    End Catch
         
    If IsNull(@w_error, 0) <> 0
        Begin
           Select @Estatus = @w_error,
                  @Mensaje = @w_desc_error 
		   
		   INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )
		   VALUES ('ERROR 5',@w_error, @w_desc_error, getdate());

           Set Xact_Abort Off
           Return
        End 

         Set   @qryMsn = 'PROCESO DE CARGOS Y ABONOS REALIZADO CON ÉXITO'
         Print @qryMsn
          
		INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )
		VALUES (@qryMsn, @w_error, @w_desc_error, getdate());


    --ELIMINANDO LA VARIABLE TABLA DEL RECORRIDO DE LOS MESES--
    Drop Table  #tmpMes
    Drop Table  #tmpFilter

    --Commit Transaction

End 