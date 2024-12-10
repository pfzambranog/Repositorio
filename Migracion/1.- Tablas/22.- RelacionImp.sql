If Exists ( Select Top 1 1
            From   SysObjects
            Where  Uid  = 1
            And    Type = 'U'
            And    Name = 'RelacionImp')
   Begin
      Drop Table dbo.RelacionImp
   End
Go

Create Table dbo.RelacionImp
(idRelacion        Integer        Not Null Identity (1, 1),
 Referencia        Varchar( 20)   Not Null,
 Fecha_Mov         datetime       Not Null,
 Fecha_Cap         Datetime       Not Null,
 NewReferencia     Varchar( 20)   Not Null,
 Usuario           Varchar( 10)   Not Null,
 FuenteDatos       Varchar(250)   Not Null Default Char(32),
 FechaImportacion  Datetime       Not Null Default Getdate(),
 Ejercicio         Smallint           Null,
 mes               Tinyint            Null,
Constraint RelacionImpPk
Primary Key (idRelacion),
Index RelacionImpIdx01 (Referencia, fecha_mov, ejercicio, mes));
Go

--
-- Comentarios
--

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Catálogo de relación de importación de pólizas contables.',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'RelacionImp'
Go

