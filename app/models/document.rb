class Document < ActiveFedora::Base
  include ::CurationConcerns::WorkBehavior
  include ::CurationConcerns::BasicMetadata
  include Metadata
  include InAdminSet
  include OnCampusAccess
  include DrawTemplate

  validates :title, presence: { message: 'Your work must have a title.' }

  def self.indexer
    BaseWorkIndexer
  end
end
