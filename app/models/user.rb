class User < ActiveRecord::Base
  attr_accessible :username, :avatar_url, :app_address, :framework

  has_many :test_runs

  def schedule_test_run!
    unless test_runs.has_waiting?
      Delayed::Job.enqueue(TestRunner.new(test_runs.create.id))
    end
  end

  def recent_test_runs
    test_runs.recent
  end

  def update_score(score)
    self.score = score
    save!
  end
end
