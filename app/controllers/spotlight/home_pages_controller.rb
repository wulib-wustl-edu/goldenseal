module Spotlight
  ##
  # CRUD actions for the exhibit home page
  class HomePagesController < Spotlight::PagesController
    include Blacklight::SearchHelper
    include Spotlight::Catalog

    load_and_authorize_resource through: :exhibit, singleton: true, instance_name: 'page'

    before_action :attach_breadcrumbs, except: :show

    def edit
      add_breadcrumb t(:'spotlight.curation.sidebar.feature_pages'), exhibit_feature_pages_path(@exhibit)
      add_breadcrumb @page.title, [:edit, @exhibit, @page]
      super
    end

    def index
      redirect_to exhibit_feature_pages_path(@exhibit)
    end

    def show
      @response, @document_list = search_results({}, search_params_logic) if @page.display_sidebar?

      if @page.nil? || !@page.published?
        render '/catalog/index'
      else
        render 'show'
      end
    end

    private

    # Calling off spotlight search urls
    #alias search_action_url exhibit_search_action_url
    #alias search_facet_url exhibit_search_facet_url
    def search_action_url options={}
      if options['exhibit_id'] && @exhibit
        options = options.except('exhibit_id')

        exhibitable_klass = @exhibit.exhibitable_type.try(:constantize)
        exhibitable = exhibitable_klass.find(@exhibit.exhibitable_id) if exhibitable_klass 
        if exhibitable
          options["f"].merge!({exhibitable.default_filter_field => [exhibitable.title]})
        end
      end
      main_app.catalog_index_url(options.except('format'))
    end

    def allowed_page_params
      super.concat [:display_title, :display_sidebar]
    end
  end
end
