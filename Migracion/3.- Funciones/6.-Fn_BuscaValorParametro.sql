Create Or Alter Function dbo.Fn_BuscaValorParametro
  (@PnIdParametroGral     Char(25),
   @PnIdConsulta          Bit)
Returns Varchar(150)
As

Begin
   Declare
      @o_salida           Varchar(100),
      @w_parametroChar    Varchar(150),
      @w_parametroNumber  Numeric(24, 6),
      @w_parametroFecha   Datetime

   Begin
      Select @w_parametroChar    = parametroChar,
             @w_parametroNumber  = parametroNumber,
             @w_parametroFecha   = parametroFecha
      From   dbo.conParametrosGralesTbl
      Where  idParametroGral  = @PnIdParametroGral
      If @@Rowcount = 0
         Begin
            Select @w_parametroChar   = Null,
                   @w_parametroNumber = Null,
                   @w_parametroFecha  = Null,
                   @o_salida          = ''
         End
      Else
         Begin
            Set @o_salida = Case When @PnIdConsulta = 0
                                 Then @w_parametroChar
                                 When @PnIdConsulta = 1
                                 Then Cast(@w_parametroNumber As Varchar)
                                 Else Convert(Char(10), @w_parametrofecha, 103)
                            End
         End
   End

   Return(@o_salida)

End
Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Función que Consulta el  Valor de un Parámetro Seleccionado.',
   @w_procedimiento  NVarchar(250) = 'Fn_BuscaValorParametro';

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