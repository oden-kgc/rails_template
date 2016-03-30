Resque.redis = 'localhost:6379'
Resque.redis.namespace = "rescue:real_mon:#{Rails.env}"
Resque.after_fork = Proc.new { ActiveRecord::Base.establish_connection }

