--
-- Observación: Script de creación de tabla de detalle de los Grupos Receptores de Correo.
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


Create Table dbo.conGrupoReceptorCorreoDetTbl
  (idGrupo        Integer        Not Null,
   correoReceptor Varchar(250)   Not Null,
   nombre         Varchar(250)   Not Null,
   idEstatus      Bit            Not Null Default 1,
   idUsuarioAct   Varchar(10)    Not Null Default Char(32),
   fechaAct       Datetime       Not Null Default Getdate(),
   ipAct          Varchar(30)        Null Default Char(32),
 Constraint conGrupoReceptorCorreoDetPk
 Primary Key Clustered (idGrupo, CorreoReceptor),
 Constraint  conGrupoReceptorCorreoDetFk01
 Foreign Key(idGrupo)
 References dbo.conGrupoReceptorCorreoTbl (idGrupo)
On Delete Cascade)
Go

--
-- Comentarios
--

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Catálogo Detalle de Grupo de Receptores de Correo',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conGrupoReceptorCorreoDetTbl';
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Identificador Único de Grupo de Receptores de Correo',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conGrupoReceptorCorreoDetTbl',
                                   @level2type = N'Column',
                                   @level2name = N'idGrupo';
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Correo del Receptor de Correo',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conGrupoReceptorCorreoDetTbl',
                                   @level2type = N'Column',
                                   @level2name = N'CorreoReceptor';
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Identificador del Estatus del Registro. 0 = Inactivo, 1 = Activo',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conGrupoReceptorCorreoDetTbl',
                                   @level2type = N'Column',
                                   @level2name = N'idEstatus';
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Identificador del Último Usuario que Actualizó el Registro',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conGrupoReceptorCorreoDetTbl',
                                   @level2type = N'Column',
                                   @level2name = N'idUsuarioAct';
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Última Fecha de Actualización del Registro',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conGrupoReceptorCorreoDetTbl',
                                   @level2type = N'Column',
                                   @level2name = N'fechaAct';
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Última Dirección IP desde Donde se Actualizo el Registro',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conGrupoReceptorCorreoDetTbl',
                                   @level2type = N'Column',
                                   @level2name = N'ipAct';
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'LLave Foránea de Grupo de Correos',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conGrupoReceptorCorreoDetTbl',
                                   @level2type = N'Constraint',
                                   @level2name = N'conGrupoReceptorCorreoDetFk01';
Go
