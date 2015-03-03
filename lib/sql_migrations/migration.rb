module SqlMigrations
  class Migration < SqlFile

    def self.find(db_name = nil)
      super(db_name, :migrations)
    end

    def to_s
      "Migration #{@name}, datetime: #{@date + @time}"
    end

    def execute(db)
      super
    end

    private
    def is_new?
      TODO
    end

    def on_success
    end

  end
end
