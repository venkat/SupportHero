#!/usr/bin/env bash
gem install slop json rest-client
curl -LO https://github.com/venkat/SupportHero/raw/master/bin/hero.rb
curl -LO https://raw.githubusercontent.com/venkat/SupportHero/master/app/command_processor.rb
chmod a+x hero.rb
echo "Please set the API_URL environment variable before using ./hero.rb"
