module SqlMigrations
  # SqlScript class
  #
  class SqlScript < ScriptFile
    def initialize(path, database_name, type)
      super
      @datetime = (@date.to_s + @time.to_s).to_i
    end

    def execute(db)
      @database = db
      return false unless new?
      driver = @database.driver
      begin
        driver.transaction do
          @benchmark = Benchmark.measure do
            statements.each { |query| driver.run(query) }
          end
        end
      rescue
        puts "[-] Error while executing #{@type} #{@name} !"
        raise
      else
        true & on_success
      end
    end

    def statements
      separator = Config.options[:separator]
      if separator
        statements = content.split(separator)
        statements.collect!(&:strip)
        statements.reject(&:empty?)
      else
        [content]
      end
    end

    def self.find(database_name, type)
      scripts = []
      Find.find(Dir.pwd) do |path|
        candidate = new(path, database_name, type)
        scripts << candidate if candidate.valid?
      end
      scripts.sort_by { |file| (file.date + file.time).to_i }
    end

    private

    def new?
      schema = @database.schema_dataset
      last = schema.order(Sequel.asc(:time)).where(type: @type).last
      is_new = schema.where(time: @datetime, type: @type).count == 0
      if is_new && !last.nil?
        if last[:time] > @datetime
          raise "#{@type.capitalize} #{@name} has time BEFORE last one recorded !"
        end
      end
      is_new
    end

    def on_success
      puts "[+] Successfully executed #{@type}, name: #{@name}"
      puts "    #{@type.capitalize} file: #{@date}_#{@time}_#{@name}.sql"
      puts "    Benchmark: #{@benchmark}"
      schema = @database.schema_dataset
      schema.insert(time: @datetime, name: @name, type: @type, executed: DateTime.now)
    end
  end
end
