class Admin::RacesController < Admin::ApplicationController
  def index
    @races = Race.all.order(date: 'desc').order(:hold)
  end

  def update
    race = Race.find(params[:id])
    if race.update(race_params)
      flash[:notice] = "#{race.name} を更新しました。"
      redirect_to admin_races_path
    else

    end
  end


  private

  def race_params
    params.require(:race).permit(:alt_name)
  end
end
