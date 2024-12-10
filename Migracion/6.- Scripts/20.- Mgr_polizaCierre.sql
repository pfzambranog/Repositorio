Declare
   @w_tabla                   Sysname,
   @w_anioIni                 Integer,
   @w_anioFin                 Integer,
   @w_error                   Integer,
   @w_registros               Integer,
   @w_mes                     Smallint,
   @w_comilla                 Char(1),
   @w_chmes                   Char(3),
   @w_sql                     Varchar(Max),
   @w_desc_error              Varchar( 250);

Begin
   Set Nocount       On

   Select @w_mes       = 0,
          @w_anioIni   = 0,
          @w_comilla   = Char(39),
          @w_registros = 0;

   Select @w_anioIni  = Datepart(yyyy, parametroFecha) -1
   From   dbo.conParametrosGralesTbl With (Nolock)
   Where  idParametroGral = 11;

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

   Select @w_mes   = Max(valor)
   From   catCriteriosTbl
   Where  criterio = 'mes'
   And    idEstatus = 1;

--

   While @w_anioIni  < @w_anioFin
   Begin
      Select @w_anioIni = @w_anioIni + 1,
             @w_tabla = Concat('MovCie', @w_chmes, @w_anioIni);

         If Ejercicio_DES.dbo.Fn_existe_tabla( @w_tabla ) = 0
            Begin
               Goto Siguiente
            End

         If Exists ( Select Top 1 1
                     From   dbo.PolizaCierre
                     Where  ejercicio = @w_anioIni)
            Begin
               Delete dbo.MovimientosCierre
               Where  ejercicio = @w_anioIni;

               Delete dbo.PolizaCierre
               Where  ejercicio = @w_anioIni;
            End

         Set @w_sql = Concat('Select Referencia, Fecha_mov, Fecha_Cap,       Concepto, ',
                                    'Cargos,     Abonos,    TCons,           Usuario, ',
                                    'TipoPoliza, Documento, Usuario_cancela, Fecha_Cancela, ',
                                    'Status,     Mes_Mov,   TipoPolizaConta, FuenteDatos, ',
                                     @w_anioIni, ', ', @w_mes, ' ',
                             'From   Ejercicio_DES.dbo.' + @w_tabla);

         Insert Into dbo.PolizaCierre
         (Referencia, Fecha_mov, Fecha_Cap,       Concepto,
          Cargos,     Abonos,    TCons,           Usuario,
          TipoPoliza, Documento, Usuario_cancela, Fecha_Cancela,
          Status,     Mes_Mov,   TipoPolizaConta, FuenteDatos,
          ejercicio,  mes)
         Execute(@w_sql)

         Set @w_registros = @w_registros + @@Rowcount;

Siguiente:

    End

    Select @w_registros RegistrosAdic;

    Return

End
Go
