module Ember
  module I18n
    class Railtie < ::Rails::Railtie
      rake_tasks do
        require "ember/i18n/rake"
      end
    end
  end
end
