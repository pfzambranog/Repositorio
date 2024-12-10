--
-- Script de incorporación inicial de datos en la tabla Ejercicios
--

Declare
   @w_error                   Integer,
   @w_linea                   Integer,
   @w_mensaje                 Varchar(  Max),
   @w_anioInicial             Smallint,
   @w_anioFinal               SmallInt,
   @w_idEstatus               Tinyint;

Begin
   Set Nocount       On
   Set Xact_Abort    On

   Set @w_idEstatus = 2;

   Select @w_anioInicial = Datepart(yyyy, parametroFecha)
   From   dbo.conParametrosGralesTbl With (Nolock)
   Where  idParametroGral = 11;
   
   Select @w_anioFinal = Cast(Substring(parametroChar, 1, 4) as Smallint)
   From   dbo.conParametrosGralesTbl With (Nolock)
   Where  idParametroGral = 12;

   Begin Try
      Delete dbo.movimientosHist
      Delete dbo.PolizaHist
      Delete dbo.movimientosCierre
      Delete dbo.PolizaCierre
      Delete dbo.movimientosAnio
      Delete dbo.polizaAnio
      Delete dbo.movDia
      Delete dbo.PolDia
      Delete dbo.Movimientos
      Delete dbo.Poliza
      Delete dbo.Control;
      Delete dbo.Ejercicios;
   End Try

   Begin Catch
      Select  @w_Error   = @@Error,
              @w_linea   = Error_line(),
              @w_mensaje = Substring (Error_Message(), 1, 200)
   
   End   Catch
   
    If Isnull(@w_Error, 0) <> 0
       Begin
          Select @w_Error Error, Concat('Error.: ', @w_Error, ' ', @w_mensaje, ' en Línea ', @w_linea) Mensaje;
   
          Set Xact_Abort Off
          Goto Salida
       End
--

   While @w_anioInicial <= @w_anioFinal
   Begin
      If @w_anioInicial = @w_anioFinal
         Begin
            Set @w_idEstatus = 1;
         End

      Insert Into dbo.Ejercicios (ejercicio, idEstatus)
      Select @w_anioInicial, @w_idEstatus

      Set @w_anioInicial = @w_anioInicial + 1;
   End

Salida:

   Set Xact_Abort Off
   Return

End
Go