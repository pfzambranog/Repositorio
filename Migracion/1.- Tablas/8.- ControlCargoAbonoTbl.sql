/****** Object:  Table dbo.ControlCargoAbonoTbl    Script Date: 31/07/2024 12:145:03 p. m. ******/
Set ansi_nulls        On
Set quoted_identifier On
Set nocount           On

If Object_id(N'dbo.ControlCargoAbonoTbl', 'U') Is Not Null
   Begin
      Drop Table dbo.ControlCargoAbonoTbl;
   End

Create Table dbo.ControlCargoAbonoTbl
(consecutivo     Integer     Not Null Identity(1, 1),
 Ejercicio       Smallint    Not Null,
 Mes             Tinyint     Not Null,
 Bloqueado       Bit         Not Null Default 0,
Constraint ControlCargoAbonoPk
Primary Key (consecutivo),
Index ControlCargoAbonoIdx01 Unique (ejercicio, mes));

Go

--
-- Comentarios
--

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Tabla de Control de Cargos y Abonos',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'ControlCargoAbonoTbl'
Go