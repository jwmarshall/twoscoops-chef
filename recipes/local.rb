#
# Cookbook Name:: twoscoops
# Recipe:: development
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "twoscoops::database"

directory "/vagrant/logs" do
  action :create
  mode 00755
end

template "/vagrant/#{node['twoscoops']['project_name']}/#{node['twoscoops']['project_name']}/settings/database.py" do
  source "database.py.erb"
  mode 00644
end

execute "pip-install-requirements" do
  cwd "/vagrant"
  command "pip install -r requirements/local.txt"
end

execute "django-syncdb" do
  cwd "/vagrant/#{node['twoscoops']['project_name']}"
  command "python manage.py syncdb --noinput"
end

directory "/tmp/twoscoops/fixtures" do
  recursive true
  action :create
  mode 00755
end

template "/tmp/twoscoops/fixtures/createsuperuser.json" do
  source "createsuperuser.json.erb"
end

execute "django-createsuperuser" do
  cwd "/vagrant/#{node['twoscoops']['project_name']}"
  command "python manage.py loaddata /tmp/twoscoops/fixtures/createsuperuser.json"
end

execute "django-migrate" do
  cwd "/vagrant/#{node['twoscoops']['project_name']}"
  command "python manage.py migrate"
end

include_recipe "supervisor"

supervisor_service "django" do
  command "python manage.py runserver 0.0.0.0:8080"
  autostart true
  directory "/vagrant/#{node['twoscoops']['project_name']}"
  stdout_logfile "/vagrant/logs/django.log"
  stderr_logfile "/vagrant/logs/django_error.log"
  action :enable
end

