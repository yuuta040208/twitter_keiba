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

    create_count = 0
    update_count = 0
    doc.css('table.table-bordered').each do |table|
      hold = table.css('tr > th').text.split('天候').first
      times = hold.split('回').first.scan(/[0-9]/).first.to_i
      day = hold.split('回').second.scan(/[0-9]/).first.to_i
      place = hold.split('回').second[0..1]

      table.css('tbody tr').each.with_index(1) do |tr, index|
        if index == 11
          if Race.where(date: "#{Date.today.year}#{args['date']}", hold: hold, number: tr.css('td:nth-child(1) > div > a').text).empty?
            Race.create!(
                date: "#{Date.today.year}#{args['date']}",
                number: tr.css('td:nth-child(1) > div > a').text,
                time: tr.css('td:nth-child(1) > span').text,
                times: times,
                day: day,
                place: place,
                hold: hold,
                name: tr.css('td:nth-child(2) > a').text.sub(/\(.*?\)/, ''),
                url: tr.css('td:nth-child(2) > a').first[:href],
                course: tr.css('td:nth-child(2)').text.sub(/\(.*?\)/, '').split("\n\t\t").last.split('m').first[0],
                distance: tr.css('td:nth-child(2)').text.sub(/\(.*?\)/, '').split("\n\t\t").last.split('m').first[1..4].to_i,
            )
            create_count += 1
          else
            race = Race.find_by(date: "#{Date.today.year}#{args['date']}", hold: hold, number: tr.css('td:nth-child(1) > div > a').text)
            race.update!(
                date: "#{Date.today.year}#{args['date']}",
                number: tr.css('td:nth-child(1) > div > a').text,
                time: tr.css('td:nth-child(1) > span').text,
                times: times,
                day: day,
                place: place,
                hold: hold,
                name: tr.css('td:nth-child(2) > a').text.sub(/\(.*?\)/, ''),
                url: tr.css('td:nth-child(2) > a').first[:href],
                course: tr.css('td:nth-child(2)').text.sub(/\(.*?\)/, '').split("\n\t\t").last.split('m').first[0],
                distance: tr.css('td:nth-child(2)').text.sub(/\(.*?\)/, '').split("\n\t\t").last.split('m').first[1..4].to_i,
            )
            update_count += 1
          end
        end
      end
    end

    puts "新規作成: #{create_count}件　更新: #{update_count}件"
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
              win: tr.css('td:nth-child(4)').text.to_f
          )
          count += 1
        end
      end

      puts "#{count}件をデータベースに追加しました。"

      # BOT認識されないように5秒スリープさせる
      sleep 5
    end
  end


  desc "オッズをスクレイピング"
  task :odds, ['date'] => :environment do |task, args|
    races = Race.where(date: "#{Date.today.year}#{args['date']}")
    races.each do |race|
      url = "#{KEIBALAB_URL}#{race.url}odds.html"
      html = open(url).read
      doc = Nokogiri::HTML.parse(html.toutf8, nil, 'utf-8')

      puts "#{url} からデータを取得します..."

      count = 0

      doc.css('table.tanTables tbody > tr').each do |tr|
        horse = race.horses.find_by(umaban: tr.css('td:nth-child(2)').text.to_i)
        count += 1
        Odds.create!(
            race_id: race.id,
            horse_id: horse.id,
            time: Odds.where(horse_id: horse.id).count + 1,
            win: tr.css('td:nth-child(4)').text.to_f,
            place: ((tr.css('td:nth-child(5)').text.to_f + tr.css('td:nth-child(7)').text.to_f) / 2).round(1)
        )
      end

      puts "#{count}件のデータを更新しました。"

      # BOT認識されないように5秒スリープさせる
      sleep 5
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
        fukus = doc.css('div.haraimodoshi > table  tr:nth-child(2) > td:nth-child(3)').text.split('円')

        Result.create!(
            race_id: race.id,
            first_horse: doc.css('table.resulttable tbody > tr:nth-child(1) > td:nth-child(4)').text.sub(/\(.*?\)/, ''),
            second_horse: doc.css('table.resulttable tbody > tr:nth-child(2) > td:nth-child(4)').text.sub(/\(.*?\)/, ''),
            third_horse: doc.css('table.resulttable tbody > tr:nth-child(3) > td:nth-child(4)').text.sub(/\(.*?\)/, ''),
            tanshou: doc.css('div.haraimodoshi > table  tr:nth-child(1) > td:nth-child(3)').text.split('円').first.gsub(',', '').to_i,
            fukushou_first: fukus.first&.gsub(',', '').to_i,
            fukushou_second: fukus.second&.gsub(',', '').to_i,
            fukushou_third: fukus.third&.gsub(',', '').to_i,
        )

        puts "#{race.name}の結果をデータベースに追加しました。"
      end

      # BOT認識されないように2秒スリープさせる
      sleep 2
    end
  end

  desc "レース結果の単勝、複勝情報を更新"
  task :update_result, ['date'] => :environment do |task, args|
    races = Race.where('id <= 36').order(:id)
    races.each do |race|
      url = "#{KEIBALAB_URL}#{race.url}raceresult.html"
      html = open(url).read
      doc = Nokogiri::HTML.parse(html.toutf8, nil, 'utf-8')

      puts "#{url} からデータを取得します..."

      result = Result.find_by(race_id: race.id)
      if race.present?
        fukus = doc.css('div.haraimodoshi > table  tr:nth-child(2) > td:nth-child(3)').text.split('円')

        result.tanshou = doc.css('div.haraimodoshi > table  tr:nth-child(1) > td:nth-child(3)').text.split('円').first.gsub(',', '').to_i
        result.fukushou_first = fukus.first&.gsub(',', '').to_i
        result.fukushou_second = fukus.second&.gsub(',', '').to_i
        result.fukushou_third = fukus.third&.gsub(',', '').to_i

        result.save!

        puts "#{race.name}の結果を更新しました。"
      end

      # BOT認識されないように2秒スリープさせる
      sleep 2
    end
  end
end
