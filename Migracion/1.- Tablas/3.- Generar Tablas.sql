
--
-- Database : Generar Tablas en Nueva Base de datos
-- Fecha:     07/24/2024
-- Genera:    Pedro Zambrano
-- --------------------------------------------------

-- --------------------------------------------------
-- Dropping existing Foreign Key constraints
-- --------------------------------------------------

If Object_id(N'dbo.FK_ catPaisesFk01', 'F') Is Not Null
    Alter Table dbo.catPaisesTbl Drop Constraint FK_catPaisesFk01;
Go

-- CatalogoAuxiliar

If Object_id(N'dbo.FK_CatalogoAuxiliarFk01', 'F') Is Not Null
    Alter Table dbo.CatalogoAuxiliar Drop Constraint FK_CatalogoAuxiliarFk01;
Go

If Object_id(N'dbo.FK_CatalogoAuxiliarFk02', 'F') Is Not Null
    Alter Table dbo.CatalogoAuxiliar Drop Constraint FK_CatalogoAuxiliarFk02;
Go

If Object_id(N'dbo.FK_CatalogoAuxiliarFk03', 'F') Is Not Null
    Alter Table dbo.CatalogoAuxiliar Drop Constraint FK_CatalogoAuxiliarFk03;
Go

-- CatalogoAuxiliarCierre

If Object_id(N'dbo.Fk01CatalogoAuxiliarCierre', 'F') Is Not Null
    Alter Table dbo.CatalogoAuxiliarCierre Drop Constraint Fk01CatalogoAuxiliarCierre;
Go

If Object_id(N'dbo.Fk02CatalogoAuxiliarCierre', 'F') Is Not Null
    Alter Table dbo.CatalogoAuxiliarCierre Drop Constraint Fk01CatalogoAuxiliarCierre;
Go

If Object_id(N'dbo.Fk03CatalogoAuxiliarCierre', 'F') Is Not Null
    Alter Table dbo.CatalogoAuxiliarCierre Drop Constraint Fk01CatalogoAuxiliarCierre;
Go


-- CatalogoAuxiliarCierre

If Object_id(N'dbo.CatalogoAuxiliarCierreFk01', 'F') Is Not Null
    Alter Table dbo.CatalogoAuxiliarCierreTbl Drop Constraint CatalogoAuxiliarCierreFk01;
Go

If Object_id(N'dbo.CatalogoAuxiliarCierreFk02', 'F') Is Not Null
    Alter Table dbo.CatalogoAuxiliarCierreTbl Drop Constraint CatalogoAuxiliarCierreFk02;
Go

If Object_id(N'dbo.CatalogoAuxiliarCierreFk03', 'F') Is Not Null
    Alter Table dbo.CatalogoAuxiliarCierreTbl Drop Constraint CatalogoAuxiliarCierreFk03;
Go

--

If Object_id(N'dbo.FK_catalogoConsolidadoFk01', 'F') Is Not Null
    Alter Table dbo.CatalogoConsolidado Drop Constraint FK_catalogoConsolidadoFk01;
Go

-- Catalogo

If Object_id(N'dbo.FK_CatalogoFk01', 'F') Is Not Null
    Alter Table dbo.Catalogo Drop Constraint FK_CatalogoFk01;
Go

If Object_id(N'dbo.FK_CatalogoFk02', 'F') Is Not Null
    Alter Table dbo.Catalogo Drop Constraint FK_CatalogoFk02;
Go


-- CatalogocierreTbl

If Object_id(N'dbo.CatalogocierreFk01', 'F') Is Not Null
    Alter Table dbo.CatalogocierreTbl Drop Constraint CatalogocierreFk01;
Go

If Object_id(N'dbo.CatalogocierreFk02', 'F') Is Not Null
    Alter Table dbo.CatalogocierreTbl Drop Constraint CatalogocierreFk02;
Go

--

If Object_id(N'dbo.FK_CatAuxExternoFk01', 'F') Is Not Null
    Alter Table dbo.CatAuxExterno Drop Constraint FK_CatAuxExternoFk01;
Go
If Object_id(N'dbo.FK_CatAuxExternoFk04', 'F') Is Not Null
    Alter Table dbo.CatAuxExterno Drop Constraint FK_CatAuxExternoFk04;
Go
If Object_id(N'dbo.FK_catCiudadesFk01', 'F') Is Not Null
    Alter Table dbo.catCiudadesTbl Drop Constraint FK_catCiudadesFk01;
Go
If Object_id(N'dbo.FK_catEstadosFk01', 'F') Is Not Null
    Alter Table dbo.catEstadosTbl Drop Constraint FK_catEstadosFk01;
Go
If Object_id(N'dbo.FK_ControlAuxiliarCCFk01', 'F') Is Not Null
    Alter Table dbo.ControlAuxiliarCC Drop Constraint FK_ControlAuxiliarCCFk01;
Go

If Object_id(N'dbo.FK_ControlPolizaFk01', 'F') Is Not Null
    Alter Table dbo.ControlPoliza Drop Constraint FK_ControlPolizaFk01;
Go

--

If Object_id(N'dbo.FK_Cuentas_predeterminadasFk01', 'F') Is Not Null
    Alter Table dbo.Cuentas_predeterminadas Drop Constraint FK_Cuentas_predeterminadasFk01;
Go

If Object_id(N'dbo.FK_Cuentas_predeterminadasFk02', 'F') Is Not Null
    Alter Table dbo.Cuentas_predeterminadas Drop Constraint FK_Cuentas_predeterminadasFk02;
Go

--

If Object_id(N'dbo.FK_Departamento_o_SucursalFk01', 'F') Is Not Null
    Alter Table dbo.Departamento_o_Sucursal Drop Constraint FK_Departamento_o_SucursalFk01;
Go
If Object_id(N'dbo.FK__PolizaCap__Regio__2FBA0BF1', 'F') Is Not Null
    Alter Table dbo.PolizaCaptura Drop Constraint FK__PolizaCap__Regio__2FBA0BF1;
Go
--
If Object_id(N'dbo.FK_Grupo_Area_o_Region_detalleFk01', 'F') Is Not Null
    Alter Table dbo.Grupo_Area_o_Region_detalle Drop Constraint FK_Grupo_Area_o_Region_detalleFk01;
Go
If Object_id(N'dbo.FK_Grupo_Area_o_Region_detalleFk02', 'F') Is Not Null
    Alter Table dbo.Grupo_Area_o_Region_detalle Drop Constraint FK_Grupo_Area_o_Region_detalleFk02;
Go
--

If Object_id(N'dbo.FK_MovDiaFk01', 'F') Is Not Null
    Alter Table dbo.MovDia Drop Constraint FK_MovDiaFk01;
Go
If Object_id(N'dbo.FK_MovDiaFk02', 'F') Is Not Null
    Alter Table dbo.MovDia Drop Constraint FK_MovDiaFk02;
Go
If Object_id(N'dbo.FK_MovDiaFk03', 'F') Is Not Null
    Alter Table dbo.MovDia Drop Constraint FK_MovDiaFk03;
Go
If Object_id(N'dbo.FK_MovDiaFk04', 'F') Is Not Null
    Alter Table dbo.MovDia Drop Constraint FK_MovDiaFk04;
Go
If Object_id(N'dbo.FK_MovDiaFk05', 'F') Is Not Null
    Alter Table dbo.MovDia Drop Constraint FK_MovDiaFk05;
Go

If Object_id(N'dbo.FK_MovimientosCapturaFk01', 'F') Is Not Null
    Alter Table dbo.MovimientosCaptura Drop Constraint FK_MovimientosCapturaFk01;
Go
If Object_id(N'dbo.FK_MovimientosCapturaFk02', 'F') Is Not Null
    Alter Table dbo.MovimientosCaptura Drop Constraint FK_MovimientosCapturaFk02;
Go
If Object_id(N'dbo.FK_MovimientosCapturaFk03', 'F') Is Not Null
    Alter Table dbo.MovimientosCaptura Drop Constraint FK_MovimientosCapturaFk03;
Go
If Object_id(N'dbo.FK_MovimientosCapturaFk04', 'F') Is Not Null
    Alter Table dbo.MovimientosCaptura Drop Constraint FK_MovimientosCapturaFk04;
Go
If Object_id(N'dbo.FK_MovimientosCapturaFk05', 'F') Is Not Null
    Alter Table dbo.MovimientosCaptura Drop Constraint FK_MovimientosCapturaFk05;
Go
If Object_id(N'dbo.FK_MovimientosErroresFk01', 'F') Is Not Null
    Alter Table dbo.MovimientosErrores Drop Constraint FK_MovimientosErroresFk01;
Go
If Object_id(N'dbo.FK_MovimientosErroresFk02', 'F') Is Not Null
    Alter Table dbo.MovimientosErrores Drop Constraint FK_MovimientosErroresFk02;
Go

If Object_id(N'dbo.FK_MovimientosFk01', 'F') Is Not Null
    Alter Table dbo.Movimientos Drop Constraint FK_MovimientosFk01;
Go
If Object_id(N'dbo.FK_MovimientosFk02', 'F') Is Not Null
    Alter Table dbo.Movimientos Drop Constraint FK_MovimientosFk02;
Go
If Object_id(N'dbo.FK_MovimientosFk03', 'F') Is Not Null
    Alter Table dbo.Movimientos Drop Constraint FK_MovimientosFk03;
Go
If Object_id(N'dbo.FK_MovimientosFk04', 'F') Is Not Null
    Alter Table dbo.Movimientos Drop Constraint FK_MovimientosFk04;
Go
If Object_id(N'dbo.FK_MovimientosFk05', 'F') Is Not Null
    Alter Table dbo.Movimientos Drop Constraint FK_MovimientosFk05;
Go

----- MovimientosHist

If Object_id(N'dbo.FK_MovimientosHistFk01', 'F') Is Not Null
    Alter Table dbo.MovimientosHist Drop Constraint MovimientosHistFk01;
Go
If Object_id(N'dbo.FK_MovimientosHistFk02', 'F') Is Not Null
    Alter Table dbo.MovimientosHist Drop Constraint FK_MovimientosHistFk02;
Go
If Object_id(N'dbo.FK_MovimientosHistFk03', 'F') Is Not Null
    Alter Table dbo.MovimientosHist Drop Constraint FK_MovimientosHistFk03;
Go
If Object_id(N'dbo.FK_MovimientosHistFk04', 'F') Is Not Null
    Alter Table dbo.MovimientosHist Drop Constraint FK_MovimientosHistFk04;
Go
If Object_id(N'dbo.FK_MovimientosHistFk05', 'F') Is Not Null
    Alter Table dbo.MovimientosHist Drop Constraint FK_MovimientosHistFk05;

----- MovimientosCierre

If Object_id(N'dbo.MovimientosCierreFk01', 'F') Is Not Null
    Alter Table dbo.MovimientosCierre Drop Constraint MovimientosCierreFk01;
Go
If Object_id(N'dbo.MovimientosCierreFk02', 'F') Is Not Null
    Alter Table dbo.MovimientosCierre Drop Constraint MovimientosCierreFk02;
Go
If Object_id(N'dbo.MovimientosCierreFk03', 'F') Is Not Null
    Alter Table dbo.MovimientosCierre Drop Constraint MovimientosCierreFk03;
Go
If Object_id(N'dbo.MovimientosCierreFk04', 'F') Is Not Null
    Alter Table dbo.MovimientosCierre Drop Constraint MovimientosCierreFk04;
Go
If Object_id(N'dbo.MovimientosCierreFk05', 'F') Is Not Null
    Alter Table dbo.MovimientosCierre Drop Constraint MovimientosCierreFk05;

-----

If Object_id(N'dbo.FK_PolDiaFk01', 'F') Is Not Null
    Alter Table dbo.PolDia Drop Constraint FK_PolDiaFk01;
Go
If Object_id(N'dbo.FK_PolDiaFk02', 'F') Is Not Null
    Alter Table dbo.PolDia Drop Constraint FK_PolDiaFk02;
Go
If Object_id(N'dbo.FK_PolDiaFk03', 'F') Is Not Null
    Alter Table dbo.PolDia Drop Constraint FK_PolDiaFk03;
Go
If Object_id(N'dbo.FK_PolizaCapturaFk01', 'F') Is Not Null
    Alter Table dbo.PolizaCaptura Drop Constraint FK_PolizaCapturaFk01;
Go
If Object_id(N'dbo.FK_PolizaCapturaFk02', 'F') Is Not Null
    Alter Table dbo.PolizaCaptura Drop Constraint FK_PolizaCapturaFk02;
Go
If Object_id(N'dbo.FK_PolizaCapturaFk03', 'F') Is Not Null
    Alter Table dbo.PolizaCaptura Drop Constraint FK_PolizaCapturaFk03;
Go

If Object_id(N'dbo.FK_PolizaFk01', 'F') Is Not Null
    Alter Table dbo.Poliza Drop Constraint FK_PolizaFk01;
Go
If Object_id(N'dbo.FK_PolizaFk02', 'F') Is Not Null
    Alter Table dbo.Poliza Drop Constraint FK_PolizaFk02;
Go
If Object_id(N'dbo.FK_PolizaFk03', 'F') Is Not Null
    Alter Table dbo.Poliza Drop Constraint FK_PolizaFk03;
Go

-- PolizaHist

If Object_id(N'dbo.FK_PolizaHistFk01', 'F') Is Not Null
    Alter Table dbo.PolizaHist Drop Constraint FK_PolizaHistFk01;
Go

If Object_id(N'dbo.FK_PolizaHistFk02', 'F') Is Not Null
    Alter Table dbo.PolizaHist Drop Constraint FK_PolizaHistFk02;
Go

