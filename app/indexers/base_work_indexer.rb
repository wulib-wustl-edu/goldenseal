class BaseWorkIndexer < CurationConcerns::WorkIndexingService
  def generate_solr_document
    super do |solr_doc|
      solr_doc['rights_label_ss'] = rights_labels.first
      solr_doc['admin_set_ssi'] = object.admin_set.try(:title)
      yield(solr_doc) if block_given?
    end
  end

  private

    def rights_labels
      object.rights.map { |r| RightsService.label(r) }
    end
end
