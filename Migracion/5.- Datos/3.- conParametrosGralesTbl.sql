--
-- Script de incorporación inicial de datos en la tabla conParametrosGralesTbl
--

Declare
   @w_fechaAct   Datetime    = Getdate(),
   @w_ipAct      Varchar(30) = dbo.Fn_BuscaDireccionIP(),
   @w_macAct     Varchar(30) = dbo.Fn_Busca_DireccionMac();

Begin
   Delete dbo.conParametrosGralesTbl;

   Insert dbo.conParametrosGralesTbl
  (idParametroGral, descripcion, parametroChar, parametroNumber, parametroFecha, idUsuarioAct, fechaAct, ipAct, macAddressAct)
   Select 1, N'Permite Usuarios Conectados por Diferente IP', Null, 1, Null, 1, Getdate(), @w_ipAct, @w_macAct

   Insert dbo.conParametrosGralesTbl
  (idParametroGral, descripcion, parametroChar, parametroNumber, parametroFecha, idUsuarioAct, fechaAct, ipAct, macAddressAct)
   Select 2, N'Encriptacion de Password', Null, 1, Null, 1, Getdate(),  @w_ipAct, @w_macAct

   Insert dbo.conParametrosGralesTbl
  (idParametroGral, descripcion, parametroChar, parametroNumber, parametroFecha, idUsuarioAct, fechaAct, ipAct, macAddressAct)
   Select 3, N'Cantidad Máxima de Usuarios Funcionales por Usuario de BD', Null, 0, Null, 1, Getdate(), @w_ipAct, @w_macAct

   Insert dbo.conParametrosGralesTbl
  (idParametroGral, descripcion, parametroChar, parametroNumber, parametroFecha, idUsuarioAct, fechaAct, ipAct, macAddressAct)
   Select 4, N'Llave Simetrica de Encriptado', N'SiccorpWEB', Null, Null, 1, Getdate(),  @w_ipAct, @w_macAct

   Insert dbo.conParametrosGralesTbl
  (idParametroGral, descripcion, parametroChar, parametroNumber, parametroFecha, idUsuarioAct, fechaAct, ipAct, macAddressAct)
   Select 5, N'Usuario Funcional Siccorp', Null, Null, Null, 1, Getdate(), @w_ipAct, @w_macAct

   Insert dbo.conParametrosGralesTbl
   (idParametroGral, descripcion, parametroChar, parametroNumber, parametroFecha, idUsuarioAct, fechaAct, ipAct, macAddressAct)
   Select 6, N'Usuario Funcional Bath Siccorp', dbo.Fn_encripta_cadena('omedina'), Null, null, 1, Getdate(), @w_ipAct, @w_macAct

   Insert dbo.conParametrosGralesTbl
  (idParametroGral, descripcion, parametroChar, parametroNumber, parametroFecha, idUsuarioAct, fechaAct, ipAct, macAddressAct)
   Select 7, N'Tiempo de Proceso Límite (Segundos)', Null, 600, Null, 1, Getdate(), @w_ipAct, @w_macAct

   Insert dbo.conParametrosGralesTbl
  (idParametroGral, descripcion, parametroChar, parametroNumber, parametroFecha, idUsuarioAct, fechaAct, ipAct, macAddressAct)
   Select 8, N'Id del Auxiliar de Resultado', Null, 1, Null, 1, Getdate(), @w_ipAct, @w_macAct

   Insert dbo.conParametrosGralesTbl
  (idParametroGral, descripcion, parametroChar, parametroNumber, parametroFecha, idUsuarioAct, fechaAct, ipAct, macAddressAct)
   Select 9, N'Usuario Funcional Contab', dbo.Fn_encripta_cadena('Contab'), Null, Null, 1, @w_fechaAct, @w_ipAct, @w_macAct

   Insert dbo.conParametrosGralesTbl
  (idParametroGral, descripcion, parametroChar, parametroNumber, parametroFecha, idUsuarioAct, fechaAct, ipAct, macAddressAct)
   Select 10, N'Dia y Mes de Inicio y Fin Proceso fin ejercicio', '0101-3103', Null, Null, 1, Getdate(), @w_ipAct, @w_macAct

   Insert dbo.conParametrosGralesTbl
  (idParametroGral, descripcion, parametroChar, parametroNumber, parametroFecha, idUsuarioAct, fechaAct, ipAct, macAddressAct)
   Select 11, N'Mes y Año Inicio de Migración', Null, Null, Cast('2022-09-01' As Date), 1, @w_fechaAct, @w_ipAct, @w_macAct

   Insert dbo.conParametrosGralesTbl
  (idParametroGral, descripcion, parametroChar, parametroNumber, parametroFecha, idUsuarioAct, fechaAct, ipAct, macAddressAct)
   Select 12, N'Mes y Año Inicio de Fin Migración', '2024-10', Null, Null, 1, @w_fechaAct, @w_ipAct, @w_macAct

   Return

End
Go