If Object_id(N'dbo.FK_PolizaFk03', 'F') Is Not Null
    Alter Table dbo.PolizaHist Drop Constraint FK_PolizaHistFk03;
Go

-- PolizaCierre

If Object_id(N'dbo.FK_PolizaCierreFk01', 'F') Is Not Null
    Alter Table dbo.PolizaCierre Drop Constraint FK_PolizaCierreFk01;
Go

If Object_id(N'dbo.FK_PolizaCierreFk02', 'F') Is Not Null
    Alter Table dbo.PolizaCierre Drop Constraint FK_PolizaCierreFk02;
Go

If Object_id(N'dbo.FK_PolizaCierreFk03', 'F') Is Not Null
    Alter Table dbo.PolizaCierre Drop Constraint FK_PolizaCierreHistFk03;
Go

--

If Object_id(N'dbo.FK_RangosFk01', 'F') Is Not Null
    Alter Table dbo.Rangos Drop Constraint FK_RangosFk01;
Go

If Object_id(N'dbo.FK_SubRangosFk01', 'F') Is Not Null
    Alter Table dbo.SubRangos Drop Constraint FK_SubRangosFk01;
Go

If Object_id(N'dbo.RelSubRangos_DepartamentosFk01', 'F') Is Not Null
    Alter Table dbo.RelSubRangos_DepartamentosTbl Drop Constraint RelSubRangos_DepartamentosFk01;
Go

If Object_id(N'dbo.RelSubRangos_DepartamentosFk02', 'F') Is Not Null
    Alter Table dbo.RelSubRangos_DepartamentosTbl Drop Constraint RelSubRangos_DepartamentosFk02;
Go

If Object_id(N'dbo.RelSubRangos_DepartamentosFk03', 'F') Is Not Null
    Alter Table dbo.RelSubRangos_DepartamentosTbl Drop Constraint RelSubRangos_DepartamentosFk03;
Go


If Object_id(N'dbo.FK_TipoDeCambioFk01', 'F') Is Not Null
    Alter Table dbo.TipoDeCambio Drop Constraint FK_TipoDeCambioFk01;
Go

If Object_id(N'dbo.FK_C_catPaisesFk01', 'F') Is Not Null
    Alter Table dbo.catPaisesTbl Drop Constraint FK_C_catPaisesFk01;
Go

If Object_id(N'dbo.MapeoCodigoAgrupadorFK01', 'F') Is Not Null
    Alter Table dbo.MapeoCodigoAgrupador Drop Constraint MapeoCodigoAgrupadorFK01;
Go



-- --------------------------------------------------
-- Dropping existing tables
-- --------------------------------------------------

If Object_id(N'dbo.Area_o_Region', 'U') Is Not Null
    Drop Table dbo.Area_o_Region;
Go
If Object_id(N'dbo.Auxiliar', 'U') Is Not Null
    Drop Table dbo.Auxiliar;
Go

-- Catalogo

If Object_id(N'dbo.Catalogo', 'U') Is Not Null
    Drop Table dbo.Catalogo;
Go

-- CatalogocierreTbl

If Object_id(N'dbo.CatalogocierreTbl', 'U') Is Not Null
   Begin
      Drop Table dbo.CatalogocierreTbl;
  End
Go
--

If Object_id(N'dbo.CatalogoAuxiliar', 'U') Is Not Null
    Drop Table dbo.CatalogoAuxiliar;
Go

-- CatalogoAuxiliarCierreTbl

If Object_id(N'dbo.CatalogoAuxiliarCierreTbl', 'U') Is Not Null
    Drop Table dbo.CatalogoAuxiliarCierreTbl;
Go

-- CatalogoAuxiliarCierre

If Object_id(N'dbo.CatalogoAuxiliarCierre', 'U') Is Not Null
    Drop Table dbo.CatalogoAuxiliarCierre;
Go

If Object_id(N'dbo.CatalogoConsolidado', 'U') Is Not Null
    Drop Table dbo.CatalogoConsolidado;
Go
If Object_id(N'dbo.CatAuxExterno', 'U') Is Not Null
    Drop Table dbo.CatAuxExterno;
Go
If Object_id(N'dbo.catCausasRechazoTbl', 'U') Is Not Null
    Drop Table dbo.catCausasRechazoTbl;
Go
If Object_id(N'dbo.catCiudadesTbl', 'U') Is Not Null
    Drop Table dbo.catCiudadesTbl;
Go
If Object_id(N'dbo.catCodigosPostalesTbl', 'U') Is Not Null
    Drop Table dbo.catCodigosPostalesTbl;
Go
If Object_id(N'dbo.catCriteriosTbl', 'U') Is Not Null
    Drop Table dbo.catCriteriosTbl;
Go

If Object_id(N'dbo.catEstadosSATTbl', 'U') Is Not Null
    Drop Table dbo.catEstadosSATTbl;
Go
If Object_id(N'dbo.catEstadosTbl', 'U') Is Not Null
    Drop Table dbo.catEstadosTbl;
Go
If Object_id(N'dbo.catGeneralesTbl', 'U') Is Not Null
    Drop Table dbo.catGeneralesTbl;
Go
If Object_id(N'dbo.catMunicipiosTbl', 'U') Is Not Null
    Drop Table dbo.catMunicipiosTbl;
Go

If Object_id(N'dbo.catPaisesSATTbl', 'U') Is Not Null
    Drop Table dbo.catPaisesSATTbl;
Go
If Object_id(N'dbo.catPaisesTbl', 'U') Is Not Null
    Drop Table dbo.catPaisesTbl;
Go
If Object_id(N'dbo.CodigoAgrupadorSAT', 'U') Is Not Null
    Drop Table dbo.CodigoAgrupadorSAT;
Go
If Object_id(N'dbo.Contadores', 'U') Is Not Null
    Drop Table dbo.Contadores;
Go
If Object_id(N'dbo.ControlCierreTbl', 'U') Is Not Null
    Drop Table dbo.ControlCierreTbl;
Go
If Object_id(N'dbo.ControlAuxiliarCC', 'U') Is Not Null
    Drop Table dbo.ControlAuxiliarCC;
Go

If Object_id(N'dbo.ControlPoliza', 'U') Is Not Null
    Drop Table dbo.ControlPoliza;
Go

If Object_id(N'dbo.Cuentas_predeterminadas', 'U') Is Not Null
    Drop Table dbo.Cuentas_predeterminadas;
Go

If Object_id(N'dbo.Departamento_o_Sucursal', 'U') Is Not Null
    Drop Table dbo.Departamento_o_Sucursal;
Go
If Object_id(N'dbo.Ejercicios', 'U') Is Not Null
    Drop Table dbo.Ejercicios;
Go

If Object_id(N'dbo.Ejercicios_Presupuesto', 'U') Is Not Null
    Drop Table dbo.Ejercicios_Presupuesto;
Go

If Object_id(N'dbo.Formato_ER', 'U') Is Not Null
    Drop Table dbo.Formato_ER;
Go
If Object_id(N'dbo.Formatos', 'U') Is Not Null
    Drop Table dbo.Formatos;
Go
If Object_id(N'dbo.Formatos_Empresas', 'U') Is Not Null
    Drop Table dbo.Formatos_Empresas;
Go
If Object_id(N'dbo.Grupo_Area_o_Region', 'U') Is Not Null
    Drop Table dbo.Grupo_Area_o_Region;
Go

If Object_id(N'dbo.Grupo_Area_o_Region_detalle', 'U') Is Not Null
    Drop Table dbo.Grupo_Area_o_Region_detalle;
Go

If Object_id(N'dbo.Grupos', 'U') Is Not Null
    Drop Table dbo.Grupos;
Go
If Object_id(N'dbo.Grupos_Empresas', 'U') Is Not Null
    Drop Table dbo.Grupos_Empresas;
Go
If Object_id(N'dbo.Mayor_Sector', 'U') Is Not Null
    Drop Table dbo.Mayor_Sector;
Go
If Object_id(N'dbo.Moneda', 'U') Is Not Null
    Drop Table dbo.Moneda;
Go
If Object_id(N'dbo.MapeoCodigoAgrupador', 'U') Is Not Null
    Drop Table dbo.MovimientosCaptura;
Go

If Object_id(N'dbo.MovDia', 'U') Is Not Null
    Drop Table dbo.MovDia;
Go
If Object_id(N'dbo.Movimientos', 'U') Is Not Null
    Drop Table dbo.Movimientos;
Go

-- MovimientosHist

If Object_id(N'dbo.MovimientosHist', 'U') Is Not Null
    Drop Table dbo.MovimientosHist;
Go

-- MovimientosCierre

If Object_id(N'dbo.MovimientosCierre', 'U') Is Not Null
    Drop Table dbo.MovimientosCierre;
Go

--

If Object_id(N'dbo.MovimientosCaptura', 'U') Is Not Null
    Drop Table dbo.MovimientosCaptura;
Go
If Object_id(N'dbo.MovimientosErrores', 'U') Is Not Null
    Drop Table dbo.MovimientosErrores;
Go
If Object_id(N'dbo.Naturaleza_Cuentas', 'U') Is Not Null
    Drop Table dbo.Naturaleza_Cuentas;
Go
If Object_id(N'dbo.Parametros', 'U') Is Not Null
    Drop Table dbo.Parametros;
Go

Go
If Object_id(N'dbo.PolDia', 'U') Is Not Null
    Drop Table dbo.PolDia;
Go
If Object_id(N'dbo.Poliza', 'U') Is Not Null
    Drop Table dbo.Poliza;
Go

-- PolizaHist

If Object_id(N'dbo.PolizaHist', 'U') Is Not Null
    Drop Table dbo.PolizaHist;
Go

-- PolizaCierre

If Object_id(N'dbo.PolizaCierre', 'U') Is Not Null
    Drop Table dbo.PolizaCierre;
Go
--

If Object_id(N'dbo.PolizaCaptura', 'U') Is Not Null
    Drop Table dbo.PolizaCaptura;
Go

If Object_id(N'dbo.Promedios', 'U') Is Not Null
    Drop Table dbo.Promedios;
Go

If Object_id(N'dbo.Rangos', 'U') Is Not Null
    Drop Table dbo.Rangos;
Go

If Object_id(N'dbo.Reportes_Formatos', 'U') Is Not Null
    Drop Table dbo.Reportes_Formatos;
Go

If Object_id(N'dbo.Sector', 'U') Is Not Null
    Drop Table dbo.Sector;
Go
If Object_id(N'dbo.Sectorizacion', 'U') Is Not Null
    Drop Table dbo.Sectorizacion;
Go

If Object_id(N'dbo.SubRangos', 'U') Is Not Null
    Drop Table dbo.SubRangos;
Go

If Object_id(N'dbo.RelSubRangos_DepartamentosTbl', 'U') Is Not Null
    Drop Table dbo.RelSubRangos_DepartamentosTbl;
Go


If Object_id(N'dbo.TasaReex', 'U') Is Not Null
    Drop Table dbo.TasaReex;
Go
If Object_id(N'dbo.TipoDeCambio', 'U') Is Not Null
    Drop Table dbo.TipoDeCambio;
Go
If Object_id(N'dbo.TipoPol', 'U') Is Not Null
    Drop Table dbo.TipoPol;
Go
If Object_id(N'dbo.TipoReex', 'U') Is Not Null
    Drop Table dbo.TipoReex;
Go
If Object_id(N'dbo.Usuarios', 'U') Is Not Null
    Drop Table dbo.Usuarios;
Go
If Object_id(N'dbo.catColoniasTbl', 'U') Is Not Null
    Drop Table dbo.catColoniasTbl;
Go

If Object_id(N'dbo.MapeoCodigoAgrupador', 'U') Is Not Null
    Drop Table dbo.MapeoCodigoAgrupador;
Go

--
-- Parametro_Rutas
--

If Object_id(N'dbo.Parametro_Rutas', 'U') Is Not Null
    Drop Table dbo.Parametro_Rutas;
Go

-- --------------------------------------------------
-- Creating all tables
-- --------------------------------------------------

-- Creating Table 'Area_o_Region'

Create Table dbo.Area_o_Region (
    Region_id Integer  Not Null,
    Region Varchar(60)  Not Null,
    Direccion Varchar(120)  Null,
    Cod_Postal Varchar(5)  Null,
    Municipio Varchar(30)  Null,
    Ciudad Varchar(30)  Null,
    Estado Varchar(30)  Null,
    Telefono1 Varchar(20)  Null,
    Telefono2 Varchar(20)  Null,
    Fax Varchar(20)  Null,
    RazonSocial Varchar(100)  Not Null,
    idEstatus bit  Not Null Default 1,
    NombreDelArchivoLogo Varchar(200)  Null,
    TipoDeContenidoLogo Varchar(10)  Null,
    DataLogo varbinary(max)  Null
);
Go

-- Creating Table 'Auxiliar'
Create Table dbo.Auxiliar (
    Auxiliar_id Varchar(6)  Not Null,
    Auxiliar1 Varchar(100)  Not Null,
    Usuario Varchar(10)  Null,
    Fecha_Creacion Datetime  Not Null,
    Fecha_Cancelacion Datetime  Null
);
Go

-- Creating Table 'Catalogo'

