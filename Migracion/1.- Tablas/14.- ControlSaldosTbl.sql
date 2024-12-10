If Exists ( Select Top 1 1
            From   Sysobjects
            Where  Uid  = 1
            And    Type = 'U'
            And    Name = 'ControlSaldosTbl')
   Begin
      Drop Table dbo.ControlSaldosTbl
   End
Go

Create Table dbo.ControlSaldosTbl
(Ejercicio      Smallint    Not Null,
 Mes            Tinyint     Not Null,
 UserId         Varchar(30) Not Null,
 FechaInicio    Datetime    Not Null,
 FechaFin       Datetime        Null,
 Cantidad       Integer     Not Null Default 0,
 Actualizado    Bit         Not Null Default 0,
 FechaCaptura   Datetime    Not Null Default Getdate(),
 Constraint ControlSaldosPk
 Primary Key (Ejercicio, Mes))
Go

--
-- Comentarios
--

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Control de Saldos por Ejercicio y mes',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'ControlSaldosTbl'
Go