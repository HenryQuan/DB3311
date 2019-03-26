dropdb a1
createdb a1
psql a1 -f asx-schema.sql
psql a1 -f asx-insert.sql
psql a1 -f a1.sql
