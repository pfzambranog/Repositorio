--
-- Script de Generación de tabla de control de importación de pólizas contables.
--

If Exists (Select Top 1 1
           From   sysobjects
           Where  Uid  = 1
           And    Type = 'U'
           And    Name = 'controlImpPolTbl')
   Begin
      Drop table dbo.controlImpPolTbl
   End
Go

Create Table dbo.controlImpPolTbl
(Id_control       Integer       Not Null Identity(1, 1),
 Fecha_Mov        Datetime      Not Null Default Getdate(),
 Polizas_Imp      Integer       Not Null Default 0,
 polizas_no_imp   Integer       Not Null Default 0,
 Constraint controlImpPolPk
 Primary Key (Id_control),
 Index controlImpPolIdx01 (Fecha_Mov));
Go

--
-- Comentarios
--

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Tabla de control de importación de pólizas contables' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'controlImpPolTbl'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Código Único de control de Importación' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'controlImpPolTbl',
                                @level2type = 'Column',
                                @level2name = 'Id_control'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Fecha del proceso de importación' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'controlImpPolTbl',
                                @level2type = 'Column',
                                @level2name = 'Fecha_Mov'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Cantidad de Pólizas Importadas.' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'controlImpPolTbl',
                                @level2type = 'Column',
                                @level2name = 'Polizas_Imp'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Cantidad de Pólizas No Importadas.' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'controlImpPolTbl',
                                @level2type = 'Column',
                                @level2name = 'polizas_no_imp'
Go