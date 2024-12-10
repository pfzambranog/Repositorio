Create Or Alter Function dbo.Fn_Encripta_cadena
 (@PsCadena         Varchar(max))
Returns Varchar(Max)
As

Begin
   Declare
      @o_salida              Varchar(Max),
      @w_llave               Varchar(150)
   Begin

      Select @w_llave = parametroChar
      From   dbo.conParametrosGralesTbl
      Where  idParametroGral = 4
      
      Select @o_salida = Convert(Varchar(Max),EncryptByPassPhrase(@w_llave, @PsCadena), 1)
   End

   Return(@o_salida)

End
Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Función que Encripta una Cadena de Caracteres',
   @w_procedimiento  NVarchar(250) = 'Fn_Encripta_cadena';

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

