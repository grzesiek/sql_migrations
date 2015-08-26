require 'forwardable'

module SqlMigrations
  # SqlScript class
  #
  class Script
    extend Forwardable
    delegate [:name, :date, :time, :datetime,
              :type, :content, :path] => :@file

    def initialize(file)
      @file = file
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
        file = File.new(path, database_name, type)
        scripts << new(file) if file.valid?
      end

      raise_exception_if_duplicates_present(scripts, type)
      scripts.sort_by(&:datetime)
    end

    private

    def self.raise_exception_if_duplicates_present(scripts, type)
      duplicates = find_duplicates(scripts)
      files = scripts.map do |script|
        script.path if duplicates.include?(script.date + script.time)
      end

      raise "Duplicate timestamps for #{type}s: #{files.compact.join(', ')}" unless
            duplicates.empty?
    end

    def self.find_duplicates(scripts)
      scripts.map { |s| s.date + s.time }.group_by { |e| e }
        .select { |_k, v| v.size > 1 }.keys
    end

    def new?
      schema = @database.schema_dataset
      last = schema.order(Sequel.asc(:time)).where(type: @file.type).last
      is_new = schema.where(time: @file.datetime, type: @file.type).count == 0
      if is_new && !last.nil?
        if last[:time] > @file.datetime
          raise "#{@file.type.capitalize} #{@file.name} has time BEFORE last one recorded !"
        end
      end
      is_new
    end

    def on_success
      puts "[+] Successfully executed #{@file.type}, name: #{@file.name}"
      puts "    #{@file.type.capitalize} file: #{@file.date}_#{@file.time}_#{@file.name}.sql"
      puts "    Benchmark: #{@benchmark}"
      schema = @database.schema_dataset
      schema.insert(time: @file.datetime, name: @file.name,
                    type: @file.type, executed: DateTime.now)
    end
  end
end
