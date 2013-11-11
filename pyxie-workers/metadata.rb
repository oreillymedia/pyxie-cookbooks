name             'docker vagrant example'
maintainer       'Steve Klise'
maintainer_email 'sklise@oreilly.com'
license          'Apache 2.0'
description      'Installs/Configures Docker along with some other stuff'
long_description 'Installs/Configures Docker with redis and postgres'
version          '0.1.0'
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