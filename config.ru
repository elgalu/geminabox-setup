require 'rubygems'
require 'geminabox'

# The so called legacy versions (< 1.2)
Geminabox.build_legacy = false

# Also pull gems from rubygems.org
# Note this can also be done through environment variables: RUBYGEMS_PROXY=true rackup
Geminabox.rubygems_proxy = true

# Sample dirs where you can save gems data:
#   /var/geminabox-data
#   File.join(ENV['HOME'], 'geminabox', 'data')
#   File.expand_path('../data', __FILE__)
Geminabox.data = './data'

run Geminabox::Server

