Insert Into dbo.catPaisesSATTbl
(idPais, descripcion, idEstatus, fechaAct, idUsuarioAct, ipAct, macAddressAct)
Select idPais, descripcion, idEstatus, fechaAct, 1, ipAct, macAddressAct
From   ServicioPostal.dbo.catPaisesSATTbl
Go

Insert Into dbo.catPaisesTbl
(idPais,    nombre,     abreviatura, nacionalidad,
 codigoSat)
Select idPais,    nombre,     abreviatura, nacionalidad,
       codigoSat
From   ServicioPostal.dbo.catPaisesTbl
Go

Insert Into dbo.catEstadosSATTbl
(idPais,   idEstado, descripcion, idEstatus, idUsuarioAct,
 fechaAct, ipAct,    macAddressAct)
Select idPais,   idEstado, descripcion, idEstatus, 1 idUsuarioAt,
       fechaAct, ipAct,    macAddressAct
From   ServicioPostal.dbo.catEstadosSATTbl


Insert Into dbo.catEstadosTbl
(idPais,   idEstado,  nombre,   abreviatura,
 claveSAT)
Select idPais,   idEstado,  nombre,   abreviatura,
       claveSAT
From   ServicioPostal.dbo.catEstadosTbl

Insert Into dbo.catMunicipiosTbl
(idPais,      idEstado, idMunicipio, nombre,
 abreviatura)
Select idPais,      idEstado, idMunicipio, nombre,
       abreviatura
From   ServicioPostal.dbo.catMunicipiosTbl

Insert Into dbo.catCiudadesTbl
(idPais,      idEstado, idCiudad, nombre,
 abreviatura)
Select idPais,      idEstado, idCiudad, nombre,
       abreviatura
From   ServicioPostal.dbo.catCiudadesTbl


Insert Into dbo.catColoniasTbl
(idPais,       idEstado, idCiudad,    idMunicipio,
 idColonia,    nombre,   abreviatura)
Select idPais,       idEstado, idCiudad,    idMunicipio,
       idColonia,    nombre,   abreviatura
From   ServicioPostal.dbo.catColoniasTbl;

Insert Into dbo.catCodigosPostalesTbl
(idPais,         idEstado,  idCiudad, idMunicipio,
 idCodigoPostal, idColonia)
Select idPais,         idEstado,  idCiudad,                  idMunicipio,
       idCodigoPostal, idColonia
From   ServicioPostal.dbo.catCodigosPostalesTbl

Insert Into dbo.CodigoAgrupadorSAT
(Nivel,               CodigoAgrupador, Descripcion, Secuencia,
 CodigoAgrupador2014)
Select Nivel,               CodigoAgrupador, Descripcion, Secuencia,
       CodigoAgrupador2014
From   ServicioPostal.dbo.CodigoAgrupadorSAT
Where  Nivel is Not Null;
Go

--

Insert Into dbo.Area_o_Region
(Region_id, Region, Direccion,   Cod_Postal, 
 Municipio, Ciudad, Estado,      Telefono1,
 Telefono2, Fax,    RazonSocial, idEstatus,
 NombreDelArchivoLogo, TipoDeContenidoLogo, DataLogo)
Select Region_id, Region, Direccion, Cod_Postal,
       Municipio, Ciudad, Estado,    Telefono1,
       Telefono2, Fax, Region RazonSocial, 1 idEstatus,
	   Null  NombreDelArchivoLogo, Null TipoDeContenidoLogo, Null DataLogo
From   DB_Gen_DES.dbo.[Area o Region];
Go

Insert Into dbo.Grupo_Area_o_Region
(GrupoArea_id, GrupoArea)
Select 1, 'Grupo Dalton'
UNION
Select 2, 'CONTABLE';
Go


Insert Into dbo.Grupo_Area_o_Region_detalle
(GrupoArea_id, Region_id, activo)
Select Distinct a.GrupoArea_id, b.Region_id, 1
From   dbo.Grupo_Area_o_Region a
Join   dbo.Area_o_Region       b
On     1 = 1;
Go

