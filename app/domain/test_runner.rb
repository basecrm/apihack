class TestRunner < MethodStruct.new(:test_run_id, :method_name => :perform)
  def perform
    test_run.mark_as_running!

    test_run.update_attributes(:score => passed_examples)
    user.update_score(passed_examples)

    test_run.mark_as_completed!
  end

  def failure
    test_run.mark_as_failed!
  end

  private
  def passed_examples
    @passed_examples ||= Examples.shuffle.count do |example|
      example.verify(endpoint_address, test_run)
    end
  end

  def endpoint_address
    @endpoint_address ||= user.app_address
  end

  def user
    @user ||= test_run.user
  end

  def test_run
    @test_run ||= TestRun.find(test_run_id)
  end
end
