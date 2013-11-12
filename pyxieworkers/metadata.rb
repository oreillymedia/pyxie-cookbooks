name             'pyxieworkers'
maintainer       'Andrew Odewahn'
maintainer_email 'odewahn@oreilly.com'
license          'MIT'
description      'Installs/Configures pyxie-workers'
long_description 'Installs/Configures pyxie-workers'
version          '0.1.0'
recipe           'pyxie-workers', 'Installs and configures pyxie-workers'


%w[ debian ubuntu centos redhat fedora scientific suse amazon].each do |os|
  supports os
end


depends "docker"
depends "apt"
depends "ruby_build"
depends "rbenv"
depends "git"
depends "redisio"
depends "nodejs"
#depends "npm"