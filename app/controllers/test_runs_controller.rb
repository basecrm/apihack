class TestRunsController < ApplicationController
  def show
    @test_run = current_user.test_runs.find(params[:id])
  end
end
