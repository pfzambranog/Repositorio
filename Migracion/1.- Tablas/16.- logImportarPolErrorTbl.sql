If Exists ( Select Top 1 1
            From   SysObjects
            Where  Uid  = 1
            And    Type = 'U'
            And    Name = 'logImportarPolErrorTbl')
   Begin
      Drop Table dbo.logImportarPolErrorTbl
   End
Go

Create Table dbo.logImportarPolErrorTbl
  (idError         Integer         Not Null  Identity(1, 1),
   Referencia      Varchar(20)     Not Null,
   Fecha_mov       Datetime        Not Null,
   Llave           Varchar(16)     Not Null,
   moneda_id       Varchar( 2)     Not Null Default '00',
   mensajeError    Varchar(500)    Not Null Default Char(32),
   fechaAct        Datetime        Not Null Default GetDate(),
Constraint logImportarPolErrorPk
Primary Key (idError),
Index  clogImportarPolErrorIdx01 (Referencia, Fecha_mov, Llave, moneda_id));

--
-- Comentarios
--

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Log de Errores en Importación de Pólizas.',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'logImportarPolErrorTbl'
Go