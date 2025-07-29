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


  private def parse_literal : Expression
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
      raise error("unexpected literal type #{token.lexeme}", token)
    end

    return Literal.new(literal_value)
  end

  private def parse_binary_expression(left : Expression, operator : Token, right : Expression) : Expression
    if assign_operator?(operator)
      var_expr = left.as(VariableExpression)
      var = var_expr.variable
      if operator.type == TokenType::EQ
        return VarReassignment.new(var, right)
      else
        binary_op_type = desugar_assign_operator(operator.type)
        binary_expr = BinaryExpression.new(var_expr, binary_op_type, right)
        return VarReassignment.new(var, binary_expr)
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
      consume(TokenType::R_PAREN, "expected ')' to match '('")
      expr
    else
      raise error("unexpected token in expression #{peek.lexeme}", peek)
    end
  end

  private def parse_identifier_expression : Expression
    variable = parse_variable
    if peek.type == TokenType::L_PAREN
      return parse_procedure_call(variable)
    elsif match?(TokenType::FN_APPLY)
      return parse_function_call(variable) 
    else
      return VariableExpression.new(variable)
    end
  end
  
  private def desugar_assign_operator(type : TokenType) : TokenType
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

  private def parse_tuple_expression : TupleExpression
    args = [] of Expression
    consume(TokenType::L_PAREN, "expected '(' to begin tuple expression")
    unless peek.type == TokenType::R_PAREN
      args << parse_expression
      while match?(TokenType::COMMA)
        args << parse_expression
      end
    end
    consume(TokenType::R_PAREN, "expected ')' to end tuple expression")

    return TupleExpression.new(args)
  end

  def parse_type : Type
    inner_types = [] of Type
    name = consume(TokenType::IDENTIFIER, "expected type annotation").lexeme
    saw_open_paren = false
    if match?(TokenType::L_PAREN) && (saw_open_paren = true)
      inner_types << parse_type
      while match?(TokenType::COMMA)
        inner_types << parse_type
      end
    end
    consume(TokenType::R_PAREN, "expected ')' to end type args") if saw_open_paren
    return Type.new(name, inner_types)
  end

  private def parse_if_expression : IfExpression
    branches = [] of IfBranch

    consume(TokenType::IF, "expected 'if' to start if expression")
    condition = parse_expression
    consume(TokenType::THEN, "expected 'then' after if condition")
    body = parse_expression
    branches << IfBranch.new(condition, body)

    while peek.type == TokenType::ELIF
      advance # TokenType::ELIF
      condition = parse_expression
      consume(TokenType::THEN, "expected 'then' after elif condition")
      body = parse_expression
      branches << IfBranch.new(condition, body)
    end

    else_body = if peek.type == TokenType::ELSE
      advance # TokenType::ELSE
      parse_expression
    else nil end

    consume(TokenType::END, "expected 'end' to end if expression")
    
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

  private def assign_operator?(token : Token) : Bool 
    ASSIGN_OPERATORS.includes?(token.type) 
  end
 
end