/**** TEst Case ****/
DROP TABLE IF EXISTS infer_type_test;
CREATE TABLE infer_type_test (
	col_int VARCHAR,
	col_float VARCHAR,
	col_string VARCHAR,
	col_date VARCHAR,
	col_tstmp VARCHAR,
	col_string2 VARCHAR
) DISTRIBUTED RANDOMLY;

INSERT INTO infer_type_test
VALUES
	('1234', '0.234', '1a.2', '1800-1-1', '1989-12-20', '1'),
	('001', '1.234', '12-34', '1900-1-1', '1989-1-1 12:03:04', '1.0'),
	('1', '1e3', 'asdf','1989-12-20', '1900-1-1', '1989-12-20'),
	('2', '2.0', 'qwer', '1989-12-20', '2000-12-31','1900-1-1');


SELECT infer_table_types('infer_type_test');

SELECT * FROM infer_type_test_infer_types;