Create Table dbo.Catalogo (
    Llave        Varchar( 16)  Not Null,
    Moneda       Varchar(  2)  Not Null Default '00',
    Niv          Smallint      Not Null,
    Descrip      Varchar(100)  Not Null,
    SAnt         Decimal(19,4)     Null Default 0,
    Car          Decimal(19,4)     Null Default 0,
    Abo          Decimal(19,4)     Null Default 0,
    SAct         Decimal(19,4)     Null Default 0,
    FecCap       Datetime          Null Default Getdate(),
    CarProceso   Decimal(19,4)     Null Default 0,
    AboProceso   Decimal(19,4)     Null Default 0,
    SAntProceso  Decimal(19,4)     Null Default 0,
    CarExt       Decimal(19,4)     Null Default 0,
    AboExt       Decimal(19,4)     Null Default 0,
    SProm        Decimal(19,4)     Null Default 0,
    SPromAnt     Decimal(19,4)     Null Default 0,
    Nivel_sector Smallint          Null,
    SProm2       Decimal(19,4)     Null Default 0,
    Sprom2Ant    Decimal(19,4)     Null Default 0,
    Ejercicio    Smallint      Not Null,
    Mes          Tinyint       Not Null);
Go

-- CatalogocierreTbl

Create Table dbo.CatalogocierreTbl (
    Llave         Varchar(16)   Not Null,
    Moneda        Varchar(  2)  Not Null Default '00',
    Niv           Smallint      Not Null,
    Descrip       Varchar(100)  Not Null,
    SAnt          Decimal(19,4)     Null Default 0,
    Car           Decimal(19,4)     Null Default 0,
    Abo           Decimal(19,4)     Null Default 0,
    SAct          Decimal(19,4)     Null Default 0,
    FecCap        Datetime          Null,
    CarProceso    Decimal(19,4)     Null Default 0,
    AboProceso    Decimal(19,4)     Null Default 0,
    SAntProceso   Decimal(19,4)     Null Default 0,
    CarExt        Decimal(19,4)     Null Default 0,
    AboExt        Decimal(19,4)     Null Default 0,
    SProm         Decimal(19,4)     Null Default 0,
    SPromAnt      Decimal(19,4)     Null Default 0,
    Nivel_sector  Smallint          Null,
    SProm2        Decimal(19,4)     Null,
    Sprom2Ant     Decimal(19,4)     Null,
    Ejercicio     Smallint      Not Null,
    Mes           Tinyint       Not Null);
Go


-- Creating Table 'CatalogoAuxiliar'

Create Table dbo.CatalogoAuxiliar (
    Llave        Varchar( 16)  Not Null,
    Moneda       Varchar(  2)  Not Null Default '00',
    Niv          Tinyint       Not Null,
    Sector_id    Varchar(  2)      Null,
    Sucursal_id  Integer       Not Null,
    Region_id    Integer       Not Null,
    Descrip      Varchar(100)  Not Null,
    SAnt         Decimal(19,4)     Null Default 0,
    Car          Decimal(19,4)     Null Default 0,
    Abo          Decimal(19,4)     Null Default 0,
    SAct         Decimal(19,4)     Null Default 0,
    FecCap       Datetime          Null Default Getdate(),
    CarProceso   Decimal(19,4)     Null Default 0,
    AboProceso   Decimal(19,4)     Null Default 0,
    SAntProceso  Decimal(19,4)     Null Default 0,
    CarExt       Decimal(19,4)     Null Default 0,
    AboExt       Decimal(19,4)     Null Default 0,
    SProm        Decimal(19,4)     Null Default 0,
    SPromAnt     Decimal(19,4)     Null Default 0,
    SProm2       Decimal(19,4)     Null Default 0,
    SProm2Ant    Decimal(19,4)     Null Default 0,
    ejercicio    Smallint      Not Null,
    mes          Tinyint       Not Null
);
Go

-- Creating Table 'CatalogoAuxiliarCierre'

Create Table dbo.CatalogoAuxiliarCierre(
    Llave        Varchar( 16)  Not Null,
    Moneda       Varchar(  2)  Not Null Default '00',
    Niv          Tinyint       Not Null,
    Sector_id    Varchar(  2)      Null,
    Sucursal_id  Integer       Not Null,
    Region_id    Integer       Not Null,
    Descrip      Varchar(100)  Not Null,
    SAnt         Decimal(19,4)     Null Default 0,
    Car          Decimal(19,4)     Null Default 0,
    Abo          Decimal(19,4)     Null Default 0,
    SAct         Decimal(19,4)     Null Default 0,
    FecCap       Datetime          Null Default Getdate(),
    CarProceso   Decimal(19,4)     Null Default 0,
    AboProceso   Decimal(19,4)     Null Default 0,
    SAntProceso  Decimal(19,4)     Null Default 0,
    CarExt       Decimal(19,4)     Null Default 0,
    AboExt       Decimal(19,4)     Null Default 0,
    SProm        Decimal(19,4)     Null Default 0,
    SPromAnt     Decimal(19,4)     Null Default 0,
    SProm2       Decimal(19,4)     Null Default 0,
    SProm2Ant    Decimal(19,4)     Null Default 0,
    ejercicio    Smallint      Not Null,
    mes          Tinyint       Not Null Default 13);
Go

-- Creating Table 'CatalogoAuxiliarCierreTbl'

Create Table dbo.CatalogoAuxiliarCierreTbl (
    Llave        Varchar( 16)  Not Null,
    Moneda       Varchar(  2)  Not Null Default '00',
    Niv          Tinyint       Not Null,
    Sector_id    Varchar(  2)      Null,
    Sucursal_id  Integer       Not Null,
    Region_id    Integer       Not Null,
    Descrip      Varchar(100)  Not Null,
    SAnt         Decimal(19,4)     Null Default 0,
    Car          Decimal(19,4)     Null Default 0,
    Abo          Decimal(19,4)     Null Default 0,
    SAct         Decimal(19,4)     Null Default 0,
    FecCap       Datetime          Null,
    CarProceso   Decimal(19,4)     Null Default 0,
    AboProceso   Decimal(19,4)     Null Default 0,
    SAntProceso  Decimal(19,4)     Null Default 0,
    CarExt       Decimal(19,4)     Null Default 0,
    AboExt       Decimal(19,4)     Null Default 0,
    SProm        Decimal(19,4)     Null Default 0,
    SPromAnt     Decimal(19,4)     Null Default 0,
    SProm2       Decimal(19,4)     Null Default 0,
    SProm2Ant    Decimal(19,4)     Null Default 0,
    ejercicio    Smallint      Not Null,
    mes          Tinyint       Not Null Default 13);
Go

-- Creating Table 'CatalogoConsolidado'

Create Table dbo.CatalogoConsolidado
   (numerodecuenta     Varchar(16)   Not Null,
    moneda_id          Varchar( 2)   Not Null Default '00',
    descripcion        Varchar(100)  Not Null,
    interdepartamental Bit           Not Null,
    naturaleza         Bit           Not Null,
    codigoAgrupador    Varchar( 20)      Null,
    idEstatus          Bit           Not Null Default 1,
    ultactual          Datetime      Not Null Default Getdate(),
    user_id            Varchar(10)       Null);
Go

-- Creating Table 'CatAuxExterno'
Create Table dbo.CatAuxExterno (
    Llave               Varchar(16)  Not Null,
    Moneda              Varchar( 2)  Not Null Default '00',
    Sector_id_externa   Varchar( 2)  Not Null,
    Sucursal_id_externa Integer      Not Null,
    Region_id_externa   Integer      Not Null,
    Llave_externa       Varchar(16)      Null
);
Go

-- Creating Table 'catCausasRechazoTbl'

Create Table dbo.catCausasRechazoTbl (
    IdCausaRechazo Integer       Not Null,
    descripcion    Varchar(250)  Not Null,
    idEstatus      bit           Not Null,
    usuario        Smallint      Not Null
);
Go

-- Creating Table 'catCiudadesTbl'
Create Table dbo.catCiudadesTbl (
    idPais Smallint  Not Null,
    idEstado Smallint  Not Null,
    idCiudad Smallint  Not Null,
    nombre Varchar(60)  Null,
    abreviatura Varchar(10)  Null
);
Go

-- Creating Table 'catCodigosPostalesTbl'
Create Table dbo.catCodigosPostalesTbl (
    idPais Smallint  Not Null,
    idEstado Smallint  Not Null,
    idCiudad Smallint  Null,
    idMunicipio Smallint  Not Null,
    idCodigoPostal Varchar(10)  Not Null,
    idColonia Smallint  Not Null
);
Go

-- Creating Table 'catCriteriosTbl'
Create Table dbo.catCriteriosTbl (
    criterio Char(25)  Not Null,
    valor Tinyint  Not Null,
    descripcion Varchar(60)  Not Null,
    valorAdicional Varchar(20)  Null,
    idEstatus bit  Not Null,
    fechaAct Datetime  Not Null,
    ipAct Varchar(30)  Null,
    macAddressAct Varchar(30)  Null
);
Go

-- Creating Table 'catEstadosSATTbl'
Create Table dbo.catEstadosSATTbl (
    idPais Char(5)  Not Null,
    idEstado Char(3)  Not Null,
    descripcion Varchar(100)  Not Null,
    idEstatus bit  Not Null,
    idUsuarioAct Smallint  Not Null,
    fechaAct Datetime  Not Null,
    ipAct Varchar(30)  Null,
    macAddressAct Varchar(30)  Null
);
Go

-- Creating Table 'catEstadosTbl'

Create Table dbo.catEstadosTbl (
    idPais Smallint  Not Null,
    idEstado Smallint  Not Null,
    nombre Varchar(60)  Null,
    abreviatura Varchar(5)  Null,
    claveSAT Varchar(3)  Null
);
Go

-- Creating Table 'catGeneralesTbl'

Create Table dbo.catGeneralesTbl (
    tabla         Sysname       Not Null,
    columna       Sysname       Not Null,
    valor         Integer       Not Null,
    descripcion   Varchar(100)  Not Null,
    idEstatus     bit           Not Null Default 1,
    fechaAct      Datetime      Not Null Default Getdate(),
    ipAct         Varchar(30)       Null,
    macAddressAct Varchar(30)       Null);
Go

-- Creating Table 'catMunicipiosTbl'

Create Table dbo.catMunicipiosTbl (
    idPais Smallint  Not Null,
    idEstado Smallint  Not Null,
    idMunicipio Smallint  Not Null,
    nombre Varchar(100)  Null,
    abreviatura Varchar(10)  Null
);
Go

-- Creating Table 'catPaisesSATTbl'

Create Table dbo.catPaisesSATTbl (
    idPais Char(5)  Not Null,
    descripcion Varchar(100)  Not Null,
    idEstatus bit  Not Null,
    idUsuarioAct Smallint  Not Null,
    fechaAct Datetime  Not Null,
    ipAct Varchar(30)  Null,
    macAddressAct Varchar(30)  Null
);
Go

-- Creating Table 'catPaisesTbl'
Create Table dbo.catPaisesTbl (
    idPais Smallint  Not Null,
    nombre Varchar(60)  Not Null,
    abreviatura Varchar(3)  Not Null,
    nacionalidad Varchar(60)  Not Null,
    codigoSat Char(5)  Null
);
Go

-- Creating Table 'CodigoAgrupadorSAT'

Create Table dbo.CodigoAgrupadorSAT (
    Nivel               Varchar(50)   Not Null,
    CodigoAgrupador     Varchar(15)   Not Null,
    Descripcion         Varchar(200)  Not Null,
    Secuencia           Integer       Not Null,
    CodigoAgrupador2014 nvarchar(15)  Null
);
Go

-- Creating Table 'Contadores'

Create Table dbo.Contadores (
    cont_id     Integer  Not Null,
    descripcion Varchar(100)  Not Null,
    valor       Integer  Null,
    valoraux    Integer  Null
);
Go

-- Creating Table 'ControlCierreTbl'

Create Table dbo.ControlCierreTbl (
    Ejercicio    Smallint      Not Null,
    Mes          Tinyint       Not Null,
    FechaProceso Datetime      Not Null Default Getdate(),
    Bloqueado    Bit           Not Null Default 0,
    NomUser      NVarchar(10)  Not Null);
Go

-- Creating Table 'ControlAuxiliarCC'
Create Table dbo.ControlAuxiliarCC (
    numerodecuenta           Varchar( 16) Not Null,
    moneda_id                Varchar(  2) Not Null Default '00',
    usuario_Solicita         Varchar( 10) Not Null,
    fechaHora_Solicita       Datetime     Not Null,
    observaciones_Solicita   Varchar(100)     Null,
    usuario_Autoriza         Varchar( 10)     Null,
    fechaHora_Autoriza       Datetime         Null,
    observaciones_Autoriza   Varchar(100)     Null,
    usuario_Rechaza          Varchar( 10)     Null,
    fechaHora_Rechaza        Datetime         Null,
    observaciones_Rechaza    Varchar(100)     Null,
    estatus                  Integer      Not Null
);
Go

-- Creating Table 'ControlPoliza'

Create Table dbo.ControlPoliza (
  TipoComprobante Varchar(5)  Not Null,
  Ejercicio       Smallint    Not Null,
  Mes             Tinyint     Not Null,
  Contador        Integer     Not Null);
Go

-- Creating Table 'Cuentas_predeterminadas'

Create Table dbo.Cuentas_predeterminadas (
    ID              Integer      Not Null,
    Descripcion     Varchar(80)      Null,
    CuentaInterna   Varchar(16)  Not Null,
    TipoPoliza      Varchar(5)   Not Null,
    moneda_id       Varchar(2)   Not Null Default '00',
    UltActual       Datetime     Not Null Default Getdate());

Go

-- Creating Table 'Departamento_o_Sucursal'

Create Table dbo.Departamento_o_Sucursal (
    Sucursal_id  Integer      Not Null,
    Region_id    Integer      Not Null,
    Sucursal     Varchar(100) Not Null,
    Direccion    Varchar(120)     Null,
    Cod_Postal   Varchar(  5)     Null,
    Municipio    Varchar( 30)     Null,
    Ciudad       Varchar( 30)     Null,
    Estado       Varchar( 30)     Null,
    Telefono1    Varchar( 20)     Null,
    Telefono2    Varchar( 20)     Null,
    Fax          Varchar( 20)     Null,
    Global       bit          Not Null,
    idEstatus    bit          Not Null Default 1,
    RazonSocial nvarchar( 50)     Null);
