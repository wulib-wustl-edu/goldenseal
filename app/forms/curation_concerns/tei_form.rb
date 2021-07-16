module CurationConcerns
  class TeiForm < CommonForm
    self.terms += [:tei_id, :representative_path, :tei_path, :thumbnail_path]
  end
end
