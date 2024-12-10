If Exists ( Select Top 1 1
            From   SysObjects
            Where  Uid  = 1
            And    Type = 'U'
            And    Name = 'Control')
   Begin
      Drop Table dbo.Control
   End
Go


Create Table dbo.Control
(Ejercicio    Smallint     Not Null,
 Mes          Tinyint      Not Null,
 idEstatus    Tinyint      Not Null Default 0,
 FechaProceso Datetime     Not Null Default Getdate(),
 usuario      Varchar(10)  Not Null,
 Constraint ControlPk
 Primary Key (ejercicio, mes),
 Constraint ControlFk01
 Foreign Key (ejercicio)
 References dbo.ejercicios (ejercicio),
 Constraint ControlCk01
 Check (idEstatus In (0, 1, 2)));
Go

--
-- Comentarios
--

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Catálogo Control de período de proceso',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'Control'
Go

