#!/usr/bin/env bash

DATABASE_PATH="$HOME/workspace/openphone/backend/dev/database"
CONTACT_PATH="$HOME/workspace/openphone/backend/dev/contact-database"

psql -h localhost -U postgres -c "
  DROP DATABASE IF EXISTS openphone;
"

psql -h localhost -U postgres -c "
  DROP DATABASE IF EXISTS openphone_contact;
"

# psql -h localhost -U postgres -c "
#   DROP ROLE IF EXISTS openphone;
# "
#
psql -h localhost -U postgres -c "
  CREATE ROLE openphone
  WITH LOGIN ENCRYPTED PASSWORD 'docker';
"

psql -h localhost -U postgres -c "
  CREATE DATABASE openphone
  OWNER = 'openphone'
  ENCODING = 'UTF8'
  LC_COLLATE = 'en_US.UTF-8'
  LC_CTYPE = 'en_US.UTF-8'
  TEMPLATE template0;
"

psql -h localhost -U postgres -c "
  CREATE DATABASE openphone_contact
  OWNER = 'openphone'
  ENCODING = 'UTF8'
  LC_COLLATE = 'en_US.UTF-8'
  LC_CTYPE = 'en_US.UTF-8'
  TEMPLATE template0;
"

psql -h localhost -U postgres -d openphone_contact -c "
  CREATE EXTENSION IF NOT EXISTS pgcrypto;
"

cd "$DATABASE_PATH" || return
npm run db:upgrade

cd "$CONTACT_PATH" || return
npm run db:upgrade
