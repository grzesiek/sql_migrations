module SqlMigrations
  # Class for finding sql scripts
  #
  class FindScripts
    class << self
      def find(db_name, type)
        files = []
        Find.find(Dir.pwd) do |path|
          file_parameters = match_file(db_name, type, path)
          next unless file_parameters
          file_parameters.merge!(path: path)
          files << file_parameters
        end
        files
      end

      private

      def match_file(db_dir, type, path)
        # parent_dir/base_dir/filename_that_matches_regexp.sql
        _filename, base_dir, parent_dir  = path.split(File::SEPARATOR).last(3).reverse

        # Only files that match agains regexp will do
        file_parameters = file_match_regexp(File.basename(path))
        return nil unless file_parameters

        # Only files that lay in specific directory structure will do
        file_database = file_match_directories(parent_dir, base_dir, db_dir, type)
        return nil unless file_database

        { date: file_parameters[1], time: file_parameters[2],
          name: file_parameters[3], db_name: file_database }
      end

      def file_match_regexp(file_name)
        file_name.match(/(\d{8})_(\d{6})_(.*)?\.sql/)
      end

      def file_match_directories(parent_dir, base_dir, db_dir, type)
        # example: migrations/migration_file.sql
        file_in_type_base_dir   = (base_dir == type.to_s)
        # example: migrations/some_database/migration_file.sql
        file_in_type_parent_dir = (parent_dir == type.to_s)
        # example migrations/some_database/migration_file.sql
        file_in_db_dir          = (base_dir == db_dir.to_s)

        file_in_valid_db_dir    = (file_in_type_parent_dir && file_in_db_dir)

        # If we are matching script assigned to :default database
        #   scripts can be placed in base_dir or in parent dir indicating type
        #   and in :default base_dir
        if db_dir == :default
          matches =  file_in_type_base_dir || file_in_valid_db_dir
          file_database = :default
        else
          # Otherwise only files for specific type dir (migration/fixture/seed)
          #   and specific database dir apply
          matches = file_in_valid_db_dir
          file_database = base_dir.to_sym
        end

        matches ? file_database : nil
      end
    end
  end
end
