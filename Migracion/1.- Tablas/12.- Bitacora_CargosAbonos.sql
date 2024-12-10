If Exists ( Select Top 1 1
            From   Sysobjects
            Where  Uid  = 1
            And    Type = 'U'
            And    Name = 'Bitacora_CargosAbonos')
   Begin
      Drop Table dbo.Bitacora_CargosAbonos
   End
Go

Create Table Bitacora_CargosAbonos
  (idBitacora       Integer       Not Null Identity (1, 1),
   mensaje          Varchar(256)  Not Null,
   idError          Integer       Not Null,
   mensajeError     Varchar(512)  Not Null,
   ultactual        Datetime      Not Null Default Getdate(),
   user_id          Varchar(10)       Null,
Constraint Bitacora_CargosAbonosPk
Primary Key(idBitacora))
Go

--
-- Comentarios
--

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Log de Errores en Proceso de Cargos y Abonos',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'Bitacora_CargosAbonos'
Go