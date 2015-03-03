module SqlMigrations
  class SqlScript

    attr_reader :date, :time, :name

    def initialize(path, opts)
      @date     = opts[:date]
      @time     = opts[:time]
      @name     = opts[:name]
      @path     = opts[:path]
      @db_name  = opts[:db_name]
      @content  = IO.read(path)
    end

    def execute(db)
      @database = db
      return unless is_new?
      begin
        db.transaction do
          time = Benchmark.measure do
            db.run @content
          end
        end
      rescue
        puts "[-] Error while executing #{@name} !"
        raise
      else
        puts time
        on_success
      end
    end

    def self.find(db_name, type)
      scripts = []
      Find.find(Dir.pwd) do |path|
        if !db_name.is_a? Array then db_name = [ db_name ] end
        file_date, file_time, file_name, file_db = self.file_options(db_name, type, path)
        next unless file_name
        scripts << self.new(path, date: file_date,time: file_time, name: file_name, db_name: file_db)
      end
      scripts.sort_by { |file| (file.date + file.time).to_i }
    end

    private
    def self.file_options(db_names, type, path)

      up_dir, dir, filename = path.split(File::SEPARATOR)[-3, 3]

      # Only files that match agains this regexp
      file_opts = File.basename(path).match(/(\d{8})_(\d{6})_(.*)?\.sql/)
      return nil unless file_opts

      file_in_type_dir   = (dir    == type.to_s)
      file_in_type_updir = (up_dir == type.to_s)
      file_in_db_dir     = db_names.include?(dir.to_sym)
                          
      # There is exception when we are looking for files for more than one database
      # or we are checking default database only
      if db_names == [ :default ] || db_names.count > 1
        return nil unless (file_in_type_dir || (file_in_db_dir && file_in_type_updir))
      else
        # Only files for specific type (migration/fixture/seed)
        # Only files for specific database
        return nil unless (file_in_db_dir && file_in_type_updir)
      end

      file_database = db_names.include?(dir.to_sym) ? dir : :default
      return file_opts[0], file_opts[1], file_opts[2], file_database
    end

  end
end
