source "http://rubygems.org"
gemspec

gem 'sinatra', :git => 'http://github.com/sinatra/sinatra.git', :branch => '459369eb66224836f72e21bbece58c007f3422fa'
gem 'lims-core', '~>1.5', :git => 'http://github.com/sanger/lims-core.git' , :branch => 'development'
#gem 'lims-core', :path => '../lims-core' 
gem 'lims-api', '~>1.2', :git => 'http://github.com/sanger/lims-api.git' , :branch => 'development'
#gem 'lims-api', :path => '../lims-api' 

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