Go

-- Creating Table 'Ejercicios'

Create Table dbo.Ejercicios (
    ejercicio Smallint  Not Null,
    idEstatus Tinyint   Not Null Default 0);
Go

-- Creating Table 'Ejercicios_Presupuesto'

Create Table dbo.Ejercicios_Presupuesto (
    Ejercicio      Smallint     Not Null,
    descripcion    Varchar(80)  Not Null);
Go

-- Creating Table 'Formato_ER'
Create Table dbo.Formato_ER (
    Cons real  Not Null,
    Tipo Varchar(50)  Null,
    Concepto Varchar(50)  Null,
    Fuente Smallint  Null,
    Posicion Smallint  Null,
    Inicio Varchar(16)  Null,
    Fin Varchar(16)  Null,
    Subrayado bit  Not Null,
    Mov1 Varchar(1)  Null,
    Mov2 Varchar(1)  Null
);
Go

-- Creating Table 'Formatos'
Create Table dbo.Formatos (
    IdFormato Smallint  Not Null,
    Formato Varchar(50)  Null,
    Usuario Varchar(10)  Null,
    Privado bit  Not Null,
    Consolidado bit  Not Null,
    Tipo_Formato Smallint  Null
);
Go

-- Creating Table 'Formatos_Empresas'

Create Table dbo.Formatos_Empresas (
    IdFormato Smallint  Not Null,
    IdEmpresa Smallint  Not Null
);
Go

-- Creating Table 'Grupo_Area_o_Region'

Create Table dbo.Grupo_Area_o_Region (
    GrupoArea_id Integer       Not Null,
    GrupoArea    Varchar(120)  Not Null);
Go

-- Creating Table 'Grupo_Area_o_Region_detalle'

Create Table dbo.Grupo_Area_o_Region_detalle (
    GrupoArea_id Integer  Not Null,
    Region_id    Integer  Not Null,
    activo       bit      Not Null Default 1);
Go

-- Creating Table 'Grupos'

Create Table dbo.Grupos (
    grupo_id        Smallint      Not Null,
    nombre          Varchar(100)  Not Null,
    restricciones   Varchar(255)      Null,
    NivelSupervisor bit           Not Null);
Go

-- Creating Table 'Grupos_Empresas'

Create Table dbo.Grupos_Empresas (
    IdFormato Smallint      Not Null,
    IdEmpresa Smallint      Not Null,
    Grupo     Integer       Not Null,
    Inicio    nvarchar(16)      Null,
    Fin       nvarchar(16)      Null
);
Go

-- Creating Table 'Mayor_Sector'

Create Table dbo.Mayor_Sector (
    Mayor     Varchar(8)  Not Null,
    Sector_id Varchar(2)  Not Null
);
Go

-- Creating Table 'Moneda'

Create Table dbo.Moneda (
    moneda_mex        Varchar(2)    Not Null,
    moneda_id         Integer       Not Null,
    descripcion_corta Varchar(10)       Null,
    descripcion_larga Varchar(100)      Null,
    activo            Smallint          Null Default 1,
    ultactual         Datetime          Null Default Getdate(),
    usuario           Varchar(10)       Null);
Go

-- Creating Table 'MovDia'

Create Table dbo.MovDia
   (Referencia         Varchar( 20)   Not Null,
    Cons               Integer        Not Null,
    Moneda             Varchar(  2)   Not Null Default '00',
    Fecha_mov          Datetime       Not Null,
    Llave              Varchar( 16)   Not Null,
    Concepto           Varchar(255)       Null,
    Importe            Decimal(19, 2)     Null   Default 0,
    Documento          Varchar(255)       Null,
    Clave              Char(1)        Not Null,
    FecCap             Datetime       Not Null,
    Sector_id          Varchar(  2)       Null,
    Sucursal_id        Integer            Null,
    Region_id          Integer            Null,
    Importe_Cargo      Decimal(19, 2)     Null   Default 0,
    Importe_Abono      Decimal(19, 2)     Null   Default 0,
    Descripcion        Varchar(150)       Null,
    TipoPolizaConta    Varchar(3)         Null,
    ReferenciaFiscal   Varchar(50)        Null,
    Fecha_Doc          Datetime           Null,
    Ejercicio          Smallint       Not Null,
    Mes                Tinyint        Not Null,
    idCausaRechazo     Varchar(250)       Null);
Go

-- Creating Table 'MovimientosHist' [Nueva]

Create Table dbo.MovimientosHist (
    Referencia       Varchar( 20)    Not Null,
    Cons             Integer         Not Null,
    Moneda           Varchar(  2)    Not Null Default '00',
    Fecha_mov        Datetime        Not Null,
    Llave            Varchar( 16)    Not Null,
    Concepto         Varchar(255)        Null,
    Importe          Decimal(19, 2)      Null Default 0,
    Documento        Varchar(255)        Null,
    Clave            Char(1)         Not Null,
    FecCap           Datetime        Not Null,
    Sector_id        Varchar(2)          Null,
    Sucursal_id      Integer             Null,
    Region_id        Integer             Null,
    Importe_Cargo    Decimal(19, 2)      Null Default 0,
    Importe_Abono    Decimal(19, 2)  Not Null Default 0,
    Descripcion      Varchar(150)        Null,
    TipoPolizaConta  Varchar(5)          Null,
    ReferenciaFiscal Varchar(50)         Null,
    Fecha_Doc        Datetime            Null,
    Ejercicio        Smallint        Not Null,
    mes              Tinyint         Not Null);
Go

-- Creating Table 'MovimientosCierre'

Create Table dbo.MovimientosCierre
   (Referencia       Varchar(20)   Not Null,
    Cons             Integer       Not Null,
    Moneda           Varchar( 2)   Not Null Default '00',
    Fecha_mov        Datetime      Not Null,
    Llave            Varchar(16)   Not Null,
    Concepto         Varchar(255)      Null,
    Importe          Decimal(19,2)     Null Default 0,
    Documento        Varchar(255)      Null,
    Clave            Char(1)       Not Null,
    FecCap           Datetime      Not Null,
    Sector_id        Varchar(2)        Null,
    Sucursal_id      Integer           Null,
    Region_id        Integer           Null,
    Importe_Cargo    Decimal(19,2)     Null Default 0,
    Importe_Abono    Decimal(19,2) Not Null Default 0,
    Descripcion      Varchar(150)      Null,
    TipoPolizaConta  Varchar(5)        Null,
    ReferenciaFiscal Varchar(50)       Null,
    Fecha_Doc        Datetime          Null,
    Ejercicio        Smallint      Not Null,
    mes              Tinyint       Not Null);
Go

-- Creating Table 'Movimientos'

Create Table dbo.Movimientos
   (Referencia        Varchar( 20)    Not Null,
    Cons              Integer         Not Null,
    Moneda            Varchar(  2)    Not Null Default '00',
    Fecha_mov         Datetime        Not Null,
    Llave             Varchar( 16)    Not Null,
    Concepto          Varchar(255)        Null,
    Importe           Decimal(19, 2)      Null Default 0,
    Documento         Varchar(255)        Null,
    Clave             Char(1)         Not Null,
    FecCap            Datetime        Not Null,
    Sector_id         Varchar(  2)        Null,
    Sucursal_id       Integer             Null,
    Region_id         Integer             Null,
    Importe_Cargo     Decimal(19, 2)      Null Default 0,
    Importe_Abono     Decimal(19, 2)      Null Default 0,
    Descripcion       Varchar(150)        Null,
    TipoPolizaConta   Varchar(  5)        Null,
    ReferenciaFiscal  Varchar( 50)        Null,
    Fecha_Doc         Datetime            Null,
    Ejercicio         Smallint            Not Null,
    mes               Tinyint             Not Null
);
Go

-- Creating Table 'MovimientosCaptura'

Create Table dbo.MovimientosCaptura
   (Referencia         Varchar( 20)     Not Null,
    Cons               Integer          Not Null,
    Moneda             Varchar(  2)     Not Null Default '00',
    Fecha_mov          Datetime         Not Null,
    Llave              Varchar( 16)     Not Null,
    Concepto           Varchar(255)         Null,
    Importe            Decimal(19, 2)       Null Default 0,
    Documento          Varchar(255)         Null,
    Clave              Char(1)          Not Null,
    FecCap             Datetime         Not Null,
    Sector_id          Varchar(  2)         Null,
    Sucursal_id        Integer              Null,
    Region_id          Integer              Null,
    Importe_Cargo      Decimal(19, 2)       Null Default 0,
    Importe_Abono      Decimal(19, 2)       Null Default 0,
    Descripcion        Varchar(150)         Null,
    TipoPolizaConta    Varchar( 5)          Null,
    ReferenciaFiscal   Varchar( 50)         Null,
    Fecha_Doc          Datetime             Null,
    Ejercicio          Smallint         Not Null,
    mes                Tinyint          Not Null
);
Go

-- Creating Table 'MovimientosErrores'

Create Table dbo.MovimientosErrores (
    ejercicio    Smallint       Not Null,
    mes          Tinyint        Not Null,
    Referencia   Varchar(20)    Not Null,
    Fecha_mov    Datetime       Not Null,
    Cons         Integer        Not Null,
    Moneda       Varchar( 2)    Not Null Default '00',
    Llave        Varchar(16)    Not Null,
    Concepto     Varchar(255)       Null,
    Importe      Decimal(19,2)      Null Default 0,
    Documento    Varchar(255)       Null,
    Clave        Char(1)        Not Null,
    FecCap       Datetime           Null,
    Sector_id    Varchar(2)         Null,
    Sucursal_id  Integer        Not Null,
    Region_id    Integer        Not Null,
    Mens_Error   Varchar(1000)  Not Null,
    idError      Integer        Not Null);
Go

-- Creating Table 'Naturaleza_Cuentas'

Create Table dbo.Naturaleza_Cuentas (
    Naturaleza_id      Varchar( 2)  Not Null,
    Nom_naturaleza     Varchar(30)  Not Null,
    Deudora_Acreedora  Smallint     Not Null
);
Go

-- Creating Table 'Parametros'

Create Table dbo.Parametros
 (id          Smallint     Not Null,
  descripcion Varchar(60)      Null,
  valor       real             Null,
  cadena      nvarchar(255)    Null,
  estatus     Smallint         Null
);
Go


-- Creating Table 'PolDia'

Create Table dbo.PolDia
   (Referencia      Varchar( 20)   Not Null,
    Fecha_Mov       Datetime       Not Null,
    Fecha_Cap       Datetime           Null,
    Concepto        Varchar(255)       Null,
    Cargos          Decimal(19,2)      Null Default 0,
    Abonos          Decimal(19,2)      Null Default 0,
    TCons           Integer            Null Default 0,
    Usuario         Varchar(10)        Null,
    TipoPoliza      Varchar(5)     Not Null,
    Documento       Varchar(255)       Null,
    Usuario_cancela Varchar(10)        Null,
    Fecha_Cancela   Datetime           Null,
    Status          Tinyint        Not Null,
    Mes_Mov         Varchar(3)         Null,
    TipoPolizaConta Varchar(3)         Null,
    FuenteDatos     Varchar(50)        Null,
    Ejercicio       Smallint       Not Null,
    Mes             Tinyint        Not Null,
    CausaRechazo    Varchar(1000)      Null Default Char(32));
Go

-- Creating Table 'Poliza'

Create Table dbo.Poliza (
    Referencia      Varchar( 20)    Not Null,
    Fecha_mov       Datetime        Not Null,
    Fecha_Cap       Datetime            Null,
    Concepto        Varchar(255)        Null,
    Cargos          Decimal(19, 2)      Null Default 0,
    Abonos          Decimal(19,2)       Null Default 0,
    TCons           Integer             Null Default 0,
    Usuario         Varchar( 10)        Null,
    TipoPoliza      Varchar(  5)    Not Null,
    Documento       Varchar(255)        Null,
    Usuario_cancela Varchar( 10)        Null,
    Fecha_Cancela   Datetime            Null,
    Status          Tinyint         Not Null,
    Mes_Mov         Varchar(  3)        Null,
    TipoPolizaConta Varchar(  3)        Null,
    FuenteDatos     Varchar( 60)        Null,
    ejercicio       Smallint        Not Null,
    mes             Tinyint         Not Null);
Go

--
-- PolizaHist [Nueva]
--

Create Table dbo.PolizaHist (
    Referencia      Varchar( 20)  Not Null,
    Fecha_mov       Datetime      Not Null,
    Fecha_Cap       Datetime          Null,
    Concepto        Varchar(255)      Null,
    Cargos          Decimal(19, 2)    Null Default 0,
    Abonos          Decimal(19, 2)    Null Default 0,
    TCons           Integer           Null Default 0,
    Usuario         Varchar( 10)      Null,
    TipoPoliza      Varchar(  5)  Not Null,
    Documento       Varchar(255)      Null,
    Usuario_cancela Varchar( 10)      Null,
    Fecha_Cancela   Datetime          Null,
    Status          Tinyint       Not Null,
    Mes_Mov         Varchar(3)        Null,
    TipoPolizaConta Varchar(3)        Null,
    FuenteDatos     Varchar(60)       Null,
    ejercicio       Smallint      Not Null,
    mes             Tinyint       Not Null);
Go

--
-- PolizaCierre
--

