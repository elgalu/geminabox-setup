# WIP geminabox sample usage

WIP On setting a geminabox Rubygems proxy/cache server to speed up CI

## Pending

- Make this work even without internet connection

> Errno::ENOENT - No such file or directory - getaddrinfo (https://bundler.rubygems.org:443):
> geminabox-0.12.1/lib/geminabox/server.rb:232:in `remote_gem_list'

> Errno::ENOENT - No such file or directory - getaddrinfo (http://rubygems.org:80)
> geminabox-0.12.1/lib/geminabox/proxy/splicer.rb:38:in `merge_content'


- Don't connect to rubygems everytime, try to cache everything
Perhaps update latest specs every 5 minutes
Perhaps update specs every 3 hours

- Add the gem server to your system-wide gem sources
gem sources --add http://localhost:3132

## Possible strategies

Ideal would be to have already downloaded most used gems, using the rubygems.org API we can:

```bash
# top 50 downloaded gem versions for today
https://rubygems.org/api/v1/downloads/top.json
# top 50 downloaded gem versions of all time
https://rubygems.org/api/v1/downloads/all.json
# 50 most recently updated gems
https://rubygems.org/api/v1/activity/just_updated.json
# 50 gems most recently added to RubyGems.org for the first time ever
https://rubygems.org/api/v1/activity/latest.json
```

### geminabox
Add missing dependencies caching?

### rubygems-mirror
But only mirroring most used gems and request on-demand the missing ones
- https://github.com/rubygems/rubygems-mirror
- http://www.railscook.com/recipes/mirror-ruby-gems-locally/

> If your environment contains a local mirror of the rubygems.org server, use the mirror.URL configuration option
> Bundler will download gems and gemspecs from that mirror instead of the source listed in the Gemfile
- http://bundler.io/v1.5/bundle_config.html#gem-source-mirrors

    bundle install --source http://mirror.localhost:3132

### squid
Plain old squid http proxy server?

- http://failshell.io/ruby/mirroring-rubygems-org-take-2/
- http://www.squid-cache.org/

## Speeding up bundler with 1.5.0.rc1

With parallel workers and retry failed. The retry option is specially useful in TravisCI

        bundle install --jobs 4 --retry 3

## Answer/solve/comment this questions/opinions or simply add the project there

- https://github.com/geminabox/geminabox/issues/94
- https://github.com/copiousfreetime/stickler/issues/7
- https://github.com/rubygems/rubygems-mirror/issues/21
- https://github.com/rubygems/rubygems/issues/286#issuecomment-30107630
- http://robots.thoughtbot.com/fetching-source-index-for-http-rubygems-org
- http://stackoverflow.com/questions/8411045/how-to-build-a-rubygems-mirror-server
- http://stackoverflow.com/questions/16959060/install-ruby-gems-offline-proxy-configuration
- http://patshaughnessy.net/2011/10/14/why-bundler-1-1-will-be-much-faster
- http://hone.heroku.com/bundler%20heroku/2012/10/22/rubygems-and-the-dependency-api.html
- http://www.sitepoint.com/a-chat-with-nick-quaranto-about-rubygems-org-internals/
- http://www.slideshare.net/rmoriz/rubygems-behind-the-gems
- http://guides.rubygems.org/resources/#hosting_and_serving
- http://guides.rubygems.org/contributing
- https://github.com/rubygems/rubygems-mirror/wiki/Mirroring-2.0

### Rubygems Team
- David Radcliffe @dwradcliffe
- Eric Hodel @drbrain
- Evan Phoenix @evanph
- Nick Quaranto @qrush
- Andre Arko @indirect
- Terence Lee @hone
- Erik Michaels-Ober @sferik
- Sam Kottler @skottler

## Debugging the API

- http://localhost:3132/api/v1/dependencies.json?gems=rake
- http://bundler.rubygems.org/api/v1/dependencies.json?gems=rake

### Debugging with WireShark

1. In order to capture rubygems packets you'll need to fall back to unsecured http instead of https:

```shell
$ cat ~/.gemrc #=>
```

```yaml
---
:backtrace: false
:bulk_threshold: 1000
:sources:
- http://rubygems.org
:update_sources: true
:verbose: true
```

2. Open WireShark. Select interface "any" to capture on all of them. Edit interface settings. Set capture filter to:

### Wireshark filters

#### Capture filter

I don't recommend you try to filter hosts like rubygems.org and bundler.rubygems.org since you may lose packets within *.s3.amazon.org and Wireshark doesn't currently support wildcard Capture Filters like *.rubygems.org. Stick with a tcp capture filter.

    # Google:  173.194.0.0/16, 173.194.42.0/24, 181.15.96.0/21
    # Dropbox: 108.160.160.0/20, 23.21.192.94
    # CloudFlare CDN network: 141.101.112.0/20, 141.101.116.0/22, 141.101.117.0/24, 54.230.57.134
    # MediaMath: 74.121.139.0/24
    # Latin American Nautilus: 200.123.192.0/20, 66.232.56.224
    # Linkedin: 216.52.224.0/19, 216.52.242.0/24
    tcp and not port 38137 and not net 173.194.0.0/16 and not net 173.194.42.0/24 and not net 181.15.96.0/21 and not net 108.160.160.0/20 and not net 23.21.192.94 and not net 141.101.112.0/20 and not net 141.101.116.0/22 and not net 141.101.117.0/24 and not net 54.230.57.134 and not net 74.121.139.0/24 and not net 200.123.192.0/20 and not net 66.232.56.224 and not 216.52.224.0/19 and not 216.52.242.0/24

#### Display filter

I suggest you always enable this filter while debugging gem/bundler related traffic

    http.host contains rubygems or http.request.uri contains gem or http.response.code == 302 or http.response.code == 301

Once you locate a request of interest, right click on it and select "Follow TCP Stream" to see where it goes.

#### Notes on Wireshark

Wireshark interprets the TCP "sub-protocol" based on the port number instead of the request headers. So if you are using port 9292 it will fail to show you a nicely parse HTTP request and instead will show "armtechdaemon" which is useless in this case.
So you have two options, to add your custom port (e.g. 9292) to Wireshark menu Edit -> Preferences -> Protocols -> HTTP -> TCP Ports or option two; stick using one of the default ports Wireshark interprets as HTTP: 80,3128,3132,5985,8080,8088,11371,1900,2869,2710.

Some example capture filters

    host rubygems.org
    (host rubygems.org and tcp) or (host localhost and port 3132)
    tcp and (host rubygems.org or host bundler.rubygems.org or (host localhost and port 3132) or (host 127.0.1.1 and port 3132))

If you are only interested in capturing HTTP GET request instead of using the "Display Filters" later on you can use this:

    ((host rubygems.org or host bundler.rubygems.org and tcp) or (host localhost and port 3132)) and (tcp[((tcp[12:1] & 0xf0) >> 2):2] = 0x4745 && tcp[((tcp[12:1] & 0xf0) >> 2) + 2:1] = 0x54)

Was built using [wireshark tools](http://www.wireshark.org/tools/string-cf.html)

3. Go to menu Capture -> Start

4. Play with display filters

Display filters (examples)

    http.request.method == GET
    http.request.uri contains ".gz"
    http.request.uri contains ".gz" or http.request.uri contains ".rz"
    http.host contains "rubygems"
    http.request.full_uri contains "rubygems"
    (ip.addr == 54.245.255.174 or ip.addr == 23.23.111.142) and http

### Ruby profiler to determine the bottle-necks

```bash
gem install ruby-prof
```


