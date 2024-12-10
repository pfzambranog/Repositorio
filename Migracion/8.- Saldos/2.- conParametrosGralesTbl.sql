Declare
   @w_fechaAct   Datetime    = Getdate(),
   @w_ipAct      Varchar(30) = dbo.Fn_BuscaDireccionIP(),
   @w_macAct     Varchar(30) = dbo.Fn_Busca_DireccionMac();

Begin
   Delete dbo.conParametrosGralesTbl
   Where  idParametroGral = 10;
   
   Insert dbo.conParametrosGralesTbl
  (idParametroGral, descripcion, parametroChar, parametroNumber, parametroFecha, idUsuarioAct, fechaAct, ipAct, macAddressAct) 
   Select 10, N'Dia y Mes de Inicio y Fin Proceso fin ejercicio', '0101-3103', Null, Null, 1, Getdate(), @w_ipAct, @w_macAct

 
   Return

End
Go

