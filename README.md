# WIP geminabox sample usage

WIP On setting a geminabox Rubygems proxy/cache server to speed up CI

## Pending

- Make this work even without internet connection

> Errno::ENOENT - No such file or directory - getaddrinfo (https://bundler.rubygems.org:443):
> geminabox-0.12.1/lib/geminabox/server.rb:232:in `remote_gem_list'

> Errno::ENOENT - No such file or directory - getaddrinfo (http://rubygems.org:80)
> geminabox-0.12.1/lib/geminabox/proxy/splicer.rb:38:in `merge_content'


- Don't connect to rubygems everytime, try to cache everything


- Add the gem server to your system-wide gem sources
gem sources --add http://localhost:9292
