Examples.register do
  describe "Lazyness"

  comment "With lazy evaluation it is OK to have infinite loops as arguments"
  comment "as long as those arguments are never used"
  infinite = create_function
  body = create_invoke(infinite)
  set_body(infinite, body)

  comment
  comment "For example a function returning its first argument..."
  arg = create_argument(0)
  fst = create_function(arg)

  comment
  comment "... can be invoked with the infinite loop as its second argument"
  a = random_int
  ida = create_int(a)
  invoke_infinite = create_invoke(infinite)
  expect_result(create_invoke(fst, ida, invoke_infinite), a)
end

Examples.register do
  describe "Conditionals revisited"

  comment "With lazy evaluation you can even implement 'if' as simply a builtin function"
  a = random_int
  b = random_int + a
  ida, idb = create_int(a), create_int(b)
  idlt, iff = find_builtin(:lt), find_builtin(:if)

  comment
  comment "Evaluates to the first branch if the predicate evaluates to true"
  comparison = create_invoke(idlt, ida, idb)
  expect_result(create_invoke(iff, comparison, ida, idb), a)

  comment
  comment "Evaluates to the second branch if the predicate evaluates to false"
  other_comparison = create_invoke(idlt, idb, ida)
  expect_result(create_invoke(iff, other_comparison, ida, idb), b)
end

Examples.register do
  describe "More types"

  comment "Booleans"
  bool = random_bool
  expect_result(create_bool(bool), bool)
  params = {:kind => "constant", :type => "bool", :value => random_int}
  post("/nodes", params, hash_matching(:error => "Could not parse boolean"), 422)

  comment
  comment "And strings"
  string = random_string
  expect_result(create_string(string), string)
  params = {:kind => "constant", :type => "string", :value => random_bool}
  post("/nodes", params, hash_matching(:error => "Could not parse string"), 422)
end

Examples.register do
  describe "Conditional typing"

  comment "Both branches of a conditional need to have the same type"
  bool, string, int = create_bool(random_bool), create_string(random_string), create_int(random_int)
  params = {:kind => "if", :predicate => bool, :true_branch => string, :false_branch => int}
  post("/nodes", params, hash_matching(:error => "Type mismatch"), 422)

  comment
  comment "The predicate must be boolean"
  params = {:kind => "if", :predicate => string, :true_branch => int, :false_branch => int}
  post("/nodes", params, hash_matching(:error => "Type mismatch"), 422)

  comment
  comment "The type is automatically inferred"
  type, node = [["int", int], ["string", string], ["bool", bool]].shuffle.first
  params = {:kind => "if", :predicate => bool, :true_branch => node, :false_branch => node}
  post("/nodes", params, hash_matching(params.merge(:id => an_int, :type => type)))
end

Examples.register do
  describe "Function types"

  comment "Functions also have types, their invocations match those"
  a, b = create_int(random_int), create_int(random_int)
  add, lt = find_builtin(:add), find_builtin(:lt)
  post("/nodes", {:kind => "invoke", :function => add, :arguments => [a, b]}, hash_matching({:type => "int"}))
  post("/nodes", {:kind => "invoke", :function => lt, :arguments => [a, b]}, hash_matching({:type => "bool"}))

  comment
  comment "It is also true of user-defined functions"
  type, node = create_random_type
  function = create_function(node)
  post("/nodes", {:kind => "invoke", :function => function, :arguments => []}, hash_matching({:type => type}))
end

Examples.register do
  describe "Polymorphic functions"

  comment "If 'if' is implemented by a function then its type will depend on the arguments"
  iff = find_builtin(:if)
  predicate = create_bool(random_bool)
  a, b = create_int(random_int), create_int(random_int)
  s1, s2 = create_string(random_string), create_string(random_string)

  post("/nodes", {:kind => "invoke", :function => iff, :arguments => [predicate, a, b]}, hash_matching({:type => "int"}))
  post("/nodes", {:kind => "invoke", :function => iff, :arguments => [predicate, s1, s2]}, hash_matching({:type => "string"}))

  comment
  comment "It should not be possible to invoke it with mismatched arguments"
  post("/nodes", {:kind => "invoke", :function => iff, :arguments => [predicate, a, s1]}, hash_matching({:error => "Type mismatch"}), 422)
  post("/nodes", {:kind => "invoke", :function => iff, :arguments => [a, a, a]}, hash_matching({:error => "Type mismatch"}), 422)
end

Examples.register do
  describe "More type inference"

  comment "In principle it should even be possible to infer the type of some simple recursive functions"
  add, lt, iff = find_builtin(:add), find_builtin(:lt), find_builtin(:if)
  a = create_int(random_int)
  zero = create_int(0)
  minus_one = create_int(-1)

  comment
  function = create_function
  argument = create_argument(0)
  condition = create_invoke(lt, argument, zero)
  body = create_invoke(iff, condition, argument, create_invoke(function, create_invoke(add, argument, minus_one)))
  put("/functions/#{function}", {:body => body}, hash_matching(:body => body))

  comment
  post("/nodes", {:kind => "invoke", :function => function, :arguments => [a]}, hash_matching({:type => "int"}))
end
