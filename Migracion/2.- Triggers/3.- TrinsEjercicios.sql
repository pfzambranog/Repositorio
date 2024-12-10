Create Or Alter Trigger dbo.TrinsEjercicios
On     dbo.Ejercicios
After Insert, Update
As

Declare
  @w_contador              Integer,
  @w_ejercicio             Smallint,
  @w_mes                   Tinyint,
  @w_idEstatus             Bit;

Begin

   Select  @w_ejercicio = ejercicio,
           @w_idEstatus = idEstatus
   From    Inserted
   If @@Rowcount   = 0 Or
      @w_idEstatus = 0
      Begin
         Return;
      End

   If Not Exists ( Select Top 1 1
                   From   dbo.catGeneralesTbl With (Nolock)
                   Where  Tabla   = 'Ejercicios'
                   And    columna = 'idEstatus'
                   And    valor   = @w_idEstatus)
      Begin
         Raiserror ('El Estatus Seleccionado no es Válido.', 16, 1)
         Rollback Transaction
         Return
      End

   Select @w_contador = Count(1)
   From   dbo.Ejercicios
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
                                  @value      = N'Valida el registro a actualizar en la tabla Ejercicios.',
                                  @level0type = 'Schema',
                                  @level0name = N'dbo',
                                  @level1type = N'Table',
                                  @level1name = N'Ejercicios',
                                  @level2type = 'Trigger',
                                  @level2name = N'TrinsEjercicios'
