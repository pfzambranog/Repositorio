--
-- Script de depuración de datos históricos. De la tablas contenidas en la tabla tmpTablasTbl,
--        con la fecha calculada del parámetro general
--

Declare
   @w_tabla                   Sysname,
   @w_fechaCorte              Date,
   @w_anioCorte               Smallint,
   @w_mesCorte                Tinyint,
   @w_error                   Integer,
   @w_registros               Integer,
   @w_linea                   Integer,
   @w_desc_error              Varchar(250),
   @w_sql                     Varchar(Max);

Declare
   C_Tablas        Cursor For
   Select tabla
   From   dbo.tmpTablasTbl With (Nolock)
   Where  idEstatus = 1
   Order  By Secuencia;

Begin
   Set Nocount       On
   Set Xact_Abort    On

   Select @w_registros  = 0,
          @w_error      = 0,
          @w_desc_error = '';

   Select @w_fechaCorte = DateAdd(dd, -1, parametroFecha)
   From   dbo.conParametrosGralesTbl With (Nolock)
   Where  idParametroGral = 11
   If @@Rowcount = 0
      Begin
         Select @w_error      = 9999,
                @w_desc_error = 'Error El parámetro 11 no esta dado de alta';

         Goto Salida;
      End;

   If @w_fechaCorte Is Null Or
      @w_fechaCorte >= Getdate()
      Begin
         Select @w_error      = 9998,
                @w_desc_error = 'Error El parámetro de Fecha de Inicio no es Válido';

         Goto Salida;
      End;

   Select @w_anioCorte = DatePart(yy, @w_fechaCorte),
          @w_mesCorte  = DatePart(mm, @w_fechaCorte);

   Open C_Tablas

   Begin Transaction
      While @@Fetch_status < 1
      Begin
         Fetch C_Tablas into @w_tabla
         If @@Fetch_status != 0
            Begin
               Break
            End

            Set @w_sql = Concat('Delete dbo.', @w_tabla, ' ',
                                'Where  ejercicio < ', @w_anioCorte, ' ',
                                'Or    (ejercicio = ', @w_anioCorte, ' ',
                                'And    mes      <= ', @w_mesCorte, ')');

            Begin Try
               Execute(@w_sql);
               Set @w_registros = @w_registros + @@Rowcount
            End Try

            Begin Catch
               Select  @w_Error      = @@Error,
                       @w_linea      = Error_line(),
                       @w_desc_error = Substring (Error_Message(), 1, 200)

            End   Catch

            If @w_error != 0
               Begin

                  RollBack Transaction

                  Goto Salida
               End

      End
      Close      C_Tablas
      Deallocate C_Tablas

   Commit Transaction

   Select @w_registros "Registros Eliminados"

Salida:

   If @w_error != 0
      Begin
         Close      C_Tablas
         Deallocate C_Tablas

         Select @w_error Error, @w_desc_error "Mensaje Error"
      End

   Set Xact_Abort    On
   Return

End
Go