Create Table dbo.PolizaCierre (
    Referencia      Varchar( 20)  Not Null,
    Fecha_mov       Datetime      Not Null,
    Fecha_Cap       Datetime          Null,
    Concepto        Varchar(255)      Null,
    Cargos          Decimal(19, 2)    Null Default 0,
    Abonos          Decimal(19, 2)    Null Default 0,
    TCons           Integer           Null Default 0,
    Usuario         Varchar( 10)      Null,
    TipoPoliza      Varchar(  5)  Not Null,
    Documento       Varchar(255)      Null,
    Usuario_cancela Varchar( 10)      Null,
    Fecha_Cancela   Datetime          Null,
    Status          Tinyint       Not Null,
    Mes_Mov         Varchar(  3)      Null,
    TipoPolizaConta Varchar(  3)      Null,
    FuenteDatos     Varchar( 60)      Null,
    ejercicio       Smallint      Not Null,
    mes             Tinyint       Not Null);
Go

-- Creating Table 'PolizaCaptura'

Create Table dbo.PolizaCaptura (
    Referencia      Varchar( 20)   Not Null,
    Fecha_mov       Datetime       Not Null,
    Fecha_Cap       Datetime           Null,
    Concepto        Varchar(255)       Null,
    Cargos          Decimal(19, 2)     Null Default 0,
    Abonos          Decimal(19, 2)     Null Default 0,
    TCons           Integer            Null Default 0,
    Usuario         Varchar( 10)       Null,
    TipoPoliza      Varchar( 5)    Not Null,
    Documento       Varchar(255)       Null,
    Usuario_cancela Varchar( 10)       Null,
    Fecha_Cancela   Datetime           Null,
    Status          Tinyint        Not Null,
    Mes_Mov         Varchar(  3)       Null,
    TipoPolizaConta Varchar(  3)       Null,
    FuenteDatos     Varchar( 60)       Null,
    ejercicio       Smallint       Not Null,
    mes             Tinyint        Not Null,
    Region_id       Integer        Not Null);
Go

-- Creating Table 'Promedios'

Create Table dbo.Promedios
   (Llave            Varchar(20)     Not Null,
    moneda_id        Varchar( 2)     Not Null Default '00',
    Ejercicio        Smallint        Not Null,
    mes              Tinyint         Not Null,
    Sact             Decimal(19, 2)  Not Null Default 0,
    Sacu             Decimal(19, 2)  Not Null Default 0,
    Spro             Decimal(19, 2)  Not Null Default 0,
    Sprom2           Decimal(19, 2)  Not Null Default 0,
    sfinmes          Decimal(19, 2)  Not Null Default 0,
    totcar           Decimal(19, 2)  Not Null Default 0,
    totabo           Decimal(19, 2)  Not Null Default 0,
    campo_valor      Nvarchar(1)         Null);
Go


-- Creating Table 'Rangos'

Create Table dbo.Rangos (
    Rango_id Varchar(2)  Not Null,
    Naturaleza_id Varchar(2)  Not Null,
    Rango Varchar(100)  Not Null,
    Llave_inicial Varchar(4)  Not Null,
    Llave_final Varchar(4)  Not Null,
    Orden Integer  Null
);
Go

-- Creating Table 'Reportes_Formatos'

Create Table dbo.Reportes_Formatos (
    Cons Smallint  Not Null,
    IdFormato Smallint  Not Null,
    Concepto nvarchar(50)  Null,
    Naturaleza_id nvarchar(2)  Null,
    Fuente Smallint  Null,
    Grupo Integer  Null,
    Posicion Smallint  Null,
    Inicio nvarchar(16)  Null,
    Fin nvarchar(16)  Null,
    Subrayado bit  Not Null,
    Mov1 nvarchar(1)  Null,
    Mov2 nvarchar(1)  Null,
    Mov3 nvarchar(1)  Null
);
Go



-- Creating Table 'Sector'
Create Table dbo.Sector (
    Sector_id Varchar(2)  Not Null,
    Sector1 nvarchar(100)  Null
);
Go

-- Creating Table 'Sectorizacion'

Create Table dbo.Sectorizacion (
    Mayor Varchar(8)  Not Null
);
Go

-- Creating Table 'SubRangos'

Create Table dbo.SubRangos (
    Subrango_id    Integer      Not Null,
    Subrango       Varchar(60)      Null,
    Rango_id       Varchar(2)   Not Null,
    Llave_inicial  Varchar(4)       Null,
    Llave_final    Varchar(4)       Null,
    Sucursalizable bit          Not Null);
Go

-- Creating Table 'RelSubRangos_DepartamentosTbl'  [Nueva]

Create Table dbo.RelSubRangos_DepartamentosTbl
  (idRelacion      Integer     Not Null Identity (1, 1),
   Subrango_id     Integer     Not Null,
   Sucursal_id     Integer     Not Null,
   Region_id       Integer     Not Null,
   FechaAct        Datetime    Not Null Default Getdate(),
   usuario         Varchar(10) Not Null,
   ipAct           Varchar(30)     Null)

-- Creating Table 'TasaReex'

Create Table dbo.TasaReex (
    ID_Reexp Integer  Not Null,
    Descripcion Varchar(60)  Not Null,
    Des_corta Varchar(30)  Null
);
Go

-- Creating Table 'TipoDeCambio'
Create Table dbo.TipoDeCambio (
    tc_id          Integer        Not Null,
    moneda_id      Varchar(2)     Not Null Default '00',
    fechamov       Datetime       Not Null Default Getdate(),
    tipodecambio1  Decimal(19,4)  Not Null Default 1);
Go

-- Creating Table 'TipoPol'
Create Table dbo.TipoPol (
    Tipo         Varchar(  5)  Not Null,
    Descripcion  Varchar(100)  Not Null,
    Tipo_externo Varchar( 10)      Null,
    Sucursal_id  Integer           Null
);
Go

-- Creating Table 'TipoReex'

Create Table dbo.TipoReex (
    ID_Reexp    Integer   Not Null,
    fechamov    Datetime  Not Null,
    porcentaje  float     Null);
Go

-- Creating Table 'Usuarios'
Create Table dbo.Usuarios (
    usuario Varchar(10)  Not Null,
    person_id Smallint  Null,
    grupo_id Smallint  Null,
    password Varchar(250)  Null,
    lim_pedidos Decimal(19,4)  Null,
    restricciones Varchar(255)  Null,
    activo Smallint  Null,
    ultactual Datetime  Null,
    creadopor Varchar(10)  Null
);
Go

-- Creating Table 'catColoniasTbl'

Create Table dbo.catColoniasTbl (
    idPais Smallint  Not Null,
    idEstado Smallint  Not Null,
    idCiudad Smallint  Null,
    idMunicipio Smallint  Not Null,
    idColonia Smallint  Not Null,
    nombre Varchar(60)  Null,
    abreviatura Varchar(10)  Null
);
Go

-- Creating Table 'MapeoCodigoAgrupador'

Create Table dbo.MapeoCodigoAgrupador (
    Llave             Varchar(16)     Not Null,
    moneda_id         Varchar( 2)     Not Null   Default '00',
    Niv               Tinyint         Not Null,
    Descrip           Varchar(100)        Null,
    CodigoAgrupador   Varchar(15)     Not Null,
    Descripcion       Varchar(200)        Null);
Go

--
-- Parametro_Rutas
--

Create Table dbo.Parametro_Rutas
   (id              Integer       Not Null,
    descripcion     Varchar(100)      Null,
    cadena          Varchar(256)      Null,
    estatus         Tinyint       Not Null Default 1,
    ibis            Varchar(100)      Null,
    bimas           Varchar(100)      Null,
    detalle         Varchar(100)      Null,
    consulta_bimas  Varchar(Max)      Null,
    consulta_ibis   Varchar(Max)      Null,
    PathRechazadas  Varchar(500)      Null,
    ultActual       Datetime      Not Null Default Getdate())
Go

-- --------------------------------------------------
-- Creating all Primary Key constraints
-- --------------------------------------------------

-- Creating Primary Key On Region_id in Table 'Area_o_Region'

Alter Table dbo.Area_o_Region
Add Constraint PK_Area_o_Region
    Primary Key Clustered (Region_id ASC);
Go

-- Creating Primary Key On Auxiliar_id in Table 'Auxiliar'
Alter Table dbo.Auxiliar
Add Constraint PK_Auxiliar
    Primary Key Clustered (Auxiliar_id ASC);
Go

-- Creating Primary Key On Llave, Moneda, Ejercicio, Mes in Table 'Catalogo'

Alter Table dbo.Catalogo
Add Constraint CatalogoPk
    Primary Key Clustered (Ejercicio, Mes, Llave, Moneda, niv);
Go

-- Creating Primary Key On Llave, Moneda, Ejercicio, Mes in Table 'CatalogoCierreTbl'

Alter Table dbo.CatalogoCierreTbl
Add Constraint CatalogoCierrePk
    Primary Key Clustered (Llave, Moneda, Ejercicio, Mes ASC);
Go

-- Creating Primary Key On Llave, Moneda, Sucursal_id, Region_id, ejercicio, mes in Table 'CatalogoAuxiliar'

Alter Table dbo.CatalogoAuxiliar
Add Constraint PK_CatalogoAuxiliar
    Primary Key Clustered (Llave, Moneda, Sucursal_id, Region_id, ejercicio, mes ASC);
Go

Create Index catalogoAuxiliarIdx01 On catalogoAuxiliar (ejercicio, mes);

-- Creating Primary Key On Llave, Moneda, Sucursal_id, Region_id, ejercicio, mes in Table 'CatalogoAuxiliarCierre'

Alter Table dbo.CatalogoAuxiliarCierre
Add   Constraint PkCatalogoAuxiliarCierre
Primary Key Clustered (Llave, Moneda, Sucursal_id, Region_id, ejercicio, mes);
Go

-- Creating Primary Key On Llave, Moneda, Sucursal_id, Region_id, ejercicio, mes in Table 'CatalogoAuxiliarCierreTbl'

Alter Table dbo.CatalogoAuxiliarCierreTbl
Add Constraint CatalogoAuxiliarCierrePk
    Primary Key Clustered (Llave, Moneda, Sucursal_id, Region_id, ejercicio, mes);
Go

-- Creating Primary Key On numerodecuenta, moneda_id in Table 'CatalogoConsolidado'

Alter Table dbo.CatalogoConsolidado
Add Constraint PK_CatalogoConsolidado
    Primary Key Clustered (numerodecuenta, moneda_id ASC);
Go

-- Creating Primary Key On Llave, Moneda, Sector_id_externa, Sucursal_id_externa in Table 'CatAuxExterno'

Alter Table dbo.CatAuxExterno
Add Constraint PK_CatAuxExterno
    Primary Key Clustered (Llave, Moneda, Sector_id_externa, Sucursal_id_externa ASC);
Go

-- Creating Primary Key On IdCausaRechazo in Table 'catCausasRechazoTbl'

Alter Table dbo.catCausasRechazoTbl
Add Constraint PK_catCausasRechazoTbl
    Primary Key Clustered (IdCausaRechazo ASC);
Go

-- Creating Primary Key On idPais, idEstado, idCiudad in Table 'catCiudadesTbl'
Alter Table dbo.catCiudadesTbl
Add Constraint PK_catCiudadesTbl
    Primary Key Clustered (idPais, idEstado, idCiudad ASC);
Go

-- Creating Primary Key On idPais, idEstado, idMunicipio, idCodigoPostal, idColonia in Table 'catCodigosPostalesTbl'
Alter Table dbo.catCodigosPostalesTbl
Add Constraint PK_catCodigosPostalesTbl
    Primary Key Clustered (idPais, idEstado, idMunicipio, idCodigoPostal, idColonia ASC);
Go

-- Creating Primary Key On criterio, valor in Table 'catCriteriosTbl'
Alter Table dbo.catCriteriosTbl
Add Constraint PK_catCriteriosTbl
    Primary Key Clustered (criterio, valor ASC);
Go

-- Creating Primary Key On idPais, idEstado in Table 'catEstadosSATTbl'
Alter Table dbo.catEstadosSATTbl
Add Constraint PK_catEstadosSATTbl
    Primary Key Clustered (idPais, idEstado ASC);
Go

-- Creating Primary Key On idPais, idEstado in Table 'catEstadosTbl'
Alter Table dbo.catEstadosTbl
Add Constraint PK_catEstadosTbl
    Primary Key Clustered (idPais, idEstado ASC);
Go

-- Creating Primary Key On tabla, columna, valor in Table 'catGeneralesTbl'
Alter Table dbo.catGeneralesTbl
Add Constraint PK_catGeneralesTbl
    Primary Key Clustered (tabla, columna, valor ASC);
Go

-- Creating Primary Key On idPais, idEstado, idMunicipio in Table 'catMunicipiosTbl'
Alter Table dbo.catMunicipiosTbl
Add Constraint PK_catMunicipiosTbl
    Primary Key Clustered (idPais, idEstado, idMunicipio ASC);
Go

-- Creating Primary Key On idPais in Table 'catPaisesSATTbl'
Alter Table dbo.catPaisesSATTbl
Add Constraint PK_catPaisesSATTbl
    Primary Key Clustered (idPais ASC);
Go

-- Creating Primary Key On idPais in Table 'catPaisesTbl'
Alter Table dbo.catPaisesTbl
Add Constraint PK_catPaisesTbl
    Primary Key Clustered (idPais ASC);
Go

-- Creating Primary Key On CodigoAgrupador in Table 'CodigoAgrupadorSAT'
Alter Table dbo.CodigoAgrupadorSAT
Add Constraint PK_CodigoAgrupadorSAT
    Primary Key Clustered (CodigoAgrupador ASC);
Go

-- Creating Primary Key On cont_id in Table 'Contadores'
Alter Table dbo.Contadores
Add Constraint PK_Contadores
    Primary Key Clustered (cont_id ASC);
