Create Or Alter Function dbo.Fn_ValidaAnioBisiesto
   (@PnAnio            Smallint,  
    @PdFecha           Datetime,  
    @PnDiasCiclos      Numeric(7,4),  
    @PnDiasDisfrutados Numeric(7,4))  
Returns Numeric(7, 4)  
As
Begin  
   Declare @w_salida      Numeric(7, 4),  
           @w_fechaInicio Datetime,  
           @w_fechaFin    Datetime,  
           @w_fechaBase   Varchar(10)  
  
   Set @w_fechaBase = Cast(@PnAnio As varchar) + Format(Month(@PdFecha), '00') + Format(Day(@PdFecha), '00')
   If IsDate(@w_fechaBase) = 1  
      Begin  
         Select @w_fechaInicio = @w_fechaBase,  
                @w_fechaFin    = Dateadd(yy, 1, @w_fechaBase)  
      End  
   Else  
      Begin  
         Set @w_fechaBase = Cast(@PnAnio As varchar) + Format(Month(@PdFecha), '00') + '28'  
         Select @w_fechaInicio = @w_fechaBase,  
                @w_fechaFin    = Dateadd(yy, 1, @w_fechaBase)  
      End  
  
   If @w_fechaFin < Getdate()  
      Begin  
         Set @w_salida = (Datediff(dd, @w_fechaInicio, @w_fechaFin) / 365.0 * @PnDiasCiclos) - @PnDiasDisfrutados  
      End  
   Else  
      Begin  
         Set @w_salida = (Datediff(dd, @w_fechaInicio, Getdate()) / 365.0) - (@PnDiasCiclos - @PnDiasDisfrutados)  
      End   
  
   Return Abs(@w_salida)
End
Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Función de Consulta de Año Bisiesto.',
   @w_procedimiento  NVarchar(250) = 'Fn_ValidaAnioBisiesto';

If Not Exists (Select Top 1 1
               From   sys.extended_properties a
               Join   sysobjects  b
               On     b.xtype   = 'Fn'
               And    b.name    = @w_procedimiento
               And    b.id      = a.major_id)
   Begin
      Execute  sp_addextendedproperty @name       = N'MS_Description',
                                      @value      = @w_valor,
                                      @level0type = 'Schema',
                                      @level0name = N'dbo',
                                      @level1type = 'Function', 
                                      @level1name = @w_procedimiento

   End
Else
   Begin
      Execute sp_updateextendedproperty @name       = 'MS_Description',
                                        @value      = @w_valor,
                                        @level0type = 'Schema',
                                        @level0name = N'dbo',
                                        @level1type = 'Function', 
                                        @level1name = @w_procedimiento
   End
Go 


