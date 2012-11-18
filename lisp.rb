class Lisp

  def self.parse(input)
    tokens = input.split
    i = 0
    @definitions = {"" => {}}
    @variables = {"" => {}}
    while i < tokens.size do
      token = tokens[i]
      if token == 'define' and tokens[i+1] == '('
        i,name = parseDefinitions(tokens,i,"")
      elsif token == 'define'
        @variables[""].update(tokens[i+1] => tokens[i+2])
        i = i + 2
      elsif token != '(' and token != ')'
        result, i = executeStmt(tokens,i,[""],{})
      end
      i = i + 1
    end
    result
  end

  def self.parseDefinitions(tokens, i, scope_name)
    method_name = tokens[i+2]
    current_scope = scope_name+"."+method_name
    @definitions = @definitions.merge({current_scope => {}})
    private_definitions = {}
    params = []
    i = i + 3
    token = tokens[i]

    while true do
      token = tokens[i]
      if token == ')'
        break
      end
      params.push(token)
      i = i + 1
    end

    i = i + 1
    token = tokens[i]
    stmts = []

    count = -1
    while true do
      token = tokens[i]
      if token == 'define' and tokens[i+1] == '('
        i,name = parseDefinitions(tokens,i, current_scope)
        private_definitions.update(name => current_scope)
        @definitions[current_scope][name][2] = @definitions[current_scope][name][2].merge(private_definitions)
      elsif token == ')' and count == 0
        break
      elsif token == '('
        count = count + 1
        stmts.push(token)
      elsif token == ')'
        count = count - 1
        stmts.push(token)
      else
        stmts.push(token)
      end
      i = i + 1
    end
    i = i + 1
    stmts.push(token)
    @definitions[scope_name] = @definitions[scope_name].merge({method_name => [params, stmts, private_definitions]})
    return i,method_name
  end

  def self.executeStmt(tokens,i, scopes, private_definitions)

    while true
      if tokens[i] == "("
        i = i +1
      else
        break
      end
    end

    puts "executing stmt = " + tokens[i]

    operands = []
    operation = tokens[i]
    i = i + 1
    while true do
      token = tokens[i]

      if token == '('
        operand,i=executeStmt(tokens,i + 1, scopes, private_definitions)
        operands.push(operand)
      elsif token != ')'
        operands.push(token)
      elsif token == ')'
        break
      end
      i = i + 1
    end
    return evaluate(operation,operands,scopes, private_definitions),i
  end

  def self.evaluate(operation, operands, scopes, private_definition)

    if operation == 'define'
      @variables[scopes.last].update(operands[0] => operands[1])
      result = 0
    else

      operands = operands.map{|operand| fetchVariableValue(operand, scopes)}
      if operation == '+'
        result = operands.reduce{|a,b| a.to_i + b.to_i}
      elsif operation == '-'
        result = operands.reduce{|a,b| a.to_i - b.to_i}
      elsif operation == '*'
        result = operands.reduce{|a,b| a.to_i * b.to_i}
      elsif operation == '/'
        result = operands.reduce{|a,b| a.to_i / b.to_i}
      else
        result = evaluateByDefinition(operation, operands, scopes, private_definition)
      end
    end

    puts "scopes " + scopes.join(',').to_s
    puts "operation " + operation.to_s
    puts "operands " + operands.join(',').to_s
    puts "result " + result.to_s

    return result
  end

  def self.evaluateByDefinition(operation, operands, scopes, private_definitions)
    function_scope = ""
    if private_definitions.include? operation
      function_scope = private_definitions[operation]
    end
    if @definitions[function_scope].include? operation
      params = @definitions[function_scope][operation][0]
      stmt = @definitions[function_scope][operation][1]
      private_definitions = @definitions[function_scope][operation][2]
      @variables.update({operation => {}})
      params.each_with_index{|param,i| @variables[operation].update({param => operands[i]})}
      scopes.push(operation)
      result,i = executeStmt(stmt,1, scopes, private_definitions)
      while(i < stmt.size - 2) do
        result,i = executeStmt(stmt,i + 1, scopes, private_definitions)
      end
      scopes.delete(operation)
      return result
    else
      puts "Unexpected operation" + operation
      return 0
    end
  end

  def self.fetchVariableValue(var,scopes)
    result = nil
    scopes.each{|scope| result = @variables[scope][var] if @variables[scope][var] != nil}
    if(result != nil)
      return result
    else
      return var
    end
  end

  def self.definitions
    @definitions
  end

  def self.variables
    @variables
  end


end

Lisp.parse("( define ( fun1 a b c ) ( define ( fun2 a f ) ( * a f ) ) ( define x 1 ) ( + a b ( - b c ) ( fun2 c b ) a x ) ) ( define x 11 ) ( + x ( fun1 1 2 3 ) )")
Lisp.parse("( define ( sum-of-square x y ) ( + ( square x ) ( square y ) ) ( define ( square x ) ( * x x ) ) ( sum-of-square 3 4 )")