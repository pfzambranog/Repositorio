--
-- Script de llenado de la tabla control.
--

Declare
   @w_tabla                   Sysname,
   @w_anioIni                 Integer,
   @w_anioFinal               Integer,
   @w_anio                    Integer,
   @w_error                   Integer,
   @w_registros               Integer,
   @w_linea                   Integer,
   @w_mesIni                  Tinyint,
   @w_mes                     Tinyint,
   @w_mesFin                  Tinyint,
   @w_mesProc                 Tinyint,
   @w_idEstatus               Tinyint,
   @w_inicio                  Tinyint,
   @w_comilla                 Char(1),
   @w_usuario                 Nvarchar(20),
   @w_sql                     NVarchar(1500),
   @w_param                   NVarchar( 750),
   @w_desc_error              Varchar( 250),
   @w_idusuario               Varchar( Max);

Begin
   Set Nocount       On
   Set Xact_Abort    On

   Select @w_mes       = 0,
          @w_anioIni   = 0,
          @w_anio      = 0,
          @w_inicio    = 0,
          @w_idEstatus = 2,
          @w_comilla   = Char(39),
          @w_registros = 0,
          @w_tabla     = 'Control';;

   Select @w_idusuario = parametroChar
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 6;

   Select @w_sql   = Concat('Select @o_usuario = dbo.Fn_Desencripta_cadena (', @w_idusuario, ')'),
          @w_param = '@o_usuario    Nvarchar(20) Output';

   Begin Try
      Execute Sp_executeSql @w_sql, @w_param, @o_usuario = @w_usuario Output
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_linea      = Error_line(),
              @w_desc_error = Substring (Error_Message(), 1, 200)

   End   Catch

   If @w_error != 0
      Begin
         Select @w_error, @w_desc_error;

         Goto Salida
      End


   If dbo.Fn_existe_tabla(@w_tabla ) = 0
      Begin
         Goto Salida
      End

   Select @w_anioIni  = Datepart(yyyy, parametroFecha),
          @w_mesProc  = Datepart(mm,   parametroFecha)
   From   dbo.conParametrosGralesTbl With (Nolock)
   Where  idParametroGral = 11;
   
   Select @w_anioFinal = Cast(Substring(parametroChar, 1, 4) As Smallint),
          @w_mesFin    = Cast(Substring(parametroChar, 6, 2) As Tinyint)
   From   dbo.conParametrosGralesTbl With (Nolock)
   Where  idParametroGral = 12;
   
   Begin Transaction
      While @w_anioIni <= @w_anioFinal
      Begin
         If Exists ( Select Top 1 1
                     From   dbo.Control
                     Where  ejercicio = @w_anioIni)
            Begin
               Begin Try
                  Delete dbo.Control
                  Where  ejercicio = @w_anioIni
               End Try

               Begin Catch
                  Select  @w_Error      = @@Error,
                          @w_linea      = Error_line(),
                          @w_desc_error = Substring (Error_Message(), 1, 200)

               End   Catch

               If @w_error != 0
                  Begin
                     Rollback Transaction
                     Select @w_error, @w_desc_error;

                     Goto Salida
                  End

            End
             
         Select @w_mes    = max(valor),
                @w_mesIni = min(Valor)
         From   catCriteriosTbl
         Where  criterio = 'mes'
         And    idEstatus = 1;

           
         While  @w_mesIni <= @w_mes
         Begin

         If @w_inicio = 0
            Begin
               Select @w_mesIni = @w_mesProc,
                      @w_inicio = 1;
            End

            If @w_mesIni  = @w_mesFin      And
               @w_anioIni = @w_anioFinal
               Begin
                  Set @w_idEstatus = 1
               End

            Begin Try
               Insert Into dbo.Control
              (Ejercicio, Mes, idEstatus, usuario)
               Select @w_anioIni, @w_mesIni, @w_idEstatus, @w_usuario
               
               Set @w_registros = @w_registros + @@Rowcount;
            End  Try

            Begin Catch
               Select  @w_Error      = @@Error,
                       @w_linea      = Error_line(),
                       @w_desc_error = Substring (Error_Message(), 1, 200)
            
            End   Catch

            If @w_error != 0
               Begin
                  Rollback Transaction
                  Select @w_error, @w_desc_error;
            
                  Goto Salida
               End

            If @w_idEstatus = 1
               Begin
                  Break
               End

            Set @w_mesIni += 1;


         End

         Set @w_anioIni += 1;

Siguiente:

      End

   Commit Transaction

   Select @w_registros;

Salida:

   Set Xact_Abort Off
   Return

End
Go
