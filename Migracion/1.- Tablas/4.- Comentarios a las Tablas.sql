--
-- Comentarios
--

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de Areas y Región',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Area_o_Region'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de Auxiliares',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Auxiliar'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de Cuentas Contables',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Catalogo'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de Cuentas Auxiliares Contables',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'CatalogoAuxiliar'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de Cuentas Auxiliares de Cierre',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'CatalogoAuxiliarCierreTbl'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de Cuentas Auxiliares de Cierre por Período',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'CatalogoAuxiliarCierre'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de Cuentas al Cierre por Período',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'CatalogocierreTbl'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de Cuentas Contables Consolidadas',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'CatalogoConsolidado'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de Cuentas Contables de Externos',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'CatAuxExterno'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de Rechazo de Pólizas Contables',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'catCausasRechazoTbl'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo SEPOMEX de Ciudades',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'catCiudadesTbl'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo SEPOMEX de Códigos Postales',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'catCodigosPostalesTbl'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo SEPOMEX de Colonias',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'catColoniasTbl'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo SEPOMEX de Estados',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'catEstadosTbl'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo SEPOMEX de Municipios',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'catMunicipiosTbl'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo SEPOMEX de Paises',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'catPaisesTbl'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo SAT de Paises',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'catPaisesSATTbl'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo SAT de Estados',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'catEstadosSATTbl'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo SAT de Códigos AGrupadores',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'CodigoAgrupadorSAT'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de descripción de criterios de seleccón',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'catCriteriosTbl'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Descripción de Catalogos Generales',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'catGeneralesTbl'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de Contadores',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Contadores'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Tabla de control de Auxiliares de CC',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'ControlAuxiliarCC'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de Cuentas Predeterminadas',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Cuentas_predeterminadas'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de Departamento y Sucursal',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Departamento_o_Sucursal'
Go


Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Tabla de control de Ejercicios contables.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Ejercicios'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Tabla de control de Ejercicios contables.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Ejercicios_Presupuesto'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de Monedas.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Moneda'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de Grupos Area y Región',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Grupo_Area_o_Region'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de Detalle de Grupos Area y Región',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Grupo_Area_o_Region_detalle'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de Grupos de Usuarios.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Grupos'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de Grupos de Empresas.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Grupos_Empresas'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de Mayores por Sectores.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Mayor_Sector'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de Mapeo de Códigos de Agrupadores Contables.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'MapeoCodigoAgrupador'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Tabla de Detalle de la Póliza Diaria.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'MovDia'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Tabla de Detalle de la Póliza Diaria por Período.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Movimientos'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Tabla de Detalle de la Póliza Diaria Histórica por Período.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'MovimientosHist'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Tabla de Detalle de la Póliza Diaria Capturada por Período.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'MovimientosCaptura'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Tabla de Detalle de la Póliza de cierre por Período.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'MovimientosCierre'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Tabla de Detalle de la Póliza con Errores.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'MovimientosErrores'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de la Naturaleaz de la cuenta contable',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Naturaleza_Cuentas'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Tabla de Encabezado de la Póliza Diaria.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'PolDia'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Tabla de Encabezado de la Póliza Diaria por Período.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Poliza'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Tabla de Encabezado de la Póliza Diaria Histórica por Período.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'PolizaHist'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Tabla de Encabezado de la Póliza Diaria Capturada por Período.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'PolizaCaptura'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Tabla de Encabezado de la Póliza de cierre por Período.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'PolizaCierre'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de Parámetros.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Parametros'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Tabla de promedios de cifras contables.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Promedios'
Go


Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de Sectores.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Sector'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de Tipo de Cambios.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'TipoDeCambio'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de Tipo de Póliza contable.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'TipoPol'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de Tipo de Reexpresión Contable.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'TipoReex'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de la tasa de Reexpresión Contable.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'TasaReex'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de Mayores de Sectorización.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Sectorizacion'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de Rangos Contables.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Rangos'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de SubRangos Contables.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'SubRangos'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de SubRangos Contables por Departamento.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'RelSubRangos_DepartamentosTbl'
Go


Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de Usuarios.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Usuarios'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de Formatos Contables ER.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Formato_ER'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de Formatos de Reportes.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Formatos'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Catálogo de Formatos de Reportes por Empresa.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Formatos_Empresas'
Go



