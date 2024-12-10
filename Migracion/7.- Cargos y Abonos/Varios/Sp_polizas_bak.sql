  
/*  
Fecha: 24/Noviembre/2022  
Autor: Desconocido  
Task: N/A  
Observaciones: Proceso que realiza actualizacion de cargos y abonos por proceso de acuerdo a condiciones.  
  
MODIFICACIONES:  
V1.0. [Zayra Mtz. Candia].[24Nov2022]. Se quita comentario a la linea 82, donde estaba comentado la variable de la condicion.  
*/  
  
  
CREATE Procedure [dbo].[Sp_polizas]  
   (@PnAnio          Integer,  
    @PsCondicion     Nvarchar(500),    
    @PsMes           Varchar(3),  
    @PsMovDia        Nvarchar(50),               
    @PsPolDia        Nvarchar(50),               
    @PsLlave         Nvarchar(16),      
    @PnImporte       Money,     
    @PsClave         Nvarchar(1),     
    @PsSector        Nvarchar(2),       
    @PnSucursal      Integer,                
    @PnRegion        Integer,  
    @PnIdPol         Integer = 1,  
    @PsCeros         Nvarchar(16)   = '0000000000000000',  
    @PnIntMes        Integer,  
    @PsNCta          Nvarchar(4),  
    @PsSubCta        Nvarchar(16),  
    @PsSSubCta       Nvarchar(16),  
    @PsSSSubCta      Nvarchar(16),  
    @PsCat           Nvarchar(50),  
    @PsCatAux        Nvarchar(50),  
    @PsCatRep        Nvarchar(50),  
    @PsCatAuxRep     Nvarchar(50),  
    @PnSAct          Money = 0     ,  
    @PsCta           Nvarchar(16)  ,  
    @PsMoneda        Nvarchar(2)   = '00',  
    @PnmesCer        Integer,  
    @PnCountReg      Integer,  
    @PnEstatus       Integer       = 0   Output,  
    @PsMensaje       Varchar( 250) = ' ' Output)  
  
As   
Declare   
    @w_desc_error  Varchar( 250),  
    @w_Error       Integer,  
    @w_comilla     Char(1),  
    @w_sql         Varchar(Max),  
    @w_ncta        Nvarchar(20),   
    @w_nivel       Nvarchar(2),  
    @w_Aux         Nvarchar(7),   
    @w_minIdF      Integer,  
    @w_maxIdF      Integer  
      
Begin  
    Set Nocount       On  
    Set Xact_Abort    On  
    Set Ansi_Nulls    Off  
  
    Select @PnEstatus  = 0,  
           @PsMensaje  = Null,  
           @w_comilla  = Char(39)  
  
 Print 'ENTRA A Sp_polizas'  
  
