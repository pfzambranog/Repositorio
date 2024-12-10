If Exists ( Select Top 1 1
            From   Sysobjects
            Where  Uid  = 1
            And    Type = 'U'
            And    Name = 'AuxiliaresCorporativos')
   Begin
      Drop Table dbo.AuxiliaresCorporativos
   End
Go

Create Table AuxiliaresCorporativos
  (llave            Varchar( 16)  Not Null,
   moneda_id        Varchar(  2)  Not Null Default '00',
   idEstatus        Bit           Not Null Default 1,
   ultactual        Datetime      Not Null Default Getdate(),
   user_id          Varchar(10)       Null,
Constraint AuxiliaresCorporativosPk
Primary Key(llave, moneda_id),
Constraint AuxiliaresCorporativosFk01
Foreign Key (llave, moneda_id)
References dbo.CatalogoConsolidado(numerodecuenta, moneda_id))
Go

--
-- Comentarios
--

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Catálogo de Cuentas Contables Cosporativas',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'AuxiliaresCorporativos'
Go