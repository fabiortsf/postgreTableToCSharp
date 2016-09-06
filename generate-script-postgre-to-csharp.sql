
DO $$
DECLARE v_tabela varchar;
DECLARE v_cursor_colunas record;
DECLARE v_nome_coluna varchar;
DECLARE v_classe VARCHAR;
DECLARE v_tipo VARCHAR;
DECLARE v_schema_name VARCHAR;

BEGIN
  v_schema_name := 'cobrarweb';
  v_tabela := 'banco';
 
  select table_name INTO v_tabela from information_schema.tables where table_schema = v_schema_name
  and table_type = 'BASE TABLE'
  and table_name = v_tabela; 

   v_classe := E'\r\n' || 'public class ' || v_tabela || ' {' ||  E'\r\n';
   FOR v_cursor_colunas IN
	SELECT column_name as coluna, is_nullable as isnull, data_type as tipo, character_maximum_length as tamanho
	FROM information_schema.columns
	WHERE table_schema = v_schema_name
	AND table_name   = v_tabela
   LOOP
      --TIPOS
      IF v_cursor_colunas.tipo='character varying' THEN
        v_tipo:= 'string';
      ELSIF v_cursor_colunas.tipo='character' and v_cursor_colunas.tamanho=1 THEN
        v_tipo:= 'char';
      ELSIF v_cursor_colunas.tipo='character' and v_cursor_colunas.tamanho<>1 THEN
        v_tipo:= 'string';
      ELSIF v_cursor_colunas.tipo='timestamp with time zone' THEN
        v_tipo:= 'DateTime';
      ELSIF v_cursor_colunas.tipo='boolean' THEN
        v_tipo:= 'bool';
      ELSIF v_cursor_colunas.tipo='integer' THEN
        v_tipo:= 'int';
      ELSIF v_cursor_colunas.tipo='numeric' THEN
        v_tipo:= 'double';
      ELSIF v_cursor_colunas.tipo='text' THEN
        v_tipo:= 'string';
      ELSE
	v_tipo:= 'another';
      END IF;
      
      --ATRIBUTES
      v_nome_coluna := v_cursor_colunas.coluna;
      v_classe := v_classe || 'private ' || v_tipo || ' _' || v_cursor_colunas.coluna || ';' || E'\r\n';

      --PROPERTIES
      v_classe := v_classe || 'public ' || v_tipo || ' ' || v_cursor_colunas.coluna || '{' || E'\r\n';
      v_classe := v_classe || '  get {' || ' return _' || v_cursor_colunas.coluna || '; }' || E'\r\n';
      v_classe := v_classe || '  set {' || ' _' || v_cursor_colunas.coluna || ' = value; }' || E'\r\n';
      v_classe := v_classe || '}' || E'\r\n';
      
   END LOOP;
   v_classe := v_classe || E'\r\n' || '}';
   
  RAISE NOTICE '%' , v_classe;

END $$;

