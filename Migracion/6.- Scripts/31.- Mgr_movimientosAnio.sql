Declare
   @w_idError                 Integer,
   @w_anioIni                 Integer,
   @w_anioFin                 Integer,
   @w_error                   Integer,
   @w_registros               Integer,
   @w_linea                   Integer,
   @w_mes                     Tinyint,
   @w_comilla                 Char(1),
   @w_chmes                   Char(3),
   @w_tabla                   Sysname,
   @w_tablaMov                Sysname,
   @w_regCat                  Integer,
   @w_idusuario               Varchar(  Max),
   @w_desc_error              Varchar(  Max),
   @w_usuario                 Nvarchar(  20),
   @w_sql                     NVarchar(1500),
   @w_param                   NVarchar( 750),
   @w_ultactual               Datetime;

Begin
   Set Nocount       On
   Set Xact_Abort    On

   Select @w_mes       = 13,
          @w_anioIni   = 2017,
          @w_comilla   = Char(39),
          @w_registros = 0;

   Select @w_anioFin = ejercicio
   From   dbo.Control With  (Nolock)
   Where  idEstatus = 1
   If @@Rowcount = 0
      Begin
         Select  @w_Error      = 9999,
                 @w_desc_error = 'Error: No hay Ejercicios en Estatus 1 en la tabla control.'

         Set Xact_Abort Off
         Return
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
                  From   dbo.movimientosAnio)
         Begin
            Begin Try
               truncate table dbo.movimientosAnio
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

      While @w_anioIni  < @w_anioFin
      Begin
         Select @w_anioIni = @w_anioIni + 1,
                @w_tabla = Concat('PolDia', @w_chmes, @w_anioIni);

         If Ejercicio_DES.dbo.Fn_existe_tabla( @w_tabla ) = 0
            Begin
               Goto Siguiente
            End

         Set @w_sql = Concat('Select Referencia,      Cons, ', @w_comilla, '00', @w_comilla, ' Moneda,      Fecha_mov, ',
                                    'Llave,           Concepto,         Importe,       Documento, ',
                                    'Clave,           FecCap,',         @w_comilla, '00', @w_comilla, ',   Sucursal_id, ',
                                    'Case When Region_id = 202 Then 5555 Else Region_id End Region_id, ',
                                    'Importe_Cargo,    Importe_Abono, Descripcion, TipoPolizaConta, ',
                                    'ReferenciaFiscal, Fecha_Doc, ',
                                     @w_anioIni, ', DatePart(mm, fecha_Mov) ',
                             'From   Ejercicio_DES.dbo.', @w_tabla, ' a ',
                             'Where  Exists (Select Top 1 1 ',
                                            'From   dbo.PolizaAnio ',
                                            'Where  Referencia = a.referencia ',
                                            'And    Fecha_mov  = a.Fecha_mov ',
                                            'And    ejercicio  = ', @w_anioIni, ' ',
                                            'And    mes        = DatePart(mm, a.fecha_Mov)) ',
                             'And    Exists (Select Top 1 1 ',
                                            'From   dbo.CatalogoConsolidado ',
                                            'Where  numerodecuenta = a.llave ',
                                            'And    Moneda_id      = ', @w_comilla, '00', @w_comilla, ') ');

         Begin Try
            Insert Into dbo.movimientosAnio
            (Referencia,      Cons,             Moneda,        Fecha_mov,
             Llave,           Concepto,         Importe,       Documento,
             Clave,           FecCap,           Sector_id,     Sucursal_id,
             Region_id,       Importe_Cargo,    Importe_Abono, Descripcion,
             TipoPolizaConta, ReferenciaFiscal, Fecha_Doc,     Ejercicio,
             mes)
            Execute(@w_sql)
            Set @w_registros = @w_registros + @@Rowcount

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

Siguiente:

   End;

   Commit Transaction

   Select @w_registros registros;


Salida:

   Set Xact_Abort  Off
   Return

End
Go
