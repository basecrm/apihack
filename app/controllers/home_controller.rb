class HomeController < ApplicationController
  def index
  end

  def run_tests
    current_user.update_attributes(params.slice(:app_address, :framework))
    current_user.schedule_test_run!
    redirect_to "/"
  end
end
