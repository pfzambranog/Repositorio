Create Or Alter Function dbo.Fn_BuscaValoresCriterio
  (@PsCriterio     Char(25),
   @PnValor        Smallint,
   @PnIdConsulta   Bit)    -- 0 = Valor Adicional, 1 = Desccripción 
Returns Varchar(100)
As

Begin
   Declare
      @o_salida           Varchar(100),
      @w_descripcion      Varchar(100),
      @w_valorAdicional   Varchar(100)

   Begin
      Select @w_descripcion    = descripcion,
             @w_valorAdicional = valorAdicional
      From   dbo.catCriteriosTbl
      Where  criterio  = @PsCriterio
      And    valor     = @PnValor
      If @@Rowcount = 0
         Begin
            Select @w_descripcion    = ' ',
                   @w_valorAdicional = ' '
         End
   End

   Set @o_salida = Case When @PnIdConsulta = 1
                        Then Isnull(@w_descripcion,    ' ')
                        Else Isnull(@w_valorAdicional, ' ')
                   End

   Return(@o_salida)

End
Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Función que Consulta la entidad catCriteriosTbl.',
   @w_procedimiento  NVarchar(250) = 'Fn_BuscaValoresCriterio';

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


