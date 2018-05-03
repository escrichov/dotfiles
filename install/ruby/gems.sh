#!/usr/bin/env bash

brew link --overwrite ruby && reload

gem install nokogiri -- --use-system-libraries=true --with-xml2-include=$(brew --prefix libxml2)/include/libxml2
gem install jekyll
gem install bundler