Insert Into dbo.Grupos (grupo_id, nombre, restricciones, NivelSupervisor)
Select 1, 'Admon. de Seguridad', N'HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH@HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH@HHHHH@',	1
Go

Insert Into dbo.moneda
(moneda_mex, moneda_id, descripcion_corta, descripcion_larga,
 activo,     ultactual, usuario)
Select '00', 1, 'PESOS', 'PESOS MEXICANOS', 1, GetDate(),	'omedina';
Go

Insert Into dbo.TipoPol
Select *
From   DB_Gen_DES.dbo.TipoPol;
Go

Insert Into dbo.sector
(Sector_id, Sector1)
Select '00', 'Sector 00';
Go

--

Insert Into dbo.Departamento_o_Sucursal
(Sucursal_id, Region_id,   Sucursal, Direccion,
 Cod_Postal,  Municipio,   Ciudad,   Estado,
 Telefono1,   Telefono2,   Fax,      Global,
 idEstatus,   RazonSocial)
Select Sucursal_id, Region_id, Sucursal, Direccion,
       Cod_Postal,  Municipio, Ciudad,   Estado,
       Telefono1,   Telefono2, Fax,      Global,
       1,           sucursal
From   DB_Gen_DES.dbo.[Departamento o Sucursal]

-- Insert Into parámetros

Insert Into  dbo.parametros
(id, descripcion, valor, cadena, estatus)
Select id, descripcion, valor, cadena, estatus
From   DB_Gen_DES.dbo.dbo_parametros
Union
Select 392, 'Referencia contable externaSET', 0, 'Si es 0 es que no hay y si el parametro trae un 1, se actualiza el campo de las tablas zMovDia y ZPolDia"', 1
Union
Select 393, 'Instalado SisArrendaCredito', 1, 'Si es 1 Instalado, 0 No Insqtalado', 1;

--

Insert Into dbo.Formatos
(IdFormato,   Formato, Usuario, Privado,
 Consolidado, Tipo_Formato)
Select IdFormato,   Formato, Usuario, Privado,
       Consolidado, Tipo_Formato
From   db_gen_des.dbo.Formatos

Insert Into dbo.Sectorizacion
(Mayor)
Select Mayor
From   DB_Gen_DES.dbo.Sectorizacion

Insert Into .dbo.Naturaleza_Cuentas
(Naturaleza_id, Nom_naturaleza, Deudora_Acreedora)
Select Naturaleza_id, Nom_naturaleza, Deudora_Acreedora
from  DB_GEN_DES.dbo.Naturaleza_Cuentas;


Insert Into dbo.Rangos
(Rango_id, Naturaleza_id, Rango, Llave_inicial,
 Llave_final, Orden)
Select Rango_id, Naturaleza_id, Rango, Llave_inicial,
       Llave_final, Orden
From   DB_Gen_DES.dbo.Rangos


Insert Into dbo.SubRangos
(Subrango_id, Rango_id, Llave_inicial, Subrango,
 Llave_final, Sucursalizable)
Select Subrango_id, Rango_id, llave_inicial, Subrango,
       Llave_final, Sucursalizable
From   DB_Gen_DES.dbo.SubRangos

Insert Into dbo.Formato_ER
(Cons,     Tipo,   Concepto, Fuente,
 Posicion, Inicio, Fin,      Subrayado,
 Mov1,     Mov2)
Select Cons,     Tipo,   Concepto, Fuente,
       Posicion, Inicio, Fin,      Subrayado,
       Mov1,     Mov2
From   DB_Gen_DES.dbo.Formato_ER


Insert Into Reportes_Formatos
(Cons,   IdFormato,  Concepto, Naturaleza_id,
 Fuente, Grupo,      Posicion, Inicio,
 Fin,    Subrayado, Mov1,     Mov2,
 Mov3)
Select Cons,   IdFormato,  Concepto, Naturaleza_id,
       Fuente, Grupo,      Posicion, Inicio,
       Fin,     Subrayado, Mov1,     Mov2,
       Mov3
From   DB_Gen_DES.dbo.Reportes_Formatos
Go

Return;