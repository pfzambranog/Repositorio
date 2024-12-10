--
-- Observación: Script de creación del trigger de la tabla conGrupoReceptorCorreoDetTbl
-- Programador: Pedro Zambrano
-- Fecha:       19-sep-2024.
--

Create Or Alter Trigger dbo.trinsConGrupoReceptorCorreoDetTbl
On    dbo.conGrupoReceptorCorreoDetTbl
After Insert, Update
As

Begin
    Declare
        @w_idGrupo          Integer,
        @w_ipAct            Varchar( 30),
        @w_error            Integer,
        @w_correoReceptor   Varchar(250),
        @w_mensaje          Varchar(250),
        @w_idEstatus        Bit,
        @w_operacion        Integer,
        @w_fechaAct         Datetime;

   Begin
      Select @w_idGrupo           = idGrupo,
             @w_correoReceptor    = correoReceptor,
             @w_ipAct             = ipAct,
             @w_fechaAct          = fechaAct,
             @w_Operacion         = 9999
      From   Inserted
      If @@Rowcount = 0
         Begin
            Return
         End

      Select @w_idEstatus = idEstatus
      From   dbo.conGrupoReceptorCorreoTbl
      Where  idGrupo = @w_idGrupo;
      If @@Rowcount = 0
         Begin
            Select @w_error   = 124,
                   @w_mensaje = 'Error..: ' + dbo.Fn_Busca_MensajeError(@w_operacion, @w_error)

            Raiserror (@w_mensaje, 16, 1)
            Rollback Transaction
            Return
         End

      If @w_idEstatus != 1
         Begin
            Select @w_error   = 125,
                   @w_mensaje = 'Error..: ' + dbo.Fn_Busca_MensajeError(@w_operacion, @w_error)

            Raiserror (@w_mensaje, 16, 1)
            Rollback Transaction
            Return
         End

      If dbo.fn_validacorreo(@w_correoReceptor) = 0
         Begin
            Select @w_error   = 134,
                   @w_mensaje = 'Error..: ' + dbo.Fn_Busca_MensajeError(@w_operacion, @w_error)

            Raiserror (@w_mensaje, 16, 1)
            Rollback Transaction
            Return
         End

      Update dbo.conGrupoReceptorCorreoDetTbl
      Set    ipAct    = Isnull(@w_ipAct, dbo.fn_buscaDireccionIP()),
             fechaAct = Isnull(@w_fechaAct, Getdate())
      Where  idGrupo  = @w_idGrupo;

   End

   Return

End
Go

--
-- Comentarios.
--

Declare
   @w_valor          Varchar(1500) = 'Valida el registro a actualizar del detalle del Grupo Receptor',
   @w_trigger        Varchar( 100) = 'trinsConGrupoReceptorCorreoDetTbl'

If Not Exists (Select Top 1 1
               From   sysobjects  b
               Join   sys.extended_properties a
               On     a.major_id = b.id
               Where  b.name     = @w_trigger
               And    b.type     = 'Tr')
   Begin
      Execute  sp_addextendedproperty @name       = N'MS_Description',
                                      @value      = @w_valor,
                                      @level0type = 'Schema',
                                      @level0name = N'Dbo',
                                      @level1type = 'Table',
                                      @level1name = N'conGrupoReceptorCorreoDetTbl',
                                      @level2type = 'Trigger',
                                      @level2name = @w_trigger

   End
Else
   Begin
      Execute  sp_Updateextendedproperty @name       = N'MS_Description',
                                         @value      = @w_valor,
                                         @level0type = 'Schema',
                                         @level0name = N'Dbo',
                                         @level1type = 'Table',
                                         @level1name = N'conGrupoReceptorCorreoDetTbl',
                                         @level2type = 'Trigger',
                                         @level2name = @w_trigger
   End
Go

