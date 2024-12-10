If Exists ( Select Top 1 1
            From   SysObjects
            Where  Uid  = 1
            And    Type = 'U'
            And    Name = 'relacion_cuenta_centro_costos')
   Begin
      Drop Table dbo.relacion_cuenta_centro_costos
   End
Go

Create Table dbo.relacion_cuenta_centro_costos
(idCuenta        Integer       Not Null Identity(1, 1),
 cuenta          Varchar(16)   Not Null,
 moneda_id       Varchar( 2)   Not Null Default '00',
 centro_costos   Integer       Not Null,
Constraint relacion_cuenta_centro_costosPk
Primary Key (idCuenta),
Index relacion_cuenta_centro_costosIdx01 Unique (cuenta, centro_costos),
Constraint relacion_cuenta_centro_costosFk01
Foreign Key (centro_costos)
References dbo.Area_o_Region(Region_id))
Go

--
-- Comentarios
--

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Catálogo de relación de cuentas contables en centros de costos.',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'relacion_cuenta_centro_costos'
Go


