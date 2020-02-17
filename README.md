# infer-col-types
 
Currently the script makes its best guess for the data type of each column based on the format of the data in the first n rows of the column (n passed to the function as a parameter).  It uses regex comparisons to decide if the column's values from the csv fit the format of an Integer, a Float or Double-Precision Float, a Date, a Timestamp, or Text.  The code defaults to the Text type if it fails to match all others.  Currently the function only searches for these 6 types, but we hope to expand to more of Postgres's data types in the future.

Run the `import_csv.py [csv] [table_name]` script to create a table in Postgresql with the CSV copied into `[table_name]`

The function `infer_table_types(‘[table name]’)` creates a new table named "[table name]_infer_types" with the inferred data types.