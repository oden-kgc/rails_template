Resque.redis = Redis.new(host: 'localhost', port: 6379)
Resque.redis.namespace = "rescue:APP_NAME:#{Rails.env}"
Resque.after_fork = Proc.new { ActiveRecord::Base.establish_connection }
