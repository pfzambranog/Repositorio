/*
-- Declare
   -- @PsBaseDatos    Sysname       = 'DB_Siccorp_DES',
   -- @PnEstatus      Integer       = 0,
   -- @PsMensaje      Varchar(250)  = Null;
-- Begin
   -- Execute  dbo.Spp_AsignaPermisos @PsBaseDatos = @PsBaseDatos,
                                   -- @PnEstatus   = @PnEstatus     Output,
                                   -- @PsMensaje   = @PsMensaje     Output;

   -- Select @PnEstatus Error, @PsMensaje mensaje
   -- Return

-- End
-- Go

*/

--
--  Database : DB_Siccorp_DES
--  Fecha:     27/24/2024
-- Genera:     Pedro Zambrano
-- --------------------------------------------------

Create Or Alter Procedure dbo.Spp_AsignaPermisos
(@PsBaseDatos    Sysname,
 @PnEstatus      Integer        = 0 Output,
 @PsMensaje      Varchar(250)   = 0 Output)
With Encryption
-- With Execute As Sa
As
Declare
   @w_Error             Integer,
   @w_desc_error        Varchar( 250),
   @w_sql               Nvarchar(Max),
   @w_param             Nvarchar(750),
   @w_comilla           Char(1),
   @w_linea             Integer,
   @w_existe            Integer;

Begin
   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off

   Select @PnEstatus = 0,
          @PsMensaje = '',
          @w_linea   = 0,
          @w_sql     = 'Create Schema dbo',
          @w_comilla = Char(39);

   If Schema_ID(N'dbo') Is Null
      Begin
          Begin Try
             Execute(@w_sql);
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

   If Fulltextserviceproperty('IsFullTextInstalled') = 1
      Begin
         Begin Try
            Set @w_sql = Concat('Execute dbo.sp_fulltext_Database @Action = ', @w_comilla, 'enable', @w_comilla)
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

   If @w_existe = 0
      Begin
         Set @w_sql = Concat(@PsBaseDatos, '.sys.sp_addextendedproperty ',
                             '@name  = N', @w_comilla, 'MS_Description',@w_comilla, ', ',
                             '@value = N', @w_comilla, 'Base de Datos Siccorp', @w_comilla)
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

--

   Set @w_sql = Concat('Alter Database ', @PsBaseDatos, ' Set ANSI_Null_DEFAULT Off')
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

--

   Set @w_sql = Concat('Alter Database ', @PsBaseDatos, ' Set ANSI_NullS Off')
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

--

   Set @w_sql = Concat('Alter Database ', @PsBaseDatos, ' Set ANSI_PADDING Off')
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

--

   Set @w_sql = Concat('Alter Database ', @PsBaseDatos, ' Set ANSI_WARNINGS Off')
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

--
   Set @w_sql = Concat('Alter Database ', @PsBaseDatos, ' Set ARITHABORT Off')
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
--

   Set @w_sql = Concat('Alter Database ', @PsBaseDatos, ' Set AUTO_CLOSE Off')
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
--

   Set @w_sql = Concat('Alter Database ', @PsBaseDatos, ' Set AUTO_SHRINK Off')
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
--

   Set @w_sql = Concat('Alter Database ', @PsBaseDatos, ' Set AUTO_UPDATE_STATISTICS Off')
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
--

   Set @w_sql = Concat('Alter Database ', @PsBaseDatos, ' Set CURSOR_CLOSE_ON_COMMIT Off')
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

--

   Set @w_sql = Concat('Alter Database ', @PsBaseDatos, ' Set CONCAT_Null_YIELDS_Null Off')
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

--

   Set @w_sql = Concat('Alter Database ', @PsBaseDatos, ' Set NUMERIC_ROUNDABORT Off')
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

--

   Set @w_sql = Concat('Alter Database ', @PsBaseDatos, ' Set QUOTED_IDENTIFIER Off')
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

   Set @w_sql = Concat('Alter Database ', @PsBaseDatos, ' Set RECURSIVE_TRIGGERS Off')
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

--

   Set @w_sql = Concat('Alter Database ', @PsBaseDatos, ' Set DISABLE_BROKER')
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

--

   Set @w_sql = Concat('Alter Database ', @PsBaseDatos, ' Set AUTO_UPDATE_STATISTICS_ASYNC Off')
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

--


   Set @w_sql = Concat('Alter Database ', @PsBaseDatos, ' Set DATE_CORRELATION_OPTIMIZATION Off')
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
--

   Set @w_sql = Concat('Alter Database ', @PsBaseDatos, ' Set TRUSTWORTHY Off')
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

--

   Set @w_sql = Concat('Alter Database ', @PsBaseDatos, ' Set ALLOW_SNAPSHOT_ISOLATION Off')
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
--

   Set @w_sql = Concat('Alter Database ', @PsBaseDatos, ' Set PARAMETERIZATION SIMPLE')
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

   Set @w_sql = Concat('Alter Database ', @PsBaseDatos, ' Set READ_COMMITTED_SNAPSHOT Off')
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

--

   Set @w_sql = Concat('Alter Database ', @PsBaseDatos, ' Set HONOR_BROKER_PRIORITY Off')
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
--

   Set @w_sql = Concat('Alter Database ', @PsBaseDatos, ' Set RECOVERY SIMPLE')
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
--

   Set @w_sql = Concat('Alter Database ', @PsBaseDatos, ' Set MULTI_USER')
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

--

   Set @w_sql = Concat('Alter Database ', @PsBaseDatos, ' Set PAGE_VERIFY CHECKSUM')
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

--

   Set @w_sql = Concat('Alter Database ', @PsBaseDatos, ' Set DB_CHAINING Off')
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

--

   Set @w_sql = Concat('Alter Database ', @PsBaseDatos, ' Set FILESTREAM( NON_TRANSACTED_ACCESS = Off ) ')
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

   Set @w_sql = Concat('Alter Database ', @PsBaseDatos, ' Set TARGET_RECOVERY_TIME = 60 SECONDS ')
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


--

   Set @w_sql = Concat('Alter Database ', @PsBaseDatos, ' Set DELAYED_DURABILITY = DISABLED ')
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


--
   Set @w_sql = Concat('Alter Database ', @PsBaseDatos, ' Set ACCELERATED_Database_RECOVERY = Off')
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
--

   Set @w_sql = Concat('Alter Database ', @PsBaseDatos, ' Set QUERY_STORE = Off')
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

--

   Set @w_sql = Concat('Alter Database ', @PsBaseDatos, ' Set READ_WRITE')
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

   Begin Try
      Execute sp_changedbowner SA
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
