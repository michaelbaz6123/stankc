module ExpressionParser

  private def parse_expression(precedence = 0) : Expression
    left = parse_prefix

    until eof?
      # Procedure call
      if peek.type == TokenType::L_PAREN
        variable = left.as(VariableExpression).variable
        left = parse_procedure_call(variable)
      end
      # Function call
      if match?(TokenType::FN_APPLY)
        variable = left.as(VariableExpression).variable
        left = parse_function_call(variable)
      end

      break unless binary_operator?(peek) || assign_operator?(peek)
      break if precedence > precedence_of(peek.type)

      operator = advance
      right = parse_expression(precedence_of(operator.type))
      left = parse_binary_expression(left, operator, right)
    end

    return left
  end


  def parse_literal : Expression
    token = advance

    literal_value = case token.type
    when TokenType::INT_LITERAL
      value = token.lexeme.to_i128
      IntLiteral.new(value)
    when TokenType::FLOAT_LITERAL
      value = token.lexeme.to_f64
      FloatLiteral.new(value)
    when TokenType::STRING_LITERAL
      StringLiteral.new(token.lexeme)
    when TokenType::CHAR_LITERAL
      CharLiteral.new(token.lexeme[0])
    when TokenType::TRUE
      BoolLiteral.new(true)
    when TokenType::FALSE
      BoolLiteral.new(false)
    when TokenType::NIL
      NilLiteral.new(nil)
    else
      raise "Unexpected literal type: #{token.lexeme}"
    end

    return Literal.new(literal_value)
  end

  private def parse_binary_expression(left : Expression, operator : Token, right : Expression) : Expression
    if assign_operator?(operator)
      var_expr = left.as(VariableExpression)
      var = var_expr.variable
      if operator.type == TokenType::EQ
        return Reassignment.new(var, right)
      else
        binary_op_type = desugar_assign_operator(operator.type)
        binary_expr = BinaryExpression.new(var_expr, binary_op_type, right)
        return Reassignment.new(var, binary_expr)
      end
    else
      return BinaryExpression.new(left, operator.type, right)
    end
  end

  private def parse_prefix : Expression
    case peek.type
    when TokenType::INT_LITERAL,
         TokenType::FLOAT_LITERAL,
         TokenType::STRING_LITERAL,
         TokenType::CHAR_LITERAL,
         TokenType::TRUE,
         TokenType::FALSE,
         TokenType::NIL
      parse_literal
    when TokenType::IDENTIFIER
      parse_identifier_expression
    when TokenType::IF
      parse_if_expression
    when TokenType::NOT || TokenType::SUB
      operator = advance
      right = parse_expression(EXPR_PRECEDENCE[:UNARY])
      UnaryExpression.new(operator.type, right)
    when TokenType::L_PAREN
      advance
      expr = parse_expression
      consume(TokenType::R_PAREN, "Expected ')' to match '('")
      expr
    else
      raise "Unexpected token in expression: #{peek}"
    end
  end

  def parse_identifier_expression : Expression
    variable = parse_variable
    if peek.type == TokenType::L_PAREN
      return parse_procedure_call(variable)
    elsif match?(TokenType::FN_APPLY)
      return parse_function_call(variable) 
    else
      return VariableExpression.new(variable)
    end
  end
  
  def desugar_assign_operator(type : TokenType) : TokenType
    token_type = DESUGARED_ASSIGN_OPERATORS[type]?
    return token_type if token_type
    return TokenType::EOF # fallback so we have some tokentype to return, should never happen
  end
  
  private def parse_procedure_call(callee : Variable) : ProcedureCall
    args = parse_tuple_expression
    return ProcedureCall.new(callee, args)
  end

  private def parse_function_call(callee : Variable) : FunctionCall
    args = if peek.type == TokenType::L_PAREN
      parse_tuple_expression
    else
      TupleExpression.new([] of Expression)
    end
    return FunctionCall.new(callee, args)
  end

  def parse_tuple_expression : TupleExpression
    args = [] of Expression
    consume(TokenType::L_PAREN, "Expected '(' to begin tuple expression")
    unless peek.type == TokenType::R_PAREN
      args << parse_expression
      while match?(TokenType::COMMA)
        args << parse_expression
      end
    end
    consume(TokenType::R_PAREN, "Expect ')' to end tuple expression")

    return TupleExpression.new(args)
  end

  private def parse_if_expression : IfExpression
    branches = [] of IfBranch

    consume(TokenType::IF, "Expect 'if' to start if expression")
    condition = parse_expression
    consume(TokenType::THEN, "Expect 'then' after condition")
    body = parse_expression
    branches << IfBranch.new(condition, body)

    while peek.type == TokenType::ELIF
      consume(TokenType::ELIF)
      condition = parse_expression
      consume(TokenType::THEN, "Expect 'then' after condition")
      body = parse_expression
      branches << IfBranch.new(condition, body)
    end

    else_body = if peek.type == TokenType::ELSE
      consume(TokenType::ELSE)
      consume(TokenType::DO) if peek.type == TokenType::DO
      parse_expression
    else nil end

    consume(TokenType::END, "Expect 'end' to terminate if expression")
    
    return IfExpression.new(branches, else_body)
  end

  private def parse_infix(left : Expression) : Expression
    operator = advance
    precedence = EXPR_PRECEDENCE[operator.type]
    right = parse_expression(precedence)

    return Binary.new(left, operator, right)
  end

  private def precedence_of(type : TokenType) : Int32
    EXPR_PRECEDENCE[type]? || 0
  end

  private def binary_operator?(token : Token) : Bool
    BINARY_OPERATORS.includes?(token.type)
  end

  def assign_operator?(token : Token) : Bool 
    ASSIGN_OPERATORS.includes?(token.type) 
  end
 
end