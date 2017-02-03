source "http://rubygems.org"
gemspec

gem 'sinatra', :git => 'http://github.com/sinatra/sinatra.git', :branch => '459369eb66224836f72e21bbece58c007f3422fa'
gem 'lims-core', '~>3.2.1', :git => 'http://github.com/sanger/lims-core.git' , :branch => 'master'
gem 'lims-api', '~>3.2.2', :git => 'http://github.com/sanger/lims-api.git' , :branch => 'master'
gem 'lims-exception-notifier-app', '~>0.1', :git => 'http://github.com/sanger/lims-exception-notifier-app.git', :branch => 'master'

gem 'open_uri_redirections'

group :development do
  gem 'redcarpet', '~> 2.1.0', :platforms => :mri
  gem 'sqlite3', :platforms => :mri
  gem 'timecop', :platforms => :mri
  gem 'mysql2', :platforms => :mri
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
