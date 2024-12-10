osql -S %1 -d %2 -E -e -i ".\2.- Triggers\1.- TrinscatGeneralesTbl.sql"         >  migracion_Trigger.log
osql -S %1 -d %2 -E -e -i ".\2.- Triggers\2.- TrinsControl.sql"                >>  migracion_Trigger.log
osql -S %1 -d %2 -E -e -i ".\2.- Triggers\3.- TrinsEjercicios.sql"             >>  migracion_Trigger.log

