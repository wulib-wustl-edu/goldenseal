module WithTEI
  extend ActiveSupport::Concern

  included do
    belongs_to :tei, predicate: ::RDF::URI('http://data.press.net/ontology/asset/hasTranscript'), class_name: 'FileSet'

    before_save :assign_default_tei
  end

  # Use the first file if tei isn't set and the first file is an xml
  def assign_default_tei
    return if tei_id || !head
    first_file = head.target
    self.tei_id = first_file.id if ['application/xml', 'text/xml'].include?(first_file.mime_type)
  end
end
