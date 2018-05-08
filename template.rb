# repository
repo_url = 'https://raw.githubusercontent.com/oden-kgc/rails_template/master'

# アプリ名
@app_name = app_name

#
# Gemfile
#

gem 'action_args'

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
  gem 'pundit'
end

# feature phone
if yes?('Use feature phone ?')
  gem 'jpmobile'
end

# db schema
#gem 'ridgepole', git: 'https://github.com/winebarrel/ridgepole', branch: '0.7'
gem 'ridgepole'

# db seed
gem 'seed-fu'

# config
gem 'config'

# for Redis
gem 'redis'
gem 'redis-rails'
gem 'redis-mutex'
gem 'redis-namespace'

# rescue
gem 'resque'
gem 'resque-scheduler'

# whenever
gem 'whenever'

# daemon-spawn (for activejob)
gem 'daemon-spawn', :require => 'daemon_spawn'

# haml
gem 'haml-rails'

# foreman
gem 'foreman'

# opal
use_opal = false
if yes?('Use Opal ?')
  use_opal = true
  gem 'opal-rails'
end

uncomment_lines 'Gemfile', 'bcrypt' if has_devise

gem_group :development, :test do
  gem 'pry'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'pry-doc'
  gem 'pry-stack_explorer'
  gem 'better_errors'
  gem 'binding_of_caller'

  gem 'hirb'

  gem 'tapp'
  gem 'timecop'
  gem 'colorize_unpermitted_parameters'
  gem 'rack-mini-profiler'

  gem 'rspec'
  gem 'rspec-rails'
  gem 'spring-commands-rspec'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'faker-japanese'

  gem 'simplecov'
  gem 'rack-dev-mark'

  gem 'bullet'

  gem 'erb2haml'
end

gem_group :production do
  gem 'pg'
end

bundle_command('install --path=vendor/bundle')

GEN = 'bundle exec rails g '
after_bundle do
  # rspec
  run "#{GEN} rspec:install"

  # generate
  run "#{GEN} config:install"
  run "#{GEN} simple_form:install --bootstrap"

  if has_devise then
    run "#{GEN} devise:install"
    run "#{GEN} devise #{model_name}"
    run "#{GEN} devise:views:locale ja"
    run "#{GEN} devise:views:bootstrap_templates"
    run "#{GEN} pundit:install"
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
  run 'rm README.md'
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
  if use_opal
    run 'rm app/assets/javascripts/application.js'
    get "#{repo_url}/application.js.rb", 'app/assets/javascripts/application.js.rb'
  end

  # application.sass
  run 'rm app/assets/stylesheets/application.css'
  get "#{repo_url}/application.sass", 'app/assets/stylesheets/application.sass'

  # locales
  get "https://raw.github.com/svenfuchs/rails-i18n/master/rails/locale/ja.yml", 'config/locales/ja.yml'

  # factory_bot
  uncomment_lines 'spec/rails_helper.rb', /Dir\[Rails\.root\.join/
  get "#{repo_url}/factory_bot.rb", 'spec/support/factory_bot.rb'

  # environment
  application do
    %Q{
    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml,yaml}')]
    config.i18n.default_locale = :ja
    config.autoload_paths += Dir["\#\{config.root\}/lib"]
    config.generators do |g|
      g.orm :active_record
      g.template_engine :haml
      g.test_framework :rspec, fixture: true
      g.fixture_replacement :factory_bot, dir: "spec/factories"
      g.view_specs false
      g.controller_specs true
      g.routing_specs false
      g.helper_specs false
      g.requiest_specs false
      #g.assets false
      #g.helper false
    end
    }
  end

  environment(nil, env: 'development') do
    %Q{
    config.rack_dev_mark.enable = true
    config.cache_store = :redis_store, 'redis://localhost:6379/9'
    config.action_controller.action_on_unpermitted_parameters = :raise
    config.after_initialize do
      Bullet.enable = true
      Bullet.alert = true
      Bullet.console = true
      Bullet.rails_logger = true
    end
    config.logger = ActiveSupport::Logger.new('log/development.log', 5, 10 * 1024 * 1024)
    config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address: '', 
      domain: '', 
      enable_startttls_auto: false
    }
    config.web_console.whitelisted_ips = '0.0.0.0/0'

    config.webpacker.check_yarn_integrity = false
    }
  end

  environment(nil, env: 'production') do
    %Q{
    config.cache_store = :redis_store, 'redis://localhost:6379/0'
    config.logger = ActiveSupport::Logger.new('log/production.log', 10, 20 * 1024 * 1024)
    }
  end

  # erb -> haml
  run 'bundle exec rails haml:replace_erbs'

  # Procfile
  run "echo 'web: bin/rails s -b 0.0.0.0' > Procfile"
  run "echo 'webpacker: bin/webpack-dev-server' >> Procfile"

  # webpacker install
  run 'bundle exec rails webpacker:install'
  gsub_file 'config/webpacker.yml', /localhost/, '0.0.0.0'

  git add: '.'
  git reset: "HEAD db/migrate/*"
  git commit: "-m 'first commit'"

end

