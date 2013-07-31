require "yajl"

class Verifier < MethodStruct.new(:endpoint, :scenario, :test_run)
  CLIENT_OPTIONS = {:content_type => :json, :accept => :json}

  include Utils

  class VerifierError < StandardError; end

  def call
    instance_eval(&scenario)
    true
  rescue VerifierError => e
    append_output(e.message)
    false
  ensure
    append_output("")
  end

  private
  def describe(description)
    append_output(description)
  end

  def comment(comment=nil)
  end

  def an_int
    IntMatcher.new
  end

  def get(path, expected_output=nil, expected_status=200)
    RestClient.get("#{endpoint}#{path}", CLIENT_OPTIONS) do |response, request, result|
      append_output("GET #{path}")
      check_response(response, expected_output, expected_status)
    end
  end

  def post(path, params, expected_output=nil, expected_status=201)
    RestClient.post("#{endpoint}#{path}", params.to_json, CLIENT_OPTIONS) do |response, request, result|
      append_output("POST #{path} with #{params.to_json}")
      check_response(response, expected_output, expected_status)
    end
  end

  def put(path, params, expected_output=nil, expected_status=201)
    RestClient.put("#{endpoint}#{path}", params.to_json, CLIENT_OPTIONS) do |response, request, result|
      append_output("PUT #{path} with #{params.to_json}")
      check_response(response, expected_output, expected_status)
    end
  end

  def check_response(response, expected_output, expected_status)
    parsed = Yajl::Parser.parse(response.to_str)
    check_status(response.code, expected_status)
    check_output(parsed, expected_output) if expected_output
    parsed
  rescue Yajl::ParseError
    raise VerifierError.new("The response body did not contain valid JSON")
  end

  def check_output(actual, expected)
    raise VerifierError.new("Expected response #{expected.to_json}, got #{actual.to_json}") unless expected === actual
  end

  def check_status(actual, expected)
    raise VerifierError.new("Expected status #{expected}, got #{actual}") unless actual == expected
  end

  def append_output(line)
    test_run.output += "#{line}\n"
  end
end
