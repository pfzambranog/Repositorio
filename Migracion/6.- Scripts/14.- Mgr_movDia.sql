Declare
   @w_idError                 Integer,
   @w_anio                    Integer,
   @w_error                   Integer,
   @w_registros               Integer,
   @w_linea                   Integer,
   @w_mes                     Tinyint,
   @w_comilla                 Char(1),
   @w_chmes                   Char(3),
   @w_tabla                   Sysname,
   @w_desc_error              Varchar( 250),
   @w_regCat                  Integer,
   @w_idusuario               Varchar(  Max),
   @w_usuario                 Nvarchar(  20),
   @w_sql                     NVarchar(1500),
   @w_param                   NVarchar( 750),
   @w_ultactual               Datetime;

Begin
   Set Nocount       On
   Set Xact_Abort    On

   Select @w_mes       = 0,
          @w_comilla   = Char(39),
          @w_registros = 0,
          @w_regCat    = 0,
          @w_ultactual = Getdate();

   Select @w_anio = ejercicio
   From   dbo.Control With  (Nolock)
   Where  idEstatus = 1
   If @@Rowcount = 0
      Begin
         Select  @w_Error      = 9999,
                 @w_desc_error = 'Error: No hay Ejercicios en Estatus 1 en la tabla control.'

         Set Xact_Abort Off
         Goto Salida
      End

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
                  From   dbo.MovDia)
         Begin
            Begin Try
               truncate table dbo.MovDia
            End Try

            Begin Catch
               Select  @w_Error      = @@Error,
                       @w_linea      = Error_line(),
                       @w_desc_error = Substring (Error_Message(), 1, 200)

            End   Catch

            If @w_error != 0
               Begin
                  Select @w_error, @w_desc_error;
                  RollBack Transaction

                  Goto Salida
               End

         End
    
      Set @w_tabla = 'poldia';
   
      If DB_Gen_DES.dbo.Fn_existe_tabla( @w_tabla ) = 0
         Begin
            Select 9999 Error, Concat('La tabla ', @w_tabla, ' No Existe en la BD Origen,') mensajeError
            Goto Salida
         End

     Set @w_sql = Concat('Select Distinct Referencia,      Cons, ', @w_comilla, '00', @w_comilla, 'Moneda,      Fecha_mov, ',
                                'Llave,           Concepto,         Importe,       Documento, ',
                                'Clave,           FecCap,',         @w_comilla, '00', @w_comilla, ',   Sucursal_id, ',
                                'Region_id,       Importe_Cargo,    Importe_Abono, Descripcion, ',
                                'TipoPolizaConta, ReferenciaFiscal, Fecha_Doc, ',
                                'DatePart(yyyy, Fecha_Mov) Ejercicio,  DatePart(mm, Fecha_Mov) Mes ',
                        'From   DB_Gen_DES.dbo.', @w_tabla, ' a ',
                        'Where  Exists ( Select Top 1 1 ',
                                        'From   dbo.PolDia ',
                                        'Where  Referencia = a.Referencia ',
                                        'And    Fecha_mov  = a.Fecha_mov ',
                                        'And    ejercicio  = DatePart(yyyy, a.Fecha_Mov) ',
                                        'And    mes        = DatePart(mm, a.Fecha_Mov)) ',
                        'And    Exists (Select Top 1 1 ',
                                       'From   dbo.CatalogoConsolidado ',
                                       'Where  numerodecuenta = a.llave ',
                                       'And    Moneda_id      = ', @w_comilla, '00', @w_comilla, ')' );

     Begin Try      
        Insert Into dbo.MovDia
       (Referencia,      Cons,             Moneda,        Fecha_mov,
        Llave,           Concepto,         Importe,       Documento,
        Clave,           FecCap,           Sector_id,     Sucursal_id,
        Region_id,       Importe_Cargo,    Importe_Abono, Descripcion,
        TipoPolizaConta, ReferenciaFiscal, Fecha_Doc,     Ejercicio,
        Mes)
        Execute(@w_sql)
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

   Select @w_registros RegistrosAlta;

Salida:

   Set Xact_Abort  Off
   Return

End
Go
