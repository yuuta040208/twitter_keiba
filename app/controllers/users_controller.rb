class UsersController < ApplicationController
  def index
    @users = User.all.order(point: 'desc')
  end

  def show

  end
end
