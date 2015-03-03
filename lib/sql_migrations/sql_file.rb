module SqlMigrations
  class SqlFile

    attr_reader :date, :time, :name

    def initialize(path, opts)
      @date     = opts[:date]
      @time     = opts[:time]
      @name     = opts[:name]
      @path     = opts[:path]
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
        file_date, file_time, file_name = self.file_options(db_name, type, path)
        next unless file_name
        scripts << self.new(path, date: file_date,time: file_time, name: file_name)
      end
      scripts.sort_by { |file| (file.date + file.time).to_i }
    end

    private
    def self.file_options(db_name, type, path)

      up_dir, dir, filename = path.split(File::SEPARATOR)[-3, 3]

      # Only files that match agains this regexp
      file_opts = File.basename(path).match(/(\d{8})_(\d{6})_(.*)?\.sql/)
      return nil unless file_opts

      file_in_type_dir   = (dir    == type.to_s)
      file_in_db_dir     = (dir    == db_name.to_s)
      file_in_type_updir = (up_dir == type.to_s)
      file_in_db_updir   = (up_dir == db_name.to_s)

      if db_name.nil? || db_name == :default # There is exception for default database
        return nil unless (file_in_type_dir || (file_in_db_dir && file_in_type_updir))
      else
        # Only files for specific type (migration/fixture/seed)
        # Only files for specific database
        return nil unless (file_in_db_dir && file_in_type_up_dir)
      end

      return file_opts[0], file_opts[1], file_opts[2]
    end

  end
end
