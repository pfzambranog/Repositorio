Create Or Alter Function dbo.Fn_Desencripta_cadena
 (@PsCadena         Varbinary(Max))
Returns Varchar(Max)
As

Begin
/*
Obtetivo: Función que Desencripta una Cadena de Caracteres
Versión:  1

*/
   Declare
      @o_salida              Varchar(Max),
	  @w_llave               Varchar(150)
   Begin

      Select @w_llave = parametroChar
      From   dbo.conParametrosGralesTbl
      Where  idParametroGral = 4;
      
	  Select @o_salida = Convert(Varchar(Max), Decryptbypassphrase(@w_llave, @PsCadena))

   End

   Return(@o_salida)

End
Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Función que Desencripta una Cadena de Caracteres',
   @w_procedimiento  NVarchar(250) = 'Fn_Desencripta_cadena';

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
