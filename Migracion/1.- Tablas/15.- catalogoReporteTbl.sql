If Exists ( Select Top 1 1
            From   SysObjects
            Where  Uid  = 1
            And    Type = 'U'
            And    Name = 'catalogoReporteTbl')
   Begin
      Drop Table dbo.catalogoReporteTbl
   End
Go

Create Table dbo.catalogoReporteTbl
  (Ejercicio       Smallint        Not Null,
   Mes             Tinyint         Not Null,
   Llave           Varchar(16)     Not Null,
   moneda_id       Varchar( 2)     Not Null Default '00',
   nivel           Tinyint         Not Null,
   SAct            Decimal(18, 2)  Not Null Default 0,
   FecCap          Datetime        Not Null Default GetDate(),
Constraint catalogoReportePk
Primary Key (Ejercicio, mes, Llave, moneda_id, nivel))


-- Constraint catalogoReporteFk01
-- Foreign Key (llave, moneda_id)
-- References dbo.CatalogoConsolidado(numerodecuenta, moneda_id))


--
-- Comentarios
--

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Catálogo de Cuentas Contables para Reportes. ',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'catalogoReporteTbl'
Go

If Exists ( Select Top 1 1
            From   SysObjects
            Where  Uid  = 1
            And    Type = 'U'
            And    Name = 'catalogoAuxReporteTbl')
   Begin
      Drop Table dbo.catalogoAuxReporteTbl
   End
Go

Create Table dbo.catalogoAuxReporteTbl
  (Ejercicio       Smallint        Not Null,
   Mes             Tinyint         Not Null,
   Llave           Varchar(16)     Not Null,
   moneda_id       Varchar( 2)     Not Null Default '00',
   nivel           Tinyint         Not Null,
   Sector_id       Varchar( 2)     Not Null,
   Sucursal_id     Integer         Not Null,
   Region_id       Integer         Not Null,
   SAct            Decimal(18, 2)  Not Null Default 0,
   FecCap          Datetime        Not Null Default GetDate(),
Constraint catalogoAuxReportePk
Primary Key (Ejercicio, mes, Llave, Moneda_id, nivel, Sector_id, Sucursal_id, Region_id))


-- Constraint catalogoReporteAuxFk01
-- Foreign Key (llave, moneda_id)
-- References dbo.CatalogoConsolidado(numerodecuenta, moneda_id))

--
-- Comentarios
--

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Catálogo de Auxiliares Contables para Reportes. ',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = 'Table',
                                  @level1name = N'catalogoAuxReporteTbl'
Go




