# Default attributes

default["twoscoops"]["project_name"] = nil
default["twoscoops"]["application_name"] = nil
default["twoscoops"]["application_revision"] = nil

default["twoscoops"]["application_deploy_path"] = "/srv/www"
default["twoscoops"]["application_environment"] = "local"

default["twoscoops"]["database"]["engine"] = "django.db.backends.postgresql_psycopg2"
default["twoscoops"]["database"]["username"] = "vagrant"
default["twoscoops"]["database"]["password"] = "vagrant"
default["twoscoops"]["database"]["host"] = "127.0.0.1"
default["twoscoops"]["database"]["port"] = ""

default["twoscoops"]["superuser"]["username"] = "vagrant"
default["twoscoops"]["superuser"]["password_hash"] = "pbkdf2_sha256$10000$NoIByEhX0v78$UgkCwmSHBNYiFPD0zCkZ9x+S7z5tlRysHv/L68OJdxc="

