#!/usr/bin/env bash

# Install Latest Ruby with rbenv and ruby-build
CURRENT_RUBY_VERSION=$(rbenv global)
LATEST_RUBY_VERSION=$(rbenv install -l | grep -v - | tail -1)
rbenv install -s $LATEST_RUBY_VERSION
rbenv global $LATEST_RUBY_VERSION
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

gem install nokogiri -- --use-system-libraries=true --with-xml2-include=$(brew --prefix libxml2)/include/libxml2
gem install jekyll
gem install bundler
gem install tmuxinator
gem install rails

# Execute this if ruby is updated
if [ "$CURRENT_RUBY_VERSION" = "$LATEST_RUBY_VERSION" ]; then
	gem pristine --all
fi
