Insert Into dbo.contadores
(cont_id, descripcion, valor, valoraux)
Select 1, 'Índice de Reexpresión', 0, 0
Union
Select 2, 'SubRangos', 0, 0
Union
Select 3, 'Monedas', 0, 0
Union
Select 4, 'Formatos del Balance General por Empresa', 0, 0
Union
Select 5, 'Ejercicios', 0, 0
Union
Select 6, 'Meses Cerrados', 0, 0
Union
Select 7, 'Meses de Control', 0, 0
Union
Select 24, 'Grupos', 0, 0
Union
Select 25, 'Personal', 0, 0
Order by 1