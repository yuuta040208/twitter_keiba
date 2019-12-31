require 'nokogiri'
require 'open-uri'
require 'kconv'

NETKEIBA_URL = 'https://race.netkeiba.com'

namespace :netkeiba do
  desc "開催日のレース一覧をスクレイピング"
  task :scrape_race, ['date'] => :environment do |task, args|
    url = "#{NETKEIBA_URL}/?pid=race_list&id=c#{args['date']}"
    html = open(url).read
    doc = Nokogiri::HTML.parse(html.toutf8, nil, 'utf-8')

    puts "#{url} からデータを取得します..."

    doc.css('dl.race_top_hold_list').each do |race_top_hold_list|
      race_top_hold_list.css('dl.race_top_data_info').each do |race_top_data_info|
        Race.create!(
            date: "#{Date.today.year}#{args['date']}",
            number: race_top_data_info.css('img').first[:alt],
            hold: race_top_hold_list.css('p.kaisaidata').text,
            name: race_top_data_info.css('div.racename > a').first[:title].sub(/\(.*?\)/, ''),
            url: race_top_data_info.css('div.racename > a').first[:href],
        )
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

      doc.css('td.horsename a').each do |a|
        Horse.create!(race_id: race.id, name: a.text)
      end

      puts "#{Horse.where(race_id: race.id).count}件をデータベースに追加しました。"

      # BOT認識されないように1秒スリープさせる
      sleep 1
    end
  end
end
