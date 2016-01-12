module CurationConcerns
  class CommonForm < CurationConcerns::Forms::WorkForm
    self.terms += [:admin_set_id, :editor, :sponsor, :funder, :researcher, :identifier, :series, :extent, :note, :description_standard, :publication_place, :date_issued]
  end
end

