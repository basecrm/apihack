Examples.register do
  describe "Creating an integer constant"
  value = random_int
  params = {:kind => "constant", :type => "int", :value => value}
  id = post("/nodes", params, hash_matching(params.merge(:id => an_int)))["id"]
  get("/nodes/#{id}", hash_matching(params))
end

Examples.register do
  describe "Integers can only be created with integer values"
  params = {:kind => "constant", :type => "int", :value => random_string}
  post("/nodes", params, hash_matching(:error => "Could not parse integer"), 422)
end

[
  ["Adding numbers", :add, :+],
  ["Multiplying numbers", :mult, :*]
].each do |description, name, operation|
  Examples.register do
    describe description
    value1 = random_int
    value2 = random_int
    id1 = create_int(value1)
    id2 = create_int(value2)
    add_id = get("/functions/builtin/#{name}", hash_matching(:id => an_int))["id"]
    params = {:kind => "invoke", :function => add_id, :arguments => [id1, id2]}
    id3 = post("/nodes", params, hash_matching(params.merge(:id => an_int)))["id"]
    get("/nodes/#{id3}/evaluate", hash_matching(:result => value1.send(operation, value2)))
  end
end

Examples.register do
  describe "Complex arithmetic"
  comment "Add two numbers and multiply the result by a third one"

  a, b, c = random_int, random_int, random_int
  idmult, idadd = find_builtin(:mult), find_builtin(:add)

  id_result = create_invoke(
    idmult,
    create_invoke(idadd, create_int(a), create_int(b)),
    create_int(c)
  )

  expect_result(id_result, (a + b) * c)
end

Examples.register do
  describe "Comparison"

  a = random_int
  b = a + random_int

  ida, idb = create_int(a), create_int(b)
  idlt = find_builtin(:lt)

  comment
  comment "Evaluates to true when the first number is smaller"
  expect_result(create_invoke(idlt, ida, idb), true)
  comment
  comment "Evaluates to false when the first number is bigger"
  expect_result(create_invoke(idlt, idb, ida), false)
end

Examples.register do
  describe "A conditional"

  a = random_int
  b = random_int + a
  ida, idb = create_int(a), create_int(b)
  idlt = find_builtin(:lt)

  comment
  comment "Evaluates to the first branch if the predicate evaluates to true"
  comparison = create_invoke(idlt, ida, idb)
  expect_result(create_if(comparison, ida, idb), a)

  comment
  comment "Evaluates to the second branch if the predicate evaluates to false"
  other_comparison = create_invoke(idlt, idb, ida)
  expect_result(create_if(other_comparison, ida, idb), b)
end

Examples.register do
  describe "Defining and invoking a function returning a constant"

  a = random_int
  ida = create_int(a)
  idf = post("/functions", {:body => ida}, hash_matching(:body => ida, :id => an_int))["id"]
  expect_result(create_invoke(idf), a)
end

Examples.register do
  describe "Defining a function returning the sum of its arguments"

  comment "Argument nodes retrieve the n-th argument of the function in which context they are evaluated"
  id_arg1, id_arg2 = create_argument(0), create_argument(1)
  id_add = create_invoke(find_builtin(:add), id_arg1, id_arg2)
  idf = create_function(id_add)

  comment
  comment "With the function prepared we can now pass in any arguments"
  a, b = random_int, random_int
  ida, idb = create_int(a), create_int(b)
  expect_result(create_invoke(idf, ida, idb), a + b)
end

Examples.register do
  describe "Putting it all together - the Fibonacci sequence"

  comment "The function will take 3 arguments - the last 2 elements and the number of elments to go"
  arg1, arg2, arg3 = create_argument(0), create_argument(1), create_argument(2)

  comment
  add, lt = find_builtin(:add), find_builtin(:lt)

  comment
  comment "Return the last element if the end is reached else invoke recursively with the elements updated"
  function = create_function
  one = create_int(1)
  minus_one = create_int(-1)
  body = create_if(
    create_invoke(lt, arg3, one),
    arg2,
    create_invoke(function, arg2, create_invoke(add, arg1, arg2), create_invoke(add, arg3, minus_one))
  )

  comment
  comment "Set the function body"
  put("/functions/#{function}", {:body => body}, hash_matching(:body => body))

  comment
  comment "The actual invocation"
  target = rand(10) + 2
  expect_result(create_invoke(function, one, one, create_int(target)), fib(target))
end

