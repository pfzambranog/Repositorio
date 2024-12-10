If Exists ( Select Top 1 1
            From   Sysobjects
            Where  Uid  = 1
            And    Type = 'U'
            And    Name = 'ControlReprocesoTbl')
   Begin
      Drop Table dbo.ControlReprocesoTbl
   End
Go

Create Table dbo.ControlReprocesoTbl
(Ejercicio      Smallint    Not Null,
 Mes            Tinyint     Not Null,
 UserId         Varchar(30) Not Null,
 FechaInicio    Datetime    Not Null,
 FechaFin       Datetime        Null,
 Cantidad       Integer     Not Null Default 0,
 Actualizado    Bit         Not Null Default 0,
 FechaCaptura   Datetime    Not Null Default Getdate(),
 Constraint ControlReprocesoPk
 Primary Key (Ejercicio, Mes))
Go

--
-- Comentarios
--

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Tabla de Control de Reprocesos',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'ControlReprocesoTbl'
Go