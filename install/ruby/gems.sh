#!/usr/bin/env bash

brew unlink ruby && brew link ruby

gem install nokogiri -- --use-system-libraries=true --with-xml2-include=$(brew --prefix libxml2)/include/libxml2
gem install jekyll
gem install bundler
gem install tmuxinator