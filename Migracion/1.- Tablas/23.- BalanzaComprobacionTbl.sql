If Exists ( Select Top 1 1
            From   SysObjects
            Where  Uid  = 1
            And    Type = 'U'
            And    Name = 'BalanzaComprobacionTbl')
   Begin
      Drop Table dbo.BalanzaComprobacionTbl
   End
Go

Create Table dbo.BalanzaComprobacionTbl
(idBalanza      Integer        Not Null Identity(1, 1),
 llave          Varchar( 16)   Not Null,
 moneda_id      Varchar(  2)   Not Null Default '00',
 Descrip        Varchar(256)   Not Null,
 region_id      Integer        Not Null,
 sucursal_id    Integer        Not Null,
 saldo_ant      Decimal(18, 2) Not Null Default 0.00,
 cargos         Decimal(18, 2) Not Null Default 0.00,
 abonos         Decimal(18, 2) Not Null Default 0.00,
 saldo_actual   Decimal(18, 2) Not Null Default 0.00,
 Ejercicio      Smallint           Null,
 mes            Tinyint            Null,
Constraint BalanzaComprobacionPk
Primary Key (idBalanza),
Index  BalanzaComprobacionIdx01(Llave, Moneda_id, Sucursal_id, Region_id, ejercicio, mes),
Constraint BalanzaComprobacionFk01
Foreign Key(llave, moneda_id)
References dbo.catalogoConsolidado(numerodecuenta, moneda_id),
Constraint BalanzaComprobacionFk02
Foreign Key (Sucursal_id, Region_id)
References dbo.Departamento_o_Sucursal(Sucursal_id, Region_id));
Go

--
-- Comentarios
--

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Catálogo del Balance de Comprobación.',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'BalanzaComprobacionTbl'
Go