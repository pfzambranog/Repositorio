--
-- Observación: Script de creación de tabla de Grupos Receptores de Correo.
-- Programador: Pedro Zambrano
-- Fecha:       19-sep-2024.
--

If Exists ( Select Top 1 1
            From   Sysobjects
            Where  Uid = 1
            And    Type = 'U'
            And    Name = 'conGrupoReceptorCorreoDetTbl')
   Begin
      Drop Table dbo.conGrupoReceptorCorreoDetTbl
   End
Go


If Exists ( Select Top 1 1
            From   Sysobjects
            Where  Uid = 1
            And    Type = 'U'
            And    Name = 'conGrupoReceptorCorreoTbl')
   Begin
      Drop Table dbo.conGrupoReceptorCorreoTbl
   End
Go

Create Table dbo.conGrupoReceptorCorreoTbl
  (idGrupo      Integer        Not Null Identity (1, 1),
   codigoGrupo  Varchar(20)    Not Null,
   nombre       Varchar(100)   Not Null,
   idEstatus    Bit            Not Null Default 1,
   idUsuarioAct Varchar(10)    Not Null Default Char(32),
   fechaAct     Datetime       Not Null Default Getdate(),
   ipAct        Varchar(30)        Null Default Char(32),
 Constraint conGrupoReceptorCorreoPk 
 Primary Key (idGrupo),
 Index  conGrupoReceptorCorreoIdx01 Unique (codigoGrupo))
Go

--
-- Comentarios.
--

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Catálogo de Grupo de Receptores de Correo',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conGrupoReceptorCorreoTbl';
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Identificador Único de Grupo de Receptores de Correo',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo', 
                                   @level1type = N'Table',
                                   @level1name = N'conGrupoReceptorCorreoTbl',
                                   @level2type = N'Column',
                                   @level2name = N'idGrupo';
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Código Único de Grupo de Receptores de Correo',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo', 
                                   @level1type = N'Table',
                                   @level1name = N'conGrupoReceptorCorreoTbl',
                                   @level2type = N'Column',
                                   @level2name = N'codigoGrupo';
Go



Execute sys.sp_addextendedproperty @name       = N'MS_Description', 
                                   @value      = N'Nombre del Grupo de Receptores de Correo',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conGrupoReceptorCorreoTbl',
                                   @level2type = N'Column',
                                   @level2name = N'nombre'
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description', 
                                   @value      = N'Identificador del Estatus del Registro. 0 = Inhabilito, 1 = Activo',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conGrupoReceptorCorreoTbl',
                                   @level2type = N'Column',
                                   @level2name = N'idEstatus'
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description', 
                                   @value      = N'Identificador del Último Usuario que Actualizó el Registro',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conGrupoReceptorCorreoTbl',
                                   @level2type = N'Column',
                                   @level2name = N'idUsuarioAct'
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description', 
                                   @value      = N'Última Fecha de Actualización del Registro',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conGrupoReceptorCorreoTbl',
                                   @level2type = N'Column',
                                   @level2name = N'fechaAct'
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description', 
                                   @value      = N'Última Dirección IP desde Donde se Actualizo el Registro.',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conGrupoReceptorCorreoTbl',
                                   @level2type = N'Column',
                                   @level2name = N'ipAct'
Go
