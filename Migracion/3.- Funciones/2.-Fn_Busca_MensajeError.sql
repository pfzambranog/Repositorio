-- /*  
-- Declare  
    -- @PnIdFormulario        Integer = 9999,  
    -- @PnIdError             Sysname = 8161;  
-- Begin  
   -- Select dbo.Fn_Busca_MensajeError(@PnIdFormulario, @PnIdError);  
   -- Return  
  
-- End  
-- Go  
  
-- */  
  
-- Version:     V1  
-- Fecha:       27-Jun-2024  
-- Programador: Pedro Zambrano.  
-- Objetivo:    Realizar consulta al catálogo de Errores  
--  
  
Create Or Alter Function dbo.Fn_Busca_MensajeError  
 (@PnIdFormulario    Smallint,  
  @PnIdError         Smallint)  
Returns Varchar(250)  
As  
  
Begin  
   Declare  
      @o_salida     Varchar( 250)  
   Begin  
  
      Select @o_salida = mensaje  
      From   dbo.catMensajesErroresTbl With (Nolock)  
      Where  idFormulario = @PnIdFormulario  
      And    idError      = @PnIdError  
      If @@Rowcount = 0  
         Begin  
            Set @o_salida = 'Mensaje No Definido'  
         End  
  
   End  
  
   Return(@o_salida)  
  
End  
Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Función que Consulta en la entidad catMensajesErroresTbl.',
   @w_procedimiento  NVarchar(250) = 'Fn_Busca_MensajeError';

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
