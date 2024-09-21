# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# rubocop:disable Style/ClassAndModuleChildren
module ATS
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults(7.1)

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    config.active_record.schema_format = :sql

    config.after_initialize do
      Rails.error.subscribe(ErrorSubscriber.new)
    end

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.view_component.default_preview_layout = "component_preview"
    config.eager_load_paths << Rails.root.join("test/components/previews")

    config.to_prepare do
      ActiveStorage::Attached::Changes::CreateOne.prepend(ActiveStorageCreateOne)
      ActiveSupport.on_load(:active_storage_attachment) { include ActiveStorageAttachment }
    end

    config.before_configuration do
      if ENV["SECRET_KEY_BASE_DUMMY"].present?
        module DummyCredentials
          def credentials = RecursiveDummy.new
        end

        class RecursiveDummy
          def method_missing(*) = self
          def respond_to_missing?(*) = true
          def to_ary = [""]
          def to_s = ""
          def to_str = ""
          def inspect = ""
        end

        Rails.application.singleton_class.prepend(DummyCredentials)
      end
    end
  end
end
# rubocop:enable Style/ClassAndModuleChildren
