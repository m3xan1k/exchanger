require 'sequel'
require 'terminal-table'
require 'time'


def init_db
  # create db and table if not exist and bulk insert data
  db = Sequel.sqlite('test.db')

  unless db.table_exists?(:currencies)
    db.create_table :currencies do
      primary_key :id

      column :code, String
      column :name, String

    end
  end

  unless db.table_exists?(:values)
    db.create_table :values do
      primary_key :id

      column :value, Float
      column :date, String

      foreign_key :currency_id, :currencies
    end
  end

  return db
end


def save_to_db(db, data={})
  currencies_table = db[:currencies]
  values_table = db[:values]

  # pre-fill currencies table if empty
  if currencies_table.empty?
    currencies_table.multi_insert(data.map { |row| row.slice(:code, :name) })
  end

  # Match values with currency ids and save to db
  values = []
  currencies_table.all.each do |currency|
    value = data.filter { |row| row[:code] == currency[:code] }.first.slice(:value, :date)
    value[:currency_id] = currency[:id]
    values.push(value)
  end
  values_table.multi_insert(values)

  currencies_table.select(:code, :name, :value, :date).join(:values, :id => :id)
end


def fetch_todays_values(db)
  today = Date.today.to_s
  table = db[:currencies]
  today_currencies = table.select(:code, :name, :value).join(:values, :id => :id).where(date: today)
end


def fetch_codes_and_names(db)
  db[:currencies].all
end


def fetch_todays_value_by_code(db, code)
  table = db[:currencies]
  date=Date.today.to_s
  where = {date: date, code: code}
  today_currencies = table.select(:code, :name, :value).join(:values, :id => :id).where(where)
end


def fetch_values_by_date(db, date)
  table = db[:currencies]
  filter_by_date = table.select(:code, :name, :value, :date).join(:values, :id => :id).where(date: date)
end


def format_response(data, fields=[:code, :name, :value])
  headings = fields
  rows = data.map { |row| row.fetch_values(*fields) }
  table = Terminal::Table.new :headings => headings, :rows => rows
  table.style = {:all_separators => true}
  table
  logo = "
  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  ░░██░█░█░██░█░█░███░██░░█░███░██░███░░░░
  ░░█░░█░█░█░░█░█░█░█░███░█░█░░░█░░█░█░░░░
  ░░██░░█░░█░░███░███░█░███░█░░░██░███░░░░
  ░░█░░█░█░█░░█░█░█░█░█░░██░█░█░█░░██░░░░░
  ░░██░█░█░██░█░█░█░█░█░░██░███░██░█░█░░░░
  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  "
  new_line = '
'
  "#{logo}#{new_line}#{table}#{new_line}#{Time.now}#{new_line}"
end


