Truncate Table dbo.tmpTablasTbl

Insert Into dbo.tmpTablasTbl
(tabla)
Select 'CatalogoAuxiliarHist'
Union
Select 'CatalogoAuxiliar'
Union
Select 'Catalogo'
Union
Select 'CatalogoAuxiliarCierre'
Union
Select 'CatalogoAuxiliarCierreTbl'
Union
Select 'CatalogocierreTbl'
Union
Select 'catalogoAuxReporteTbl'
Union
Select 'catalogoReporteTbl'
Union
Select 'MovimientosHist'
Union
Select 'movimientosAnio'
Union
Select 'MovDia'
Union
Select 'MovimientosCierre'
Union
Select 'MovimientosCaptura'
Union
Select 'MovimientosErrores'
Union
Select 'PolizaHist'
Union
Select 'Poliza'
Union
Select 'polizaAnio'
Union
Select 'ControlPoliza'
Union
Select 'PolizaCierre'
Union
Select 'PolizaCaptura'
