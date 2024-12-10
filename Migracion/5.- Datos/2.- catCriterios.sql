Declare
   @w_fechaAct   Datetime    = Getdate(),
   @w_ipAct      Varchar(30) = dbo.Fn_BuscaDireccionIP(),
   @w_macAct     Varchar(30) = dbo.Fn_Busca_DireccionMac();

Begin
   Delete dbo.catCriteriosTbl;

   Insert Into dbo.catCriteriosTbl
  (criterio,  valor,    descripcion, valorAdicional, idEstatus, fechaAct, ipAct, macAddressAct)
   Select 'idEstatus', 1, 'Activo', '', 1, Getdate(),  dbo.Fn_BuscaDireccionIP(),  dbo.Fn_Busca_DireccionMac()
   Union
   Select 'idEstatus', 2, 'Inactivo', '', 1, Getdate(),  dbo.Fn_BuscaDireccionIP(),  dbo.Fn_Busca_DireccionMac()
   Union
   Select 'Status', 1, 'Activa', '', 1, Getdate(),  dbo.Fn_BuscaDireccionIP(),  dbo.Fn_Busca_DireccionMac()
   Union
   Select 'Status', 2, 'Procesada', '', 1, Getdate(),  dbo.Fn_BuscaDireccionIP(),  dbo.Fn_Busca_DireccionMac()
   Union
   Select 'Status', 3, 'Cancelada', '', 1, Getdate(),  dbo.Fn_BuscaDireccionIP(),  dbo.Fn_Busca_DireccionMac()
   Union
   Select 'Status', 4, 'Rechazada', '', 1, Getdate(),  dbo.Fn_BuscaDireccionIP(),  dbo.Fn_Busca_DireccionMac()

   Insert Into dbo.catCriteriosTbl
  (criterio,  valor,    descripcion, valorAdicional, idEstatus, fechaAct, ipAct, macAddressAct)
   Select 'mes',  0 ,  'Inicio',     'INI', 1, Getdate(),  dbo.Fn_BuscaDireccionIP(),  dbo.Fn_Busca_DireccionMac()
   Union
   Select 'mes',  1 ,  'Enero',      'ENE', 1, Getdate(),  dbo.Fn_BuscaDireccionIP(),  dbo.Fn_Busca_DireccionMac()
   Union
   Select 'mes',  2 ,  'Febrero',    'FEB', 1, Getdate(),  dbo.Fn_BuscaDireccionIP(),  dbo.Fn_Busca_DireccionMac()
   Union
   Select 'mes',  3 ,  'Marzo',      'MAR', 1, Getdate(),  dbo.Fn_BuscaDireccionIP(),  dbo.Fn_Busca_DireccionMac()
   Union
   Select 'mes',  4 ,  'Abril',      'ABR', 1, Getdate(),  dbo.Fn_BuscaDireccionIP(),  dbo.Fn_Busca_DireccionMac()
   Union
   Select 'mes',  5 ,  'Mayo',       'MAY', 1, Getdate(),  dbo.Fn_BuscaDireccionIP(),  dbo.Fn_Busca_DireccionMac()
   Union
   Select 'mes',  6 ,  'Junio',      'JUN', 1, Getdate(),  dbo.Fn_BuscaDireccionIP(),  dbo.Fn_Busca_DireccionMac()
   Union
   Select 'mes',  7 ,  'Julio',      'JUL', 1, Getdate(),  dbo.Fn_BuscaDireccionIP(),  dbo.Fn_Busca_DireccionMac()
   Union
   Select 'mes',  8 ,  'Agosto',     'AGO', 1, Getdate(),  dbo.Fn_BuscaDireccionIP(),  dbo.Fn_Busca_DireccionMac()
   Union
   Select 'mes',  9 ,  'Septiembre', 'SEP', 1, Getdate(),  dbo.Fn_BuscaDireccionIP(),  dbo.Fn_Busca_DireccionMac()
   Union
   Select 'mes',  10,  'Octubre',    'OCT', 1, Getdate(),  dbo.Fn_BuscaDireccionIP(),  dbo.Fn_Busca_DireccionMac()
   Union
   Select 'mes',  11,  'Noviembre',  'NOV', 1, Getdate(),  dbo.Fn_BuscaDireccionIP(),  dbo.Fn_Busca_DireccionMac()
   Union
   Select 'mes',  12,  'Diciembre',  'DIC', 1, Getdate(),  dbo.Fn_BuscaDireccionIP(),  dbo.Fn_Busca_DireccionMac()
   Union
   Select 'mes',  13,  'Cierre',     'CIE', 1, Getdate(),  dbo.Fn_BuscaDireccionIP(),  dbo.Fn_Busca_DireccionMac();

   Insert Into dbo.catCriteriosTbl
  (criterio,  valor,    descripcion, valorAdicional, idEstatus, fechaAct, ipAct, macAddressAct)
   Select 'diaSemana', 1,   'Lunes',     'LUN', 1, Getdate(),  dbo.Fn_BuscaDireccionIP(),  dbo.Fn_Busca_DireccionMac()
   Union
   Select 'diaSemana', 2,   'Marte',     'MAR', 1, Getdate(),  dbo.Fn_BuscaDireccionIP(),  dbo.Fn_Busca_DireccionMac()
   Union
   Select 'diaSemana', 3,   'Miércoles', 'MIE', 1, Getdate(),  dbo.Fn_BuscaDireccionIP(),  dbo.Fn_Busca_DireccionMac()
   Union
   Select 'diaSemana', 4,   'Jueves',    'JUE', 1, Getdate(),  dbo.Fn_BuscaDireccionIP(),  dbo.Fn_Busca_DireccionMac()
   Union
   Select 'diaSemana', 5,   'Viernes',   'VIE', 1, Getdate(),  dbo.Fn_BuscaDireccionIP(),  dbo.Fn_Busca_DireccionMac()
   Union
   Select 'diaSemana', 6,   'Sábado',    'SAB', 1, Getdate(),  dbo.Fn_BuscaDireccionIP(),  dbo.Fn_Busca_DireccionMac()
   Union
   Select 'diaSemana', 7,   'Domingo',   'DOM', 1, Getdate(),  dbo.Fn_BuscaDireccionIP(),  dbo.Fn_Busca_DireccionMac();

   Insert Into dbo.catCriteriosTbl
  (criterio,  valor,    descripcion, valorAdicional, idEstatus, fechaAct, ipAct, macAddressAct)
   Select 'idTipoUsuario', 0, 'Funcional',      '', 1, Getdate(),  dbo.Fn_BuscaDireccionIP(),  dbo.Fn_Busca_DireccionMac()
   Union
   Select 'idTipoUsuario', 1, 'Administrativo', '', 1, Getdate(),  dbo.Fn_BuscaDireccionIP(),  dbo.Fn_Busca_DireccionMac();

   Insert Into dbo.catCriteriosTbl
  (criterio,  valor,    descripcion, valorAdicional, idEstatus, fechaAct, ipAct, macAddressAct)
   Select 'criterio', 0, 'NO', '', 1, Getdate(),  dbo.Fn_BuscaDireccionIP(),  dbo.Fn_Busca_DireccionMac()
   Union
   Select 'criterio', 1, 'SI', '', 1, Getdate(),  dbo.Fn_BuscaDireccionIP(),  dbo.Fn_Busca_DireccionMac();

   Return

End
Go