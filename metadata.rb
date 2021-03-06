name             'twoscoops'
maintainer       'YOUR_COMPANY_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures twoscoops'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.5'

depends          'build-essential'
depends          'python'
depends          'supervisor'
depends          'database'
depends          'postgresql'
depends          'nginx'
depends          'uwsgi'
depends          'application'
