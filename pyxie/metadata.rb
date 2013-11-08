name             'pyxie'
maintainer       'Andrew Odewahn'
maintainer_email 'odewahn@oreilly.com'
license          'MIT'
description      'Installs/Configures pyxie frontend webapp and dependencies'
long_description 'Installs/Configures pyxie frontend webapp and dependencies'
version          '0.1.0'
%w[ debian ubuntu centos redhat fedora scientific suse amazon].each do |os|
  supports os
end

recipe "pyxie::localhost", "Recipe specifically for local provisioning via Vagrant"

depends "apt"
depends "ruby_build"
depends "rbenv"
depends "git"
depends "redisio"
depends "postgresql"