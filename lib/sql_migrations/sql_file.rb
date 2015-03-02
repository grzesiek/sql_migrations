module SqlMigrations
  class SqlFile

    attr_reader :date, :time, :name

    def initialize(path, opts)
      @date = opts[:date]
      @time = opts[:time]
      @name = opts[:name]
      @path = opts[:path]
      @content = IO.read(path)
    end

    def to_s
      raise NotImplementedError
    end

    def execute(db)
      begin
        db.transaction do
          db.run @content
        end
      rescue
        # TODO
      end
    end

    def self.find(type)
      files = []
      Find.find(Dir.pwd) do |path|
        if file_opts = File.basename(path).match(/(\d{8})_(\d{6})_(.*)?\.sql/)
          # Only files within specific directory are valid sql_files
          if File.basename(File.dirname(path)) == type.to_s
            files << self.new(path, date: file_opts[1],
                                    time: file_opts[2],
                                    name: file_opts[3])
          end
        end
      end
      files.sort_by { |file| (file.date + file.time).to_i }
    end

  end
end
