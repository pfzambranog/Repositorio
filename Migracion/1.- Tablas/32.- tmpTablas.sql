--
-- Script de Generación de tabla de control de importación de datos por fecha.
--

If Exists (Select Top 1 1
           From   sysobjects
           Where  Uid  = 1
           And    Type = 'U'
           And    Name = 'tmpTablasTbl')
   Begin
      Drop table dbo.tmpTablasTbl
   End
Go
-- Creating table 'tmpTablasTbl'

Create Table dbo.tmpTablasTbl
   (secuencia           Integer      Not Null Identity (1, 1),
    tabla               Sysname      Not Null,
    idEstatus           Bit          Not Null Default 1,
    fechaAct            Datetime     Not Null Default Getdate()
Constraint tmpTablasPk
Primary Key Clustered(secuencia),
Index  tmpTablasIdx01 Unique (tabla));
Go

--
-- Comentarios
--

Execute sys.sp_addextendedproperty @name       = 'MS_Description',
                                   @value      = 'Tabla Relación de control de importación de datos por fecha' ,
                                   @level0type = 'Schema',
                                   @level0name = 'dbo',
                                   @level1type = 'Table',
                                   @level1name = 'tmpTablasTbl'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description',
                                   @value      = 'Secuencia Única del registro.' ,
                                   @level0type = 'Schema',
                                   @level0name = 'dbo',
                                   @level1type = 'Table',
                                   @level1name = 'tmpTablasTbl',
                                   @level2type = 'Column',
                                   @level2name = 'secuencia'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description',
                                   @value      = 'Nombre de la Tabla a Controlar.' ,
                                   @level0type = 'Schema',
                                   @level0name = 'dbo',
                                   @level1type = 'Table',
                                   @level1name = 'tmpTablasTbl',
                                   @level2type = 'Column',
                                   @level2name = 'tabla'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description',
                                   @value      = 'Identificador del Estatus del Registro. 1 Habbilitado, 2 Deshabilitado' ,
                                   @level0type = 'Schema',
                                   @level0name = 'dbo',
                                   @level1type = 'Table',
                                   @level1name = 'tmpTablasTbl',
                                   @level2type = 'Column',
                                   @level2name = 'idEstatus'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Fecha de la Migración de la Póliza Contable.' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'tmpTablasTbl',
                                @level2type = 'Column',
                                @level2name = 'fechaAct'
Go


