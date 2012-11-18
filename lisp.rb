
class Lisp

  @definitions = {}
  @variables={}

  def self.evaluate(operation, operands, scopes)

    operands = operands.map{|operand| fetchVariableValue(operand, scopes)}
    result = 0
    if operation == '+'
      result = operands.reduce{|a,b| a.to_i+b.to_i}
    elsif operation == '-'
      result = operands.reduce{|a,b| a.to_i-b.to_i}
    elsif operation == '*'
      result = operands.reduce{|a,b| a.to_i*b.to_i}
    elsif operation == '/'
      result = operands.reduce{|a,b| a.to_i/b.to_i}
    else
      result = evaluateByDefinition(operation, operands)
    end
    return result
  end

  def self.fetchVariableValue(var,scopes)
    value = nil
    scopes.each{|scope|  value = variables[scope][var] if( variables[scope][var] != nil}

    if(value != nil)
      return value
    else
      return var
    end
    end

    def self.evaluateByDefinition(operation, operands)
      if @definitions.include? operation
        param = @definitions[operation][0]
        stmt = @definitions[operation][1]
        i = 0
        while i < param.size do
          stmt = stmt.sub(param[i],operands[i])
          i = i + 1
        end

        return execute(stmt)
      else
        puts "Unexpected operation"
        return 0
      end
    end

    def self.execute(input)
      tokens = input.split

      operands = []
      operation = tokens[1]
      i = 2
      while i < tokens.size do
        token = tokens[i]

        if token == '('
          temp_tokens = []
          temp_tokens.push(token)
          while token != ')'
            i = i +1
            token = tokens[i]
            temp_tokens.push(token)
          end
          operands.push(execute(temp_tokens.join(' ')))
        elsif token != ')'
          operands.push(token);
        end
        prevToken = token
        i = i + 1
      end
      return evaluate(operation,operands)
    end

    def self.parse(scope_name, input)
      tokens = input.split
      i = 0
      @definitions = {"" => {}}
      while i < tokens.size do
        token = tokens[i]
        if token == 'define'
          i = parseDefinitions(tokens,i,"")
        end
        i = i + 1
      end
      @definitions
    end

    def self.parseDefinitions(tokens, i, scope_name)
      method_name = tokens[i+2]
      @definitions.merge({scope_name+"."+method_name => {}})
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

      count = 0
      while true do
        token = tokens[i]
        if token == 'define'
          i = parseDefinitions(tokens,i,scope_name+"."+method_name)
        elsif token == ')' and count == 0
          break
        elsif token == '('
          count = count + 1
        elsif token == ')'
          count = count - 1
        end
        stmts.push(token)
        i = i + 1
      end
      stmts.push(token)
      @definitions[scope_name] = @definitions[scope_name].merge({method_name => [params, stmts.join(' ')]})
      return i
    end

    def self.definitions
      @definitions
    end

    end

    Lisp.parse("( define ( add a b ) ( + a b ) )")
