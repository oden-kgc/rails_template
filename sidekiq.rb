db = 1
if Rails.env.development?
  db = 8
end
Sidekiq.configure_server do |config|
  config.redis = { url: "redis://localhost:6379/#{db}" }
end
Sidekiq.configure_client do |config|
  config.redis = { url: "redis://localhost:6379/#{db}" }
end
