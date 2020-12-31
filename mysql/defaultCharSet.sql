--Find default Characater Set for Database:

SELECT 
	default_character_set_name 
FROM information_schema.SCHEMATA 
WHERE schema_name = 'Database_Name';

--Find default Characater Set for Table:

SELECT 
	CCSA.character_set_name 
FROM information_schema.TABLES AS T
INNER JOIN information_schema.COLLATION_CHARACTER_SET_APPLICABILITY AS CCSA
	ON CCSA.collation_name = T.table_collation
WHERE T.table_schema = 'Database_Name'
  AND T.table_name = 'Table_Name';

--Find default Character Set for Column:

SELECT 
	character_set_name 
FROM information_schema.COLUMNS 
WHERE table_schema = 'Database_Name'
  AND table_name = 'Table_Name'
  AND column_name = 'Column_Name';
