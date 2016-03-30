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
run "wget -O lib/tasks/ridgepole.rake #{repo_url}/ridgepole.rake"

# db seed
gem 'seed-fu'
run 'mkdir -p db/fixtures/{development,production}'

# config
gem 'config'
after_bundle do
  generate 'config:install'
end

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
run "wget -O config/initializers/resque.rb #{repo_url}/resque.rb"
gsub_file 'config/initializers/resque.rb', /APP_NAME/, @app_name
initializer 'active_job.rb', <<-ACTIVE_JOB
  ActiveJob::Base.queue_adapter = :resque
ACTIVE_JOB

# whenever
gem 'whenever'

# daemon-spawn (for activejob)
gem 'daemon-spawn', :require => 'daemon_spawn'
run "wget -O lib/tasks/resque.rake #{repo_url}/resque.rake"
run "wget -O bin/resque_worker #{repo_url}/resque_worker"
gsub_file 'bin/resque_worker', /APP_NAME/, @app_name
run "chmod +x bin/resque_worker"
run 'mkdir -p tmp/pids'

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

after_bundle do
  generate 'bootstrap:install'
  generate 'bootstrap:layout fluid'
end

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
    generate 'devise:views:locale ja'
    generate 'devise:views:bootstrap_templates'
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
  file '.rspec', <<-CODE
    --color
    -fd
    --require spec_helper
  CODE
end

gem_group :test do
  gem 'capybara'
  gem 'poltergeist'
  gem 'database_cleaner'
end

gem_group :production do
  gem 'pg'
end
run "wget -O config/database.yml #{repo_url}/database.yml"

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

after_bundle do
  rake 'haml:replace_erbs'
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

# locales
run "wget -O config/locales/ja.yml https://raw.github.com/svenfuchs/rails-i18n/master/rails/locale/ja.yml"

# environment
application do
  config.time_zone = 'Tokyo'
  config.active_record.default_timezone = :local
  config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml,yaml}')]
  config.i18n.default_locale = :ja
  config.autoload_paths += Dir["#{config.root}/lib"]
end

environment env: 'development' do
  config.action_controller.action_on_unpermitted_parameters = :raise
  config.rack_dev_mark.enable = true
  config.web_console.whitelisted_ips = '172.30.244.1'
  config.after_initialize do
    Bullet.enable = true
    Bullet.alert = true
    Bullet.bullet_logger = true
    Bullet.console = true
    Bullet.rails_logger = true
  end
  config.logger = Logger.new('log/development.log', 5, 10 * 1024 * 1024)
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: '', 
    domain: '', 
    enable_startttls_auto: false
  }
end

environment env: 'production' do
  config.cache_store = :redis_store, 'redis://localhost:6379/0'
  config.logger = Logger.new('log/production.log', 5, 20 * 1024 * 1024)
end

