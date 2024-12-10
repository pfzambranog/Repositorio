If Exists ( Select Top 1 1
            From   sysObjects
            Where  Uid  = 1
            And    Type = 'U'
            And    Name = 'CatAuxErrorMgrTbl')
   Begin
      Drop Table dbo.CatAuxErrorMgrTbl
   End
Go

Create Table dbo.CatAuxErrorMgrTbl
(Secuencia        Integer      Not Null Identity (1, 1) Primary Key,
 TablaOrigen      Sysname      Not Null,
 Ejercicio        Integer      Not Null,
 mes              Integer      Not Null,
 llave            Varchar( 16)     Null,
 Descripcion      Varchar(100)     Null)
 Go

Create Unique Index CatAuxErrorMgrIdx01 On CatAuxErrorMgrTbl (Secuencia);

--
-- Comentarios
--

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Catálogo de Auxiliares con Error en Migración.',
                                  @level0type = 'SCHEMA',
                                  @level0name = N'dbo',
                                  @level1type = 'TABLE',
                                  @level1name = N'CatAuxErrorMgrTbl'
Go
