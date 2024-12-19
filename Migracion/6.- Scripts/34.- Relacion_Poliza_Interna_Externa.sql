use DB_Siccorp_DES
go
set dateformat ymd

INSERT INTO RelSubRangos_DepartamentosTbl (Subrango_id, Sucursal_id, Region_id, FechaAct, usuario, ipAct)
SELECT 
    sr.Subrango_id,
    ds.Sucursal_id,
    ds.Region_id,
    GETDATE() AS FechaAct,   
    'omedina' AS usuario,    
    '1.1.1.1' AS ipAct       
FROM 
    SubRangos sr
CROSS JOIN 
    Departamento_o_Sucursal ds
	where Sucursal_id in ('1111000','0','5555000') 