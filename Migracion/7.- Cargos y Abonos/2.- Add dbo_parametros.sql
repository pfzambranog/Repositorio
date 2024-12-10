Declare
   @w_id             Integer       = 350,
   @w_valor          Integer       = 4,
   @w_estatus        Smallint      = 1,
   @w_cadena         Varchar( 30)  = Null,
   @w_descripcion    Varchar(250)  = 'Usuario Proceso Bath';

Begin

   If Not Exists ( Select Top 1 1
                   From   dbo.parametros With (Nolock)
                   Where  id  = @w_id)
      Begin
         Insert Into dbo.parametros
         (id, descripcion, valor, cadena, estatus)
         Select @w_id,     @w_descripcion, @w_valor,
                @w_cadena, @w_estatus;
      End
   Else
      Begin
         Update dbo.parametros
         Set    descripcion      = @w_descripcion,
                valor            = @w_valor,
                estatus          = @w_estatus,
                cadena           = @w_cadena
         Where  id           = @w_id;
      End

   Select @w_id            = 351,
          @w_valor         = 16,
          @w_descripcion   = 'Longitud Llave contable';

   If Not Exists ( Select Top 1 1
                   From   dbo.parametros With (Nolock)
                   Where  id  = @w_id)
      Begin
         Insert Into dbo.parametros
         (id, descripcion, valor, cadena, estatus)
         Select @w_id,     @w_descripcion, @w_valor,
                @w_cadena, @w_estatus;
      End
   Else
      Begin
         Update dbo.parametros
         Set    descripcion      = @w_descripcion,
                valor            = @w_valor,
                estatus          = @w_estatus,
                cadena           = @w_cadena
         Where  id           = @w_id;
      End

   Return;

End;
Go
