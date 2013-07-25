source 'https://rubygems.org'

gem 'rails', '3.2.13'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

#Use the new Hydra release stack - this isn't working at the moment
#gem 'hydra', '~> 6.0.0.rc2'

#We still need the blacklight/hydra-head reference
gem 'blacklight', '4.1.0'
gem "hydra-head", "~> 6.3.1"
gem 'hydra-role-management', '~> 0.0.2'

#State machine
gem 'state_machine', '~> 1.2.0'

#simple_form gem for forms
gem "simple_form", "~> 2.1.0"

gem 'sqlite3'

#devise_cas_authenticable is used to enable CAS integration
gem 'devise_cas_authenticatable', '~> 1.2.0'

# rubytree provides generic tree structures, used for building set trees...
gem "rubytree", "~> 0.8.3"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'jquery-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'debugger', '~> 1.5.0'
end

group :development, :test do
  gem 'jettywrapper'
end

group :test do 
  gem 'rspec-rails'
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
