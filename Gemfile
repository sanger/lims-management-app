source "http://rubygems.org"
gemspec

gem 'sinatra', :git => 'http://github.com/sinatra/sinatra.git', :branch => '459369eb66224836f72e21bbece58c007f3422fa'
gem 'lims-core', '~>2.0', :git => 'http://github.com/sanger/lims-core.git' , :branch => 'version-2'
gem 'lims-api', '~>2.0', :git => 'http://github.com/sanger/lims-api.git' , :branch => 'version-2'

group :development do
  gem 'redcarpet', '~> 2.1.0', :platforms => :mri
  gem 'sqlite3', :platforms => :mri
  gem 'mysql2'
end

group :debugger do
  gem 'debugger', :platforms => :mri
  gem 'debugger-completion', :platforms => :mri
  gem 'shotgun', :platforms => :mri
end

group :deployment do
  gem "psd_logger", :git => "http://github.com/sanger/psd_logger.git"
  gem 'trinidad', :platforms => :jruby
  gem "trinidad_daemon_extension", :platforms => :jruby
  gem 'activesupport', '~> 3.0.0', :platforms => :jruby
  gem 'jdbc-mysql', :platforms => :jruby
end
