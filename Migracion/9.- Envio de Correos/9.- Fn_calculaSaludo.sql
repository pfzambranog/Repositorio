--
-- Objetivo:    Construye el Saludo.
-- Programador: Pedro Felipe Zambrano
-- Fecha:       18/09/2024
-- Versión:     1
--

Create Or Alter  Function dbo.Fn_calculaSaludo
()
Returns Char(20)
As

Begin
   Declare
      @o_salida             Varchar(20),
      @w_fecha              Datetime,
      @w_fecha1             Datetime,
      @w_fecha2             Datetime,
      @w_fecha3             Datetime,
      @w_fecha4             Datetime,
      @w_fecha5             Datetime,
      @w_fecha6             Datetime,
      @w_fecha7             Datetime;

   Begin
      Select @w_fecha              = Getdate(),
             @w_fecha1             = Cast(@w_fecha As Date),
             @w_fecha2             = Dateadd(second, 0.01,          @w_fecha1),
             @w_fecha3             = Dateadd(minute, ( 5 * 60),     @w_fecha1),
             @w_fecha4             = Dateadd(second, 0.01,          @w_fecha3),
             @w_fecha5             = Dateadd(minute, (12 * 60),     @w_fecha1),
             @w_fecha6             = Dateadd(second, 0.01,          @w_fecha5),
             @w_fecha7             = Dateadd(minute, (19 * 60),     @w_fecha1)


      Set @o_salida = Case When @w_fecha Between @w_fecha2 And @w_fecha3
                            Then 'Buenas Noches'
                            When @w_fecha Between @w_fecha4 And @w_fecha5
                            Then 'Buenos Días'
                            When @w_fecha Between @w_fecha6 And @w_fecha7
                            Then 'Buenas Tardes'
                            Else 'Buenas Noches'
                       End
   End

   Return(@o_salida)

End
Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Función que Construye el saludo.',
   @w_procedimiento  NVarchar(250) = 'Fn_calculaSaludo';

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
