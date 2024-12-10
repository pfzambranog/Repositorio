Create Or Alter Function dbo.Fn_existe_tabla  
(@PsTabla      Sysname)  
Returns Smallint  
As  
  
Begin  
   Declare  
      @w_existe      Tinyint  = 0  
  
   Begin  
      If Exists ( Select Top 1 1  
                  From   Sysobjects  
                  Where  Uid  = 1  
                  And    Type = 'U'  
                  And    Name = @PsTabla)  
         Begin  
            Set @w_existe = 1  
         End  
  
   End  
  
   Return(@w_existe)  
  
End  
Go