If Exists ( Select Top 1 1
            From   SysObjects
            Where  Uid  = 1
            And    Type = 'U'
            And    Name = 'MontoDepreciacionMensual')
   Begin
      Drop Table dbo.MontoDepreciacionMensual
   End
Go

Create Table dbo.MontoDepreciacionMensual
(ID_Depreciacion    Integer        Not Null Identity(1, 1),
 ID_Clase           Integer        Not Null,
 ID_centro_costo    Integer        Not Null,
 Bursa              Integer        Not Null,
 MontoDepreciacion  Decimal(20, 2) Not Null Default 0,
 Ejercicio          Smallint       Not Null,
 Mes                Tinyint        Not Null,
 ultActual          Datetime       Not Null Default Getdate(),
 Constraint MontoDepreciacionMensualPK
 Primary Key(ID_Depreciacion),
 Index MontoDepreciacionMensualIdx01 (ID_Clase, ID_centro_costo, Bursa, Ejercicio, Mes));
Go

--
-- Comentarios
--

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Tabla de control de depreciación por clase, centro de costo.',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'MontoDepreciacionMensual'
Go