Go

-- Creating Primary Key On Ejercicio, Mes in Table 'ControlCierreTbl'

Alter Table dbo.ControlCierreTbl
Add   Constraint ControlCierrePk
Primary Key Clustered (Ejercicio, Mes ASC);
Go

-- Creating Primary Key On numerodecuenta, moneda_id in Table 'ControlAuxiliarCC'
Alter Table dbo.ControlAuxiliarCC
Add Constraint PK_ControlAuxiliarCC
    Primary Key Clustered (numerodecuenta, moneda_id ASC);
Go

-- Creating Primary Key On TipoComprobante, Ejercicio, Mes in Table 'ControlPoliza'

Alter Table dbo.ControlPoliza
Add Constraint PK_ControlPoliza
    Primary Key Clustered (TipoComprobante, Ejercicio, Mes);
Go

-- Creating Primary Key On ID in Table 'Cuentas_predeterminadas'

Alter Table dbo.Cuentas_predeterminadas
Add Constraint PK_Cuentas_predeterminadas
    Primary Key Clustered (ID);
Go

-- Creating Primary Key On Sucursal_id, Region_id in Table 'Departamento_o_Sucursal'
Alter Table dbo.Departamento_o_Sucursal
Add Constraint PK_Departamento_o_Sucursal
    Primary Key Clustered (Sucursal_id, Region_id ASC);
Go

-- Creating Primary Key On ejercicio in Table 'Ejercicios'
Alter Table dbo.Ejercicios
Add Constraint PK_Ejercicios
    Primary Key Clustered (ejercicio ASC);
Go

-- Creating Primary Key On Cons in Table 'Ejercicios_Presupuesto'

Alter Table dbo.Ejercicios_Presupuesto
Add Constraint PK_Ejercicios_Presupuesto
    Primary Key Clustered (Ejercicio);
Go

-- Creating Primary Key On Cons in Table 'Formato_ER'
Alter Table dbo.Formato_ER
Add Constraint PK_Formato_ER
    Primary Key Clustered (Cons ASC);
Go

-- Creating Primary Key On IdFormato in Table 'Formatos'
Alter Table dbo.Formatos
Add Constraint PK_Formatos
    Primary Key Clustered (IdFormato ASC);
Go

-- Creating Primary Key On IdFormato, IdEmpresa in Table 'Formatos_Empresas'
Alter Table dbo.Formatos_Empresas
Add Constraint PK_Formatos_Empresas
    Primary Key Clustered (IdFormato, IdEmpresa ASC);
Go

-- Creating Primary Key On GrupoArea_id in Table 'Grupo_Area_o_Region'
Alter Table dbo.Grupo_Area_o_Region
Add Constraint PK_Grupo_Area_o_Region
    Primary Key Clustered (GrupoArea_id ASC);
Go

-- Creating Primary Key On GrupoArea_id, Region_id in Table 'Grupo_Area_o_Region_detalle'
Alter Table dbo.Grupo_Area_o_Region_detalle
Add Constraint PK_Grupo_Area_o_Region_detalle
    Primary Key Clustered (GrupoArea_id, Region_id ASC);
Go

-- Creating Primary Key On grupo_id in Table 'Grupos'

Alter Table dbo.Grupos
Add Constraint PK_Grupos
    Primary Key Clustered (grupo_id ASC);
Go

-- Creating Primary Key On IdFormato, IdEmpresa, Grupo in Table 'Grupos_Empresas'
Alter Table dbo.Grupos_Empresas
Add Constraint PK_Grupos_Empresas
    Primary Key Clustered (IdFormato, IdEmpresa, Grupo ASC);
Go

-- Creating Primary Key On Mayor, Sector_id in Table 'Mayor_Sector'
Alter Table dbo.Mayor_Sector
Add Constraint PK_Mayor_Sector
    Primary Key Clustered (Mayor, Sector_id ASC);
Go

-- Creating Primary Key On moneda_id in Table 'Moneda'
Alter   Table dbo.Moneda
Add     Constraint PK_Moneda
Primary Key Clustered (moneda_mex ASC);
Go

-- Creating Primary Key On Referencia, Cons, Fecha_mov, Ejercicio, Mes in Table 'MovDia'

Alter Table dbo.MovDia
Add Constraint PK_MovDia
    Primary Key Clustered (Referencia, Cons, Fecha_mov, Ejercicio, Mes ASC);
Go

-- Creating Primary Key On Referencia, Cons, Fecha_mov, Ejercicio, mes in Table 'Movimientos'

Alter Table dbo.Movimientos
Add Constraint PK_Movimientos
    Primary Key Clustered (Referencia, Cons, Fecha_mov, Ejercicio, mes ASC);
Go

-- Creating Primary Key On Referencia, Cons, Fecha_mov, Ejercicio, mes in Table 'MovimientosHist'

Alter Table dbo.MovimientosHist
Add Constraint PK_MovimientosHist
    Primary Key Clustered (Referencia, Cons, Fecha_mov, Ejercicio, mes ASC);
Go

-- Creating Primary Key On Referencia, Cons, Fecha_mov, Ejercicio, mes in Table 'MovimientosCierre'

Alter Table dbo.MovimientosCierre
Add Constraint PK_MovimientosCierre
    Primary Key Clustered (Referencia, Cons, Fecha_mov, Ejercicio, mes ASC);
Go


-- Creating Primary Key On Referencia, Cons, Fecha_mov, Ejercicio, mes in Table 'MovimientosCaptura'

Alter Table dbo.MovimientosCaptura
Add Constraint PK_MovimientosCaptura
    Primary Key Clustered (Referencia, Cons, Fecha_mov, Ejercicio, mes ASC);
Go

-- Creating Primary Key On ejercicio, mes, Referencia, Fecha_mov, Cons, idError in Table 'MovimientosErrores'
Alter Table dbo.MovimientosErrores
Add Constraint PK_MovimientosErrores
    Primary Key Clustered (ejercicio, mes, Referencia, Fecha_mov, Cons, idError ASC);
Go

-- Creating Primary Key On Naturaleza_id in Table 'Naturaleza_Cuentas'
Alter Table dbo.Naturaleza_Cuentas
Add Constraint PK_Naturaleza_Cuentas
    Primary Key Clustered (Naturaleza_id ASC);
Go

-- Creating Primary Key On id in Table 'Parametros'
Alter Table dbo.Parametros
Add Constraint PK_Parametros
    Primary Key Clustered (id ASC);
Go


-- Creating Primary Key On Referencia, Fecha_Mov, Ejercicio, Mes in Table 'PolDia'
Alter Table dbo.PolDia
Add Constraint PK_PolDia
    Primary Key Clustered (Referencia, Fecha_Mov, Ejercicio, Mes ASC);
Go

-- Creating Primary Key On Referencia, Fecha_mov, ejercicio, mes in Table 'Poliza'
Alter Table dbo.Poliza
Add Constraint PK_Poliza
    Primary Key Clustered (Referencia, Fecha_mov, ejercicio, mes ASC);
Go

-- Creating Primary Key On Referencia, Fecha_mov, ejercicio, mes in Table 'PolizaHist'

Alter Table dbo.PolizaHist
Add Constraint PK_PolizaHist
    Primary Key Clustered (Referencia, Fecha_mov, ejercicio, mes ASC);
Go

-- Creating Primary Key On Referencia, Fecha_mov, ejercicio, mes in Table 'PolizaCierre'

Alter Table dbo.PolizaCierre
Add Constraint PK_PolizaCierre
    Primary Key Clustered (Referencia, Fecha_mov, ejercicio, mes ASC);
Go

-- Creating Primary Key On Referencia, Fecha_mov, ejercicio, mes in Table 'PolizaCaptura'

Alter Table dbo.PolizaCaptura
Add Constraint PK_PolizaCaptura
    Primary Key Clustered (Referencia, Fecha_mov, ejercicio, mes ASC);
Go

-- Creating Primary Key On numerodecuenta, moneda_mex, periodo in Table 'Promedios'

Alter Table dbo.Promedios
Add Constraint PK_Promedios
    Primary Key Clustered (Llave, moneda_id, ejercicio, mes  ASC);
Go

-- Creating Primary Key On Rango_id in Table 'Rangos'
Alter Table dbo.Rangos
Add Constraint PK_Rangos
    Primary Key Clustered (Rango_id ASC);
Go

-- Creating Primary Key On Cons, IdFormato in Table 'Reportes_Formatos'
Alter Table dbo.Reportes_Formatos
Add Constraint PK_Reportes_Formatos
    Primary Key Clustered (Cons, IdFormato ASC);
Go

-- Creating Primary Key On Sector_id in Table 'Sector'
Alter Table dbo.Sector
Add Constraint PK_Sector
    Primary Key Clustered (Sector_id ASC);
Go

-- Creating Primary Key On Mayor in Table 'Sectorizacion'
Alter Table dbo.Sectorizacion
Add Constraint PK_Sectorizacion
    Primary Key Clustered (Mayor ASC);
Go

-- Creating Primary Key On Subrango_id in Table 'SubRangos'

Alter Table dbo.SubRangos
Add Constraint PK_SubRangos
    Primary Key Clustered (Subrango_id ASC);
Go

-- Creating Primary Key On idRelacion  in table RelSubRangos_DepartamentosTbl

Alter Table dbo.RelSubRangos_DepartamentosTbl
Add   Constraint RelSubRangos_DepartamentosPk
Primary Key (idRelacion)
Go

Create Unique Index RelSubRangos_DepartamentosIdx01 On dbo.RelSubRangos_DepartamentosTbl
 (Subrango_id, Sucursal_id, Region_id)
Go

-- Creating Primary Key On ID_Reexp in Table 'TasaReex'
Alter Table dbo.TasaReex
Add Constraint PK_TasaReex
    Primary Key Clustered (ID_Reexp ASC);
Go

-- Creating Primary Key On tc_id in Table 'TipoDeCambio'
Alter Table dbo.TipoDeCambio
Add Constraint PK_TipoDeCambio
    Primary Key Clustered (tc_id ASC);
Go

-- Creating Primary Key On Tipo in Table 'TipoPol'
Alter Table dbo.TipoPol
Add Constraint PK_TipoPol
    Primary Key Clustered (Tipo ASC);
Go

-- Creating Primary Key On ID_Reexp, fechamov in Table 'TipoReex'
Alter Table dbo.TipoReex
Add Constraint PK_TipoReex
    Primary Key Clustered (ID_Reexp, fechamov ASC);
Go

-- Creating Primary Key On usuario in Table 'Usuarios'
Alter Table dbo.Usuarios
Add Constraint PK_Usuarios
    Primary Key Clustered (usuario ASC);
Go

-- Creating Primary Key On idPais, idEstado, idMunicipio, idColonia in Table 'catColoniasTbl'

Alter Table dbo.catColoniasTbl
Add Constraint PK_catColoniasTbl
    Primary Key Clustered (idPais, idEstado, idMunicipio, idColonia ASC);
Go

-- Creating Primary Key On Llave, Moneda, Niv in Table 'MapeoCodigoAgrupador'

Alter Table dbo.MapeoCodigoAgrupador
Add   Constraint PK_MapeoCodigoAgrupador
      Primary Key Clustered (Llave, Moneda_id, Niv);
Go

-- Creating Primary Key On Id

Alter Table dbo.Parametro_Rutas
Add   Constraint Parametro_RutasPk
Primary Key (id);


-- --------------------------------------------------
-- Creating all Foreign Key constraints
-- --------------------------------------------------


-- Creating Foreign Key On Region_id in Table 'Departamento_o_Sucursal'

Alter Table dbo.Departamento_o_Sucursal
Add Constraint FK_Departamento_o_SucursalFk01
    Foreign Key (Region_id)
    References dbo.Area_o_Region
        (Region_id)
    On Delete No Action On Update No Action;
Go

-- Creating non-Clustered Index for Foreign Key 'FK_Departamento_o_SucursalFk01'
Create Index IX_FK_Departamento_o_SucursalFk01
On dbo.Departamento_o_Sucursal
    (Region_id);
Go

-- Creating Foreign Key On Region_id in Table 'PolizaCaptura'
Alter Table dbo.PolizaCaptura
Add Constraint FK__PolizaCap__Regio__2FBA0BF1
    Foreign Key (Region_id)
    References dbo.Area_o_Region
        (Region_id)
    On Delete No Action On Update No Action;
Go

-- Creating non-Clustered Index for Foreign Key 'FK__PolizaCap__Regio__2FBA0BF1'
Create Index IX_FK__PolizaCap__Regio__2FBA0BF1
On dbo.PolizaCaptura
    (Region_id);
Go

-- Creating Foreign Key On Region_id in Table 'Grupo_Area_o_Region_detalle'

Alter Table dbo.Grupo_Area_o_Region_detalle
Add Constraint FK_Grupo_Area_o_Region_detalleFk02
    Foreign Key (Region_id)
    References dbo.Area_o_Region
        (Region_id)
    On Delete No Action On Update No Action;
Go

-- Creating non-Clustered Index for Foreign Key 'FK_Grupo_Area_o_Region_detalleFk02'
Create Index IX_FK_Grupo_Area_o_Region_detalleFk02
On dbo.Grupo_Area_o_Region_detalle
    (Region_id);
Go

-- Creating Foreign Key On Llave, Moneda in Table 'Catalogo'

Alter Table dbo.Catalogo
Add Constraint FK_CatalogoFk01
    Foreign Key (Llave, Moneda)
    References dbo.CatalogoConsolidado
        (numerodecuenta, moneda_id)
    On Delete No Action On Update No Action;
Go



-- Creating Foreign Key On Region_id, Sucursal_id in Table 'CatalogoAuxiliar'

