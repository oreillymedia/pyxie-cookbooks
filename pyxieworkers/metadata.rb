name             'pyxieworkers'
maintainer       'Andrew Odewahn'
maintainer_email 'odewahn@oreilly.com'
license          'MIT'
description      'Installs/Configures pyxie-workers'
long_description 'Installs/Configures pyxie-workers'
version          '0.1.0'
recipe           'pyxieworkers::deploy', 'Installs and configures pyxie workers'
recipe           'pyxieworkers::configure_localhost', 'Installs and configures pyxie workers on a vagrant box'


%w[ debian ubuntu centos redhat fedora scientific suse amazon].each do |os|
  supports os
end


depends "dotenv"
depends "docker"
depends "apt"
depends "ruby_build"
depends "rbenv"
depends "git"
depends "redisio"
depends "nodejs"
depends "npm"