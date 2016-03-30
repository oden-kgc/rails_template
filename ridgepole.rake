namespace :ridgepole do
  desc "DB Schema 管理"
  task :schema => :environment do
    ENV['RAILS_ENV'] ||= 'development'
    sh "bundle exec ridgepole -E#{ENV['RAILS_ENV']} -f db/Schemafile -c config/database.yml --apply"
  end
end

namespace :db do
  task :migrate => :environment do
    ENV['RAILS_ENV'] ||= 'development'
    sh "bundle exec ridgepole -E#{ENV['RAILS_ENV']} -f db/Schemafile -c config/database.yml --apply"
  end
end

