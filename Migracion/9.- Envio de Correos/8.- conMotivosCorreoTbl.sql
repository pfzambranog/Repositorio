--
-- Observación: Script de creación de tabla de Motivos de Correo.
-- Programador: Pedro Zambrano
-- Fecha:       19-sep-2024.
--

If Exists ( Select Top 1 1
            From   Sysobjects
            Where  Uid = 1
            And    Type = 'U'
            And    Name = 'conMotivosCorreoTbl')
   Begin
      Drop Table dbo.conMotivosCorreoTbl
   End
Go

Create Table dbo.conMotivosCorreoTbl
  (idMotivoCorreo        Integer            Not Null Identity (1, 1),
   codigoMotivoCorreo    Varchar(   30)     Not Null,
   descripcion           Varchar(  100)     Not Null,
   titulo                Varchar( 1000)         Null,
   cuerpo                Nvarchar( Max)         Null,
   html                  Nvarchar( Max)         Null,
   URL                   Varchar( 1000)         Null,
   idEstatus             Bit                Not Null Default 1,
   idUsuarioAct          Varchar(   10)     Not Null,
   fechaAct              Datetime           Not Null Default Getdate(),
   ipAct                 Varchar(   30)         Null,
 Constraint conMotivosCorreoPk
 Primary Key Clustered (idMotivoCorreo),
 Index conMotivosCorreoIdx01 Unique (codigoMotivoCorreo));
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Catálogo de Configuración de Motivos de Emisión de Correos.',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conMotivosCorreoTbl';
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Identificador Único de Motivo de Emisión de Correo' ,
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conMotivosCorreoTbl',
                                   @level2type = N'Column',
                                   @level2name = N'idMotivoCorreo'
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Código Único de Motivo de Emisión de Correo',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conMotivosCorreoTbl',
                                   @level2type = N'Column',
                                   @level2name = N'codigoMotivoCorreo'
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Descripción del Motivo de Emisión de Correo',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conMotivosCorreoTbl',
                                   @level2type = N'Column',
                                   @level2name = N'descripcion'
Go


Execute sys.sp_addextendedproperty @name       = N'MS_Description', 
                                   @value      = N'Titulo del Correo',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conMotivosCorreoTbl',
                                   @level2type = N'Column',
                                   @level2name = N'titulo'
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Texto del Correo',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conMotivosCorreoTbl',
                                   @level2type = N'Column',
                                   @level2name = N'cuerpo'
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Texto del Correo  en Formato HTML',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conMotivosCorreoTbl',
                                   @level2type = N'Column',
                                   @level2name = N'html';
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Dirección URL que se requiere llamar.',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conMotivosCorreoTbl',
                                   @level2type = N'Column',
                                   @level2name = N'URL';
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description', 
                                   @value      = N'Identificador del Estatus del Registro. 0 = Inhabilito, 1 = Activo',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conMotivosCorreoTbl',
                                   @level2type = N'Column',
                                   @level2name = N'idEstatus'
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description', 
                                   @value      = N'Identificador del Último Usuario que Actualizó el Registro',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conMotivosCorreoTbl',
                                   @level2type = N'Column',
                                   @level2name = N'idUsuarioAct'
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description', 
                                   @value      = N'Última Fecha de Actualización del Registro',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conMotivosCorreoTbl',
                                   @level2type = N'Column',
                                   @level2name = N'fechaAct'
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description', 
                                   @value      = N'Última Dirección IP desde Donde se Actualizo el Registro.',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conMotivosCorreoTbl',
                                   @level2type = N'Column',
                                   @level2name = N'ipAct'
Go


