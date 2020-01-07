class ApplicationController < ActionController::Base
  before_action :set_request_variant

  def set_request_variant
    request.variant = request.device_variant
    request.variant = :smartphone if request.browser == 'Googlebot' && request.user_agent =~ /Mobile/
  end
end
