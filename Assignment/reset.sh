dropdb a1-c
createdb a1-c
psql a1-c -f asx-schema.sql
psql a1-c -f asx-insert.sql
psql a1-c -f a1.sql
