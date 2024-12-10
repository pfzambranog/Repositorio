--
-- Script de Generación de tabla de Relación de importación de pólizas contables.
--

If Exists (Select Top 1 1
           From   sysobjects
           Where  Uid  = 1
           And    Type = 'U'
           And    Name = 'Relacion_Poliza_Interna_Externa')
   Begin
      Drop table dbo.Relacion_Poliza_Interna_Externa
   End
Go
-- Creating table 'Relacion_Poliza_Interna_Externa'

Create Table dbo.Relacion_Poliza_Interna_Externa
   (Referencia          Varchar(20)  Not Null,
    Fecha_Mov           datetime     Not Null,
    Fuentedatos         Varchar(50)  Not Null,
    Referencia_contable Varchar(20)      Null,
    Fecha_Cap           Datetime     Not Null Default Getdate(),
    Usuario             Varchar(10)      Null
Constraint Relacion_Poliza_Interna_ExternaPk
Primary Key Clustered(Referencia, Fecha_Mov, Fuentedatos));
Go

--
-- Comentarios
--

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Tabla Relación de importación de pólizas contables' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'Relacion_Poliza_Interna_Externa'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Referencia Única de la Póliza Origen' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'Relacion_Poliza_Interna_Externa',
                                @level2type = 'Column',
                                @level2name = 'Referencia'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Fecha de la Póliza Origen' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'Relacion_Poliza_Interna_Externa',
                                @level2type = 'Column',
                                @level2name = 'Fecha_Mov'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Descripción del Origen de la Póliza.' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'Relacion_Poliza_Interna_Externa',
                                @level2type = 'Column',
                                @level2name = 'Fuentedatos'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Referencia Única de la Póliza Destino.' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'Relacion_Poliza_Interna_Externa',
                                @level2type = 'Column',
                                @level2name = 'Referencia_contable'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Fecha de la Migración de la Póliza Contable.' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'Relacion_Poliza_Interna_Externa',
                                @level2type = 'Column',
                                @level2name = 'Fecha_Cap'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Código de Usuario que realiza la Migración de la Póliza Contable.' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'Relacion_Poliza_Interna_Externa',
                                @level2type = 'Column',
                                @level2name = 'Usuario'
Go
