Truncate Table dbo.Parametro_Rutas

Insert Into dbo.Parametro_Rutas
(id,    descripcion, cadena,         estatus,       ibis, 
 bimas, detalle,     consulta_bimas, consulta_ibis, PathRechazadas)
Select 80, 'Cobranza electrónica SAT', '\\20.66.41.152\Archivos_import\', 1, 'C:\Archivos_import\', 
       Null, Null, Null, Null, Null
Union
Select 36, 'Ruta de Archivos Import', '\\20.66.41.152\Archivos_import\', 1, Null,
       Null, Null, Null, Null, Null
Go
