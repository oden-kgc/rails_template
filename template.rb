# repository
repo_url = 'https://raw.githubusercontent.com/oden-kgc/rails_template/master'

# アプリ名
@app_name = app_name

#
# Gemfile
#

# simple_form
gem 'simple_form'
if yes?('Use nested_form ?')
  gem 'nested_form'
end

# devise & cancan
has_devise = false
model_name = 'user'
if yes?('Use devise ?')
  has_devise = true
  model_name = ask('Devise user model name ? [user]')
  model_name = "user" if model_name.blank?
  gem 'devise'
  gem 'devise-bootstrap-views'
  gem 'devise-i18n'
  gem 'devise-i18n-views'
  gem 'cancancan'
end

# feature phone
if yes?('Use feature phone ?')
  gem 'jpmobile'
end

# jasmine install
has_jasmine = false
if yes?('Use jasmine ?')
  has_jasmine = true
  gem_group :development, :test do
    gem 'phantomjs'
    gem 'jasmine-rails'
    gem 'jasmine-jquery-rails'
  end
end

# db schema
gem 'ridgepole', git: 'https://github.com/winebarrel/ridgepole', branch: 'v0.6.5'

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

# whenever
gem 'whenever'

# daemon-spawn (for activejob)
gem 'daemon-spawn', :require => 'daemon_spawn'

# confirm bootstrap dialog
gem 'data-confirm-modal', git: 'https://github.com/ifad/data-confirm-modal'

# haml
gem 'haml-rails'

# bootstrap
gem 'autoprefixer-rails'
gem 'bootstrap-sass'
gem 'font-awesome-sass'
gem 'bootbox-rails'
gem 'bootstrap-sass-extras'

# pagination
gem 'kaminari'

# js cookie
gem 'js_cookie_rails'

uncomment_lines 'Gemfile', 'therubyracer'
uncomment_lines 'Gemfile', 'bcrypt' if has_devise
comment_lines 'Gemfile', /gem 'listen'/
comment_lines 'Gemfile', /web-console/

gem 'listen', '~> 3.0.5'

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

  gem 'tapp'
  gem 'awesome_print'
  gem 'timecop'
  gem 'colorize_unpermitted_parameters'
  gem 'rack-mini-profiler'
  #gem 'xray-rails', git: 'https://github.com/brentd/xray-rails.git'

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

gem_group :test do
  gem 'capybara'
  gem 'poltergeist'
  gem 'database_cleaner'
end

gem_group :production do
  gem 'pg'
end

bundle_command('install --path=vendor/bundle')

GEN = 'bundle exec rails g '
after_bundle do
  # rspec
  run "#{GEN} rspec:install"

  # rack-dev-mark
  run "#{GEN} rack:dev-mark:install"

  # generate
  run "#{GEN} config:install"
  run "#{GEN} bootstrap:install"
  run "#{GEN} bootstrap:layout application fluid"
  run "#{GEN} simple_form:install --bootstrap"

  if has_devise then
    run "#{GEN} devise:install"
    run "#{GEN} devise #{model_name}"
    run "#{GEN} devise:views:locale ja"
    run "#{GEN} devise:views:bootstrap_templates"
    run "#{GEN} cancan:ability"
  end

  if has_jasmine then
    run "#{GEN} jasmine_rails:install"
  end


  # ridgepole
  get "#{repo_url}/ridgepole.rake", 'lib/tasks/ridgepole.rake'
  run 'touch db/Schemafile'

  # seed_fu
  run 'mkdir -p db/fixtures/development'
  run 'mkdir -p db/fixtures/production'

  # resque
  get "#{repo_url}/resque.rb", 'config/initializers/resque.rb'
  gsub_file 'config/initializers/resque.rb', /APP_NAME/, @app_name
  initializer 'active_job.rb', <<-ACTIVE_JOB
    ActiveJob::Base.queue_adapter = :resque
  ACTIVE_JOB

  # daemon_spawn
  get "#{repo_url}/resque.rake", 'lib/tasks/resque.rake'
  get "#{repo_url}/resque_worker", 'bin/resque_worker'
  gsub_file 'bin/resque_worker', /APP_NAME/, @app_name
  run "chmod +x bin/resque_worker"
  run 'mkdir -p tmp/pids'

  # database
  run 'rm config/database.yml'
  get "#{repo_url}/database.yml", 'config/database.yml'

  # remove
  run 'rm README.rdoc'
  run 'rm -rf test/'

  # .gitignore
  run 'rm .gitignore'
  get "#{repo_url}/gitignore", '.gitignore'

  # .pryrc
  get "#{repo_url}/pryrc", '.pryrc'

  # .rspec
  run 'rm .rspec'
  file '.rspec', <<-CODE
    --color
    -fd
    --require spec_helper
  CODE

  # application.js
  run 'rm app/assets/javascripts/application.js'
  get "#{repo_url}/application.js", 'app/assets/javascripts/application.js'

  # application.sass
  run 'rm app/assets/stylesheets/application.css'
  get "#{repo_url}/application.sass", 'app/assets/stylesheets/application.sass'

  # locales
  get "https://raw.github.com/svenfuchs/rails-i18n/master/rails/locale/ja.yml", 'config/locales/ja.yml'

  # jquery.readyselector
  get 'https://raw.githubusercontent.com/Verba/jquery-readyselector/master/jquery.readyselector.js', 'vendor/assets/javascripts/jquery.readyselector.js'

  # factory_girl
  uncomment_lines 'spec/rails_helper.rb', /Dir\[Rails\.root\.join/
  get "#{repo_url}/factory_girl.rb", 'spec/support/factory_girl.rb'

  # environment
  application do
    %Q{
    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml,yaml}')]
    config.i18n.default_locale = :ja
    config.autoload_paths += Dir["\#\{config.root\}/lib"]
    }
  end

  environment(nil, env: 'development') do
    %Q{
    config.cache_store = :redis_store, 'redis://localhost:6379/9'
    config.action_controller.action_on_unpermitted_parameters = :raise
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
    }
  end

  environment(nil, env: 'production') do
    %Q{
    config.cache_store = :redis_store, 'redis://localhost:6379/0'
    config.logger = Logger.new('log/production.log', 5, 20 * 1024 * 1024)
    }
  end

  run 'bundle exec rake haml:replace_erbs'

  git :init
  git add: '.'
  git commit: "-m 'first commit'"

end

