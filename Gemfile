source 'https://rubygems.org'

gem "rails", "~> 3.2.16"

#Use the new Hydra release stack
gem "hydra", "~> 6.1.0"
gem "hydra-role-management", "~> 0.1.0"

#State machine
gem 'state_machine', '~> 1.2.0'

#simple_form gem for forms
gem "simple_form", "~> 2.1.0"

gem 'sqlite3'
gem 'mysql2'

#devise_cas_authenticable is used to enable CAS integration
gem "devise_cas_authenticatable", "~> 1.3.2"

# rubytree provides generic tree structures, used for building set trees...
gem "rubytree", "~> 0.8.3"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'jquery-rails'
  gem "jquery-ui-rails", "~> 4.1.0"

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'debugger', '~> 1.5.0'
end

group :development, :test do
  gem "jettywrapper", "~> 1.5.0"
end

group :test do 
  gem "rspec-rails", "~> 2.14.0"
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'warden'
end


# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'

gem "unicode", :platforms => [:mri_18, :mri_19]
gem "devise"
gem "devise-guests", "~> 0.3"
gem "bootstrap-sass"
gem "bootstrap_forms"
