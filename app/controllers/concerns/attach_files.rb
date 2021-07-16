# This module needs to be included after CurationConcerns::CurationConcernController
module AttachFiles

  # Add the thumbnail, representative, and tei to the files list so they will be properly attached to the work.
  def add_attachments_to_files
    representative_files = []
    representative_files << params[hash_key_for_curation_concern]['representative'] if params[hash_key_for_curation_concern]['representative'].present?
    file_path = params[hash_key_for_curation_concern]['representative_path']
    representative_files << file_for_path(File.join(ENV['FILE_UPLOAD_DIR'], file_path)) if file_path.present?

    tei_files = []
    tei_files << params[hash_key_for_curation_concern]['tei'] if params[hash_key_for_curation_concern]['tei'].present?
    file_path = params[hash_key_for_curation_concern]['tei_path']
    tei_files << file_for_path(File.join(ENV['FILE_UPLOAD_DIR'], file_path)) if file_path.present?

    thumbnail_files = []
    file_path = params[hash_key_for_curation_concern]['thumbnail_path']
    thumbnail_files << file_for_path(File.join(ENV['FILE_UPLOAD_DIR'], file_path)) if file_path.present?

    files = representative_files + tei_files + thumbnail_files
    params[hash_key_for_curation_concern]['files'] ||= []
    params[hash_key_for_curation_concern]['files'] += files
  end

  # Override method from CurationConcerns::CurationConcernController
  def after_create_response
    assign_representative
    assign_tei
#    assign_thumbnail

    unless curation_concern.save
      flash['alert'] = 'There were problems assigning the representative, thumbnail, or transcript.  You may want to edit this work and select the correct files.'
    end

    super
  end

  def assign_representative
    return unless params[hash_key_for_curation_concern]['representative']
    curation_concern.representative = find_matching_file_set('representative')
  end

  def assign_tei
    return unless params[hash_key_for_curation_concern]['tei']
    curation_concern.tei = find_matching_file_set('tei')
  end

#  def assign_thumbnail
#    return unless params[hash_key_for_curation_concern]['thumbnail']
#    curation_concern.thumbnail = find_matching_file_set('thumbnail')
#  end

  def find_matching_file_set(hash_key_for_file)
    filename = Array(params[hash_key_for_curation_concern][hash_key_for_file]).first.original_filename
    curation_concern.file_sets.select {|fs| fs.label == filename }.first
  end

  def file_for_path(file)
    name = File.basename(file)
    tempfile = File.open(file, 'r')
    ActionDispatch::Http::UploadedFile.new(:tempfile => tempfile, :filename => name, :original_filename => name)
  end

end
