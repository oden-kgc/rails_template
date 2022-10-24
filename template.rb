# repository
repo_url = 'https://raw.githubusercontent.com/oden-kgc/rails_template/master'

# アプリ名
@app_name = app_name

#
# Gemfile
#

#gem 'action_args'

# simple_form
gem 'simple_form'

# devise & pundit
has_devise = false
model_name = 'user'
if yes?('Use devise ?')
  has_devise = true
  model_name = ask('Devise user model name ? [user]')
  model_name = "user" if model_name.blank?
  gem 'devise'
  gem 'devise-i18n'
  gem 'devise-bootstrap5'
  gem 'pundit'
end

# job queue
has_resque = false
has_sidekiq = false
if yes?('User Resque ?')
  has_resque = true
  gem 'resque'
  gem 'daemon-spawn', :require => 'daemon_spawn'
else
  if yes?('Use Sidekiq ?')
    has_sidekiq = true
    gem 'sidekiq'
  end
end

gem 'haml-rails', '< 2.1'
gem 'ridgepole'
gem 'seed-fu'
gem 'config'
gem 'draper'

gem 'redis-mutex'
gem 'whenever'
gem 'sassc-rails'

bundle_command('install --path=vendor/bundle')

GEN = 'bundle exec rails g '
after_bundle do
  # generate
  run "#{GEN} config:install"
  run "#{GEN} simple_form:install --bootstrap"

  if has_devise then
    run "#{GEN} devise:install"
    run "#{GEN} devise #{model_name}"
    run "#{GEN} devise:i18n:locale ja"
    run "#{GEN} devise:views:bootstrap"
    run "#{GEN} pundit:install"
  end

  # ridgepole
  get "#{repo_url}/ridgepole.rake", 'lib/tasks/ridgepole.rake'
  run 'touch db/Schemafile'

  # seed_fu
  run 'mkdir -p db/fixtures/development'
  run 'mkdir -p db/fixtures/production'

  if has_resque
    # resque
    get "#{repo_url}/resque.rb", 'config/initializers/resque.rb'
    gsub_file 'config/initializers/resque.rb', /APP_NAME/, @app_name

    # daemon_spawn
    get "#{repo_url}/resque.rake", 'lib/tasks/resque.rake'
    get "#{repo_url}/resque_worker", 'bin/resque_worker'
    gsub_file 'bin/resque_worker', /APP_NAME/, @app_name
    run "chmod +x bin/resque_worker"
    run 'mkdir -p tmp/pids'
  end

  if has_sidekiq
    get "#{repo_url}/sidekiq.rb", 'config/initializers/sidekiq.rb'
    get "#{repo_url}/sidekiq.yml", 'config/sidekiq.yml'
    get "#{repo_url}/sidekiq.service", 'lib/templates/systemd/sidekiq.service'
  end

  # remove
  run 'rm README.md'

  # .gitignore
  run 'rm .gitignore'
  get "#{repo_url}/gitignore", '.gitignore'

  # locales
  get "https://raw.github.com/svenfuchs/rails-i18n/master/rails/locale/ja.yml", 'config/locales/ja.yml'

  # environment
  application do
    base = %Q{
    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :ja
    config.active_model.i18n_customize_full_message = true
    config.log_formatter = ::Logger::Formatter.new
    }
    if has_resque
      %Q{
      #{base}
      config.active_job.queue_adapter = :resque
      }
    end
    if has_sidekiq
      %Q{
      #{base}
      config.active_job.queue_adapter = :sidekiq
      }
    end
  end

  environment(nil, env: 'development') do
    %Q{
    config.cache_store = :redis_cache_store, {
      url: 'redis://localhost:6379/9'
    }

    config.logger = ActiveSupport::Logger.new('log/development.log', 5, 10 * 1024 * 1024)
    config.logger.formatter = config.log_formatter
    }
  end

  environment(nil, env: 'production') do
    %Q{
    config.cache_store = :redis_cache_store, {
      url: 'redis://localhost:6379/0'
    }
    config.logger = ActiveSupport::Logger.new('log/production.log', 10, 20 * 1024 * 1024)
    config.logger.formatter = config.log_formatter
    }
  end

  # erb -> haml
  run 'bundle exec rails haml:erb2haml'

  run "#{GEN} draper:install"

  run 'bundle exec rails javascript:install:esbuild'
  run 'bundle exec rails css:install:bootstrap'
  run 'bundle exec rails turbo:install:node'
  run 'bundle exec rails stimulus:install:node'

end

