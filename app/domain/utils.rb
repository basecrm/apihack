module Utils
  def random_string
    (0...8).map { (65 + rand(26)).chr }.join
  end

  def random_int
    rand(1000) + 1
  end

  def random_bool
    rand > 0.5
  end

  def hash_matching(hash)
    HashMatcher.new(hash)
  end

  def create_int(value)
    create_constant(:int, value)
  end

  def create_bool(value)
    create_constant(:bool, value)
  end

  def create_string(value)
    create_constant(:string, value)
  end

  def create_random_type
    case rand(3)
    when 0 then ["int", create_int(random_int)]
    when 1 then ["string", create_string(random_string)]
    when 2 then ["bool", create_bool(random_bool)]
    end
  end

  def create_constant(type, value)
    params = {:kind => "constant", :type => type.to_s, :value => value}
    post("/nodes", params, hash_matching(params.merge(:id => an_int)))["id"]
  end

  def find_builtin(name)
    get("/functions/builtin/#{name}", hash_matching(:id => an_int))["id"]
  end

  def create_invoke(id, *args)
    params = {:kind => "invoke", :function => id, :arguments => args}
    post("/nodes", params, hash_matching(params.merge(:id => an_int)))["id"]
  end

  def create_function(body=nil)
    post("/functions", {:body => body}, hash_matching(:body => body, :id => an_int))["id"]
  end

  def create_argument(number)
    params = {:kind => "argument", :argument => number}
    post("/nodes", params, hash_matching(params.merge(:id => an_int)))["id"]
  end

  def create_if(predicate, true_branch, false_branch)
    params = {:kind => "if", :predicate => predicate, :true_branch => true_branch, :false_branch => false_branch}
    post("/nodes", params, hash_matching(params.merge(:id => an_int)))["id"]
  end

  def set_body(function, body)
    put("/functions/#{function}", {:body => body}, hash_matching(:body => body))
  end

  def expect_result(id, expected)
    get("/nodes/#{id}/evaluate", hash_matching(:result => expected))
  end

  def fib(target)
    a, b = 1, 1
    target.times do
      a, b = b, a + b
    end
    b
  end
end
