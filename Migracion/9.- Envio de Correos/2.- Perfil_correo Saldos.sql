Use msdb
Go

--
-- Programador: Pedro Zambrano
-- Fecha:       17-sep-2024.
-- Observación: Script de creación del Perfil de correo para Incidencias Cierre Periodo.
--

If Not Exists(Select top 1 1         
              From   msdb.dbo.sysmail_profile    
              Where  name = 'Incidencias Cierre Periodo')  
   Begin
      Execute msdb.dbo.sysmail_add_account_sp   @account_name     = N'Incidencias Cierre Periodo',      
                                                @description      = N'Incidencias Cierre Periodo' ,      
                                                @email_address    = N'comunicaciondes@dalton.com.mx'  ,     
                                                @display_name     = 'Incidencias Cierre Periodo',      
                                                @username         = 'comunicaciones_des',    
                                                @password         = 'm3la8-Bc',     
                                                @port             = 2525,
                                                @enable_ssl       = 1,                          
                                                @mailserver_name  = '10.1.1.15'
	  
      Execute msdb.dbo.sysmail_add_profile_sp   @profile_name     = N'Incidencias Cierre Periodo' ,      
                                                @description      = N'Incidencias Cierre Periodo'      
            
      -- Add the account to the profile      
	  
      Execute msdb.dbo.sysmail_add_profileaccount_sp  @profile_name    = N'Incidencias Cierre Periodo',      
                                                      @account_name    = N'Incidencias Cierre Periodo',      
                                                      @sequence_number = 1 
   End
Go
