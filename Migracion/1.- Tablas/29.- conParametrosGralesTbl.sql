If Exists (Select Top 1 1
           From   Sysobjects
           Where  Uid = 1
           And    Type = 'U'
           And    Name = 'conParametrosGralesTbl')
   Begin
     Drop Table conParametrosGralesTbl
   End
Go

Create Table conParametrosGralesTbl(
    idParametroGral Smallint       Not Null,
    descripcion     Varchar(100)   Null,
    parametroChar   Varchar(150)   Null,
    parametroNumber Numeric(24, 6) Null,
    parametroFecha  Datetime       Null,
    idUsuarioAct    Smallint       Not Null,
    fechaAct        Datetime       Not Null,
    ipAct           Varchar(30)    Null,
    macAddressAct   Varchar(30)    Null,
 Constraint conParametrosGralesPk
 Primary Key (idParametroGral))

--
-- Comentarios
--

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'CódiGo de Parámetro General de Configuración' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'conParametrosGralesTbl',
                                @level2type = 'Column',
                                @level2name = 'idParametroGral'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Descripción de Parámetro General de Configuración' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'conParametrosGralesTbl',
                                @level2type = 'Column',
                                @level2name = 'descripcion'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Parámetro Tipo Char.' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'conParametrosGralesTbl',
                                @level2type = 'Column',
                                @level2name = 'parametroChar'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Parámetro Tipo Numerico.' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'conParametrosGralesTbl',
                                @level2type = 'Column',
                                @level2name = 'parametroNumber'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Parámetro Tipo Fecha.' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'conParametrosGralesTbl',
                                @level2type = 'Column',
                                @level2name = 'parametroFecha'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'CódiGo de Usuario que realizó última actualizacion' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'conParametrosGralesTbl',
                                @level2type = 'Column',
                                @level2name = 'idUsuarioAct'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Fecha de Aactualización del Registro' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'conParametrosGralesTbl',
                                @level2type = 'Column',
                                @level2name = 'fechaAct'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Última Dirección IP desde donde se efectuó la Actualización del Registro' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'conParametrosGralesTbl',
                                @level2type = 'Column',
                                @level2name = 'ipAct'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Última Dirección Mac desde donde se efectuó la Actualización del Registro' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'conParametrosGralesTbl',
                                @level2type = 'Column',
                                @level2name = 'macAddressAct'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'CatáloGo de Parámetros de Generales de Configuración' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'conParametrosGralesTbl'
Go
