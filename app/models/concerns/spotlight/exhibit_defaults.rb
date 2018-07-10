module Spotlight
  # Mixin for adding default configuration to exhibits
  module ExhibitDefaults
    extend ActiveSupport::Concern

    included do
      before_create :build_home_page
      before_create :add_site_reference
      after_create :initialize_config
      after_create :initialize_browse
      after_create :initialize_main_navigation
      after_create :initialize_filter
    end

    protected

    def initialize_filter
      return unless Spotlight::Engine.config.filter_resources_by_exhibit

      filters.create field: default_filter_field, value: default_filter_value
    end

    def initialize_config
      self.blacklight_configuration ||= Spotlight::BlacklightConfiguration.create!
    end

    def initialize_browse
      return unless searches.blank?

      searches.create title: 'All Exhibit Items',
                      long_description: 'All items in this exhibit.'
    end

    def initialize_main_navigation
      default_main_navigations.each_with_index do |nav_type, weight|
        main_navigations.create nav_type: nav_type, weight: weight
      end
    end

    def add_site_reference
      self.site ||= Spotlight::Site.instance
    end

    def default_filter_field
      raise "'default_filter_field' should be implemented in class including this module"
    end

    # Return a string to work around any ActiveRecord type-casting
    def default_filter_value
      self.exhibitable.title
    end

    private

    def default_main_navigations
      Spotlight::Engine.config.exhibit_main_navigation.dup
    end
  end
end