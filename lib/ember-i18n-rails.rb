require "FileUtils" unless defined?(FileUtils)

module Ember
  module I18n
    extend self

    require "ember/i18n/railtie" if Rails.version >= "3.0"
    require "ember/i18n/engine" if Rails.version >= "3.1"

    # Under rails 3.1.1 and higher, perform a check to ensure that the
    # full environment will be available during asset compilation.
    # This is required to ensure I18n is loaded.
    def assert_usable_configuration!
      @usable_configuration ||= Rails.version >= "3.1.1" &&
        Rails.configuration.assets.initialize_on_precompile ||
        raise("Cannot precompile ember-i18n translations unless environment is initialized. Please set config.assets.initialize_on_precompile to true.")
    end

    def has_asset_pipeline?
      Rails.configuration.respond_to?(:assets) && Rails.configuration.assets.enabled
    end

    def config_file
      Rails.root.join("config/ember-i18n.yml")
    end

    def export_dir
      if has_asset_pipeline?
        "app/assets/javascripts/i18n"
      else
        "public/javascripts"
      end
    end

    def javascript_file
      Rails.root.join(export_dir, "ember-i18n.js")
    end

    # Export translations to JavaScript, considering settings
    # from configuration file
    def export!
      if config[:split]
        translations.keys.each do |locale|
          translations_hash = translations[locale]
          translations_hash.each do |key, value|
            english_fallback = translations["en"][key]
            puts "Translation #{key} is missing for #{locale}! Taking english default '#{english_fallback}'"
            translations_hash[key] = english_fallback if value == nil && value == ""
          end
          save(flat_hash(translations[locale]), File.join(export_dir, "translations_#{locale}.js"))
        end
      else
        save(flat_hash(translations), File.join(export_dir, "translations.js"))
      end
    end

    def flat_hash(data, prefix = '', result = {})
      data.each do |key, value|
        current_prefix = prefix.present? ? "#{prefix}.#{key}" : key

        if !value.is_a?(Hash)
          result[current_prefix] = value.respond_to?(:stringify_keys) ? value.stringify_keys : value
        else
          flat_hash(value, current_prefix, result)
        end
      end

      result.stringify_keys
    end

    # Load configuration file for partial exporting and
    # custom output directory
    def config
      if config?
        (YAML.load_file(config_file) || {}).with_indifferent_access
      else
        {}
      end
    end

    # Check if configuration file exist
    def config?
      File.file? config_file
    end

    # Copy configuration and JavaScript library files to
    # <tt>config/ember-i18n.yml</tt> and <tt>public/javascripts/i18n.js</tt>.
    def setup!
      FileUtils.mkdir_p(export_dir)
      FileUtils.cp(File.dirname(__FILE__) + "/../vendor/assets/javascripts/ember-i18n.js", javascript_file)
      FileUtils.cp(File.dirname(__FILE__) + "/../config/ember-i18n.yml", config_file) unless config?
    end

    # Retrieve an updated JavaScript library from Github.
    def update!
      FileUtils.mkdir_p(export_dir)
      require "open-uri"
      contents = open("https://raw.github.com/jamesarosen/ember-i18n/master/lib/i18n.js").read
      File.open(javascript_file, "w+") {|f| f << contents}
    end

    # Convert translations to JSON string and save file.
    def save(translations, file)
      file = Rails.root.join(file)
      FileUtils.mkdir_p File.dirname(file)

      File.open(file, "w+") do |f|
        f << 'Em.I18n.translations = '
        f << JSON.pretty_generate(translations).html_safe
        f << ';'
      end
    end

    # Initialize and return translations
    def translations
      ::I18n.load_path = default_locales_path
      ::I18n.backend.instance_eval do
        init_translations unless initialized?
        translations
      end
    end

    def default_locales_path
      Dir[Rails.root.join('config', 'locales', '*.yml').to_s]
    end
  end
end

