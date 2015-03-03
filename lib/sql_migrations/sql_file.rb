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

    def self.find(type)
      sql_files = []
      Find.find(Dir.pwd) do |path|
        if file_opts = File.basename(path).match(/(\d{8})_(\d{6})_(.*)?\.sql/)
          if File.basename(File.dirname(path)) == type.to_s
            sql_files << self.new(path, date: file_opts[1],
                                        time: file_opts[2],
                                        name: file_opts[3])
          end
        end
      end
      sql_files.sort_by { |file| (file.date + file.time).to_i }
    end

  end
end
