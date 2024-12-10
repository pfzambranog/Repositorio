If Exists ( Select Top 1 1
            From   Sysobjects
            Where  Uid  = 1
            And    Type = 'U'
            And    Name = 'CatalogoCtasContabElectroTbl')
   Begin
      Drop Table dbo.CatalogoCtasContabElectroTbl
   End
Go

Create Table CatalogoCtasContabElectroTbl
  (id               Integer      Not Null Identity (1, 1),
   CodigoAgrupador  Varchar( 15) Not Null,
   llave            Varchar( 16) Not Null,
   moneda_id        Varchar(  2) Not Null Default '00',
   descripcion      Varchar(200) Not Null,
   nivel            Tinyint      Not Null,
   naturaleza       Char(20) Not Null,
Constraint CatalogoCtasContabElectroPk
Primary Key(id),
Constraint CatalogoCtasContabElectroFk01
Foreign Key (CodigoAgrupador)
References dbo.CodigoAgrupadorSAT(CodigoAgrupador),
Constraint CatalogoCtasContabElectroFk02
Foreign Key (llave, moneda_id)
References dbo.CatalogoConsolidado(numerodecuenta, moneda_id),
Constraint CatalogoCtasContabElectroCk01
Check (naturaleza In ('A', 'D')),
Index CatalogoCtasContabElectroIdx01 Unique (llave, moneda_id),
Index CatalogoCtasContabElectroIdx02 (CodigoAgrupador))
Go

--
-- Comentarios
--

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Catálogo de Cuentas Contables, Contabilidad Electrónica ',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'CatalogoCtasContabElectroTbl'
Go