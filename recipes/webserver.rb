#
# Cookbook Name:: twoscoops
# Recipe:: production
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "nginx"

template "#{node['nginx']['dir']}/sites-enabled/#{node['twoscoops']['application_name']}" do
  source "nginx.conf.erb"
  mode 0440
  owner "root"
  group "root"  
end

nginx_site node['twoscoops']['application_name'] do
  action :enable
end

include_recipe "supervisor"
include_recipe "uwsgi"

supervisor_service "uwsgi" do
  user "www-data"
  command "/usr/local/bin/uwsgi --uwsgi-socket :8080 --wsgi-file #{node['twoscoops']['project_name']}/wsgi.py --touch-reload=/tmp/uwsgi_restart.txt"
  autostart true
  directory "#{node['twoscoops']['application_deploy_path']}/#{node['twoscoops']['application_name']}/current/#{node['twoscoops']['project_name']}"
  stdout_logfile "/var/log/uwsgi.log"
  stderr_logfile "/var/log/uwsgi_error.log"
  environment "SECRET_KEY" => node['twoscoops']['secret_key'],
              "DJANGO_SETTINGS_MODULE" => "#{node['twoscoops']['project_name']}.settings.#{node['twoscoops']['application_environment']}"
  action :enable
end
