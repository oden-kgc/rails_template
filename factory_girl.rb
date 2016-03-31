RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include Devise::TestHelpers, type: :controller
  config.include Rails.application.routes.url_helpers
  config.include Capybara::SDL
end

