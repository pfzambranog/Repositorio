--
-- Script de incorporación inicial de datos en la tabla catGeneralesTbl
--

Delete dbo.catGeneralesTbl;

Insert Into dbo.catGeneralesTbl(tabla, columna, valor, descripcion, ipAct, macAddressAct) Select 'CatalogoConsolidado', 'interdepartamental', 0, 'No Interdepartamental', dbo.Fn_buscaDireccionIP(), dbo.Fn_Busca_DireccionMac()
Insert Into dbo.catGeneralesTbl(tabla, columna, valor, descripcion, ipAct, macAddressAct) Select 'CatalogoConsolidado', 'interdepartamental', 1, 'Interdepartamental', dbo.Fn_buscaDireccionIP(), dbo.Fn_Busca_DireccionMac()
Insert Into dbo.catGeneralesTbl(tabla, columna, valor, descripcion, ipAct, macAddressAct) Select 'CatalogoConsolidado', 'naturaleza', 0, 'Sin Naturaleza', dbo.Fn_buscaDireccionIP(), dbo.Fn_Busca_DireccionMac()
Insert Into dbo.catGeneralesTbl(tabla, columna, valor, descripcion, ipAct, macAddressAct) Select 'CatalogoConsolidado', 'naturaleza', 1, 'Con Naturaleza', dbo.Fn_buscaDireccionIP(), dbo.Fn_Busca_DireccionMac()
Insert Into dbo.catGeneralesTbl(tabla, columna, valor, descripcion, ipAct, macAddressAct) Select 'Departamento_o_Sucursal', 'Global', 0, 'No Global', dbo.Fn_buscaDireccionIP(), dbo.Fn_Busca_DireccionMac()
Insert Into dbo.catGeneralesTbl(tabla, columna, valor, descripcion, ipAct, macAddressAct) Select 'Departamento_o_Sucursal', 'Global', 1, 'Existe Global', dbo.Fn_buscaDireccionIP(), dbo.Fn_Busca_DireccionMac()
Insert Into dbo.catGeneralesTbl(tabla, columna, valor, descripcion, ipAct, macAddressAct) Select 'Formatos', 'Consolidado', 0, 'No Consolidado', dbo.Fn_buscaDireccionIP(), dbo.Fn_Busca_DireccionMac()
Insert Into dbo.catGeneralesTbl(tabla, columna, valor, descripcion, ipAct, macAddressAct) Select 'Formatos', 'Consolidado', 1, 'Consolidado', dbo.Fn_buscaDireccionIP(), dbo.Fn_Busca_DireccionMac()
Insert Into dbo.catGeneralesTbl(tabla, columna, valor, descripcion, ipAct, macAddressAct) Select 'Formatos', 'Privado', 0, 'Público', dbo.Fn_buscaDireccionIP(), dbo.Fn_Busca_DireccionMac()
Insert Into dbo.catGeneralesTbl(tabla, columna, valor, descripcion, ipAct, macAddressAct) Select 'Formatos', 'Privado', 1, 'Privado', dbo.Fn_buscaDireccionIP(), dbo.Fn_Busca_DireccionMac()
Insert Into dbo.catGeneralesTbl(tabla, columna, valor, descripcion, ipAct, macAddressAct) Select 'Grupo_Area_o_Region_detalle', 'activo', 0, 'Activo', dbo.Fn_buscaDireccionIP(), dbo.Fn_Busca_DireccionMac()
Insert Into dbo.catGeneralesTbl(tabla, columna, valor, descripcion, ipAct, macAddressAct) Select 'Grupo_Area_o_Region_detalle', 'activo', 1, 'Inactivo', dbo.Fn_buscaDireccionIP(), dbo.Fn_Busca_DireccionMac()
Insert Into dbo.catGeneralesTbl(tabla, columna, valor, descripcion, ipAct, macAddressAct) Select 'Grupos', 'NivelSupervisor', 0, 'Sin NivelSupervisor', dbo.Fn_buscaDireccionIP(), dbo.Fn_Busca_DireccionMac()
Insert Into dbo.catGeneralesTbl(tabla, columna, valor, descripcion, ipAct, macAddressAct) Select 'Grupos', 'NivelSupervisor', 1, 'NivelSupervisor', dbo.Fn_buscaDireccionIP(), dbo.Fn_Busca_DireccionMac()
Insert Into dbo.catGeneralesTbl(tabla, columna, valor, descripcion, ipAct, macAddressAct) Select 'Moneda', 'activo', 0, 'Inactivo', dbo.Fn_buscaDireccionIP(), dbo.Fn_Busca_DireccionMac()
Insert Into dbo.catGeneralesTbl(tabla, columna, valor, descripcion, ipAct, macAddressAct) Select 'Moneda', 'activo', 1, 'Activo', dbo.Fn_buscaDireccionIP(), dbo.Fn_Busca_DireccionMac()
Insert Into dbo.catGeneralesTbl(tabla, columna, valor, descripcion, ipAct, macAddressAct) Select 'Reportes_Formatos', 'Subrayado', 0, 'Sin Subrayado', dbo.Fn_buscaDireccionIP(), dbo.Fn_Busca_DireccionMac()
Insert Into dbo.catGeneralesTbl(tabla, columna, valor, descripcion, ipAct, macAddressAct) Select 'Reportes_Formatos', 'Subrayado', 1, 'Subrayado', dbo.Fn_buscaDireccionIP(), dbo.Fn_Busca_DireccionMac()
Insert Into dbo.catGeneralesTbl(tabla, columna, valor, descripcion, ipAct, macAddressAct) Select 'SubRangos', 'sucursalizable', 0, 'No Sucurzalible', dbo.Fn_buscaDireccionIP(), dbo.Fn_Busca_DireccionMac()
Insert Into dbo.catGeneralesTbl(tabla, columna, valor, descripcion, ipAct, macAddressAct) Select 'SubRangos', 'sucursalizable', 1, 'Sucurzalible', dbo.Fn_buscaDireccionIP(), dbo.Fn_Busca_DireccionMac()
Insert Into dbo.catGeneralesTbl(tabla, columna, valor, descripcion, ipAct, macAddressAct) Select 'Usuarios', 'activo', 0, 'Inactivo', dbo.Fn_buscaDireccionIP(), dbo.Fn_Busca_DireccionMac()
Insert Into dbo.catGeneralesTbl(tabla, columna, valor, descripcion, ipAct, macAddressAct) Select 'Usuarios', 'activo', 1, 'Activo', dbo.Fn_buscaDireccionIP(), dbo.Fn_Busca_DireccionMac()

