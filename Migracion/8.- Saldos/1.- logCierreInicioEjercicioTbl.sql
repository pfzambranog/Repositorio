--
-- Programador: Pedro Zambrano
-- Fecha:       17-sep-2024.
-- Observación: Script de creación de tabla de seguimiento al proceso de cierre e inicio de ejercicio.
--

If Exists ( Select Top 1 1
            From   Sysobjects
            Where  Uid = 1
            And    Type = 'U'
            And    Name = 'logCierreInicioEjercicioTbl')
   Begin
      Drop Table dbo.logCierreInicioEjercicioTbl
   End
Go

Create Table dbo.logCierreInicioEjercicioTbl
(idLog          Integer      Not Null Identity (1, 1),
 Ejercicio      Smallint     Not Null,
 mes            Tinyint      Not Null,
 descripcion    Varchar(100) Not Null,
 idError        Integer      Not Null Default 0,
 mensajeError   Varchar(250) Not Null Default Char(32),
 usuario        Varchar( 10) Not Null Default Char(32),
 fechaAct       Datetime     Not Null Default Getdate(),
 ipAct          Varchar( 30)     Null Default Char(32),
 Constraint     logCierreInicioEjercicioPk
 Primary Key (idLog),
 Index logCierreInicioEjercicioIdx01 (Ejercicio, mes));
Go

--
-- Comentarios
--

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Tabla de seguimiento al proceso de cierre e inicio de ejercicio.',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'logCierreInicioEjercicioTbl'
Go

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Identificador único del seguimiento de proceso.',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'logCierreInicioEjercicioTbl',
                                  @level2type = 'Column',
                                  @level2name = N'idLog'
Go

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Identificador del Ejercicio en proceso.',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'logCierreInicioEjercicioTbl',
                                  @level2type = 'Column',
                                  @level2name = N'Ejercicio'
Go

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Identificador del Mes en proceso.',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'logCierreInicioEjercicioTbl',
                                  @level2type = 'Column',
                                  @level2name = N'mes'
Go

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Descripción de la secuencia de proceso.',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'logCierreInicioEjercicioTbl',
                                  @level2type = 'Column',
                                  @level2name = N'descripcion'
Go

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Identificador del error presentado en la secuencia del proceso.',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'logCierreInicioEjercicioTbl',
                                  @level2type = 'Column',
                                  @level2name = N'idError'
Go

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Mensaje de error presentado en la secuencia del proceso.',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'logCierreInicioEjercicioTbl',
                                  @level2type = 'Column',
                                  @level2name = N'mensajeError'
Go

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Fecha de la actualización del registro.',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'logCierreInicioEjercicioTbl',
                                  @level2type = 'Column',
                                  @level2name = N'fechaAct'
Go

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Identificador del Usuario que realizó el proceso',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'logCierreInicioEjercicioTbl',
                                  @level2type = 'Column',
                                  @level2name = N'usuario'
Go

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Dirección IP desde donde se realizó la actualización.',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'logCierreInicioEjercicioTbl',
                                  @level2type = 'Column',
                                  @level2name = N'ipAct'
Go
