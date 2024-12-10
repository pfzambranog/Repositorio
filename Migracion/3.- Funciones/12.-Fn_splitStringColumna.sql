Create Or Alter Function dbo.Fn_splitStringColumna(
    @PsCadena      Varchar(Max),
    @PsDelimitador Char(1),
    @PnColumna     Tinyint)
Returns Varchar(50)

As
Begin
   Declare @w_x      Smallint = 1,
           @w_cadena Varchar(100),
           @w_salida Varchar(10),
           @w_len    Smallint
   
   Set @w_len = Len(@PsCadena)
   
   While @w_x <= @w_len
   Begin
      Set @w_cadena = @PsCadena
   
      If @w_x = @PnColumna
         Begin
            If Charindex(@PsDelimitador, @w_cadena) <> 0
               Begin
                  Set @w_salida = Substring(@w_cadena, 1, Charindex(@PsDelimitador, @w_cadena) -1)
               End
            Else
               Begin
                  Set @w_salida = @w_cadena
               End
            Break
         End
      
      Set @PsCadena = Substring(@w_cadena, Charindex(@PsDelimitador, @w_cadena) + 1, Len(@w_cadena))
      Set @w_x = @w_x + 1
   End
   
   Return @w_salida
End
Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Función que Realiza una Extracción de un Texto desde una cadena Seleccionada.',
   @w_procedimiento  NVarchar(250) = 'Fn_splitStringColumna';

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