--Filtra las polizas dentro de la condicion, la suma de cargos y abono por cta, moneda, sector y sucursal  
  
     -- A PARTIR DE AQUI CREAR EL PROCEDIMIENTO DE POLIZAS  
                 Set @w_sql = 'Select P.Llave, Round(Sum(P.Importe),2,0) AS Importe, P.Clave, P.Sector_id, P.Sucursal_id, P.Region_id ' +   
                              'From ' + @PsMovDia + ' M ' +   
                              'Join ' + @PsPolDia + ' P ' +  
                              'On  P.Referencia = M.Referencia ' +   
         'And M.Mes_Mov = ' + @w_comilla  + @PsMes + @w_comilla + ' ' +   
                              'And P.Fecha_Mov  = M.Fecha_Mov ' + @PsCondicion + ' ' +                                 
                              'Group By P.Llave, P.Moneda, P.Clave, P.Sector_id, P.Sucursal_id, P.Region_id '  
                   
                  --Truncate Table  #tmpFilter  
                  --DBCC CHECKIDENT ('#tmpFilter', RESEED, 1)  
                 Begin Try   
                     Insert Into #tmpFilter   
                     (Llave, Importe, Clave, Sector_id, Sucursal_id, Region_id)  
                     Execute (@w_sql)  
                       
                 End Try   
                 Begin Catch                      
       Select @w_error = ERROR_NUMBER(),  
                          @w_desc_error = ERROR_MESSAGE()  
  
          INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )  
             VALUES ('ERROR 6',@w_error, @w_desc_error, getdate());  
                   
                 End Catch  
                   
                 If IsNull(@w_error, 0) <> 0  
                 Begin   
                    Select @PnEstatus = @w_error,  
                           @PsMensaje = @w_desc_error   
                    Set Xact_Abort Off  
                    Return  
                 End  
  
                 Select @w_minIdF = MIN(id),  
                        @w_maxIdF = MAX(id)  
                 From   #tmpFilter  
  
                 While @w_minIdF <= @w_maxIdF  
                         Begin  
                            Begin Try  
          Print 'ENTRA A HACER CALCULOS'  
                               Select @PsLlave    = Llave,   
                                      @PnImporte  = Importe,   
                                      @PsClave    = Clave,   
                                      @PsSector   = Sector_id,   
                                      @PnSucursal = Sucursal_id,   
                                      @PnRegion   = Region_id   
                               From   #tmpFilter   
                               Where  Id = @w_minIdF    
  
                            End Try   
                            Begin Catch   
                              Select @w_error = ERROR_NUMBER(),  
                                     @w_desc_error = ERROR_MESSAGE()  
  
         INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )  
                        VALUES ('ERROR 6',@w_error, @w_desc_error, getdate());  
  
                            End Catch  
                              
                            If IsNull(@w_error, 0) <> 0  
                            Begin   
                               Select @PnEstatus = @w_error,  
                                      @PsMensaje = @w_desc_error   
            
          INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )  
          VALUES ('ERROR 7',@w_error, @w_desc_error, getdate());  
  
                               Set Xact_Abort Off  
                               Return  
                            End                                                   
  
       Print 'ASIGNA LAS VARIABLES'  
                           Select @w_Aux      = Substring  (@PsLlave, 11, 6)                ,   
                                  @PsNCta     = Substring  (@PsLlave,  7, 2)                , -- Valor 00  
                                  @PsSSSubCta = Concat(Left(@PsLlave,10),Right(@PsCeros,6)) , --Variable que se encarga de la SSSubCta--  
                                  @PsSSubCta  = Concat(Left(@PsLlave,8) ,Right(@PsCeros,8)) , --Variable que se encarga de la SSubCta--  
                                  @PsSubCta   = Concat(Left(@PsLlave,6) ,Right(@PsCeros,10)), --Variable que se encarga de la SubCta--  
                                  @PsCta      = Concat(Left(@PsLlave,4) ,Right(@PsCeros,12)), --Variable que se encarga de la Cta Mayor  
                                  @PnImporte  = Convert(Nvarchar, @PnImporte)               , --Definir variables tipo varchar --  
                                  @PnSucursal = Convert(Nvarchar, @PnSucursal)              ,  
                                  @PnRegion   = Convert(Nvarchar, @PnRegion  )              ,  
                                  @w_nivel    = Case When @w_Aux  = '000000'  
                                                     Then '0'   
                                                     Else '1'  
                                                End  
                         
                         --COMPARACION DEL MES EN CURSO Y MES CERRADO--  
                        --SI el mes en curso es igual al mes cerrado, solo se va actualizar los catalogos contables.  
                        --Catalogo Contable CATMESAÑO y Catalogo Auxiliar CATAUXMESAÑO, correspondiente al mes.  
                              --INICIO DE LA COMPARACION DEL MES, CUANDO CUMPLE CON LA CONDICION--   
                       
                      If (@PnIntMes = @PnmesCer)  
                        Begin         --COMPARACION DE CLAVE SEA IGUAL A C --En SICCORP se manejan dos tipos de Clave.--El primer tipo es C corresponde a CARGO.  
                           --INICIO DE LA COMPARACION DE LA CLAVE, CUANDO CUMPLE CON LA CONDICION--  
                          PRINT 'Actualiza los saldos de la cta correspondiente, en el catalogo del mes en curso.'  
                           Set @w_sql = 'Update ' + @PsCat + ' '                                +   
                                        'Set ' + Case When @PsClave = 'C'   
                                                      Then + ' CarExt        = CarExt + '     + Convert(Nvarchar, @PnImporte) + ', ' +   
                                                             ' CarProceso    = CarProceso + ' + Convert(Nvarchar, @PnImporte) + ' '      
                                                      Else + ' AboExt     = AboExt + ' + Convert(Nvarchar, @PnImporte) + ', '         +   
                                                             ' AboProceso = AboProceso + ' + Convert(Nvarchar, @PnImporte) + ' '    
                                                      End   
                           Set @w_sql = @w_sql   + 'Where Llave       = ' + @w_comilla  + @PsLlave  + @w_comilla + ' '            +  
                                                   'And   Moneda      = ' + @w_comilla  + @PsMoneda + @w_comilla + ' '          --+   
                                                 --'And   Niv         = ' + @w_comilla  + @w_nivel  + @w_comilla + ''   
  
                           Begin Try   
                              Execute(@w_sql)  
                           End Try   
                           Begin Catch  
                              If @@ERROR != 0  
                                Begin  
                                  Select @w_error      = Error_Number(),  
                                         @w_desc_error = Error_Message()  
          INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )  
                            VALUES ('ERROR 8',@w_error, @w_desc_error, getdate());   
                                End  
                           End Catch  
  
                           If IsNull(@w_error, 0) <> 0  
                           Begin   
                              Select @PnEstatus = @w_error,  
                                     @PsMensaje = @w_desc_error   
  
         INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )  
                        VALUES ('ERROR 9',@w_error, @w_desc_error, getdate());  
  
                              Set Xact_Abort Off  
                              Return  
                           End  
                                  
                           Set @w_sql = 'Update ' + @PsCatAux + ' '                                                               +    
                                        'Set ' + Case When @PsClave = 'C'   
                                                      Then ' CarExt        = CarExt + '     + Convert(Nvarchar, @PnImporte) + ', ' +  
                                                           ' CarProceso    = CarProceso + ' + Convert(Nvarchar, @PnImporte) + ' '    
                                                      Else ' AboExt        = AboExt + ' + Convert(Nvarchar, @PnImporte) + ', '     +   
                                                           ' AboProceso    = AboProceso + ' + Convert(Nvarchar, @PnImporte) + ' '    
                                                      End   
                           Set @w_sql = @w_sql + 'Where Llave       = ' + @w_comilla + @PsLlave  + @w_comilla + ' '                +  
                                                 'And   Moneda      = ' + @w_comilla + @PsMoneda + @w_comilla + ' '                +  
                                                 'And   Sucursal_id In ( ' + Convert(Nvarchar, @PnSucursal) + ', 0) '              +   
                                                 'And   Sector_id   = ' + @w_comilla + '00' + @w_comilla + ' '                   +  
                                                 'And   Region_id   In ( ' + Convert(Nvarchar, @PnRegion) + '  , 0) '                                                         
                             
                           Begin Try   
                              Execute(@w_sql)  
                           End Try   
                           Begin Catch  
                              If @@ERROR != 0  
                                Begin  
                                   Select @w_error      = Error_Number(),  
                                          @w_desc_error = Error_Message()   
  
          INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )  
                            VALUES ('ERROR 10',@w_error, @w_desc_error, getdate());  
                                    
                                End  
                           End Catch  
  
                           If IsNull(@w_error, 0) <> 0  
                              Begin   
                                 Select @PnEstatus = @w_error,  
                                        @PsMensaje = @w_desc_error   
           
         INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )  
                           VALUES ('ERROR 11',@w_error, @w_desc_error, getdate());  
  
                                 Set Xact_Abort Off  
                                 Return  
                              End  
           
                           --Actualiza los saldos de la subcta y cuenta mayor correspondiente, en el catalogo del mes en curso.  
                            Set @w_sql =  'Update ' + @PsCat + ' '                                                                                                                 +   
                                          'Set ' + Case When @PsClave = 'C'                                                                                                          
                                                        Then ' CarExt     = CarExt + ' + Convert(Nvarchar, @PnImporte) + ', '                                                      +  
                                                             ' CarProceso = CarProceso + ' + Convert(Nvarchar, @PnImporte) + ' '                                                     
                                                        Else ' AboExt     = AboExt +'+ Convert(Nvarchar, @PnImporte) +', '                                                         +   
                                                             ' AboProceso = AboProceso + '+ Convert(Nvarchar, @PnImporte) +' '                                                       
                                                        End   
  
                            Set @w_sql = @w_sql + 'Where Niv      = 0 '                                                                                                         +  
                                                  'And   Moneda   = ' + @w_comilla + @PsMoneda + @w_comilla + ' '                                                                 +  
                                                  'And   Llave     ' + Case When @PsNCta = '00'    
                                                                          Then ' In ( '+ @w_comilla + @PsSubCta   + @w_comilla +' , ' + @w_comilla + @PsCta     + @w_comilla +' ) '    
                                                                          Else ' In ( '+ @w_comilla + @PsSSSubCta + @w_comilla +' , ' + @w_comilla + @PsSSubCta + @w_comilla +' , ' +  
                                                                                       + @w_comilla + @PsSubCta   + @w_comilla +' , ' + @w_comilla + @PsCta     + @w_comilla +' ) '   
                                                                           End   
                                 Begin Try   
                                    Execute(@w_sql)  
                                 End Try   
                                 Begin Catch  
                                    If @@ERROR != 0  
                                      Begin  
                                         Select @w_error      = Error_Number(),  
                                                @w_desc_error = Error_Message()   
  
           INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )  
                                   VALUES ('ERROR 12',@w_error, @w_desc_error, getdate());  
                                           
                                      End  
                                End Catch  
  
                                If IsNull(@w_error, 0) <> 0  
                                   Begin   
                                      Select @PnEstatus = @w_error,  
                                             @PsMensaje = @w_desc_error   
                
           INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )  
                                VALUES ('ERROR 11',@w_error, @w_desc_error, getdate());  
  
                                      Set Xact_Abort Off  
                                      Return  
                                   End  
                         End   
                           
                         --CUANDO NO CUMPLE CON LA CONDICION DE LOS MESES QUE SEAN IGUALES--  
                        --SI el mes en curso NO es igual al mes cerrado, se va actualizar los catalogos contables y se realiza un registro de los importes en las tablas de registros.  
                        --Catalogo Contable CATMESAÑO y Catalogo Auxiliar CATAUXMESAÑO, correspondiente al mes.  
                        PRINT 'Tablas de registro CATREPAÑO y CATAUXREPAÑO.'  
                         If (@PnIntMes <> @PnmesCer)  
                          Begin    /*ELSE SI LOS MESES NO SON IGUALES*/  -- SI NO EXISTE, SE UTILIZA EN LA SENTENCIA INSERT, PARA AÑADIR UN ELEMENTO, EVITANDO AÑADIR REGISTROS DUPLICADOS                           
                            Set @w_sql = 'If Not Exists ( Select * '                                                                            +   
                                         '                From ' + @PsCatRep + ' '                                                                +    
                                         '                Where Llave  = ' + @w_comilla + @PsLlave + @w_comilla   + ' '                           +   
                                    /**/-- '                And   Moneda = ' + @w_comilla + @PsMoneda + @w_comilla + ' '                            +  
                                    /**/-- '                And   Niv    = 1'                           +  
                                         '                And   FecCap = ' + Convert(Nvarchar,@PnIntMes) + ') '                                   +                       
                                         '   Begin ' +  
                                         '      Insert Into ' + @PsCatRep + '(Llave, Moneda, Niv, SAct, FecCap) '                                 +   
                                         '      Values (' + @w_comilla + @PsLlave + @w_comilla  + ',' + @w_comilla + @PsMoneda + @w_comilla + ','   +   
                                         '              1, '                                                                                    +   
                                         '              ' + Cast(@PnImporte As Varchar) + ',' + Convert(Nvarchar,@PnIntMes) + ') '                  +   
                                         '   End '                                                                                              +  
                                         'Else '                                                                                                +  
                                         '    Begin ' +   
                                         '       Update ' + @PsCatRep + ' ' +  Case When @PsClave = 'C'  
                                                                                    Then 'Set   SAct   = SAct + ' + Cast(@PnImporte As Varchar)  + ' '               
                                                                                    Else 'Set   SAct   = SAct - ' + Convert(Nvarchar, @PnImporte) + ' '             
                           End   
                            Set @w_sql = @w_sql + 'Where Llave     = ' + @w_comilla + @PsLlave + @w_comilla  + ' ' +  
                                           /**/ --  'And   Moneda    = ' + @w_comilla + @PsMoneda + @w_comilla + ' ' +  
                                           /**/ --  'And   Niv       = 1 '                                           +   
                                                  'And   FecCap    = ' + Convert(Nvarchar,@PnIntMes) + ' '         +   
                                                  '    End '      
                              
                            Begin try   
                                Execute (@w_sql)  
                            End Try   
                            Begin Catch  
                                 If @@ERROR != 0  
                                   Begin  
                                      Select @w_error      = Error_Number(),  
                                             @w_desc_error = Error_Message()   
  
                                     INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )  
                               VALUES ('ERROR 12',@w_error, @w_desc_error, getdate());  
                                  End  
                            End Catch  
  
                            If IsNull(@w_error, 0) <> 0  
                               Begin   
                                  Select @PnEstatus = @w_error,  
                                         @PsMensaje = @w_desc_error  
            
          INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )  
                            VALUES ('ERROR 13',@w_error, @w_desc_error, getdate());  
             
                                  Set Xact_Abort Off  
                                  Return  
                               End  
                            PRINT 'Actualiza los saldos de la cta correspondiente, en el catalogo del mes en curso.'  
                            Set @w_sql = 'Update ' + @PsCat + ' '                                                 +   
                                            'Set ' + Case When @PsClave = 'C'  
                                                       Then ' CarExt     = CarExt + '     + Convert(Nvarchar, @PnImporte) + ', ' +  
                                                            ' CarProceso = CarProceso + ' + Convert(Nvarchar, @PnImporte) + ' '    
                                                       Else ' AboExt     = AboExt + '     + Convert(Nvarchar, @PnImporte) + ', ' +  
                                                            ' AboProceso = AboProceso + ' + Convert(Nvarchar, @PnImporte) + ' '     
                                                       End  
                               
                            Set @w_sql = @w_sql + 'Where Llave  = ' + @w_comilla + @PsLlave  + @w_comilla + ' '             -- +  
                                             /**/ --'And   Moneda = ' + @w_comilla + @PsMoneda + @w_comilla + ' '              +  
                                             /**/ --'And   Niv    = ' + @w_comilla + @w_nivel  + @w_comilla + ' '       
  
                               
                             Begin try   
                                 Execute (@w_sql)  
                             End Try   
                             Begin Catch  
                                  If @@ERROR != 0  
                                    Begin  
                                       Select @w_error      = Error_Number(),  
                                              @w_desc_error = Error_Message()   
              
            INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )  
                                 VALUES ('ERROR 6',@w_error, @w_desc_error, getdate());  
  
                                   End  
                             End Catch  
  
                             If IsNull(@w_error, 0) <> 0  
                        Begin   
                                   Select @PnEstatus = @w_error,  
                                          @PsMensaje = @w_desc_error  
              
         INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )  
                              VALUES ('ERROR 14',@w_error, @w_desc_error, getdate());  
            
                                   Set Xact_Abort Off  
                                   Return  
                                End  
           
                             --Inserta en la tabla CATAUXREPAÑO, la cta, sucursal y region correspondiente saldo cero, en el mes en curso.    
                             PRINT 'REGISTRO EN LA EMPRESA 0, QUE CORRESPONDE A LA CORPORATIVA'  
                             Set @w_sql = 'If Not Exists (Select Top 1 1 '                                                                                                   +   
                                          '               From ' + @PsCatAuxRep + ' '                                                                                          +   
                                          '               Where Llave       = ' + @w_comilla + @PsLlave  + @w_comilla + ' '                                                    +   
                                /**/  --    '               And   Moneda      = ' + @w_comilla + @PsMoneda + @w_comilla + ' '                                                  +   
                                /**/  --    '               And   Sector_id   = ' + @w_comilla + '00' + @w_comilla + ' '                                                     +  
                                          '               And   Sucursal_id = ' + Convert(Nvarchar, @PnSucursal) + ' '                                                         +   
                                          '               And   Region_id   = ' + Convert(Nvarchar, @PnRegion)   + ' '                                                         +   
                                          '               And   FecCap      = ' + Convert(Nvarchar,@PnIntMes) + ') '                                                           +   
                                          '   Begin  '                                                                                                                       +  
                                          '     Insert Into ' + @PsCatAuxRep + ' '                                                                                             +   
                                          '            (Llave, Moneda, Niv, Sector_id, Sucursal_id, Region_id, SAct, FecCap) '                                               +   
                                          '     Values (' + @w_comilla + @PsLlave  + @w_comilla + ', ' + @w_comilla + @PsMoneda + @w_comilla + ', '                              +   
                                          '             1, ' +                                                                                                               +   
                                          '             ' + @w_comilla + @PsSector + @w_comilla + ', ' + Convert(Nvarchar, @PnSucursal) + ',' + Convert(Nvarchar, @PnRegion) + ',' +   
                                          '             ' + Cast(@PnImporte As Varchar) + ', ' + Convert(Nvarchar,@PnIntMes) + ') '                                              +  
                                          '    End '                                                                                                                         +  
                                          'Else '                                                                                                                            +  
                                          '   Begin  '                                                                                                                       +   
         '      Update ' + @PsCatAuxRep + ' ' + Case When @PsClave = 'C'                                                            
                                                                              Then 'Set   SAct = SAct + ' + Convert(Nvarchar, @PnImporte)  + ' '            
                                                                              Else 'Set   SAct = SAct - ' + Convert(Nvarchar, @PnImporte)  + ' '           
                                                                              End   
                            Set @w_sql = @w_sql + '       Where Llave       = ' + @w_comilla + @PsLlave + @w_comilla  + ' '   +  
                                          /**/  --  '       And   Moneda      = ' + @w_comilla + @PsMoneda + @w_comilla + ' '   +    
                                          /**/  --  '       And   Sector_id   = ' + @w_comilla + '00' + @w_comilla + ' '        +  
                                                  '       And   Sucursal_id = ' + Convert(Nvarchar, @PnSucursal) + ' '        +   
                                                  '       And   Region_id   = ' + Convert(Nvarchar, @PnRegion)   + ' '        +  
                                                  '       And   FecCap      = ' + Convert(Nvarchar, @PnIntMes)   + ' '        +              
                                                  '    End '  
  
                             Begin try   
                                 Execute (@w_sql)  
                             End Try   
                             Begin Catch  
                                  If @@ERROR != 0  
                                    Begin  
                                       Select @w_error      = Error_Number(),  
                                              @w_desc_error = Error_Message()  
              
            INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )  
                                 VALUES ('ERROR 15',@w_error, @w_desc_error, getdate());              
               
                                    End  
                             End Catch  
           
                             If IsNull(@w_error, 0) <> 0  
                                Begin   
                                   Select @PnEstatus = @w_error,  
                                          @PsMensaje = @w_desc_error   
  
         INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )  
                              VALUES ('ERROR 6',@w_error, @w_desc_error, getdate());  
  
  
                                   Set Xact_Abort Off  
                                   Return  
                                End  
  
                             Set @w_sql = 'Update ' + @PsCatAux + ' '                                            +   
                                          'Set ' + Case When @PsClave = 'C'  
                                                        Then ' CarExt     = CarExt + ' + Convert(Nvarchar, @PnImporte) + ', '    +   
                                                             ' CarProceso = CarProceso + ' + Convert(Nvarchar, @PnImporte) + ' '   
                                                        Else ' AboExt     = AboExt + ' + Convert(Nvarchar, @PnImporte) + ', '      +  
                                                             ' AboProceso = AboProceso + ' + Convert(Nvarchar, @PnImporte) + ' '     
                                                        End  
                                   
                             Set @w_sql = @w_sql + 'Where Llave       = ' + @w_comilla + @PsLlave + @w_comilla     + ' '    +   
                                       /**/      --  'And   Moneda      = ' + @w_comilla + @PsMoneda + @w_comilla + ' '       +   
                                       /**/      --  'And   Sector_id   = ' + @w_comilla + '00' + @w_comilla      + ' '     +  
                                                   'And   Sucursal_id   = ' + Convert(Nvarchar, @PnSucursal) + ' '      +  
                                                   'And   Region_id     = ' + Convert(Nvarchar, @PnRegion)   + ' '                                          
   
                             Begin try   
                                 Execute (@w_sql)  
                             End Try   
                             Begin Catch  
                                  If @@ERROR != 0  
                                    Begin  
                                       Select @w_error      = Error_Number(),  
                                              @w_desc_error = Error_Message()   
  
          INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )  
                                  VALUES ('ERROR 6',@w_error, @w_desc_error, getdate());  
  
                                    End  
                             End Catch  
  
                             If IsNull(@w_error, 0) <> 0  
                                Begin   
                                   Select @PnEstatus = @w_error,  
                                          @PsMensaje = @w_desc_error   
  
         INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )  
                              VALUES ('ERROR 16',@w_error, @w_desc_error, getdate());  
  
                                   Set Xact_Abort Off  
                                   Return  
                                End  
  
                             Set @w_sql = 'If Not Exists (Select Top 1 1 '                                                                                                   +   
                                          '               From ' + @PsCatAuxRep + ' '                                                                                          +   
                                          '               Where Llave       = ' + @w_comilla + @PsLlave  + @w_comilla + ' '                                                    +   
                             /**/   --      '               And   Moneda      = ' + @w_comilla + @PsMoneda + @w_comilla + ' '                                                    +   
                             /**/   --      '               And   Sector_id   = ' + @w_comilla + '00' + @w_comilla + ' '                                                       +  
                                          '               And   Sucursal_id = 0  '                                                   +   
                                          '               And   Region_id   = 0  '                                                   +   
                                          '               And   FecCap      = ' + Convert(Nvarchar,@PnIntMes) + ') '                                                           +   
                                          '   Begin  '                                                                                                                       +  
                                          '     Insert Into '+ @PsCatAuxRep +'(Llave, Moneda, Niv, Sector_id, Sucursal_id, Region_id, SAct, FecCap) '                          +  
                                          '     Values (' + @w_comilla + @PsLlave + @w_comilla  + ', ' + @w_comilla + @PsMoneda + @w_comilla + ', '                              +   
                                          '             1, 00, 0, 0,' + Cast(@PnImporte As Varchar) + ',' + Convert(Nvarchar,@PnIntMes) + ') '                                   +   
                                          '    End ' +  
                                          'Else ' +  
                                          '   Begin  '                                                                                                         +   
                                          '      Update ' + @PsCatAuxRep + ' ' + Case When @PsClave = 'C'  
                                                                                      Then '       Set   SAct = SAct + ' + Convert(Nvarchar, @PnImporte)  + ' '            
                                                                                      Else '       Set   SAct = SAct - ' + Convert(Nvarchar, @PnImporte)  + ' '            
                                                                                      End  
                             Set @w_sql = @w_sql + '       Where Llave       = ' + @w_comilla + @PsLlave + @w_comilla  + ' '   +  
                                  /**/    --         '       And   Moneda      = ' + @w_comilla + @PsMoneda + @w_comilla + ' '   +    
                                  /**/    --         '       And   Sector_id   = ' + @w_comilla + '00' + @w_comilla + ' '        +  
                                                   '       And   Sucursal_id = 0 '                                             +   
                                                   '       And   Region_id   = 0 '                                             +  
                                                   '       And   FecCap      = ' + Convert(Nvarchar,@PnIntMes) + ' '           +        
                                                   '    End '  
  
                             Begin try   
                                 Execute (@w_sql)  
                             End Try   
                             Begin Catch  
                                  If @@ERROR != 0  
                                    Begin  
                                       Select @w_error      = Error_Number(),  
                                              @w_desc_error = Error_Message()   
  
            INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )  
                                 VALUES ('ERROR 17',@w_error, @w_desc_error, getdate());  
  
                                    End  
                             End Catch  
           
                             If IsNull(@w_error, 0) <> 0  
                                Begin   
                                   Select @PnEstatus = @w_error,  
                                          @PsMensaje = @w_desc_error   
                                   Set Xact_Abort Off  
                                   Return  
                                End                                  
  
                             PRINT 'Actualiza los saldos de la cta, sucursal y region correspondiente, en el catalogo auxiliar del mes en curso.'   
                             Set @w_sql = 'Update ' + @PsCatAux + ' '                                            +   
                                          'Set ' + Case When @PsClave = 'C'  
                                                        Then ' CarExt     = CarExt + ' + Convert(Nvarchar, @PnImporte) + ', '    +   
                                                             ' CarProceso = CarProceso + ' + Convert(Nvarchar, @PnImporte) + ' '   
                                                        Else ' AboExt     = AboExt + ' + Convert(Nvarchar, @PnImporte) + ', '      +  
                                                             ' AboProceso = AboProceso + ' + Convert(Nvarchar, @PnImporte) + ' '     
                                                        End  
                                   
                             Set @w_sql = @w_sql + 'Where Llave       = ' + @w_comilla + @PsLlave + @w_comilla     + ' '    +   
                                        /**/       'And   Moneda      = ' + @w_comilla + @PsMoneda + @w_comilla + ' '       +   
                                        /**/       'And   Sector_id   = ' + @w_comilla + '00' + @w_comilla      + ' '     +  
                                                   'And   Sucursal_id =  0 '      +  
                                                   'And   Region_id   =  0 '                                          
   
                             Begin try   
                                 Execute (@w_sql)  
                             End Try   
                             Begin Catch  
                             If @@ERROR != 0  
                                    Begin  
                                       Select @w_error      = Error_Number(),  
                                              @w_desc_error = Error_Message()  
  
            INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )  
                                 VALUES ('ERROR 18',@w_error, @w_desc_error, getdate());  
            
             
                                    End  
                             End Catch  
  
                             If IsNull(@w_error, 0) <> 0  
                                Begin   
                                   Select @PnEstatus = @w_error,  
                                          @PsMensaje = @w_desc_error   
  
         INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )  
                               VALUES ('ERROR 19',@w_error, @w_desc_error, getdate());  
  
                                   Set Xact_Abort Off  
                                   Return  
                                End  
  
  
                             PRINT 'COMPARACION DEL VALOR 00 EXTRAIDO DE LA LLAVE--'  
                             --Para trabajar con los niveles de las ctas.  
                             --Si cumple con la condicion, es para los tres niveles.  
                             --Inserta en la tabla CATREPAÑO, la subcta correspondiente saldo cero, en el mes en curso.  
                             --Inserta en la tabla CATREPAÑO, la sub-sub-subcta correspondiente saldo cero, en el mes en curso.  
                             --Actualiza los saldos de la sub-sub-subcta correspondiente, en el catalogo del mes en curso.  
                             --Inserta en la tabla CATREPAÑO, la subcta correspondiente saldo cero, en el mes en curso.   
        PRINT 'SUBCUENTA'  
                             /*SUBCUENTA*/  
                             Set @w_sql = 'If Not Exists  (Select Top 1 1 '                                                                       +   
                                          '               From  ' + @PsCatRep + ' '                                                                 +   
                                          '               Where Llave ' + Case When @PsNCta = '00'    
                                                                               Then ' = ' + @w_comilla + @PsSubCta + @w_comilla + ' '                 
                                                                               End   
                             Set @w_sql = @w_sql + --'               And   Moneda = ' + @w_comilla + @PsMoneda + @w_comilla + ' '                            +   
                                                   -- '               And   Niv    = ' + @w_comilla + @w_nivel  + @w_comilla + ' '                         +   
                                                   '               And   FecCap = ' + Convert(Nvarchar,@PnIntMes) + ') '                                     +  
                                                   '   Begin '                                                                                             +   
                                                   '      Insert Into ' + @PsCatRep + '    (Llave, Moneda, Niv,  SAct, FecCap) '                             +  
                                                   '      Values( ' + @w_comilla + @PsSubCta + @w_comilla + ',' + @w_comilla + @PsMoneda + @w_comilla + ', '   +   
                                                   '              0,' + Cast(@PnImporte As Varchar) + ','                                                    +   
                                                   '              ' + Convert(Nvarchar,@PnIntMes) + ') '                                                     +  
                                                   '   End '                                                                                               +  
                                             'Else '                                                                                                 +   
                                                   '   Begin '                                                                                             +     
                                                   '   Update ' + @PsCatRep + ' '                                                                            +   
                                                         'Set ' + Case When @PsClave = 'C'   
                                                                       Then 'SAct = SAct + ' + Convert(Nvarchar, @PnImporte) + ' '                             
                                                                       Else 'SAct   = SAct - ' + Convert(Nvarchar, @PnImporte) + ' '      
                                                                       End   
                             Set @w_sql = @w_sql + 'Where Llave  =  ' + @w_comilla + @PsSubCta + @w_comilla + ' '                   +   
                                                   --'And   Moneda = ' + @w_comilla + @PsMoneda + @w_comilla + ' '                  +  
                                                   --'And   Niv    = ' + @w_comilla + @w_nivel  + @w_comilla + ' '                  +   
                                                   'And   FecCap = ' + Convert(Nvarchar,@PnIntMes) + ' '                            +   
                                                   ' End '  
  
                             Begin try   
                                 Execute (@w_sql)  
                             End Try   
                             Begin Catch  
                                  If @@ERROR != 0  
                                    Begin  
                                       Select @w_error      = Error_Number(),  
                                              @w_desc_error = Error_Message()  
              
            INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )  
                                 VALUES ('ERROR 20',@w_error, @w_desc_error, getdate());  
  
                                    End  
                             End Catch  
  
                             If IsNull(@w_error, 0) <> 0  
                                Begin   
                                   Select @PnEstatus = @w_error,  
                                          @PsMensaje = @w_desc_error   
  
           INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )  
                             VALUES ('ERROR 21',@w_error, @w_desc_error, getdate());  
  
                                   Set Xact_Abort Off  
                                   Return  
                                End  
                                  
                              PRINT 'CUENTA'    
                             /*CUENTA*/  
  
                             --Set @w_sql =         'If Not Exists  (Select Top 1 1 '                                                                                             +   
                             --                     '               From  ' + @PsCatRep + ' '                                                                                     +   
                             --                     '               Where Llave ' + Case When @PsNCta = '00'                                                                        
                             --                                                          Then ' =   ' + @w_comilla + @PsCta     + @w_comilla + ' '                                     
                             --                                                          Else ' In(' + @w_comilla + @PsSSSubCta + @w_comilla + ', '                               +   
                             --                     '                                              ' + @w_comilla + @PsSSubCta  + @w_comilla + ', '                       +   
                             --                     '                                              ' + @w_comilla + @PsSubCta   + @w_comilla + ', '                               +   
                             --                     '                                              ' + @w_comilla + @PsCta      + @w_comilla + ') '                                 
                             --                                                          End  
                             --Set @w_sql = @w_sql + --'               And   Moneda = ' + @w_comilla + @PsMoneda + @w_comilla + ' '                                               +   
                             --                      -- '               And   Niv    = ' + @w_comilla + @w_nivel  + @w_comilla + ' '                                              +   
                             --                      '               And   FecCap = ' + Convert(Nvarchar,@PnIntMes) + ') '                                                        +  
                             --                      '   Begin ' + Case When @PsNCta = '00'                                                                                         
                             --                                         Then  'Insert Into ' + @PsCatRep + '    (Llave, Moneda, Niv,  SAct,           FecCap) '                   +  
                             --                                               'Values( ' + @w_comilla + @PsCta   + @w_comilla + ', ' + @w_comilla + @PsMoneda + @w_comilla + ', ' +   
                             --                                               '        0,' + Cast(@PnImporte As Varchar) + ','                                                    +   
                             --                                               '        ' + Convert(Nvarchar,@PnIntMes) + ') '                                                       
                             --                                         Else  'Insert Into ' + @PsCatRep + '(Llave, Moneda, Niv, SAct, FecCap) '                                  +  
                             --                                               'Values (' + @w_comilla + @PsSSSubCta + @w_comilla + ','                                            +   
                             --                                               '        ' + @w_comilla + @PsMoneda   + @w_comilla + ', 0,'                                         +   
                             --                                               '        ' + Cast(@PnImporte As Varchar) + ',' + Convert(Nvarchar,@PnIntMes) + ') '                 +  
                             --                                               'Insert Into '+ @PsCatRep +'(Llave, Moneda, Niv, SAct, FecCap) '                                    +  
                             --                                               'Values(' + @w_comilla + @PsSSubCta + @w_comilla + ','                                              +   
                             --                                               '       ' + @w_comilla + @PsMoneda  + @w_comilla + ', 0, '                                          +   
                             --                                               '       ' + Cast(@PnImporte As Varchar) + ',' + Convert(Nvarchar,@PnIntMes) + ') '                  +   
                             --                                               'Insert Into '+ @PsCatRep +'(Llave, Moneda, Niv, SAct, FecCap) '                                    +  
                             --                                               'Values(' + @w_comilla + @PsSubCta + @w_comilla + ','                                               +   
                             --                                               '       ' + @w_comilla + @PsMoneda  + @w_comilla + ', 0, '                                          +   
                             --         '       ' + Cast(@PnImporte As Varchar) + ',' + Convert(Nvarchar,@PnIntMes) + ') '                  +  
                             --                                               'Insert Into '+ @PsCatRep +'(Llave, Moneda, Niv, SAct, FecCap) '                                    +  
                             --                                               'Values(' + @w_comilla + @PsCta + @w_comilla + ','                                                  +   
                             --                                               '       ' + @w_comilla + @PsMoneda  + @w_comilla + ', 0, '                                          +   
                             --                                               '       ' + Cast(@PnImporte As Varchar) + ',' + Convert(Nvarchar,@PnIntMes) + ') '  
                             --                                         End                      
                             --Set @w_sql = @w_sql + '   End '                                                                                                                    +  
                             --                      'Else '                                                                                                                      +   
                             --                      '   Begin '                                                                                                                  +     
                             --                      '   Update ' + @PsCatRep + ' '                                                                                               +   
                             --                      '   Set ' + Case When @PsClave = 'C'   
                             --                                       Then 'SAct = SAct + ' + Convert(Nvarchar, @PnImporte) + ' '                             
                             --                                       Else 'SAct   = SAct - ' + Convert(Nvarchar, @PnImporte) + ' '                           
                             --                                       End   
                             --set @w_sql = @w_sql +  '   Where ' + Case When @PsNCta = '00'  
                             --                                          Then ' Llave  =   ' + @w_comilla + @PsCta      + @w_comilla + ' '      
                             --                                          Else 'Llave  In ( ' + @w_comilla + @PsSSSubCta + @w_comilla + ','                                        +   
                             --                                               '            ' + @w_comilla + @PsSSubCta  + @w_comilla + ','                                        +  
                             --                                               '            ' + @w_comilla + @PsSubCta   + @w_comilla + ','                                        +  
                             --                                               '            ' + @w_comilla + @PsCta      + @w_comilla + ')'   
                             --                                          End  
                             --Set @w_sql = @w_sql + --'  And   Moneda = ' + @w_comilla + @PsMoneda + @w_comilla + ' '                                                            +  
                             --                      --'  And   Niv    = ' + @w_comilla + @w_nivel  + @w_comilla + ' '                                                            +   
                             --                      '    And   FecCap = ' + Convert(Nvarchar,@PnIntMes) + ' '                                                                    +   
                             --                      ' End '    
                 
           /*Se restructura la consulta para validar una cuenta a la vez [MiguelZamora][ZayraCandia][CarlosUrbina]*/  
        --  
        --@PsSSSubCta  
        --  
                             Set @w_sql =         'If Not Exists  (Select Top 1 1 '                                                                                             +   
                                                  '               From  ' + @PsCatRep + ' '                                                                                     +   
                                                  '               Where Llave ' + Case When @PsNCta = '00'                                                                        
                                                                                       Then ' =   ' + @w_comilla + @PsCta     + @w_comilla + ' '                                     
                                                                                       Else ' In(' + @w_comilla + @PsSSSubCta + @w_comilla + ') '                                  
                                                                                       End                           
                             Set @w_sql = @w_sql + --'               And   Moneda = ' + @w_comilla + @PsMoneda + @w_comilla + ' '                                               +   
                                                   -- '               And   Niv    = ' + @w_comilla + @w_nivel  + @w_comilla + ' '                                              +   
                                                   '               And   FecCap = ' + Convert(Nvarchar,@PnIntMes) + ') '                                                        +  
                                                   '   Begin ' + Case When @PsNCta = '00'                                                                                         
                                                                      Then  'Insert Into ' + @PsCatRep + '    (Llave, Moneda, Niv,  SAct,           FecCap) '                   +  
                                                                            'Values( ' + @w_comilla + @PsCta   + @w_comilla + ', ' + @w_comilla + @PsMoneda + @w_comilla + ', ' +   
                                                                            '        0,' + Cast(@PnImporte As Varchar) + ','                                                    +   
                                                                            '        ' + Convert(Nvarchar,@PnIntMes) + ') '                                                       
                                                                      Else  'Insert Into ' + @PsCatRep + '(Llave, Moneda, Niv, SAct, FecCap) '                                  +  
                                                                            'Values (' + @w_comilla + @PsSSSubCta + @w_comilla + ','                                            +   
                                                                            '        ' + @w_comilla + @PsMoneda   + @w_comilla + ', 0,'                                         +   
                                                                            '        ' + Cast(@PnImporte As Varchar) + ',' + Convert(Nvarchar,@PnIntMes) + ') '  
                                                                      End                      
                             Set @w_sql = @w_sql + '   End '                                                                                                                    +  
                                                   'Else '                                                                                                                      +   
                                                   '   Begin '                                                                                                                  +     
                                                   '   Update ' + @PsCatRep + ' '                                                                                               +   
                                                   '   Set ' + Case When @PsClave = 'C'   
                                           Then 'SAct = SAct + ' + Convert(Nvarchar, @PnImporte) + ' '                             
                                                                    Else 'SAct   = SAct - ' + Convert(Nvarchar, @PnImporte) + ' '                           
                                                                    End   
                             set @w_sql = @w_sql +  '   Where ' + Case When @PsNCta = '00'  
                                                                       Then ' Llave  =   ' + @w_comilla + @PsCta      + @w_comilla + ' '      
                                                                       Else 'Llave  In ( ' + @w_comilla + @PsSSSubCta + @w_comilla + ')'   
                                                                       End  
                             Set @w_sql = @w_sql + --'  And   Moneda = ' + @w_comilla + @PsMoneda + @w_comilla + ' '                                                            +  
                                                   --'  And   Niv    = ' + @w_comilla + @w_nivel  + @w_comilla + ' '                                                            +   
                                                   '    And   FecCap = ' + Convert(Nvarchar,@PnIntMes) + ' '                                                                    +   
                                                   ' End '  
                             Begin try   
                                 Execute (@w_sql)  
                             End Try   
                             Begin Catch  
                                  If @@ERROR != 0  
                                    Begin  
                                       Select @w_error      = Error_Number(),  
                                              @w_desc_error = Error_Message()  
              
            --Borrar  
            Select @w_sql As w_sql, @PsSSSubCta As PsSSSubCta, @w_minIdF As w_minIdF  
            Select * From #tmpFilter Where  Id = @w_minIdF  
            --Borrar  
  
            INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )  
                                 VALUES ('ERROR @PsSSSubCta ',@w_error, @w_desc_error, getdate());  
  
                                    End  
                             End Catch  
                               
                             If IsNull(@w_error, 0) <> 0  
                                Begin   
                                   Select @PnEstatus = @w_error,  
                                          @PsMensaje = @w_desc_error   
             
           INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )  
                             VALUES ('ERROR 02 @PsSSSubCta ',@w_error, @w_desc_error, getdate());  
  
                                   Set Xact_Abort Off  
                                   Return  
                                End  
        --  
        --@PsSSubCta  
        --  
                             Set @w_sql =         'If Not Exists  (Select Top 1 1 '                                                                                             +   
                                                  '               From  ' + @PsCatRep + ' '                                                                                     +   
                                                  '               Where Llave ' + Case When @PsNCta = '00'                                                                       
                                                                                       Then ' =   ' + @w_comilla + @PsCta     + @w_comilla + ' '                                    
                                                                                       Else ' In(' +@w_comilla + @PsSSubCta  + @w_comilla  + ') '                                 
                                                                                       End  
                             Set @w_sql = @w_sql + --'               And   Moneda = ' + @w_comilla + @PsMoneda + @w_comilla + ' '                                               +   
                                                   -- '               And   Niv    = ' + @w_comilla + @w_nivel  + @w_comilla + ' '                                              +   
                                                   '               And   FecCap = ' + Convert(Nvarchar,@PnIntMes) + ') '                                                        +  
                                                   '   Begin ' + Case When @PsNCta = '00'                                                                                         
                                                                      Then  'Insert Into ' + @PsCatRep + '    (Llave, Moneda, Niv,  SAct,           FecCap) '                   +  
                                                                            'Values( ' + @w_comilla + @PsCta   + @w_comilla + ', ' + @w_comilla + @PsMoneda + @w_comilla + ', ' +   
                                                                            '        0,' + Cast(@PnImporte As Varchar) + ','                                                    +   
                                                                            '        ' + Convert(Nvarchar,@PnIntMes) + ') '                                                       
                                                                      Else  'Insert Into '+ @PsCatRep +'(Llave, Moneda, Niv, SAct, FecCap) '                                    +  
                                                                            'Values(' + @w_comilla + @PsSSubCta + @w_comilla + ','                                              +   
                                                                            '       ' + @w_comilla + @PsMoneda  + @w_comilla + ', 0, '                                          +   
                                                                            '       ' + Cast(@PnImporte As Varchar) + ',' + Convert(Nvarchar,@PnIntMes) + ') '  
                                                                      End                      
                             Set @w_sql = @w_sql + '   End '                                                                                                                    +  
                                                   'Else '                                                                                                                      +   
                                                   '   Begin '                                                                                                                  +     
                                                   '   Update ' + @PsCatRep + ' '                                                                                               +   
                                                   '   Set ' + Case When @PsClave = 'C'   
                                                                    Then 'SAct = SAct + ' + Convert(Nvarchar, @PnImporte) + ' '                             
                                                                    Else 'SAct   = SAct - ' + Convert(Nvarchar, @PnImporte) + ' '                           
                                                                    End   
                             set @w_sql = @w_sql +  '   Where ' + Case When @PsNCta = '00'  
                                                                       Then ' Llave  =   ' + @w_comilla + @PsCta      + @w_comilla + ' '      
                                                                       Else 'Llave  In ( ' + @w_comilla + @PsSSubCta  + @w_comilla + ')'   
                                                                       End  
                             Set @w_sql = @w_sql + --'  And   Moneda = ' + @w_comilla + @PsMoneda + @w_comilla + ' '           +  
                                                   --'  And   Niv    = ' + @w_comilla + @w_nivel  + @w_comilla + ' '                                                            +   
                                                   '    And   FecCap = ' + Convert(Nvarchar,@PnIntMes) + ' '                                                                    +   
                                                   ' End '   
                             Begin try   
                                 Execute (@w_sql)  
                             End Try   
                             Begin Catch  
                                  If @@ERROR != 0  
                                    Begin  
                                       Select @w_error      = Error_Number(),  
                                              @w_desc_error = Error_Message()  
  
                                       --Borrar  
            Select @w_sql As w_sql, @PsSSubCta As PsSSubCta, @w_minIdF As w_minIdF  
            Select * From #tmpFilter Where  Id = @w_minIdF  
            --Borrar  
  
            INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )  
                                 VALUES ('ERROR @PsSSubCta ',@w_error, @w_desc_error, getdate());  
  
                                    End  
                             End Catch  
                               
                             If IsNull(@w_error, 0) <> 0  
                                Begin   
                                   Select @PnEstatus = @w_error,  
                                          @PsMensaje = @w_desc_error   
             
           INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )  
                             VALUES ('ERROR 02 @PsSSubCta ',@w_error, @w_desc_error, getdate());  
  
                                   Set Xact_Abort Off  
                                   Return  
                                End  
        --  
        --@PsSubCta  
        --  
                             Set @w_sql =         'If Not Exists  (Select Top 1 1 '                                                                                             +   
                                                  '               From  ' + @PsCatRep + ' '                                                                                     +   
                                                  '               Where Llave ' + Case When @PsNCta = '00'                                                                        
                                                                                       Then ' =   ' + @w_comilla + @PsCta     + @w_comilla + ' '                                     
                                                                                       Else ' In(' + @w_comilla + @PsSubCta   + @w_comilla + ') '                                 
                                                                                       End  
                             Set @w_sql = @w_sql + --'               And   Moneda = ' + @w_comilla + @PsMoneda + @w_comilla + ' '                                               +   
                                                   -- '               And   Niv    = ' + @w_comilla + @w_nivel  + @w_comilla + ' '                                              +   
                                                   '               And   FecCap = ' + Convert(Nvarchar,@PnIntMes) + ') '                                                        +  
                                                   '   Begin ' + Case When @PsNCta = '00'                                                                                         
                                                                      Then  'Insert Into ' + @PsCatRep + '    (Llave, Moneda, Niv,  SAct,           FecCap) '                   +  
                                                                            'Values( ' + @w_comilla + @PsCta   + @w_comilla + ', ' + @w_comilla + @PsMoneda + @w_comilla + ', ' +   
                                                                            '        0,' + Cast(@PnImporte As Varchar) + ','                                                    +   
                                                                            '        ' + Convert(Nvarchar,@PnIntMes) + ') '                                                       
                                                                      Else  'Insert Into '+ @PsCatRep +'(Llave, Moneda, Niv, SAct, FecCap) '                                    +  
                                                                            'Values(' + @w_comilla + @PsSubCta + @w_comilla + ','                                               +   
                                                                            '       ' + @w_comilla + @PsMoneda  + @w_comilla + ', 0, '                                          +   
                                                                            '       ' + Cast(@PnImporte As Varchar) + ',' + Convert(Nvarchar,@PnIntMes) + ') '  
                                                                      End                      
                             Set @w_sql = @w_sql + '   End '                                                                                                                    +  
                                                   'Else '                                                                                                                      +   
                                                   '   Begin '                                                                                                                  +     
                                                   '   Update ' + @PsCatRep + ' '                                                                                               +   
                                                   '   Set ' + Case When @PsClave = 'C'   
                                                                    Then 'SAct = SAct + ' + Convert(Nvarchar, @PnImporte) + ' '                             
                                                                    Else 'SAct   = SAct - ' + Convert(Nvarchar, @PnImporte) + ' '                           
                                                                    End   
                             set @w_sql = @w_sql +  '   Where ' + Case When @PsNCta = '00'  
                                                                       Then ' Llave  =   ' + @w_comilla + @PsCta      + @w_comilla + ' '      
                                                                       Else 'Llave  In ( ' + @w_comilla + @PsSubCta   + @w_comilla + ')'   
                                                                       End  
                             Set @w_sql = @w_sql + --'  And   Moneda = ' + @w_comilla + @PsMoneda + @w_comilla + ' '                                                            +  
                                                   --'  And   Niv    = ' + @w_comilla + @w_nivel  + @w_comilla + ' '                                                            +   
                                                   '    And   FecCap = ' + Convert(Nvarchar,@PnIntMes) + ' '                                                                    +   
                                                   ' End '    
                             Begin try   
                                 Execute (@w_sql)  
                             End Try   
                             Begin Catch  
                                  If @@ERROR != 0  
                                    Begin  
                                       Select @w_error      = Error_Number(),  
                                              @w_desc_error = Error_Message()  
  
                                       --Borrar  
            Select @w_sql As w_sql, @PsSubCta As PsSubCta, @w_minIdF As w_minIdF  
            Select * From #tmpFilter Where  Id = @w_minIdF  
            --Borrar  
  
            INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )  
                                 VALUES ('ERROR @PsSubCta ',@w_error, @w_desc_error, getdate());  
  
                                    End  
                             End Catch  
                               
                             If IsNull(@w_error, 0) <> 0  
                                Begin   
                                   Select @PnEstatus = @w_error,  
                                          @PsMensaje = @w_desc_error   
             
           INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )  
                             VALUES ('ERROR 02 @PsSubCta ',@w_error, @w_desc_error, getdate());  
  
                                   Set Xact_Abort Off  
                                   Return  
                                End  
        --  
        --@PsCta  
        --  
                             Set @w_sql =         'If Not Exists  (Select Top 1 1 '                                                                                             +   
                                                  '               From  ' + @PsCatRep + ' '                                                                                     +   
                                                  '               Where Llave ' + Case When @PsNCta = '00'                                                                        
                                                                                       Then ' =   ' + @w_comilla + @PsCta     + @w_comilla + ' '                                     
                                                                                       Else ' In(' + @w_comilla + @PsCta      + @w_comilla + ') '                                 
                                                                                       End  
                             Set @w_sql = @w_sql + --'               And   Moneda = ' + @w_comilla + @PsMoneda + @w_comilla + ' '                                               +   
                                                   -- '               And   Niv    = ' + @w_comilla + @w_nivel  + @w_comilla + ' '                                              +   
                                                   '               And   FecCap = ' + Convert(Nvarchar,@PnIntMes) + ') '                                                        +  
                                                   '   Begin ' + Case When @PsNCta = '00'                                                                                         
                                                                      Then  'Insert Into ' + @PsCatRep + '    (Llave, Moneda, Niv,  SAct,           FecCap) '                   +  
                                                                            'Values( ' + @w_comilla + @PsCta   + @w_comilla + ', ' + @w_comilla + @PsMoneda + @w_comilla + ', ' +   
                                                                            '        0,' + Cast(@PnImporte As Varchar) + ','                                                    +   
                                                                            '        ' + Convert(Nvarchar,@PnIntMes) + ') '                                                       
                                                                      Else  'Insert Into '+ @PsCatRep +'(Llave, Moneda, Niv, SAct, FecCap) '                                    +  
                                                                            'Values(' + @w_comilla + @PsCta + @w_comilla + ','                                                  +   
                                                                            '       ' + @w_comilla + @PsMoneda  + @w_comilla + ', 0, '                                          +                                                                             
  '       ' + Cast(@PnImporte As Varchar) + ',' + Convert(Nvarchar,@PnIntMes) + ') '  
                                                                      End                      
                             Set @w_sql = @w_sql + '   End '                                                                                                                    +  
                                                   'Else '                                                                                                                      +   
                                                   '   Begin '                                                                                                                  +     
                                                   '   Update ' + @PsCatRep + ' '                                                                                               +   
                                                   '   Set ' + Case When @PsClave = 'C'   
                                                                    Then 'SAct = SAct + ' + Convert(Nvarchar, @PnImporte) + ' '                             
                                                                    Else 'SAct   = SAct - ' + Convert(Nvarchar, @PnImporte) + ' '                           
                                                                    End   
                             set @w_sql = @w_sql +  '   Where ' + Case When @PsNCta = '00'  
                                                                       Then ' Llave  =   ' + @w_comilla + @PsCta      + @w_comilla + ' '      
                                                                       Else 'Llave  In ( ' + @w_comilla + @PsCta      + @w_comilla + ')'   
                                                                       End  
                             Set @w_sql = @w_sql + --'  And   Moneda = ' + @w_comilla + @PsMoneda + @w_comilla + ' '                                                            +  
                                                   --'  And   Niv    = ' + @w_comilla + @w_nivel  + @w_comilla + ' '                                                            +   
                                                   '    And   FecCap = ' + Convert(Nvarchar,@PnIntMes) + ' '                                                                    +   
                                                   ' End '   
                             Begin try   
                                 Execute (@w_sql)  
                             End Try   
                             Begin Catch  
                                  If @@ERROR != 0  
                                    Begin  
                                       Select @w_error      = Error_Number(),  
                                              @w_desc_error = Error_Message()  
  
                                       --Borrar  
            Select @w_sql As w_sql, @PsCta As PsCta, @w_minIdF As w_minIdF  
            Select * From #tmpFilter Where  Id = @w_minIdF  
            --Borrar  
  
            INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )  
                                 VALUES ('ERROR @PsCta ',@w_error, @w_desc_error, getdate());  
  
                                    End  
                             End Catch  
                               
                             If IsNull(@w_error, 0) <> 0  
                                Begin   
                                   Select @PnEstatus = @w_error,  
                                          @PsMensaje = @w_desc_error   
             
           INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )  
                             VALUES ('ERROR 02 @PsCta ',@w_error, @w_desc_error, getdate());  
  
                                   Set Xact_Abort Off  
                                   Return  
          End  
           /*Se restructura la consulta para validar una cuenta a la vez [MiguelZamora][ZayraCandia][CarlosUrbina]*/  
  
                                 /**/  
           --                  Begin try   
           --                      Execute (@w_sql)  
           --                  End Try   
           --                  Begin Catch  
           --                       If @@ERROR != 0  
           --                         Begin  
           --                            Select @w_error      = Error_Number(),  
           --                                   @w_desc_error = Error_Message()  
              
           -- INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )  
           --                      VALUES ('ERROR 22',@w_error, @w_desc_error, getdate());  
  
           --                         End  
           --                  End Catch  
                               
           --                  If IsNull(@w_error, 0) <> 0  
           --                     Begin   
           --                        Select @PnEstatus = @w_error,  
           --                               @PsMensaje = @w_desc_error   
             
           --INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )  
           --                  VALUES ('ERROR 23',@w_error, @w_desc_error, getdate());  
  
           --                        Set Xact_Abort Off  
           --                        Return  
           --                     End                                                                               
        PRINT 'Actualiza los saldos de la subcta correspondiente, en el catalogo del mes en curso.'  
                             --Actualiza los saldos de la subcta correspondiente, en el catalogo del mes en curso.  
                             Set @w_sql = 'Update ' + @PsCat + ' '                                                   +    
                                          'Set ' + Case When @PsClave = 'C'   
                                                        Then ' CarExt     = CarExt + ' + Convert(Nvarchar, @PnImporte) + ', '       +   
                                                             ' CarProceso = CarProceso + ' + Convert(Nvarchar, @PnImporte) + ' '    +   
                                                             'Where Moneda   = ' + @w_comilla + @PsMoneda + @w_comilla + ' '           +   
                                                             'And   Niv      = 0 '                                                     +  
                                                             'And   Llave    ' +  Case When @PsNCta = '00'    
                                                                                       Then ' In ( '+ @w_comilla + @PsSubCta   + @w_comilla +' , ' + @w_comilla + @PsCta      + @w_comilla +' ) '    
                                                                                       Else ' In ( '+ @w_comilla + @PsSSSubCta + @w_comilla +' , ' + @w_comilla + @PsSSubCta  + @w_comilla +' , ' +  
                                                                                            '      '+ @w_comilla + @PsSubCta   + @w_comilla +' , ' + @w_comilla + @PsCta      + @w_comilla +' ) '      
                                                                                  End   
                                                        Else ' AboExt      = AboExt + ' + Convert(Nvarchar, @PnImporte) + ', '              +  
                                                             ' AboProceso  = AboProceso + ' + Convert(Nvarchar, @PnImporte) + ' '           +  
                                                             'Where Moneda =  ' + @w_comilla + @PsMoneda + @w_comilla + '  '                   +  
                                                             'And   Niv    =  0  '                                                             +  
                                                             'And   Llave ' + Case When @PsNCta = '00'  
                                                                                   Then ' In( ' + @w_comilla + @PsSubCta + @w_comilla + ', '   +   
                                                             '                                ' + @w_comilla + @PsCta    + @w_comilla + ') '           
                                                                                   Else ' In( ' + @w_comilla + @PsSSSubCta + @w_comilla + ','  +  
                                                             '                                ' + @w_comilla + @PsSSubCta  + @w_comilla + ','  +  
                                                             '                                ' + @w_comilla + @PsSubCta   + @w_comilla + ','  +  
                                                             '                                ' + @w_comilla + @PsCta      + @w_comilla + ')'     
                                                                                   End   
                                                        End   
                               
                             Begin try   
                                 Execute (@w_sql)  
                             End Try   
                             Begin Catch  
                                  If @@ERROR != 0  
                                    Begin  
                                       Select @w_error      = Error_Number(),  
                                              @w_desc_error = Error_Message()  
               
           INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )  
                                VALUES ('ERROR 24',@w_error, @w_desc_error, getdate());   
                                   End  
                             End Catch      
                                     
                             If IsNull(@w_error, 0) <> 0  
                                Begin   
                                   Select @PnEstatus = @w_error,  
                                          @PsMensaje = @w_desc_error   
  
           INSERT INTO Bitacora_CargosAbonos (mensaje, error, descripcion_Error, ultActual )  
                             VALUES ('ERROR 25',@w_error, @w_desc_error, getdate());  
  
                                   Set Xact_Abort Off  
                                   Return  
                                End                             
                               PRINT 'FIN DE LA COMPARACION DE LA CLAVE, CUANDO CUMPLE CON LA CONDICION-- /*   ELSE SI LOS MESES NO SON IGUALES Y NO ES CARGOS    */'  
                                         PRINT 'CUANDO NO ENTRA EN LA CONDICION DE CLAVE-- --El segundo tipo es A corresponde a ABONO.   '  
                         End PRINT 'FIN DE LA COMPARACION DEL MES, CUANDO NO CUMPLE CON LA CONDICION-- '                      
                  
                 Set @w_minIdF += 1   
           
             End       
  
        End  