import sqlalchemy as sql
import sys
import os

def create_tbl_for_csv(file, tbl):
    ## create table with cols from csv file
    qry = 'DROP TABLE IF EXISTS {tbl}; CREATE TABLE {tbl}('.format(tbl=tbl)
    with open(file) as f:
        l = f.readline().strip()
        cols = l.split(',')
    for i,c in enumerate(cols):
        if i != 0:
            qry += ','      ## add prefix comma for all but first col
        qry += '{} TEXT'.format(c)
    qry += ');'
    # print(qry)

    ## import csv data into table
    eng = sql.create_engine('postgresql://gpadmin:pivotal@localhost:5432/gpadmin')
    with eng.connect() as conn:
        conn.execute(qry)
    bash = 'psql -c "\COPY {tbl} FROM \'{file}\' DELIMITER \',\' CSV HEADER;"'.format(tbl=tbl, file=file)
    os.system(bash)

if __name__ == '__main__':
    ## opt: [csv_filename], [tbl_created_name]
    file = sys.argv[1]
    tbl = sys.argv[2]
    create_tbl_for_csv(file, tbl)
