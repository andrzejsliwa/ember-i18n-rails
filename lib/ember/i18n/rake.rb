namespace :ember do
  namespace :i18n do
    desc "install ember-i18n.js"
    task :setup => :environment do
      Ember::I18n.setup!
    end

    desc "Export the messages files"
    task :export => :environment do
      Ember::I18n.export!
    end

    desc "install ember-i18n.js"
    task :update => :environment do
      Ember::I18n.update!
    end
  end
end

