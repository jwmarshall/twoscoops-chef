#
# Cookbook Name:: twoscoops
# Recipe:: deploy
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

secret = Chef::EncryptedDataBagItem.load_secret("/tmp/encrypted_data_bag_secret")
github_keys = Chef::EncryptedDataBagItem.load("github-deploy", node['twoscoops']['application_name'], secret)

include_recipe "twoscoops::database"
include_recipe "twoscoops::webserver"

user "deploy" do
  home node['twoscoops']['application_deploy_path']
  shell "/bin/bash"
  supports :manage_home => true
end

application node['twoscoops']['application_name'] do
  packages ["git-core"]
  path "#{node['twoscoops']['application_deploy_path']}/#{node['twoscoops']['application_name']}"
  repository node['twoscoops']['application_repository']
  revision node['twoscoops']['application_revision']
  deploy_key github_keys['private_key']
  owner "deploy"
  group "deploy"

  migrate true
  migration_command "echo 'migrate!'"
  symlink_before_migrate ({
    "settings/database.py" => "#{node['twoscoops']['project_name']}/#{node['twoscoops']['project_name']}/settings/database.py",
    "app_environment.sh" => "#{node['twoscoops']['project_name']}/app_environment.sh" 
  })
  before_migrate do
    directory "#{shared_path}/settings" do
      recursive true
    end

    template "#{shared_path}/settings/database.py" do
      source "database.py.erb"
      mode 00644
    end

    template "#{shared_path}/app_environment.sh" do
      source "environment.sh.erb"
      mode 00755
    end
  end

  restart_command do
    supervisor_service "uwsgi" do
      action :restart
    end
  end
  before_restart do
    execute "pip-install-requirements" do
      cwd "#{shared_path}/../current"
      command "pip install -r requirements.txt"
    end

    bash "django-syncdb" do
      cwd "#{shared_path}/../current/#{node['twoscoops']['project_name']}"
      code <<-EOF
        source app_environment.sh
        ./manage.py syncdb --noinput
      EOF
    end

    bash "django-createcachetable" do
      cwd "#{shared_path}/../current/#{node['twoscoops']['project_name']}"
      code <<-EOF
        source app_environment.sh
        ./manage.py createcachetable application_cache
      EOF
      only_if do
        con = PGconn.connect("host=localhost user=postgres password=#{node['postgresql']['password']['postgres']} dbname=#{node['twoscoops']['application_name']}")
        res = con.exec("SELECT count(*) FROM information_schema.tables WHERE table_name = 'application_cache'")
        res.entries[0]['count'] == 0
      end
    end

    directory "/tmp/twoscoops/fixtures" do
      recursive true
      action :create
      mode 00755
    end

    template "/tmp/twoscoops/fixtures/createsuperuser.json" do
      source "createsuperuser.json.erb"
    end

    bash "django-createsuperuser" do
      cwd "#{shared_path}/../current/#{node['twoscoops']['project_name']}"
      code <<-EOF
        source app_environment.sh
        ./manage.py loaddata /tmp/twoscoops/fixtures/createsuperuser.json
      EOF
    end

    bash "django-migrate" do
      cwd "#{shared_path}/../current/#{node['twoscoops']['project_name']}"
      code <<-EOF
        source app_environment.sh
        ./manage.py migrate
      EOF
    end

    bash "django-collectstatic" do
      cwd "#{shared_path}/../current/#{node['twoscoops']['project_name']}"
      code <<-EOF
        source app_environment.sh
        ./manage.py collectstatic --noinput
      EOF
    end
  end
end

