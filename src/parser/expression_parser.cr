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


  private def parse_literal : Literal
    token = advance

    case token.type
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
    when TokenType::L_BRACK
      parse_array_literal
    when TokenType::L_BRACE
      parse_map_literal
    else
      raise error("unexpected literal type #{token.lexeme}", token)
    end
  end

  def parse_array_literal : ArrayLiteral
    items = [] of Expression
    unless peek.type == TokenType::R_BRACK
      items << parse_expression
      while match?(TokenType::COMMA)
        items << parse_expression
      end
    end
    consume(TokenType::R_BRACK, "expected ] to end array literal")
    ArrayLiteral.new(items)
  end

  def parse_map_literal : MapLiteral
    mapping = Hash(Expression, Expression).new
    unless peek.type == TokenType::R_BRACK
      key = parse_expression
      consume(TokenType::ARROW, "expected =>, set literals not supported")
      mapping[key] = parse_expression
      
      while match?(TokenType::COMMA)
        key = parse_expression
        consume(TokenType::ARROW, "expected =>, set literals not supported")
        mapping[key] = parse_expression
      end
    end
    consume(TokenType::R_BRACE, "expected } to end map literal")
    MapLiteral.new(mapping)
  end

  def parse_tuple_literal(first_expression : Expression) : TupleLiteral
    items = [first_expression]
    unless peek.type == TokenType::R_PAREN
      items << parse_expression
      while match?(TokenType::COMMA)
        items << parse_expression
      end
    end
    consume(TokenType::R_PAREN, "expected ')' to end tuple literal")

    return TupleLiteral.new(items)
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
    when TokenType::INT_LITERAL, TokenType::FLOAT_LITERAL, TokenType::STRING_LITERAL,
         TokenType::CHAR_LITERAL, TokenType::TRUE, TokenType::FALSE, TokenType::NIL,
         TokenType::L_BRACK, TokenType::L_BRACE
      parse_literal
    when TokenType::IDENTIFIER
      parse_identifier_expression
    when TokenType::IF
      parse_if_expression
    when TokenType::NOT, TokenType::SUB
      operator = advance
      right = parse_expression(EXPR_PRECEDENCE[:UNARY])
      UnaryExpression.new(operator.type, right)
    when TokenType::L_PAREN
      advance
      expr = parse_expression
      if match?(TokenType::COMMA)
        expr = parse_tuple_literal(expr)
      else
        consume(TokenType::R_PAREN, "expected ')' to match '(' in expression")
        return expr
      end
    else
      raise error("unexpected token in expression #{peek.lexeme}", peek)
    end
  end

  private def parse_identifier_expression : Expression
    variable = parse_variable_identifier
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
  
  private def parse_procedure_call(callee : VariableIdentifier) : ProcedureCall
    arguments = parse_arguments
    return ProcedureCall.new(callee, arguments)
  end

  private def parse_function_call(callee : VariableIdentifier) : FunctionCall
    arguments = parse_arguments
    return FunctionCall.new(callee, arguments)
  end

  private def parse_arguments : Array(Expression)
    arguments = [] of Expression
    if match?(TokenType::L_PAREN)
      unless peek.type == TokenType::R_PAREN
        arguments << parse_expression
        while match?(TokenType::COMMA)
          arguments << parse_expression
        end
      end
      consume(TokenType::R_PAREN, "expected ')' to end args in expression")
    end
    return arguments
  end

  

  private def parse_if_expression : IfExpression
    branches = [] of IfBranch(Expression)

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