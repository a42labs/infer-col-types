/******************************
func_name: infer_table_types\

Function creates a new table from an existing one.  Types for columns in new table are inferred
from values in original table.

## TODO
	* check tbl for schema
		* if present, reuse schema for new tbl
		* if missing use public
	* param to select how many rows to use
		* defaul to whole table
		* accepts # of rows to use
		* accepts % of rows to sample
*********************************/

CREATE OR REPLACE FUNCTION infer_table_types(tbl VARCHAR, tbl_out VARCHAR = '', dist_key VARCHAR = 'RANDOMLY', check_rows INT = 0)
RETURNS TEXT
AS
$$
import plpy
import re

## regex patterns for datatypes
int_ptrn = re.compile('^\d+$')
float_ptrn = re.compile('^\d+([\.e]\d+)?$')
date_ptrn = re.compile('^\d{2,4}[-/]\d+[-/]\d{1,4}\s*$')
dtime_ptrn = re.compile('^\d\d\d\d[-/]\d+[-/]\d+\s\d+:\d+:\d+$')

## start building ddl query
tbl_new = tbl + ('_infer_types' if tbl_out == '' else tbl_out)
ddl_qry = "DROP TABLE IF EXISTS {tbl_new};CREATE TABLE {tbl_new} AS SELECT ".format(tbl_new=tbl_new)

## get cols from tbl
qry = """SELECT column_name FROM information_schema.columns WHERE table_name = '{}' ORDER BY ordinal_position;""".format(tbl)
cols = plpy.execute(qry)
col_names = [c['column_name'] for c in cols]

## loop through cols
lim = ('LIMIT '+str(check_rows)) if check_rows != 0 else ''
for c in col_names:
## infer type for each col
	qry = "SELECT {col} FROM {tbl} WHERE LENGTH({col}) > 0 {lim};".format(col=c, tbl=tbl, lim=lim)
	res = plpy.execute(qry)
	vals = [r[c] for r in res]
	val_types = []
	for v in vals:
		if int_ptrn.match(v):
			val_types.append(1)
		elif float_ptrn.match(v):
			val_types.append(2)
		elif date_ptrn.match(v):
			val_types.append(3)
		elif dtime_ptrn.match(v):
			val_types.append(4)
		else:
			val_types.append(5)
		# plpy.notice('v', v)
		# plpy.notice('val_types', val_types)
	if max(val_types) == 1:
		col_type = 'INTEGER'
	elif max(val_types) == 2:
		col_type = 'DOUBLE PRECISION'
	elif max(val_types) == -1 and min(val_types) == 3:
		col_type = 'DATE'
	elif max(val_types) == 4 and min(val_types) == 3:
		col_type = 'TIMESTAMP'
	else:
		col_type = 'TEXT'

	## append col name and inferred type to ddl query
	ddl_qry += "CASE WHEN {k} = '' THEN NULL ELSE {k}::{v} END AS {k}, ".format(k=c,v=col_type)

dist = dist_key if dist_key == 'RANDOMLY' else '(' + dist_key + ')'
ddl_qry = ddl_qry[:-2] + " FROM {} DISTRIBUTED {};".format(tbl, dist)

plpy.notice(ddl_qry)
plpy.execute(ddl_qry)

return("DONE")
$$
LANGUAGE plpythonu;
