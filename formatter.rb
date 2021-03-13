require 'sequel'
require 'terminal-table'
require 'time'
require 'active_support/time'
require 'pry'

LOGO = "
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░██░█░█░██░█░█░███░██░░█░███░██░███░░░░
░░█░░█░█░█░░█░█░█░█░███░█░█░░░█░░█░█░░░░
░░██░░█░░█░░███░███░█░███░█░░░██░███░░░░
░░█░░█░█░█░░█░█░█░█░█░░██░█░█░█░░██░░░░░
░░██░█░█░██░█░█░█░█░█░░██░███░██░█░█░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
".freeze

NEW_LINE = '
'.freeze

NOT_FOUND = "
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░█░░░█░░█████░░█░░░█░░░░░░░░░░░
░░░░░░░█░░░█░░█░░░█░░█░░░█░░░░░░░░░░░
░░░░░░░█░░░█░░█░░░█░░█░░░█░░░░░░░░░░░
░░░░░░░█████░░█░░░█░░█████░░░░░░░░░░░
░░░░░░░░░░░█░░█░░░█░░░░░░█░░░░░░░░░░░
░░░░░░░░░░░█░░█░░░█░░░░░░█░░░░░░░░░░░
░░░░░░░░░░░█░░█████░░░░░░█░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
".freeze

def format_404
  "#{LOGO}#{NEW_LINE}#{NOT_FOUND}#{NEW_LINE}#{Time.now}#{NEW_LINE}"
end
# def fetch_rates_by_date(db, date: Date.today.to_s)
#   table = db[:currencies]
#   date = Date.parse(date)
#   table.select(:code, :name, :rate, :date).join(:rates, currency_id: :id).where(date: date)
# end

def format_response(data, fields: [])
  # check if only single currency requested
  data = [data] if data.is_a?(Hash)

  # extract rates corresponding to fields
  # binding.pry

  rows = data.map do |row|
    row['date'] = row['date'].to_s if fields.include?('date')
    row['rate'] = row['rate'].to_f.round(2) if fields.include?('rate')

    # if row data not unified with fields
    begin
      row.fetch_values(*fields)
    rescue KeyError
      fields = %w[code name rate]
      row.fetch_values(*fields)
    end
  end

  # set headings and draw table
  headings = fields
  table = Terminal::Table.new headings: headings, rows: rows
  table.style = { all_separators: true }

  "#{LOGO}#{NEW_LINE}#{table}#{NEW_LINE}#{Time.now}#{NEW_LINE}"
end
