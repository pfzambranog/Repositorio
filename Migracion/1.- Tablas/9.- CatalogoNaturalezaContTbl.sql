If Exists ( Select Top 1 1
            From   Sysobjects
            Where  Uid  = 1
            And    Type = 'U'
            And    Name = 'CatalogoNaturalezaContTbl')
   Begin
      Drop Table dbo.CatalogoNaturalezaContTbl
   End
Go

Create Table CatalogoNaturalezaContTbl
  (Naturaleza_id    Varchar( 2) Not Null,
   nom_naturaleza   Varchar(80) Not Null,
   rango_id         Varchar( 2) Not Null,
   rango            Varchar(80) Not Null,
   llaveinicila     Varchar( 4) Not Null,
   llavefinal       Varchar( 4) Not Null,
   tipoCuenta       Varchar(20) Not Null,
   llave            Varchar(16) Not Null,
   moneda_id        Varchar( 2) Not Null,
Constraint CatalogoNaturalezaContFk01
Foreign Key (Naturaleza_id)
References dbo.Naturaleza_Cuentas(Naturaleza_id),
Constraint CatalogoNaturalezaContFk02
Foreign Key (rango_id)
References dbo.Rangos(rango_id),
Constraint CatalogoNaturalezaContFk03
Foreign Key (llave, moneda_id)
References dbo.CatalogoConsolidado(numerodecuenta, moneda_id),
Constraint CatalogoNaturalezaContCk01
Check (tipoCuenta In ('Acreedora', 'Deudora')),
Index CatalogoNaturalezaContIdx01 Unique (llave, moneda_id),
Index CatalogoNaturalezaContIdx02 (Naturaleza_id, nom_naturaleza))
Go

--
-- Comentarios
--

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Catálogo de Naturaleza de la Cuenta Contable',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'CatalogoNaturalezaContTbl'
Go