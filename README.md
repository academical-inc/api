Academical API
===

The API is a REST API implemented using Sinatra and Ruby. It manages students, schedules and courses. It provides endpoints for searching and authenticating students. 

* **Storage**: The API uses Mongo ID as its ORM and expects to be backed by a mongodb instance.

* **Searching**: The API uses elasticsearch for indexing and searching course catalogs. 

* **Authentication**: The API uses Open ID for authentication. At the moment only Facebook and Active Directory are supported.

Running
====

You should be able to use ``rackup`` for running the project. The project uses environment variables for its configuration. 
