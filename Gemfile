source "http://rubygems.org"
gemspec

gem 'sinatra', :git => 'http://github.com/sinatra/sinatra.git', :branch => '459369eb66224836f72e21bbece58c007f3422fa'
gem 'lims-core', '~>1.5', :git => 'http://github.com/sanger/lims-core.git' , :branch => 'master'
gem 'lims-api', '~>1.2', :git => 'http://github.com/sanger/lims-api.git' , :branch => 'master'

group :development do
  gem 'redcarpet', '~> 2.1.0', :platforms => :mri
  gem 'sqlite3', :platforms => :mri
end

group :debugger do
  gem 'debugger', :platforms => :mri
  gem 'debugger-completion', :platforms => :mri
  gem 'shotgun', :platforms => :mri
end
