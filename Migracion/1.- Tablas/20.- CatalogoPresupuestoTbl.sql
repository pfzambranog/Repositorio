If Exists ( Select Top 1 1
            From   SysObjects
            Where  Uid  = 1
            And    Type = 'U'
            And    Name = 'CatalogoPresupuestoTbl')
   Begin
      Drop Table dbo.CatalogoPresupuestoTbl
   End
Go

Create Table dbo.CatalogoPresupuestoTbl
(Ejercicio          Smallint       Not Null,
 Llave              Varchar(16)    Not Null,
 moneda_id          Varchar( 2)    Not Null Default '00',
 Sector_id          Integer        Not Null,
 Sucursal_id        Integer        Not Null,
 Region_id          Integer        Not Null,
 Descripcion        Varchar(100)   Not Null,
 mes_01             Decimal(18, 2) Not Null Default 0.00,
 mes_02             Decimal(18, 2) Not Null Default 0.00,
 mes_03             Decimal(18, 2) Not Null Default 0.00,
 mes_04             Decimal(18, 2) Not Null Default 0.00,
 mes_05             Decimal(18, 2) Not Null Default 0.00,
 mes_06             Decimal(18, 2) Not Null Default 0.00,
 mes_07             Decimal(18, 2) Not Null Default 0.00,
 mes_08             Decimal(18, 2) Not Null Default 0.00,
 mes_09             Decimal(18, 2) Not Null Default 0.00,
 mes_10             Decimal(18, 2) Not Null Default 0.00,
 mes_11             Decimal(18, 2) Not Null Default 0.00,
 mes_12             Decimal(18, 2) Not Null Default 0.00,
Constraint CatalogoPresupuestoPk
Primary Key(ejercicio, Llave, moneda_id),
Constraint CatalogoPresupuestoFk01
Foreign Key (ejercicio)
References dbo.Ejercicios_Presupuesto(ejercicio),
Constraint CatalogoPresupuestoFk02
Foreign Key (Llave, moneda_id)
References dbo.CatalogoConsolidado(numerodecuenta, moneda_id))
Go

--
-- Comentarios
--

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Catálogo de cuentas contables a presupuestar por ejercicio.',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'CatalogoPresupuestoTbl'
Go