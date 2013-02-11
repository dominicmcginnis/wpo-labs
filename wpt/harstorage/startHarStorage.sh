#!/bin/sh

mongod --dbpath /Users/rmcginnis/opt/mongodb/data &
paster serve production.ini &
