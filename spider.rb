#!/usr/bin/env ruby
require 'anemone'
require 'optparse'
require 'csv'

options = {}
OptionParser.new do |parser|
  parser.on("-u", "--url URL", "URL is required.") do |url|
    options[:url] = url
  end
end.parse!

if origin = options.dig(:url)

  rows = []
  Anemone.crawl(origin) do |anemone|
    # anemone.skip_links_like(/^\/(news|events)\/(2014|2017)/)
    anemone.on_every_page { |page|
      title = page.doc.at('title').inner_html rescue nil
      url = page.url
      code = page.code
      row = [title, url, code]
      #STDOUT.write "\n#{row}"
      rows.push(row)
      sleep 1
    }
  end

  csv_string = CSV.generate({
      write_headers: true,
      headers: [:title, :url]
    }) do |csv|
    rows.each {|row| csv << row }
  end
  STDOUT.write "\n\n#{csv_string}"

else
  STDOUT.write "No URL specified.\n"
end
