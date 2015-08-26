require 'sequel'
require 'find'
require 'benchmark'
require 'time'

module SqlMigrations
  # SqlScript class
  #
  class Script
    DELEGATED = [:name, :date, :time, :datetime, :type, :content, :path]
    attr_reader(*DELEGATED)

    def initialize(file)
      @file = file

      DELEGATED.each do |method|
        instance_variable_set("@#{method}", file.send(method))
      end
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

    def self.find(database, type)
      files = []

      Find.find(Dir.pwd) do |path|
        file = File.new(path, database, type)

        raise "Duplicate time for #{type}s: #{files.find { |f| f == file }}, #{file}" if
          file.valid? && files.include?(file)

        files << file if file.valid?
      end

      files.sort_by(&:datetime).map { |file| new(file) }
    end

    def statements
      separator = Config.options[:separator]
      if separator
        statements = @content.split(separator)
        statements.collect!(&:strip)
        statements.reject(&:empty?)
      else
        [content]
      end
    end

    private

    def new?
      history = @database.history
      last = history.order(Sequel.asc(:time)).where(type: @type).last
      is_new = history.where(time: @datetime, type: @type).count == 0

      if is_new && !last.nil?
        if last[:time] > @datetime
          raise "#{@type.capitalize} #{@name} has time BEFORE last one recorded !"
        end
      end
      is_new
    end

    def on_success
      puts "[+] Successfully executed #{@type}, name: #{@name}"
      puts "    #{type.capitalize} file: #{@date}_#{@time}_#{@name}.sql"
      puts "    Benchmark: #{@benchmark}"

      @database.history.insert(time: @datetime, name: @name,
                               type: @type, executed: DateTime.now)
    end
  end
end
