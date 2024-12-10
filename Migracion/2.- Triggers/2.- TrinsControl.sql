Create Or Alter Trigger dbo.TrinsControl
On     dbo.Control
After Insert, Update
As

Declare
  @w_contador              Integer,
  @w_ejercicio             Smallint,
  @w_mes                   Tinyint,
  @w_idEstatus             Bit;

Begin

   Select  @w_ejercicio = ejercicio,
           @w_mes       = mes,
           @w_idEstatus = idEstatus
   From    Inserted
   If @@Rowcount   = 0 Or
      @w_idEstatus = 0
      Begin
         Return;
      End

   Select @w_contador = Count(1)
   From   dbo.control
   Where  idEstatus  = 1
   If Isnull(@w_contador, 0) > 1
      Begin
         Raiserror ('Ya Existe un Registro con Estatus 1.', 16, 1)
         Rollback Transaction
         Return
      End

  Return
End
Go

--
-- Comentarios.
--

Execute sp_addextendedproperty    @name       = N'MS_Description',
                                  @value      = N'Valida el registro a actualizar en la tabla control.',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = N'Table',
                                  @level1name = N'control',
                                  @level2type = 'Trigger',
                                  @level2name = N'TrinsControl'
