Create Or Alter Function Fn_ConvierteNumeroLetra
  (@PnValor     Decimal(18, 6))

Returns Varchar(4000)

As
Begin
   Declare
      @o_salida           Varchar(1000),
      @w_PrimeraParte     Varchar(1000),
      @w_SegundaParte     Varchar(1000),
      @w_valor            Integer,
      @w_valorDecimal     Decimal(18, 6),
      @w_valorNuevo       Integer,
      @w_decimales         Varchar(20)

   Declare
      @TablaValores1      Table
      (valor              Integer,
       descripcion        Varchar(100))

   Declare
      @TablaValores2      Table
      (valor              Integer,
       descripcion        Varchar(100) Default 'CIENTOS')

   Begin

      If @PnValor > 999999999999
         Begin
            Return ''
         End

      Insert into @TablaValores1
      Select       0, 'CERO'
      Union
      Select       1, 'UN'
      Union
      Select       2, 'DOS'
      Union
      Select       3, 'TRES'
      Union
      Select       4, 'CUATRO'
      Union
      Select       5, 'CINCO'
      Union
      Select       6, 'SEIS'
      Union
      Select       7, 'SIETE'
      Union
      Select       8, 'OCHO'
      Union
      Select       9, 'NUEVE'
      Union
      Select      10, 'DIEZ'
      Union
      Select      11, 'ONCE'
      Union
      Select      12, 'DOCE'
      Union
      Select      13, 'TRECE'
      Union
      Select      14, 'CATORCE'
      Union
      Select      15, 'QUINCE'
      Union
      Select      20, 'VEINTE'
      Union
      Select      30, 'TREINTA'
      Union
      Select      40, 'CUARENTA'
      Union
      Select      50, 'CINCUENTA'
      Union
      Select      60, 'SESENTA'
      Union
      Select      70, 'SETENTA'
      Union
      Select      80, 'OCHENTA'
      Union
      Select      90, 'NOVENTA'
      Union
      Select     100, 'CIEN'
      Union
      Select     500, 'QUINIENTOS'
      Union
      Select     700, 'SETECIENTOS'
      Union
      Select     900, 'NOVECIENTOS'
      Union
      Select    1000, 'MIL'
      Union
      Select 1000000, 'UN MILLON'

      Insert into @TablaValores2
      (valor)
      Select     200
      Union
      Select     300
      Union
      Select     400
      Union
      Select     600
      Union
      Select     800

--

      Select @w_PrimeraParte = '',
             @w_SegundaParte = '',
             @w_valor        = Cast(@PnValor As Integer),
             @w_valorDecimal = (@PnValor - @w_valor) * 100.00,
             @w_decimales    = 'PESOS CON ' + Format(@w_valorDecimal, '00') + '/100 CTS'

      Select @o_salida = descripcion
      From   @TablaValores1
      Where  valor  = @w_valor
      If @@Rowcount > 0
         Begin
            Goto  Salida
         End

      Select @o_salida = descripcion
      From   @TablaValores2
      Where  valor = @w_valor
      If @@Rowcount > 0
          Begin
             Select @w_valorNuevo   = @w_valor / 100,
                    @w_PrimeraParte = dbo.Fn_ConvierteNumeroLetra (@w_valorNuevo),
                    @o_salida       =  @w_PrimeraParte +  'CIENTOS'

             Goto  Salida
          End

      If @w_valor Between 16 And 19
         Begin
            Select @w_valorNuevo   = @w_valor - 10,
                   @w_PrimeraParte = dbo.Fn_ConvierteNumeroLetra(@w_valorNuevo),
                   @o_salida       = 'DIECI' + @w_PrimeraParte

            Goto  Salida
       End

       If @w_valor Between 21 And 29
          Begin
             Select @w_valorNuevo   = @w_valor - 20,
                    @w_PrimeraParte = dbo.Fn_ConvierteNumeroLetra (@w_valorNuevo),
                    @o_salida       = 'VEINTI' + @w_PrimeraParte

             Goto  Salida
          End

       If @w_valor Between 31 And 99
          Begin
             Select @w_valorNuevo   = Convert(integer, @w_valor / 10 ) * 10,
                    @w_PrimeraParte = dbo.Fn_ConvierteNumeroLetra (@w_valorNuevo),
                    @w_valorNuevo   = @w_valor % 10,
                    @w_SegundaParte = dbo.Fn_ConvierteNumeroLetra (@w_valorNuevo),
                    @o_salida       = @w_PrimeraParte + ' Y ' + @w_SegundaParte

             Goto  Salida
       End

       If @w_valor Between 101 And 199
          Begin
             Select @w_valorNuevo   = @w_valor - 100,
                    @w_PrimeraParte = dbo.Fn_ConvierteNumeroLetra (@w_valorNuevo),
                    @o_salida       = 'CIENTO ' + @w_PrimeraParte

             Goto  Salida
          End


       If @w_valor Between 201 And 999
          Begin
             Select @w_valorNuevo   = (@w_valor / 100 ) * 100,
                    @w_PrimeraParte = dbo.Fn_ConvierteNumeroLetra (@w_valorNuevo),
                    @w_valorNuevo   = @w_valor % 100,
                    @w_SegundaParte = dbo.Fn_ConvierteNumeroLetra (@w_valorNuevo),
                    @o_salida       = @w_PrimeraParte + @w_SegundaParte

             Goto  Salida
          End

       If @w_valor Between 1001 And 1999
          Begin
             Select @w_valorNuevo   = @w_valor % 1000,
                    @w_PrimeraParte = dbo.Fn_ConvierteNumeroLetra (@w_valorNuevo),
                    @o_salida       =  'MIL ' + @w_PrimeraParte

             Goto  Salida
          End

       If @w_valor Between 2000 And 999999
          Begin
             Select @w_valorNuevo   = @w_valor / 1000,
                    @w_PrimeraParte = dbo.Fn_ConvierteNumeroLetra (@w_valorNuevo),
                    @w_valorNuevo   = @w_valor % 1000,
                    @w_SegundaParte = dbo.Fn_ConvierteNumeroLetra (@w_valorNuevo),
                    @o_salida       =  @w_PrimeraParte + ' MIL ' + @w_SegundaParte

             Goto  Salida
          End

       If @w_valor Between 1000001 And 1999999
          Begin
             Select @w_valorNuevo   = @w_valor % 1000000,
                    @w_PrimeraParte = dbo.Fn_ConvierteNumeroLetra (@w_valorNuevo),
                    @o_salida       =  'UN MILLON ' + @w_PrimeraParte

             Goto  Salida
          End

       If @w_valor Between 2000000 And 999999999999
          Begin
             Select @w_valorNuevo   = @w_valor / 1000000,
                    @w_PrimeraParte = dbo.Fn_ConvierteNumeroLetra (@w_valorNuevo),
                    @w_valorNuevo   = @w_valor % 1000000,
                    @w_SegundaParte = dbo.Fn_ConvierteNumeroLetra (@w_valorNuevo),
                    @o_salida       = @w_PrimeraParte  + ' MILLONES ' + @w_SegundaParte

             Goto  Salida
         End
    End

Salida:

    Select @o_salida = Replace(@o_salida, ' ' + @w_decimales, ''),
           @o_salida = @o_salida + ' ' + @w_decimales

    Return @o_salida

End
Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Función que Convierte un Cifra Númerica en Letras.',
   @w_procedimiento  NVarchar(250) = 'Fn_ConvierteNumeroLetra';

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