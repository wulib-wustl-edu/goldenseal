module Import

  # The results of running the importer.  Keep track of
  # errors, warnings, successful imports, or skipped imports.
  ImportResults = Struct.new(:errors, :warnings, :successful_imports, :skipped_imports)

  # A base class for other importers
  class CommonImporter
    delegate :errors, :warnings, to: :status
    delegate :successful_imports, :skipped_imports, to: :status

    # The path to the directory where the files that we want to import are located
    attr_reader :root_dir

    # The access rights visibility that will be applied to the imported records
    attr_reader :visibility

    # The AdminSet that imported records will be assigned to
    attr_reader :admin_set_id

    def initialize(dir, options={})
      @root_dir = dir
      @visibility = options[:visibility] || Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
      @admin_set_id = options[:admin_set_id]
      $stdout.sync = true  # flush output immediately
    end

    def status
      @status ||= ImportResults.new([], [], [], [])
    end

    # Parse all the metadata files that are found in the
    # root_dir, and create a new record for each one.
    def run
      admin_set
      return unless errors.empty?
      metadata_files.each { |file| parse_metadata(file) }
    end

    def admin_set
      return unless admin_set_id
      @admin_set ||= AdminSet.find(admin_set_id)
    rescue ActiveFedora::ObjectNotFoundError => e
      errors << "Unable to find AdminSet: #{admin_set_id}.  Please run 'rake admin_set:list' to see the list of valid IDs."
      nil
    end

    def metadata_files
      fail "Directory not found: #{root_dir}" unless File.exist?(root_dir)
      @metadata_files ||= Dir.glob(File.join(root_dir, '*.xml'))
    end

    # Parse one metadata file
    def parse_metadata(file)
      file_name = File.basename(file)
      puts "\n#{Time.now.strftime('%T')} Parsing #{file_name}" unless Rails.env.test?
      attrs = parser.new(file).attributes

      if attrs.blank?
        errors << "Failed to parse file: #{file_name}"
      elsif record_exists?(attrs)
        # Don't re-import the record if this record already
        # exists in fedora.
        skipped_imports << file_name
      else
        create_record(attrs.merge(metadata_file: file, visibility: visibility, admin_set: admin_set))
        successful_imports << file_name
      end
    rescue => e
      errors << "#{file_name}: #{e}"
    end

    def record_exists?(attrs)
      ident = attrs[:identifier]
      return false if ident.blank?

      existing_records = ActiveFedora::Base.where("identifier_tesim" => ident)
      fail "Too many matches found for record: #{ident}" if existing_records.count > 1

      existing_records.count == 1
    end

    def create_record(attributes)
      metadata_file = attributes.delete(:metadata_file)
      files = attributes.delete(:files) || []
      files = files.uniq

      attributes[:rights] = transform_rights(attributes) unless attributes[:rights].blank?

      record = record_class.create!(attributes) do |r|
        r.apply_depositor_metadata(user)
      end

      file_sets = [create_file(record, metadata_file, 'text/xml')] # Attach metadata file
      file_sets += attach_files(record, File.basename(metadata_file), files)
      puts "    Ordering attached files" unless Rails.env.test?
      time = Benchmark.measure {
        record.ordered_members.concat(file_sets.compact)
      }
      puts "    Adding in order took %0.2fs" % time.real  unless Rails.env.test?
      set_representative(record)
      record.save!
    end

    def attach_files(record, metadata_file, files)
      files.map do |file_name|
        matching_file = find_file(file_name, metadata_file)
        next unless matching_file
        create_file(record, matching_file)
      end
    end

    def create_file(record, matching_file, mime_type = nil)
      puts "    #{Time.now.strftime('%T')} attaching file: #{File.basename(matching_file)}" unless Rails.env.test?
      file = FileWithName.new(matching_file)
      fs = FileSet.new(mime_type: mime_type)

      actor = CurationConcerns::ImportFileActor.new(fs, user)
      actor.create_metadata(nil, record)
      fail 'Content creation failed' unless actor.create_content(file)

      fs.errors.each { |k, v| errors << "FileSet #{k}: #{v}" }
      fail 'FileSet had errors' unless fs.errors.blank?
      fs
    end

    def find_file(file_name, metadata_file)
      match = Dir.glob("#{root_dir}/**/#{file_name}")

      if match.empty?
        warnings << "#{metadata_file}: File not found: #{file_name}"
        nil
      elsif match.count != 1
        errors << "Unable to attach file.  More than one file was found with the same name: #{match.inspect}"
        nil
      else
        match.first
      end
    end

    def set_representative(record)
      first_page = record.file_sets[1]
      return unless first_page && first_page.id
      record.representative = first_page
      record.thumbnail = first_page
    end

    def transform_rights(attrs)
      rights = attrs[:rights].map do |rights_text|
        Import::Rights.url_for(rights_text)
      end
    end

    # A "system" user to act as the depositor of the record
    def user
      @user ||= User.find_by_user_key('system')
      return @user if @user
      @user = User.create!(Devise.authentication_keys.first => 'system')
    end

  end
end
