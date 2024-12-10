USE msdb
Go

--
-- Programador: Pedro Zambrano
-- Fecha:       17-sep-2024.
-- Observación: Script de creación del Job inicio de ejercicio.
--

/****** Object:  Job [FinalizaEjercicio]    Script Date: 18/09/2024 01:47:21 p. m. ******/
Declare
   @ReturnCode Integer,
   @jobId      Binary(16);

Begin
   Set @ReturnCode = 0

/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 18/09/2024 01:47:21 p. m. ******/

   Begin Transaction
      If Not Exists (Select name
                     From   msdb.dbo.syscategories
                     Where  name          = N'[Uncategorized (Local)]'
                     And    category_class= 1)
         Begin
            Execute @ReturnCode = msdb.dbo.sp_add_category @class = N'JOB',
                                                           @type  = N'LOCAL',
                                                           @name  = N'[Uncategorized (Local)]'
            If @@Error     <> 0 Or
               @ReturnCode <> 0
               Begin
                  Rollback Transaction
                  Goto Salida
               End

         End

      If Exists ( Select Top 1 1
                  From   msdb.dbo.sysjobs
			      where  Name = 'FinalizaEjercicio')
               Begin
                  Rollback Transaction
                  Goto Salida
               End           

      Execute @ReturnCode =  msdb.dbo.sp_add_job @job_name              = N'FinalizaEjercicio',
                                                 @enabled               = 1,
                                                 @notify_level_eventlog = 0,
                                                 @notify_level_email    = 0,
                                                 @notify_level_netsend  = 0,
                                                 @notify_level_page     = 0,
                                                 @delete_level          = 0,
                                                 @description           = N'Proceso de Pase de Acumulados al Histórico.',
                                                 @category_name         = N'[Uncategorized (Local)]',
                                                 @owner_login_name      = N'sa',
                                                 @job_id                = @jobId Output;

      If @@Error     <> 0 Or
         @ReturnCode <> 0
         Begin
            Rollback Transaction
            Goto Salida
         End

/****** Object:  Step [FinalizaEjercicio]    Script Date: 18/09/2024 01:47:21 p. m. ******/

      Execute @ReturnCode = msdb.dbo.sp_add_jobstep @job_id               = @jobId,
                                                    @step_name            = N'FinalizaEjercicio',
                                                    @step_id              = 1,
                                                    @cmdexec_success_code = 0,
                                                    @on_success_action    = 1,
                                                    @on_success_step_id   = 0,
                                                    @on_fail_action       = 2,
                                                    @on_fail_step_id      = 0,
                                                    @retry_attempts       = 0,
                                                    @retry_interval       = 0,
                                                    @os_run_priority      = 0,
                                                    @subsystem            = N'TSQL',
                                                    @command              = N'dbo.Spp_InicioEjercicio',
                                                    @database_name        = N'DB_Siccorp_DES',
                                                    @flags                = 0

      If @@Error     <> 0 Or
         @ReturnCode <> 0
         Begin
            Rollback Transaction
            Goto Salida
         End

      Execute @ReturnCode = msdb.dbo.sp_update_job @job_id        = @jobId, 
                                                   @start_step_id = 1;

      If @@Error     <> 0 Or
         @ReturnCode <> 0
         Begin
            Rollback Transaction
            Goto Salida
         End

      Execute @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id                  = @jobId,
                                                        @name                    = N'FinalizaEjercicio',
                                                        @enabled                 = 1,
                                                        @freq_type               = 4,
                                                        @freq_interval           = 1,
                                                        @freq_subday_type        = 1,
                                                        @freq_subday_interval    = 0,
                                                        @freq_relative_interval  = 0,
                                                        @freq_recurrence_factor  = 0,
                                                        @active_start_date       = 20250101,
                                                        @active_end_date         = 99991231,
                                                        @active_start_time       = 230000,
                                                        @active_end_time         = 235959,
                                                        @schedule_uid            = N'5eaa18cd-27e0-4f9f-8fd2-cd61abce75e6';

      If @@Error     <> 0 Or
         @ReturnCode <> 0
         Begin
            Rollback Transaction
            Goto Salida
         End

      Execute @ReturnCode = msdb.dbo.sp_add_jobserver @job_id      = @jobId,
                                                      @server_name = N'(local)';

      If @@Error     <> 0 Or
         @ReturnCode <> 0
         Begin
            Rollback Transaction
            Goto Salida
         End

   Commit Transaction

Salida:

   If @@Trancount > 0
      Begin
         Rollback Transaction
      End

   Return;

End
Go
