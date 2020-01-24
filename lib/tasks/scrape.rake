require 'nokogiri'
require 'open-uri'
require 'kconv'

KEIBALAB_URL = 'https://www.keibalab.jp'

namespace :scrape do
  desc "開催日のレース一覧をスクレイピング"
  task :race, ['date'] => :environment do |task, args|
    url = "#{KEIBALAB_URL}/db/race/#{Date.today.year}#{args['date']}"
    html = open(url).read
    doc = Nokogiri::HTML.parse(html.toutf8, nil, 'utf-8')

    puts "#{url} からデータを取得します..."

    count = 0
    doc.css('table.table-bordered').each do |table|
      hold = table.css('tr > th').text.split('天候').first

      table.css('tbody tr').each.with_index(1) do |tr, index|
        if index.between?(9, 11)
          if Race.where(date: "#{Date.today.year}#{args['date']}", number: tr.css('td:nth-child(1) > div > a').text).empty?
            Race.create!(
                date: "#{Date.today.year}#{args['date']}",
                number: tr.css('td:nth-child(1) > div > a').text,
                time: tr.css('td:nth-child(1) > span').text,
                hold: hold,
                name: tr.css('td:nth-child(2) > a').text.sub(/\(.*?\)/, ''),
                url: tr.css('td:nth-child(2) > a').first[:href],
            )
            count += 1
          end
        end
      end
    end

    puts "#{count}件をデータベースに追加しました。"
  end


  desc "競走馬名をスクレイピング"
  task :horse, ['date'] => :environment do |task, args|
    races = Race.where(date: "#{Date.today.year}#{args['date']}")
    races.each do |race|
      url = "#{KEIBALAB_URL}#{race.url}odds.html"
      html = open(url).read
      doc = Nokogiri::HTML.parse(html.toutf8, nil, 'utf-8')

      puts "#{url} からデータを取得します..."

      count = 0

      doc.css('table.tanTables tbody > tr').each do |tr|
        if Horse.where(race_id: race.id, name: tr.css('td:nth-child(3)').text).empty?
          Horse.create!(
              race_id: race.id,
              name: tr.css('td:nth-child(3)').text,
              wakuban: tr.css('td:nth-child(1)').text.to_i,
              umaban: tr.css('td:nth-child(2)').text.to_i,
              odds: tr.css('td:nth-child(4)').text.to_f
          )
          count += 1
        end
      end

      puts "#{count}件をデータベースに追加しました。"

      # BOT認識されないように2秒スリープさせる
      sleep 2
    end
  end


  desc "レース結果をスクレイピング"
  task :result, ['date'] => :environment do |task, args|
    races = Race.where(date: "#{Date.today.year}#{args['date']}")
    races.each do |race|
      url = "#{KEIBALAB_URL}#{race.url}raceresult.html"
      html = open(url).read
      doc = Nokogiri::HTML.parse(html.toutf8, nil, 'utf-8')

      puts "#{url} からデータを取得します..."

      if Result.find_by(race_id: race.id).nil?
        Result.create!(
            race_id: race.id,
            first_horse: doc.css('table.resulttable tbody > tr:nth-child(1) > td:nth-child(4)').text.sub(/\(.*?\)/, ''),
            second_horse: doc.css('table.resulttable tbody > tr:nth-child(2) > td:nth-child(4)').text.sub(/\(.*?\)/, ''),
            third_horse: doc.css('table.resulttable tbody > tr:nth-child(3) > td:nth-child(4)').text.sub(/\(.*?\)/, ''),
        )

        puts "#{race.name}の結果をデータベースに追加しました。"
      end

      # BOT認識されないように2秒スリープさせる
      sleep 2
    end
  end
end