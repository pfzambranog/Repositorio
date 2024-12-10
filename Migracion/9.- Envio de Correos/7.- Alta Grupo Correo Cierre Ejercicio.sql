--
-- Observación: Script de alta de Grupo de correo.
-- Programador: Pedro Zambrano
-- Fecha:       19-sep-2024.
--

Declare
   @w_idGrupo           Integer,
   @w_idusuario         Varchar(  Max),
   @w_desc_error        Varchar(  250),
   @w_Error             Integer,
   @w_linea             Integer,
   @w_usuario           Varchar(   10),
   @w_ipAct             Varchar(   30),
   @w_codigoGrupo       Varchar(   20),
   @w_correoReceptor    Varchar(  250),
   @w_nombre            Varchar(  250),
   @w_consulta          NVarchar(1500),
   @w_param             NVarchar( 750);

Begin
   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off
--
-- Obtención del usuario de la aplicación para procesos batch.
--

   Select @w_codigoGrupo    = 'GrupoCierre',
          @w_correoReceptor = 'pzambrano.zepga@hotmail.com',
          @w_nombre         = 'Pedro Zambrano',
          @w_ipAct          = dbo.Fn_buscaDireccionIp();

   Select @w_idusuario = parametroChar
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 6;

   Select @w_consulta   = Concat('Select @o_usuario = dbo.Fn_Desencripta_cadena (', @w_idusuario, ')'),
          @w_param      = '@o_usuario    Nvarchar(20) Output';

   Begin Try
      Execute Sp_executeSql @w_consulta, @w_param, @o_usuario = @w_usuario Output
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_linea      = Error_line(),
              @w_desc_error = Substring (Error_Message(), 1, 200)

   End   Catch

   If Isnull(@w_error, 0) != 0
      Begin
         Select @w_error, @w_desc_error;

         Set Xact_Abort    Off
         Return
      End

   Select @w_idGrupo = idGrupo
   From   dbo.conGrupoReceptorCorreoTbl
   Where  codigoGrupo = @w_codigoGrupo
   If @@Rowcount = 0
      Begin
         Insert Into dbo.conGrupoReceptorCorreoTbl
        (codigoGrupo, nombre, idUsuarioAct, ipAct)
         Select @w_codigoGrupo, 'Grupo de Correo de Cierre Ejercicio', @w_usuario, @w_ipAct
         Set @w_idGrupo = @@Identity
      End

   If Not Exists ( Select Top 1 1
                   From   dbo.conGrupoReceptorCorreoDetTbl
                   Where  idGrupo        = @w_idGrupo
                   And    correoReceptor = @w_correoReceptor)
      Begin
         Insert Into dbo.conGrupoReceptorCorreoDetTbl
        (idGrupo, correoReceptor, nombre, idUsuarioAct, ipAct)
         Select @w_idGrupo, @w_correoReceptor, @w_nombre, @w_usuario, @w_ipAct
      End

   Select @w_correoReceptor = 'carlos.urbina@sian.com.mx',
          @w_nombre         = 'Carlos Urbina';

   If Not Exists ( Select Top 1 1
                   From   dbo.conGrupoReceptorCorreoDetTbl
                   Where  idGrupo        = @w_idGrupo
                   And    correoReceptor = @w_correoReceptor)
      Begin
         Insert Into dbo.conGrupoReceptorCorreoDetTbl
        (idGrupo, correoReceptor, nombre, idUsuarioAct, ipAct)
         Select @w_idGrupo, @w_correoReceptor, @w_nombre, @w_usuario, @w_ipAct
      End

   Set Xact_Abort    Off
   Return

End
Go