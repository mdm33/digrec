source 'https://rubygems.org'

#gem 'rails', '3.2.21'
gem 'rails', git: 'https://github.com/rails/rails.git', branch: '3-2-stable'
gem 'json'
gem 'sass-rails'

gem 'formtastic'
gem 'kaminari'
gem 'haml'
gem 'devise', '~> 2.2.4'
gem 'devise-encryptable'
gem 'exception_notification', '~> 3.0.1'
gem 'audited-activerecord', '~> 3.0'
gem 'ransack', '~> 0.7.2'

gem 'unicode'

gem 'builder' # builder is faster than Nokogiri's built-in builder
gem 'nokogiri'
gem 'nori'

gem 'gchartrb', :require => 'google_chart'
gem 'diff-lcs', :require => 'diff/lcs'
gem 'alignment'
gem 'redcarpet', '~> 2.3.0'
gem 'differ'
gem 'iso-codes', :require => 'iso_codes'
gem 'ruby-sfst', :require => 'sfst'
gem 'colorize'

group :production, :development do
  gem 'mysql2', '> 0.3.0'
  gem 'pg'
  gem 'thin'
end

gem 'foreman'
gem 'dotenv'

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'sqlite3'
  gem 'simplecov', require: false
  gem 'test-unit'
  gem 'rack-mini-profiler', require: false
  gem 'flamegraph'
end
