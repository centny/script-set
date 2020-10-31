#!/bin/bash
ofile=$1.sql
pg_dump -s -c -d $1 -f $ofile
sed -i 's/public\.//g' $ofile
sed -i 's/ Owner: cny//g' $ofile
sed -i 's/ALTER TABLE .* OWNER TO .*;//g' $ofile
sed -i ':a;N;$!ba;s/\n\n\n\n/\n\n/g' $ofile
sed -i ':a;N;$!ba;s/START WITH 1\n/START WITH 1000\n/g' $ofile
sed -i ':a;N;$!ba;s/DROP SEQUENCE [^\n]*\n//g' $ofile
sed -i ':a;N;$!ba;s/SET[^=]*=[^\n]*\n//g' $ofile
sed -i ':a;N;$!ba;s/ALTER TABLE ONLY [^\n]* DROP [^\n]*\n//g' $ofile
sed -i ':a;N;$!ba;s/ALTER TABLE [^\n]* ALTER [^\n]* DROP [^\n]*\n//g' $ofile
sed -i ':a;N;$!ba;s/SELECT pg_catalog[^\n]*\n//g' $ofile
sed -i 's/DROP INDEX/DROP INDEX IF EXISTS/g' $ofile
sed -i 's/DROP TABLE/DROP TABLE IF EXISTS/g' $ofile
