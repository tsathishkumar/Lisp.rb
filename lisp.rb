
def evaluate(operation, operands)
    puts operation
    puts operands
    result = 0
    if operation == '+'
        result = operands.reduce{|a,b| a.to_i+b.to_i}
    elsif operation == '-'
        result = operands.reduce{|a,b| a.to_i-b.to_i}
    elsif operation == '*'
        result = operands.reduce{|a,b| a.to_i*b.to_i}
    elsif operation == '/'
        result = operands.reduce{|a,b| a.to_i/b.to_i}
    end
    return result
end

def execute(input)
    tokens = input.split

    operands = []
    operation = tokens[1]
    i = 2
    while i < tokens.size do
        token = tokens[i]
        puts token

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

execute('( + 1 2 )')
