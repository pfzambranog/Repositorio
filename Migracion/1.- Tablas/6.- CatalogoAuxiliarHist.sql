If Exists ( Select Top 1 1
            From   Sysobjects
            Where  Uid  = 1
            And    Type = 'U'
            And    Name = 'CatalogoAuxiliarHist')
   Begin
      Drop Table dbo.CatalogoAuxiliarHist
   End
Go

Create Table dbo.CatalogoAuxiliarHist
   (Llave        Varchar( 16)  Not Null,
    Moneda       Varchar(  2)  Not Null Default '00',
    Niv          Tinyint       Not Null,
    Sector_id    Varchar(  2)      Null,
    Sucursal_id  Integer       Not Null,
    Region_id    Integer       Not Null,
    Descrip      Varchar(100)  Not Null,
    SAnt         Decimal(19,4)     Null,
    Car          Decimal(19,4)     Null,
    Abo          Decimal(19,4)     Null,
    SAct         Decimal(19,4)     Null,
    FecCap       Datetime          Null  Default Getdate(),
    CarProceso   Decimal(19,4)     Null,
    AboProceso   Decimal(19,4)     Null,
    SAntProceso  Decimal(19,4)     Null,
    CarExt       Decimal(19,4)     Null,
    AboExt       Decimal(19,4)     Null,
    SProm        Decimal(19,4)     Null,
    SPromAnt     Decimal(19,4)     Null,
    SProm2       Decimal(19,4)     Null,
    SProm2Ant    Decimal(19,4)     Null,
    ejercicio    Smallint      Not Null,
    mes          Tinyint       Not Null,
Constraint CatalogoAuxiliarHistPK
Primary Key Clustered (Llave, Moneda, Sucursal_id, Region_id, ejercicio, mes),
Index catalogoAuxiliarHistIdx01 (ejercicio, mes),
Constraint CatalogoAuxiliarHistFk01
Foreign Key (Llave, Moneda)
References dbo.CatalogoConsolidado(numerodecuenta, moneda_id),
Constraint CatalogoAuxiliarHistFk02
Foreign Key (Sucursal_id, Region_id)
References dbo.Departamento_o_Sucursal(Sucursal_id, Region_id));
Go

--
-- Comentarios
--

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de Cuentas Auxiliares Contables',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'CatalogoAuxiliarHist'
Go