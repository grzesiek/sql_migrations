describe 'loadable configuration file' do
  before do
    File.open('databases.yml', 'w') do |f|
      f.puts 'default:'
      f.puts '  test:'
      f.puts '    adapter: sqlite3'
      f.puts '    database: <%= ENV["DB_NAME"] %>'
    end
  end

  it 'should use environment variables in config' do
    ENV['DB_NAME'] = 'test_database'
    SqlMigrations::Config.load! 'databases.yml'
    expect(SqlMigrations::Config.options['default']['test']['database']).to eq 'test_database'
  end
end
