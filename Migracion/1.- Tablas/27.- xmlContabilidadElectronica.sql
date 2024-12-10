If Exists ( Select Top 1 1
            From   Sysobjects
            Where  Uid  = 1
            And    Type = 'U'
            And    Name = 'xmlContabilidadElectronica')
   Begin
      Drop Table dbo.xmlContabilidadElectronica
   End
Go

Create Table xmlContabilidadElectronica
  (idXml            Integer       Not Null Identity (1, 1),
   xmlEnvio         Xml           Not Null,
   textEnvio        Varchar(Max)  Not Null,
   tipo             Integer       Not Null,
   NombreArchivo    Sysname       Not Null,
   ultactual        Datetime      Not Null Default Getdate(),
   user_id          Varchar(10)       Null,
Constraint xmlContabilidadElectronicaPk
Primary Key(idXml))
ON [Primary] Textimage_on [Primary]
Go

--
-- Comentarios
--

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Control de XML para contabilidad electrónica',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'xmlContabilidadElectronica'
Go