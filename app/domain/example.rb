class Example < Struct.new(:scenario)
  def verify(endpoint, test_run)
    Verifier.call(endpoint, scenario, test_run)
  end

  def describe
    Describer.call(scenario)
  end
end
