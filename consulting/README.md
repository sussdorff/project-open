# project-open
Dockerfile for project-open image creation

Ensure to unpack the correct database file in database FIRST before you start the containers with docker-compose up.

This is only needed for initialization of the database and you can use your own pg_dump (as long as it is created with the -O flag) in here.