Alter Table dbo.CatalogoAuxiliar
Add Constraint FK_CatalogoAuxiliarFk01
    Foreign Key (Sucursal_id, Region_id)
    References dbo.Departamento_o_Sucursal
        (Sucursal_id, Region_id)
    On Delete No Action On Update No Action;
Go

-- Creating Foreign Key On Llave, Moneda in Table 'CatalogoAuxiliar'

Alter Table dbo.CatalogoAuxiliar
Add Constraint FK_CatalogoAuxiliarFk03
    Foreign Key (Llave, Moneda)
    References dbo.CatalogoConsolidado
        (numerodecuenta, moneda_id)
    On Delete No Action On Update No Action;
Go

-- Creating Foreign Key On Region_id, Sucursal_id in Table 'CatalogoAuxiliarCierre'

Alter Table dbo.CatalogoAuxiliarCierre
Add Constraint Fk01CatalogoAuxiliarCierre
Foreign Key (Sucursal_id, Region_id)
References dbo.Departamento_o_Sucursal (Sucursal_id, Region_id)
   On Delete No Action On Update No Action;
Go

-- Creating non-Clustered Index for Foreign Key 'Fk01CatalogoAuxiliarCierre'

Create Index CatalogoAuxiliarCierreIdx01
On dbo.CatalogoAuxiliarCierre
    (Region_id, Sucursal_id);
Go

-- Creating Foreign Key On Moneda in Table 'CatalogoAuxiliarCierre'

Alter Table dbo.CatalogoAuxiliarCierre
Add   Constraint Fk02CatalogoAuxiliarCierre
Foreign Key (Moneda)
References dbo.Moneda (moneda_mex)
On Delete No Action On Update No Action;
Go

-- Creating Foreign Key On Llave, Moneda in Table 'CatalogoAuxiliarCierre'

Alter Table dbo.CatalogoAuxiliarCierre
Add   Constraint Fk03CatalogoAuxiliarCierre
Foreign Key (Llave, Moneda)
References dbo.CatalogoConsolidado (numerodecuenta, moneda_id)
On Delete No Action On Update No Action;
Go

-- Creating Foreign Key On Region_id, Sucursal_id in Table 'CatalogoAuxiliarCierreTbl'

Alter Table dbo.CatalogoAuxiliarCierreTbl
Add Constraint CatalogoAuxiliarCierreFk01
    Foreign Key (Sucursal_id, Region_id)
    References dbo.Departamento_o_Sucursal
        (Sucursal_id, Region_id)

    On Delete No Action On Update No Action;
Go

-- Creating non-Clustered Index for Foreign Key 'CatalogoAuxiliarCierreFk01'

Create Index IX_CatalogoAuxiliarCierre
On dbo.CatalogoAuxiliarCierreTbl
    (Region_id, Sucursal_id);
Go

-- Creating Foreign Key On Moneda in Table 'CatalogoAuxiliarCierreTbl'

Alter Table dbo.CatalogoAuxiliarCierreTbl
Add Constraint CatalogoAuxiliarCierreFk02
    Foreign Key (moneda)
    References dbo.Moneda (moneda_mex)
    On Delete No Action On Update No Action;
Go

-- Creating Foreign Key On Llave, Moneda in Table 'CatalogoAuxiliarCierre'

Alter Table dbo.CatalogoAuxiliarCierreTbl
Add Constraint CatalogoAuxiliarCierreFk03
    Foreign Key (Llave, moneda)
    References dbo.CatalogoConsolidado
        (numerodecuenta, moneda_id)
    On Delete No Action On Update No Action;
Go

--

-- Creating Foreign Key On moneda_id in Table 'CatalogoConsolidado'

Alter Table dbo.CatalogoConsolidado
Add Constraint FK_catalogoConsolidadoFk01
    Foreign Key (moneda_id)
    References dbo.Moneda  (moneda_mex)
    On Delete No Action On Update No Action;
Go

-- Creating non-Clustered Index for Foreign Key 'FK_catalogoConsolidadoFk01'

Create Index IX_FK_catalogoConsolidadoFk01
On dbo.CatalogoConsolidado
    (moneda_id);
Go

-- Creating Foreign Key On Llave, Moneda in Table 'CatAuxExterno'

Alter Table dbo.CatAuxExterno
Add Constraint FK_CatAuxExternoFk01
    Foreign Key (Llave, Moneda)
    References dbo.CatalogoConsolidado
        (numerodecuenta, moneda_id)
    On Delete No Action On Update No Action;
Go

-- Creating Foreign Key On numerodecuenta, moneda_id in Table 'ControlAuxiliarCC'
Alter Table dbo.ControlAuxiliarCC
Add Constraint FK_ControlAuxiliarCCFk01
    Foreign Key (numerodecuenta, moneda_id)
    References dbo.CatalogoConsolidado
        (numerodecuenta, moneda_id)
    On Delete No Action On Update No Action;
Go

-- Creating Foreign Key On Llave, Moneda in Table 'MovDia'

Alter Table dbo.MovDia
Add Constraint FK_MovDiaFk05
    Foreign Key (Llave, Moneda)
    References dbo.CatalogoConsolidado
        (numerodecuenta, moneda_id)
    On Delete No Action On Update No Action;
Go

-- Creating non-Clustered Index for Foreign Key 'FK_MovDiaFk05'

Create Index IX_FK_MovDiaFk05
On dbo.MovDia
    (Llave, Moneda);
Go

-- Creating Foreign Key On Llave, Moneda in Table 'MovimientosCaptura'

Alter Table dbo.MovimientosCaptura
Add Constraint FK_MovimientosCapturaFk05
    Foreign Key (Llave, Moneda)
    References dbo.CatalogoConsolidado
        (numerodecuenta, moneda_id)
    On Delete No Action On Update No Action;
Go

-- Creating non-Clustered Index for Foreign Key 'FK_MovimientosCapturaFk05'

Create Index IX_FK_MovimientosCapturaFk05
On dbo.MovimientosCaptura
    (Llave, Moneda);
Go

-- Creating Foreign Key On Llave, Moneda in Table 'MovimientosErrores'
Alter Table dbo.MovimientosErrores
Add Constraint FK_MovimientosErroresFk02
    Foreign Key (Llave, Moneda)
    References dbo.CatalogoConsolidado
        (numerodecuenta, moneda_id)
    On Delete No Action On Update No Action;
Go

-- Creating non-Clustered Index for Foreign Key 'FK_MovimientosErroresFk02'

Create Index IX_FK_MovimientosErroresFk02
On dbo.MovimientosErrores
    (Llave, Moneda);
Go

-- Creating Foreign Key On Llave, Moneda in Table 'Movimientos'

Alter Table dbo.Movimientos
Add Constraint FK_MovimientosFk05
    Foreign Key (Llave, Moneda)
    References dbo.CatalogoConsolidado
        (numerodecuenta, moneda_id)
    On Delete No Action On Update No Action;
Go

-- Creating non-Clustered Index for Foreign Key 'FK_MovimientosFk05'

Create Index IX_FK_MovimientosFk05
On dbo.Movimientos
    (Llave, Moneda);
Go

-- Creating Foreign Key On Moneda in Table 'CatAuxExterno'

Alter Table dbo.CatAuxExterno
Add Constraint FK_CatAuxExternoFk04
    Foreign Key (Moneda)
    References dbo.Moneda (moneda_mex)
    On Delete No Action On Update No Action;
Go

-- Creating non-Clustered Index for Foreign Key 'FK_CatAuxExternoFk04'

Create Index IX_FK_CatAuxExternoFk04
On dbo.CatAuxExterno
    (Moneda);
Go

-- Creating Foreign Key On idPais, idEstado in Table 'catCiudadesTbl'

Alter Table dbo.catCiudadesTbl
Add Constraint FK_catCiudadesFk01
Foreign Key (idPais, idEstado)
References dbo.catEstadosTbl(idPais, idEstado) On Delete No Action On Update No Action;
Go

-- Creating Foreign Key On idPais in Table 'catEstadosTbl'
Alter Table dbo.catEstadosTbl
Add Constraint FK_catEstadosFk01
    Foreign Key (idPais)
    References dbo.catPaisesTbl
        (idPais)
    On Delete No Action On Update No Action;
Go

-- Creating Foreign Key On codigoSat in Table 'catPaisesTbl'

Alter Table dbo.catPaisesTbl
Add Constraint FK_C_catPaisesFk01
    Foreign Key (codigoSat)
    References dbo.catPaisesSATTbl
        (idPais)
    On Delete No Action On Update No Action;
Go

-- Creating non-Clustered Index for Foreign Key 'FK_C_catPaisesFk01'

Create Index IX_FK_C_catPaisesFk01
On dbo.catPaisesTbl
    (codigoSat);
Go

-- Creating Foreign Key On TipoComprobante in Table 'ControlPoliza'

Alter Table dbo.ControlPoliza
Add Constraint FK_ControlPolizaFk01
    Foreign Key (TipoComprobante)
    References dbo.TipoPol(Tipo)
    On Delete No Action On Update No Action;
Go

-- Creating Foreign Key On CuentaInterna, moneda in Table 'Cuentas_predeterminadas'

Alter Table dbo.Cuentas_predeterminadas
Add Constraint FK_Cuentas_predeterminadasFk01
    Foreign Key (CuentaInterna, moneda_id)
    References dbo.CatalogoConsolidado
    On Delete No Action On Update No Action;
Go


-- Creating Foreign Key On TipoPoliza in Table 'Cuentas_predeterminadas'

Alter Table dbo.Cuentas_predeterminadas
Add Constraint FK_Cuentas_predeterminadasFk02
    Foreign Key (TipoPoliza)
    References dbo.TipoPol
        (Tipo)
    On Delete No Action On Update No Action;
Go

-- Creating non-Clustered Index for Foreign Key 'FK_Cuentas_predeterminadasFk01'

Create Unique Index IX_FK_Cuentas_predeterminadasFk01
On dbo.Cuentas_predeterminadas
    (TipoPoliza, CuentaInterna, moneda_id);
Go

-- Creating Foreign Key On Region_id, Sucursal_id in Table 'MovDia'

Alter Table dbo.MovDia
Add Constraint FK_MovDiaFk03
    Foreign Key (Sucursal_id, Region_id )
    References dbo.Departamento_o_Sucursal
        (Sucursal_id, Region_id)
    On Delete No Action On Update No Action;
Go

-- Creating non-Clustered Index for Foreign Key 'FK_MovDiaFk03'
Create Index IX_FK_MovDiaFk03
On dbo.MovDia
    (Region_id, Sucursal_id);
Go

-- Creating Foreign Key On Region_id, Sucursal_id in Table 'MovimientosCaptura'
Alter Table dbo.MovimientosCaptura
Add Constraint FK_MovimientosCapturaFk03
    Foreign Key (Sucursal_id, Region_id)
    References dbo.Departamento_o_Sucursal
        (Sucursal_id, Region_id)
    On Delete No Action On Update No Action;
Go

-- Creating non-Clustered Index for Foreign Key 'FK_MovimientosCapturaFk03'
Create Index IX_FK_MovimientosCapturaFk03
On dbo.MovimientosCaptura
    (Region_id, Sucursal_id);
Go

-- Creating Foreign Key On Region_id, Sucursal_id in Table 'MovimientosErrores'

Alter Table dbo.MovimientosErrores
Add Constraint FK_MovimientosErroresFk01
    Foreign Key (Sucursal_id, Region_id)
    References dbo.Departamento_o_Sucursal
        (Sucursal_id, Region_id)
    On Delete No Action On Update No Action;
Go

-- Creating non-Clustered Index for Foreign Key 'FK_MovimientosErroresFk01'

Create Index IX_FK_MovimientosErroresFk01
On dbo.MovimientosErrores
    (Region_id, Sucursal_id);
Go

-- Creating Foreign Key On Region_id, Sucursal_id in Table 'Movimientos'
Alter Table dbo.Movimientos
Add Constraint FK_MovimientosFk03
    Foreign Key (Sucursal_id, Region_id )
    References dbo.Departamento_o_Sucursal
        (Sucursal_id, Region_id)
    On Delete No Action On Update No Action;
Go

-- Creating non-Clustered Index for Foreign Key 'FK_MovimientosFk03'

Create Index IX_FK_MovimientosFk03
On dbo.Movimientos
    (Region_id, Sucursal_id);
Go

-- Creating Foreign Key On Ejercicio in Table 'PolDia'
Alter Table dbo.PolDia
Add Constraint FK_PolDiaFk03
    Foreign Key (Ejercicio)
    References dbo.Ejercicios
        (ejercicio)
    On Delete No Action On Update No Action;
Go

-- Creating non-Clustered Index for Foreign Key 'FK_PolDiaFk03'

Create Index IX_FK_PolDiaFk03
On dbo.PolDia
    (Ejercicio);
Go

-- Creating Foreign Key On ejercicio in Table 'PolizaCaptura'
Alter Table dbo.PolizaCaptura
Add Constraint FK_PolizaCapturaFk03
    Foreign Key (ejercicio)
    References dbo.Ejercicios
        (ejercicio)
    On Delete No Action On Update No Action;
Go

-- Creating non-Clustered Index for Foreign Key 'FK_PolizaCapturaFk03'

Create Index IX_FK_PolizaCapturaFk03
On dbo.PolizaCaptura
    (ejercicio);
Go

-- Creating Foreign Key On ejercicio in Table 'Poliza'

Alter Table dbo.Poliza
Add Constraint FK_PolizaFk03
    Foreign Key (ejercicio)
    References dbo.Ejercicios
        (ejercicio)
    On Delete No Action On Update No Action;
Go

-- Creating non-Clustered Index for Foreign Key 'FK_PolizaFk03'

