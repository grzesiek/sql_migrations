describe 'loadable configuration file' do
  before do
    File.open('databases.yml', 'w') do |f|
      f.puts 'default:'
      f.puts '  development:'
      f.puts '    adapter: sqlite3'
      f.puts '    database: <%= ENV["DB_NAME"] %>'
    end
    ENV['DB_NAME'] = 'test_database'
    SqlMigrations::Config.load! 'databases.yml'
  end

  it 'should use environment variables in config' do
    expect(SqlMigrations::Config.options[:default][:development][:database]).to eq 'test_database'
  end

  it 'should parse database correctly' do
    config = SqlMigrations::Config.new
    expect(config.databases).to eq [ { adapter: "sqlite3", database: "test_database", name: :default} ]
  end
end
