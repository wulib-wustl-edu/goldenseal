module CurationConcerns
  module CommonActorBehavior
    extend ActiveSupport::Concern

    def create
      transform_dates
      remove_paths
      super
    end

    def update
      transform_dates
      remove_paths
      super
    end

    # Format the date
    def transform_dates
      attributes['date_issued'] = DateService.parse(attributes['date_issued'])
    end

    def remove_paths
      attributes.try(:except!, :representative_path, :tei_path, :thumbnail_path)
    end
  end
end
