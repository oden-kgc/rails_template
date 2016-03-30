# repository
repo_url = 'https://raw.githubusercontent.com/oden-kgc/rails_template/master'

# アプリ名
@app_name = app_name

#
# Gemfile
#
gem 'therubyracer', platforms: :ruby
gem 'bcrypt', '~> 3.1.7'

# db schema
gem 'ridgepole'
run "wget 

# db seed
gem 'seed-fu'

# config
gem 'config'

# javascript sugar
gem 'sugar-rails'

# jquery & turbolinks
gem 'jquery-turbolinks'

# jquery ui
gem 'jquery-ui-rails'

# for Redis
gem 'redis'
gem 'redis-rails'

# rescue
gem 'resque'
gem 'resque-scheduler'
initializer 'resque.rb', <<-CODE
  Resque.redis = 'localhost:6379'
  Resque.redis.namespace = "rescue:#{@app_name}:\#\{Rails.env\}"
  Resque.after_fork = Proc.new { ActiveRecord::Base.establish_connection }
CODE
initializer 'active_job.rb', <<-ACTIVE_JOB
  ActiveJob::Base.queue_adapter = :resque
ACTIVE_JOB

# whenever
gem 'whenever'

# daemon-spawn (for activejob)
gem 'daemon-spawn', :require => 'daemon_spawn'

# jquery cookie
gem 'jquery-cookie-rails'

# confirm bootstrap dialog
gem 'data-confirm-modal', github: 'ifad/data-confirm-modal'

# haml
gem 'haml-rails'

# bootstrap
gem 'autoprefixer-rails'
gem 'bootstrap-sass'
gem 'font-awesome-sass'
gem 'bootbox-rails'
gem 'bootstrap-sass-extras'

# simple_form
gem 'simple_form'
generate 'simple_form:install --bootstrap'
if yes?('Use nested_form ?')
  gem 'nested_form'
end

# pagination
gem 'kaminari'

# devise & cancan
if yes?('Use devise ?')
  gem 'devise'
  gem 'devise-bootstrap-views'
  gem 'devise-i18n'
  gem 'devise-i18n-views'
  gem 'cancancan'

  after_bundle do
    generate 'devise:install'
    model_name = ask('User model name ? [user]')
    model_name = "user" if model_name.blank?
    generate "devise", model_name
    generate 'cancan:ability'
  end
end

# feature phone
if yes?('Use feature phone ?')
  gem 'jpmobile'
end

gem_group :development, :test do
  gem 'pry'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'pry-doc'
  gem 'pry-stack_explorer'
  gem 'better_errors'
  gem 'binding_of_caller'

  gem 'hirb'
  gem 'hirb-unicode'

  gem 'quiet_assets'
  gem 'annotate'
  gem 'tapp'
  gem 'awesome_print'
  gem 'timecop'
  gem 'colorize_unpermitted_parameters'
  gem 'rack-mini-profiler'
  gem 'xray-rails'

  gem 'rspec'
  gem 'rspec-rails'
  gem 'guard-rspec', require: false
  gem 'spring-commands-rspec'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'faker-japanese'

  gem 'simplecov'
  gem 'rack-dev-mark'

  gem 'bullet'

  gem 'erb2haml'
  gem 'rails-footnotes'
end

after_bundle do
  generate 'rspec:install'
end

gem_group :test do
  gem 'capybara'
  gem 'poltergeist'
  gem 'database_cleaner'
end

gem_group :production do
  gem 'pg'
end

# jasmine install
if yes?('Use jasmine ?')
  gem_group :development, :test do
    gem 'phantomjs'
    gem 'jasmine-rails'
    gem 'jasmine-jquery-rails'
  end

  after_bundle do
    generate 'jasmine_rails:install'
  end
end

# remove
run 'rm README.rdoc'
run 'rm -rf test/'

# .gitignore
run 'rm .gitignore'
run "wget -O .gitignore #{repo_url}/gitignore"

# .pryrc
run "wget -O .pryrc #{repo_url}/pryrc"

# application.js
run 'rm app/assets/javascripts/application.js'
run "wget -O app/assets/javascripts/application.js #{repo_url}/application.js"

# application.sass
run 'rm app/assets/stylesheets/application.css'
run "wget -O app/assets/stylesheets/application.sass #{repo_url}/application.sass"

