If Exists ( Select Top 1 1
            From   Sysobjects
            Where  Uid  = 1
            And    Type = 'U'
            And    Name = 'XmlPoliza')
   Begin
      Drop Table dbo.XmlPoliza
   End
Go

Create Table XmlPoliza
  (idXml            Integer       Not Null Identity (1, 1),
   XmlPoliza        Xml           Not Null,
   NombreArchivo    Sysname       Not Null,
   ultactual        Datetime      Not Null Default Getdate(),
   user_id          Varchar(10)       Null,
Constraint XmlPolizaPk
Primary Key(idXml))
ON [Primary] Textimage_on [Primary]
Go

--
-- Comentarios
--

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Control de XML para Póliza COntable Electrónica',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'XmlPoliza'
Go