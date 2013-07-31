class TestRun < ActiveRecord::Base
  WAITING = :waiting
  RUNNING = :running
  COMPLETED = :completed
  FAILED = :failed

  RECENT_LIMIT = 5

  belongs_to :user, :inverse_of => :test_runs

  after_initialize :initialize_status
  after_initialize :initialize_output

  def self.has_waiting?
    where(:status => WAITING).exists?
  end

  def self.recent
    order("created_at DESC").limit(RECENT_LIMIT)
  end

  [WAITING, RUNNING, COMPLETED, FAILED].each do |status|
    define_method "mark_as_#{status}!" do
      update_attributes(:status => status)
    end
  end

  private
  def initialize_status
    self.status ||= WAITING
  end

  def initialize_output
    self.output ||= ""
  end
end