Create Index IX_FK_PolizaFk03
On dbo.Poliza
    (ejercicio);
Go

-- Creating Foreign Key On ejercicio in Table 'PolizaHist'

Alter Table dbo.PolizaHist
Add Constraint FK_PolizaHistFk03
    Foreign Key (ejercicio)
    References dbo.Ejercicios (ejercicio)
    On Delete No Action On Update No Action;
Go

-- Creating Foreign Key On ejercicio in Table 'PolizaCierre'

Alter Table dbo.PolizaCierre
Add Constraint FK_PolizaCierreFk03
    Foreign Key (ejercicio)
    References dbo.Ejercicios (ejercicio)
    On Delete No Action On Update No Action;
Go

-- Creating Foreign Key On GrupoArea_id in Table 'Grupo_Area_o_Region_detalle'

Alter Table dbo.Grupo_Area_o_Region_detalle
Add Constraint FK_Grupo_Area_o_Region_detalleFk01
    Foreign Key (GrupoArea_id)
    References dbo.Grupo_Area_o_Region
        (GrupoArea_id)
    On Delete No Action On Update No Action;
Go

-- Creating Foreign Key On Moneda in Table 'MovDia'

Alter Table dbo.MovDia
Add Constraint FK_MovDiaFk04
    Foreign Key (Moneda)
    References dbo.Moneda(moneda_mex)
    On Delete No Action On Update No Action;
Go

-- Creating non-Clustered Index for Foreign Key 'FK_MovDiaFk04'

Create Index IX_FK_MovDiaFk04
On dbo.MovDia
    (Moneda);
Go

-- Creating Foreign Key On Moneda in Table 'MovimientosCaptura'

Alter Table dbo.MovimientosCaptura
Add Constraint FK_MovimientosCapturaFk04
    Foreign Key (Moneda)
    References dbo.Moneda
        (moneda_mex)
    On Delete No Action On Update No Action;
Go

-- Creating non-Clustered Index for Foreign Key 'FK_MovimientosCapturaFk04'

Create Index IX_FK_MovimientosCapturaFk04
On dbo.MovimientosCaptura(Moneda);
Go

-- Creating Foreign Key On Moneda in Table 'Movimientos'
Alter Table dbo.Movimientos
Add Constraint FK_MovimientosFk04
    Foreign Key (Moneda)
    References dbo.Moneda(moneda_mex)
    On Delete No Action On Update No Action;
Go

-- Creating non-Clustered Index for Foreign Key 'FK_MovimientosFk04'
Create Index IX_FK_MovimientosFk04
On dbo.Movimientos (Moneda);
Go


-- Creating Foreign Key On moneda_id in Table 'TipoDeCambio'
Alter Table dbo.TipoDeCambio
Add Constraint FK_TipoDeCambioFk01
    Foreign Key (moneda_id)
    References dbo.Moneda
        (moneda_mex)
    On Delete No Action On Update No Action;
Go

-- Creating non-Clustered Index for Foreign Key 'FK_TipoDeCambioFk01'

Create Index IX_FK_TipoDeCambioFk01
On dbo.TipoDeCambio
    (moneda_id);
Go

-- Creating Foreign Key On Ejercicio, Mes, Referencia, Fecha_mov in Table 'MovDia'

Alter Table dbo.MovDia
Add Constraint FK_MovDiaFk01
    Foreign Key (Referencia, Fecha_mov, ejercicio, mes)
    References dbo.PolDia
        (Referencia, Fecha_mov, ejercicio, mes)
    On Delete No Action On Update No Action;
Go

-- Creating Foreign Key On Sector_id in Table 'MovDia'

Alter Table dbo.MovDia
Add Constraint FK_MovDiaFk02
    Foreign Key (Sector_id)
    References dbo.Sector
        (Sector_id)
    On Delete No Action On Update No Action;
Go

-- Creating non-Clustered Index for Foreign Key 'FK_MovDiaFk02'

Create Index IX_FK_MovDiaFk02
On dbo.MovDia
    (Sector_id);
Go

-- Creating Foreign Key On Ejercicio, mes, Referencia, Fecha_mov in Table 'Movimientos'

Alter Table dbo.Movimientos
Add Constraint FK_MovimientosFk01
    Foreign Key (Referencia, Fecha_mov, ejercicio, mes)
    References dbo.Poliza
        (Referencia, Fecha_mov, ejercicio, mes)
    On Delete No Action On Update No Action;
Go

-- Creating Foreign Key On Ejercicio, mes, Referencia, Fecha_mov in Table 'MovimientosHist'

Alter Table dbo.MovimientosHist
Add Constraint FK_MovimientosHistFk01
    Foreign Key (Referencia, Fecha_mov, ejercicio, mes)
    References dbo.PolizaHist
        (Referencia, Fecha_mov, ejercicio, mes)
    On Delete No Action On Update No Action;
Go

-- Creating Foreign Key On Ejercicio, mes, Referencia, Fecha_mov in Table 'MovimientosCierre'

Alter Table dbo.MovimientosCierre
Add Constraint MovimientosCierreFk01
    Foreign Key (Referencia, Fecha_mov, ejercicio, mes)
    References dbo.polizacierre
        (Referencia, Fecha_mov, ejercicio, mes)
    On Delete No Action On Update No Action;
Go


-- Creating non-Clustered Index for Foreign Key 'FK_MovimientosFk01'

Create Index IX_FK_MovimientosFk01
On dbo.Movimientos
    (Ejercicio, mes, Referencia, Fecha_mov);
Go

-- Creating non-Clustered Index for Foreign Key 'FK_MovimientosHistFk01'

Create Index IX_FK_MovimientosHistFk01
On dbo.MovimientosHist
    (Ejercicio, mes, Referencia, Fecha_mov);
Go

-- Creating non-Clustered Index for Foreign Key 'MovimientosCierreFk01'

Create Index IX_MovimientosCierreFk01
On dbo.MovimientosCierre
    (Ejercicio, mes, Referencia, Fecha_mov);
Go

-- Creating Foreign Key On Sector_id in Table 'Movimientos'

Alter Table dbo.Movimientos
Add Constraint FK_MovimientosFk02
    Foreign Key (Sector_id)
    References dbo.Sector
        (Sector_id)
    On Delete No Action On Update No Action;
Go

-- Creating Foreign Key On Sector_id in Table 'MovimientosHist'

Alter Table dbo.MovimientosHist
Add Constraint FK_MovimientosHistFk02
    Foreign Key (Sector_id)
    References dbo.Sector
        (Sector_id)
    On Delete No Action On Update No Action;
Go

-- Creating Foreign Key On Sector_id in Table 'MovimientosHist'

Alter Table dbo.MovimientosHist
Add   constraint MovimientosHistFk03
Foreign Key (Llave, moneda)
References dbo.catalogoConsolidado(numerodecuenta, moneda_id)

-- Creating Foreign Key On Sector_id in Table 'MovimientosCierre'

Alter Table dbo.MovimientosCierre
Add Constraint MovimientosCierreFk02
    Foreign Key (Sector_id)
    References dbo.Sector
        (Sector_id)
    On Delete No Action On Update No Action;
Go

-- Creating non-Clustered Index for Foreign Key 'FK_MovimientosFk02'

Create Index IX_FK_MovimientosFk02
On dbo.Movimientos(Sector_id);
Go

-- Creating non-Clustered Index for Foreign Key 'FK_MovimientosHistFk02'

Create Index IX_FK_MovimientosHistFk02
On dbo.MovimientosHist
    (Sector_id);
Go


-- Creating non-Clustered Index for Foreign Key 'FK_MovimientosCierreFk02'

Create Index IX_MovimientosCierreFk02
On dbo.MovimientosCierre
    (Sector_id);
Go

-- Creating Foreign Key On Ejercicio, mes, Referencia, Fecha_mov in Table 'MovimientosCaptura'

Alter Table dbo.MovimientosCaptura
Add Constraint FK_MovimientosCapturaFk01
    Foreign Key (Referencia, Fecha_mov, ejercicio, mes)
    References dbo.PolizaCaptura
        (Referencia, Fecha_mov, ejercicio, mes)
    On Delete No Action On Update No Action;
Go



-- Creating non-Clustered Index for Foreign Key 'FK_MovimientosCapturaFk01'

Create Index IX_FK_MovimientosCapturaFk01 On dbo.MovimientosCaptura
    (Ejercicio, mes, Referencia, Fecha_mov);
Go

-- Creating Foreign Key On Sector_id in Table 'MovimientosCaptura'

Alter Table dbo.MovimientosCaptura
Add Constraint FK_MovimientosCapturaFk02
    Foreign Key (Sector_id)
    References dbo.Sector
        (Sector_id)
    On Delete No Action On Update No Action;
Go

-- Creating non-Clustered Index for Foreign Key 'FK_MovimientosCapturaFk02'
Create Index IX_FK_MovimientosCapturaFk02
On dbo.MovimientosCaptura
    (Sector_id);
Go

-- Creating Foreign Key On Naturaleza_id in Table 'Rangos'

Alter Table dbo.Rangos
Add Constraint FK_RangosFk01
    Foreign Key (Naturaleza_id)
    References dbo.Naturaleza_Cuentas
        (Naturaleza_id)
    On Delete No Action On Update No Action;
Go

-- Creating Foreign Key in Table 'RelSubRangos_DepartamentosTbl'

Alter Table dbo.RelSubRangos_DepartamentosTbl
Add Constraint RelSubRangos_DepartamentosFk01
Foreign Key (Subrango_id)
References dbo.SubRangos(Subrango_id)
On Delete No Action On Update No Action;
Go

Alter Table dbo.RelSubRangos_DepartamentosTbl
Add Constraint RelSubRangos_DepartamentosFk02
Foreign Key (Sucursal_id, Region_id)
References dbo.Departamento_o_Sucursal(Sucursal_id, Region_id)
On Delete No Action On Update No Action;
Go

Alter Table dbo.RelSubRangos_DepartamentosTbl
Add Constraint RelSubRangos_DepartamentosFk03
Foreign Key (usuario)
References dbo.usuarios(usuario)
On Delete No Action On Update No Action;
Go


-- Creating non-Clustered Index for Foreign Key 'FK_RangosFk01'

Create Index IX_FK_RangosFk01
On dbo.Rangos
    (Naturaleza_id);
Go

-- Creating Foreign Key On TipoPoliza in Table 'PolDia'
Alter Table dbo.PolDia
Add Constraint FK_PolDiaFk01
    Foreign Key (TipoPoliza)
    References dbo.TipoPol
        (Tipo)
    On Delete No Action On Update No Action;
Go

-- Creating non-Clustered Index for Foreign Key 'FK_PolDiaFk01'

Create Index IX_FK_PolDiaFk01
On dbo.PolDia
    (TipoPoliza);
Go

-- Creating Foreign Key On TipoPoliza in Table 'Poliza'

Alter Table dbo.Poliza
Add Constraint FK_PolizaFk01
    Foreign Key (TipoPoliza)
    References dbo.TipoPol
        (Tipo)
    On Delete No Action On Update No Action;
Go

-- Creating Foreign Key On TipoPoliza in Table 'PolizaHist'

Alter Table dbo.PolizaHist
Add Constraint FK_PolizaHistFk01
    Foreign Key (TipoPoliza)
    References dbo.TipoPol (Tipo)
    On Delete No Action On Update No Action;
Go

-- Creating Foreign Key On TipoPoliza in Table 'PolizaCierre'

Alter Table dbo.PolizaCierre
Add Constraint FK_PolizaCierreFk01
    Foreign Key (TipoPoliza)
    References dbo.TipoPol (Tipo)
    On Delete No Action On Update No Action;
Go

-- Creating non-Clustered Index for Foreign Key 'FK_PolizaFk01'

Create Index IX_FK_PolizaFk01
On dbo.Poliza
    (TipoPoliza);
Go

-- Creating non-Clustered Index for Foreign Key 'FK_PolizaHistFk01'

Create Index IX_FK_PolizaHistFk01
On dbo.PolizaHist
    (TipoPoliza);
Go

-- Creating non-Clustered Index for Foreign Key 'FK_PolizaCierreFk01'

Create Index IX_FK_PolizaCierreFk01
On dbo.PolizaCierre (TipoPoliza);
Go

-- Creating Foreign Key On TipoPoliza in Table 'PolizaCaptura'

Alter Table dbo.PolizaCaptura
Add Constraint FK_PolizaCapturaFk01
    Foreign Key (TipoPoliza)
    References dbo.TipoPol
        (Tipo)
    On Delete No Action On Update No Action;
Go

-- Creating non-Clustered Index for Foreign Key 'FK_PolizaCapturaFk01'

Create Index IX_FK_PolizaCapturaFk01
On dbo.PolizaCaptura
    (TipoPoliza);
Go

-- Creating Foreign Key On Rango_id in Table 'SubRangos'

Alter Table dbo.SubRangos
Add Constraint FK_SubRangosFk01
    Foreign Key (Rango_id)
    References dbo.Rangos
        (Rango_id)
    On Delete No Action On Update No Action;
Go

-- Creating non-Clustered Index for Foreign Key 'FK_SubRangosFk01'
Create Index IX_FK_SubRangosFk01
On dbo.SubRangos
    (Rango_id);
Go

-- Creating Foreign Key On Llave, Moneda in Table 'MapeoCodigoAgrupador'

Alter Table dbo.MapeoCodigoAgrupador
Add Constraint MapeoCodigoAgrupadorFK01
    Foreign Key (Llave, Moneda_id)
    References dbo.CatalogoConsolidado
        (numerodecuenta, moneda_id)
    On Delete No Action On Update No Action;
Go


-- --------------------------------------------------
-- Script has ended
-- --------------------------------------------------