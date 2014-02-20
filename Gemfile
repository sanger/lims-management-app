source "http://rubygems.org"
gemspec

gem 'sinatra', :git => 'http://github.com/sinatra/sinatra.git', :branch => '459369eb66224836f72e21bbece58c007f3422fa'
gem 'lims-core', '~>3.1', :git => 'http://github.com/sanger/lims-core.git' , :branch => 'development'
gem 'lims-api', '~>3.1', :git => 'http://github.com/sanger/lims-api.git' , :branch => 'development'

gem 'json'
gem 'oj', :platforms => :mri

group :development do
  gem 'sqlite3', :platforms => :mri
  gem 'mysql2', :platforms => :mri
  gem 'jdbc-mysql', :platforms => :jruby
  gem 'jdbc-sqlite3', :platforms => :jruby
  gem 'timecop'
  gem 'rest-client', :platforms => :mri
  # fix dependency problem for macaddr gem, to remove when macaddr gem is fixed
  # https://github.com/ahoward/macaddr/commit/a0ae1a76775c705206bde51772d53b178be5ce45
  # https://github.com/ahoward/macaddr/issues/2
  gem 'systemu'
end

group :debugger do
  gem 'debugger', :platforms => :mri
  gem 'debugger-completion', :platforms => :mri
  gem 'shotgun', :platforms => :mri
  gem 'ruby-debug', :platforms => :jruby
end

group :deployment do
  gem "psd_logger", :git => "http://github.com/sanger/psd_logger.git"
  gem 'trinidad', :platforms => :jruby
  gem "trinidad_daemon_extension", :platforms => :jruby
  gem 'activesupport', '~> 3.0.0', :platforms => :jruby
  gem 'jdbc-mysql', :platforms => :jruby
end
