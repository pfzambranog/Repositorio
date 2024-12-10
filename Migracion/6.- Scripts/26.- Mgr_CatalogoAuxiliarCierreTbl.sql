Declare
   @w_tabla                   Sysname,
   @w_anioIni                 Integer,
   @w_anio                    Integer,
   @w_error                   Integer,
   @w_registros               Integer,
   @w_linea                   Integer,
   @w_mes                     Tinyint,
   @w_comilla                 Char(1),
   @w_chmes                   Char(3),
   @w_usuario                 Nvarchar(  20),
   @w_sql                     NVarchar(1500),
   @w_param                   NVarchar( 750),
   @w_desc_error              Varchar(  250),
   @w_idusuario               Varchar(  Max),
   @w_fechaAct                Datetime;

Begin
   Set Nocount       On
   Set Xact_Abort    On

   Select @w_mes       = 0,
          @w_anioIni   = 2016,
          @w_anio      = 2024,
          @w_comilla   = Char(39),
          @w_registros = 0,
          @w_fechaAct  = Getdate();

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

   Begin Transaction
      If Exists ( Select Top 1 1
                  From   dbo.CatalogoAuxiliarCierreTbl)
         Begin
            truncate table dbo.CatalogoAuxiliarCierreTbl
         End

      Begin Try
         Insert Into dbo.CatalogoAuxiliarCierreTbl
        (Llave,     Moneda,     Niv,        Sector_id,   Sucursal_id,
         Region_id, Descrip,    SAnt,       Car,         Abo,
         SAct,      FecCap,     CarProceso, AboProceso,  SAntProceso,
         CarExt,    AboExt,     SProm,      SPromAnt,    SProm2,
         SProm2Ant, ejercicio,  mes)
         Select Llave,     '00' moneda, Niv,        Sector_id,  Sucursal_id,
                Case When Region_id = 202 Then 5555 Else Region_id End Region_id,
                Descrip,   SAnt,     Car,        Abo,
                SAct,      FecCap,   CarProceso, AboProceso, SAntProceso,
                CarExt,    AboExt,   SProm,      SPromAnt,   SProm2,
                SProm2Ant, DatePart(yyyy, FecCap), DatePart(mm, FecCap)
         From   EJERCICIO_DES.dbo.CatAuxCierre a
         Where  Exists (Select Top 1 1
                        From   dbo.Catalogo
                        Where  llave          = a.Llave
                        And    moneda         = '00'
                        And    ejercicio      = DatePart(yyyy, a.FecCap)
                        And    mes            = DatePart(mm,   a.FecCap))
         Set @w_registros = @w_registros + @@Rowcount;
      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Substring (Error_Message(), 1, 200)

      End   Catch

      If @w_error != 0
         Begin
            Select @w_error Error, @w_desc_error mensajeError;
            RollBack Transaction

            Goto Salida
         End

   Commit Transaction

   Select @w_registros;

Salida:

   Set Xact_Abort    Off
   Return

End
Go
