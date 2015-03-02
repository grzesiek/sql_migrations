module SqlMigrations
  class Migration

    def self.find
      migrations = []
      Find.find(Dir.pwd) do |path|
        if file_opts = File.basename(path).match(/(\d{8})_(\d{6})_(.*)?\.sql/)
          # Only files within migrations directory are valid migrations
          if File.basename(File.dirname(path)) == 'migrations'
            migrations << self.new(path, date: file_opts[1],
                                         time: file_opts[2],
                                         name: file_opts[3])
          end
        end
      end
      migrations
    end

    def initialize(path, opts)
      @date = opts[:date]
      @time = opts[:time]
      @name = opts[:name]
      @path = opts[:path]
      @content = IO.read(path)
    end

    def to_s
      "Migration #{@name}, datetime: #{@date + @time}"
    end

    def execute(db)
      puts "[+] Running migration #{@name}, added #{@date}"
    end
  end
end
