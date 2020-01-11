require 'nokogiri'
require 'open-uri'
require 'kconv'

NETKEIBA_URL = 'https://race.netkeiba.com'

namespace :netkeiba do
  desc "開催日のレース一覧をスクレイピング"
  task :scrape_race, ['date'] => :environment do |task, args|
    url = "#{NETKEIBA_URL}/?pid=race_old&id=c#{args['date']}"
    html = open(url).read
    doc = Nokogiri::HTML.parse(html.toutf8, nil, 'utf-8')

    puts "#{url} からデータを取得します..."

    doc.css('dl.race_top_hold_list').each do |race_top_hold_list|
      race_top_hold_list.css('dl.race_top_data_info').each_with_index do |race_top_data_info, index|
        if index.between?(8, 10)
          Race.create!(
              date: "#{Date.today.year}#{args['date']}",
              number: race_top_data_info.css('img').first[:alt],
              hold: race_top_hold_list.css('p.kaisaidata').text,
              name: race_top_data_info.css('div.racename > a').first[:title].sub(/\(.*?\)/, ''),
              url: race_top_data_info.css('div.racename > a').first[:href],
          )
        end
      end
    end

    puts "#{Race.where(date: "#{Date.today.year}#{args['date']}").count}件をデータベースに追加しました。"
  end


  desc "競走馬名をスクレイピング"
  task :scrape_horse, ['date'] => :environment do |task, args|
    races = Race.where(date: "#{Date.today.year}#{args['date']}")
    races.each do |race|
      url = "#{NETKEIBA_URL}#{race.url}"
      html = open(url).read
      doc = Nokogiri::HTML.parse(html.toutf8, nil, 'utf-8')

      puts "#{url} からデータを取得します..."

      doc.css('tr.bml1').each do |tr|
        Horse.create!(
            race_id: race.id,
            name: tr.css('td.horsename a').text,
            wakuban: tr.css('td:nth-child(1) > span').text.to_i,
            umaban: tr.css('td.umaban').text.to_i,
            jockey_name: tr.css('td:nth-child(8)').text,
            odds: tr.css('td.txt_r').text.to_f
        )
      end

      puts "#{Horse.where(race_id: race.id).count}件をデータベースに追加しました。"

      # BOT認識されないように2秒スリープさせる
      sleep 2
    end
  end


  desc "レース結果をスクレイピング"
  task :scrape_result, ['date'] => :environment do |task, args|
    races = Race.where(date: "#{Date.today.year}#{args['date']}")
    races.each do |race|
      url = "#{NETKEIBA_URL}#{race.url.gsub('_old', '')}&mode=result"
      html = open(url).read
      doc = Nokogiri::HTML.parse(html.toutf8, nil, 'utf-8')

      puts "#{url} からデータを取得します..."

      Result.create!(
          race_id: race.id,
          first_horse: doc.css('table.race_table_01 tr:nth-child(2) > td:nth-child(4) > a').first.text,
          second_horse: doc.css('table.race_table_01 tr:nth-child(3) > td:nth-child(4) > a').first.text,
          third_horse: doc.css('table.race_table_01 tr:nth-child(4) > td:nth-child(4) > a').first.text,
      )

      puts "#{Result.find_by(race_id: race.id).attributes}をデータベースに追加しました。"

      # BOT認識されないように2秒スリープさせる
      sleep 2
    end
  end
end
