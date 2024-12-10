   Select *
   Into   #tempPoliza
from   dbo.PolizaAnio   a With (Nolock)
   Where  a.ejercicio      = 2023
   And    a.mes            = 12
   And    Referencia       = 'PDI000007'

Update #tempPoliza
Set    mes = 13

Insert Into dbo.PolizaAnio 
Select *
from #tempPoliza

Drop table #tempPoliza


--



   Select *
   Into   #tempPoliza
from   dbo.movimientosAnio   a With (Nolock)
   Where  a.ejercicio      = 2023
   And    a.mes            = 12
   And    Referencia       = 'PDI000007'

Update #tempPoliza
Set    mes = 13

Insert Into dbo.MovimientosAnio 
Select *
from #tempPoliza

Drop table #tempPoliza

--

Select *
Into   #Temp
                  From   dbo.Catalogo With (Nolock)
                  Where  Ejercicio = 2023
                  And    mes       = 12
Update #Temp
Set    Sant = Sact,
       car  = 0,
	   abo  = 0,
	   CarProceso = 0,
	   AboProceso = 0,
	   SAntProceso = Sact,
       AboExt      = 0,
	   CarExt      = 0,
	   SProm       = 0,
	   SProm2      = 0,
       mes  = 13

Delete dbo.Catalogo
Where  Ejercicio = 2023
And    mes       = 13;

Insert Into dbo.Catalogo
Select *
From   #Temp

Drop Table #Temp
--

Select *
Into   #Temp
                  From   dbo.CatalogoAuxiliarHist With (Nolock)
                  Where  Ejercicio = 2023
                  And    mes       = 12
Update #Temp
Set    Sant = Sact,
       car  = 0,
	   abo  = 0,
	   CarProceso = 0,
	   AboProceso = 0,
	   SAntProceso = Sact,
       AboExt      = 0,
	   CarExt      = 0,
	   SProm       = 0,
	   SProm2      = 0,
       mes  = 13

Delete dbo.CatalogoAuxiliarHist
Where  Ejercicio = 2023
And    mes       = 13;

Insert Into dbo.CatalogoAuxiliarHist
Select *
From   #Temp

Drop Table #Temp