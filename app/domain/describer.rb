class Describer < MethodStruct.new(:scenario)
  include Utils

  def call
    instance_eval(&scenario)
    output
  end

  private
  def describe(description)
    output.title = description
  end

  def comment(comment = nil)
    if comment
      output.lines << "# #{comment}"
    else
      output.lines << ""
    end
  end

  def get(path, expected_output=nil, expected_status=200)
    output.lines << "GET #{path} => #{expected_status}: #{expected_output.to_json}"
    expected_output.as_json
  end

  def post(path, params, expected_output=nil, expected_status=201)
    output.lines << "POST #{path} with #{params.to_json} => #{expected_status}: #{expected_output.to_json}"
    expected_output.as_json
  end

  def put(path, params, expected_output=nil, expected_status=201)
    output.lines << "PUT #{path} with #{params.to_json} => #{expected_status}: #{expected_output.to_json}"
    expected_output.as_json
  end

  def an_int
    @next_int ||= 0
    @next_int += 1
  end

  def output
    @output ||= Description.new
  end
end
