--
-- Objetivo : Recovery de Base de datos.
-- Fecha:     03/10/2024
-- Genera:    Pedro Zambrano
-- --------------------------------------------------

Create Or Alter Procedure dbo.Spp_RecuperaBd
(@PsBaseDatos    Sysname,
 @PsDireccion    Varchar(250),
 @PsDirDestino   Varchar(250),
 @PnEstatus      Integer        = 0    Output,
 @PsMensaje      Varchar(250)   = Null Output)
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
          @w_sql     = 'Use tempDB',
          @w_comilla = Char(39),
          @w_char92  = Char(92);

   Execute (@w_sql);

--
-- Validación de parámetro de Directorio
--

   Create Table #tempDir
   (archivo        Integer,
    directorio     Integer,
    ParentDir      Integer)

   Insert Into  #tempDir
   (archivo, directorio, ParentDir)
   Execute master.dbo.xp_fileexist @PsDireccion

   If Not Exists ( Select Top 1 1
                   From   #tempDir
                   Where  directorio = 1)
      Begin
         Select @PnEstatus = 9999,
                @PsMensaje = 'Error.: El Directorio Seleccionado no es Válido';

         Set Xact_Abort Off
         Return
      End

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

-- Recuperación de BASE de Datos

   Set @w_sql = Concat('Restore Database ', @PsBaseDatos, ' ',
                       'From Disk = ', @w_comilla, @PsDireccion, Char(92), @PsBaseDatos, '.bak', @w_comilla,' ',
                       'With Move ', @w_comilla, @PsBaseDatos, @w_comilla,         ' To ', @w_comilla, @PsDirDestino, @PsBaseDatos, '.mdf', @w_comilla,', ',
                            'Move ', @w_comilla, @PsBaseDatos, '_log', @w_comilla, ' TO ', @w_comilla, @PsDirDestino, @PsBaseDatos, '.ldf', @w_comilla)

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

   Set Xact_Abort Off
   Return
End
Go
