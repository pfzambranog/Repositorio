--
-- Funcionalidad: Borra Base de datos.
-- Fecha:         03/10/2024
-- Genera:        Pedro Zambrano
-- --------------------------------------------------

Create Or Alter Procedure dbo.Spp_BorraBd
(@PsBaseDatos    Sysname,
 @PnEstatus      Integer        = 0 Output,
 @PsMensaje      Varchar(250)   = 0 Output)
As
Declare
   @w_Error             Integer,
   @w_desc_error        Varchar( 250),
   @w_sql               Nvarchar(Max),
   @w_param             Nvarchar(750),
   @w_comilla           Char(1),
   @w_char92            Char(1),
   @w_linea             Integer,
   @w_existe            Integer;

Begin
   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off

   Select @PnEstatus = 0,
          @PsMensaje = '',
          @w_linea   = 0,
          @w_comilla = Char(39),
          @w_char92  = Char(92);
--
--
--

   If Exists ( Select Top 1 1
               From   sys.Databases
               Where  name  = @PsBaseDatos)
      Begin
         Select @w_sql   = Concat('Select @o_existe = count(1) ',
                                  'From  ', @PsBaseDatos, '.sys.extended_properties ',
                                  'Where class = 0'),
                @w_param = '@o_existe Integer Output';

         Begin Try
            Execute Sp_ExecuteSQL @w_sql, @w_param, @o_existe = @w_existe Output;
         End Try

         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_linea      = Error_line(),
                    @w_desc_error = Substring (Error_Message(), 1, 200)

         End Catch

         If IsNull(@w_error, 0) <> 0
            Begin
               Select @PnEstatus = @w_error,
                      @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

               Set Xact_Abort Off
               Return
            End

         If @w_existe = 1
            Begin
               Set @w_sql = Concat(@PsBaseDatos, '.sys.sp_dropextendedproperty @name=N',
                                   @w_comilla, 'MS_Description', @w_comilla);

               Begin Try
                  Execute (@w_sql)
               End Try

               Begin Catch
                  Select  @w_Error      = @@Error,
                          @w_linea      = Error_line(),
                          @w_desc_error = Substring (Error_Message(), 1, 200)

               End Catch

               If IsNull(@w_error, 0) <> 0
                  Begin
                     Select @PnEstatus = @w_error,
                            @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

                     Set Xact_Abort Off
                     Return
                  End
            End

         Set @w_sql = Concat('Alter Database ', @PsBaseDatos, ' Set Single_user With Rollback Immediate')

         Begin Try
            Execute (@w_sql)
         End Try

         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_linea      = Error_line(),
                    @w_desc_error = Substring (Error_Message(), 1, 200)

         End Catch

         If IsNull(@w_error, 0) <> 0
            Begin
               Select @PnEstatus = @w_error,
                      @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

               Set Xact_Abort Off
               Return
            End

         Set @w_sql = Concat('Drop  Database ', @PsBaseDatos);

         Begin Try
            Execute (@w_sql)
         End Try

         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_linea      = Error_line(),
                    @w_desc_error = Substring (Error_Message(), 1, 200)

         End Catch

         If IsNull(@w_error, 0) <> 0
            Begin
               Select @PnEstatus = @w_error,
                      @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

               Set Xact_Abort Off
               Return
            End

      End

   Set Xact_Abort Off
   Return
End
Go
