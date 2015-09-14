module DisplayFields
  extend ActiveSupport::Concern

  # Common fields for presenters to display

  def identifier
    solr_document['identifier_tesim']
  end

  def series
    solr_document['series_ssim']
  end

  def date_issued
    solr_document['date_issued_dtsi']
  end

  def note
    solr_document['note_tesim']
  end

  def extent
    solr_document['extent_ssim']
  end

  def description_standard
    solr_document['description_standard_ssim']
  end

  def publication_place
    solr_document['publication_place_tesim']
  end

  def editor
    solr_document['editor_tesim']
  end

  def sponsor
    solr_document['sponsor_tesim']
  end

  def funder
    solr_document['funder_tesim']
  end

  def researcher
    solr_document['researcher_tesim']
  end
end