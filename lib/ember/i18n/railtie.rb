module Ember
  module I18n
    class Railtie < ::Rails::Railtie
      rake_tasks do
        require "ember/i18n/rake"
      end

      initializer "ember-i18n-rails.initialize" do |app|
        app.config.middleware.use(Middleware) if ::Rails.env.development? && !Ember::I18n.has_asset_pipeline?
      end
    end
  end
end