Insert Into dbo.catGeneralesTbl(tabla, columna, valor, descripcion, ipAct, macAddressAct) Select 'control', 'idEstatus', 0, 'Mes no Habilitado', dbo.Fn_buscaDireccionIP(), dbo.Fn_Busca_DireccionMac()
Insert Into dbo.catGeneralesTbl(tabla, columna, valor, descripcion, ipAct, macAddressAct) Select 'control', 'idEstatus', 1, 'Mes en Proceso', dbo.Fn_buscaDireccionIP(), dbo.Fn_Busca_DireccionMac()
Insert Into dbo.catGeneralesTbl(tabla, columna, valor, descripcion, ipAct, macAddressAct) Select 'control', 'idEstatus', 2, 'Mes Cerrado', dbo.Fn_buscaDireccionIP(), dbo.Fn_Busca_DireccionMac()
Insert Into dbo.catGeneralesTbl(tabla, columna, valor, descripcion, ipAct, macAddressAct) Select 'control', 'idEstatus', 3, 'Mes en Proceso de Cierre', dbo.Fn_buscaDireccionIP(), dbo.Fn_Busca_DireccionMac()

Insert Into dbo.catGeneralesTbl(tabla, columna, valor, descripcion, ipAct, macAddressAct) Select 'ejercicios', 'idEstatus', 0, 'Ejercicio no Habilitado', dbo.Fn_buscaDireccionIP(), dbo.Fn_Busca_DireccionMac()
Insert Into dbo.catGeneralesTbl(tabla, columna, valor, descripcion, ipAct, macAddressAct) Select 'ejercicios', 'idEstatus', 1, 'Ejercicio en Proceso', dbo.Fn_buscaDireccionIP(), dbo.Fn_Busca_DireccionMac()
Insert Into dbo.catGeneralesTbl(tabla, columna, valor, descripcion, ipAct, macAddressAct) Select 'ejercicios', 'idEstatus', 2, 'Ejercicio Cerrado', dbo.Fn_buscaDireccionIP(), dbo.Fn_Busca_DireccionMac()
Insert Into dbo.catGeneralesTbl(tabla, columna, valor, descripcion, ipAct, macAddressAct) Select 'ejercicios', 'idEstatus', 3, 'Ejercicio en proceso de Cierre', dbo.Fn_buscaDireccionIP(), dbo.Fn_Busca_DireccionMac()
