Create Or Alter Function Fn_GeneraNombreTablaDin
 (@PsNombre     Sysname)
Returns Sysname

Begin
   Declare
      @o_salida           Sysname

   Begin
      Set @o_salida = Rtrim(Rtrim(@PsNombre) + '_' +
                     Replace(Replace(Replace(Substring(Convert(Varchar, Getdate(), 126), 1, 30),':', ''), '.',''), '-', ''))
   End

   Return(@o_salida)

End
Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Función que Genera Nombres para Tablas Dinámicas Seleccionando un Prefijo.',
   @w_procedimiento  NVarchar(250) = 'Fn_GeneraNombreTablaDin';

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

