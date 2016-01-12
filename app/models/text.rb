class Text < ActiveFedora::Base
  include CurationConcerns::WorkBehavior
  include CurationConcerns::BasicMetadata
  include Metadata
  include InAdminSet
  include OnCampusAccess

  validates :title, presence: { message: 'Your work must have a title.' }

  include WithTEI

  # Given a filename that appears in the TEI, return the id for the
  # corresponding FileSet that has the page image
  def id_for_filename(filename)
    filenames_to_filesets[filename]
  end

  def self.indexer
    TextIndexer
  end

  private
    def filenames_to_filesets
      @filenames_to_filesets ||= begin
        query = "{!join from=member_ids_ssim to=id}id:#{id}"
        results = ActiveFedora::SolrService.query(query, fl: 'id,label_ssi', rows: 5000)
        results.each_with_object({}) do |row, h|
          h[row.fetch('label_ssi')] = row.fetch('id')
        end
      end
    end
end
