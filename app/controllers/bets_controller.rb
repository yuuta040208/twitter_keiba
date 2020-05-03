class BetsController < ApplicationController
  def index
  end

  def show
    @race = Race.find(params[:id])
    forecasts = @race.cache_forecasts(User::RETURN_RATE_PROFESSIONAL)

    honmeis = forecasts.pluck(:honmei)
    taikous = forecasts.pluck(:taikou)
    tananas = forecasts.pluck(:tanana)
    renkas = forecasts.pluck(:renka)

    twitter_rates = @race.calculate_twitter_rates(honmeis, taikous, tananas, renkas, User::RETURN_RATE_PROFESSIONAL)
    @my_forecasts = my_forecast(twitter_rates, @race)
  end


  private

  # オッズに重みをつける
  #   1( 0.10): 1.25
  #   2( 0.20): 1.20
  #   4( 0.40): 1.15
  #   6( 0.60): 1.10
  #   8( 0.80): 1.05
  #  10( 1.00): 1.00
  #  20( 2.00): 0.90
  #  40( 4.00): 0.80
  #  60( 6.00): 0.70
  #  80( 8.00): 0.60
  # 100(10.00): 0.50
  def my_forecast(rates, race)
    horses = race.horses
    horse_info = rates.map.with_index(1) do |rate, i|
      horse = horses.find_by(umaban: i)
      odds = horse.odds.present? ? horse.odds.last.win : horse.win
      weight = if odds <= 10
                 1 + (10 - odds) * 0.025
               else
                 1 - (odds / 10) * 0.05
               end

      {
          number: i,
          name: horse.name,
          odds: odds,
          rate: rate * weight
      }
    end

    horse_info.sort_by {|a| a[:rate]}.reverse
  end
end
