Create Or Alter Trigger dbo.TrinscatGeneralesTbl  
On     dbo.catGeneralesTbl  
After Insert, Update  
As  
  
Declare   
  @w_tabla               Sysname,  
  @w_columna             Sysname,  
  @w_id                  Integer  
  
Begin  
     
   Select  @w_tabla           = tabla,  
           @w_columna         = columna  
   From   Inserted  
  
   Select @w_id = id  
   From   Sysobjects  
   Where  Uid  = 1  
   And    Type = 'U'  
   And    Name = @w_tabla  
   If @@Rowcount = 0  
      Begin  
         Raiserror ('El Código de la Tabla Seleccionada no es Válido.', 16, 1)       
         Rollback Transaction  
         Return  
      End  
  
   If Not Exists ( Select Top 1 1  
                   From   Sys.Columns  
                   Where  Object_id = @w_id  
                   And    Name      = @w_columna)  
      Begin  
         Raiserror ('El Código de la Columna Seleccionada no es Válido para a Tabla Seleccionada.', 16, 1)       
         Rollback Transaction  
      End  
  
  Return  
End  
Go

--
-- Comentarios.
--

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Valida el registro a actualizar en la tabla catGeneralesTbl.',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = N'Table',
                                  @level1name = N'catGeneralesTbl',
                                  @level2type = 'Trigger',
                                  @level2name = N'TrinscatGeneralesTbl'