require "./literal_parser"
require "./pattern_parser"
module ExpressionParser
  include LiteralParser
  include PatternParser

  private def parse_expression(precedence = 0) : Expression
    left = parse_prefix

    until eof?
      # Procedure call
      if peek.type == TokenType::L_PAREN
        variable = left.as(VariableExpression).variable
        left = parse_procedure_call(variable, variable.source_location)
      end
      # Function call
      if match?(TokenType::FN_APPLY)
        variable = left.as(VariableExpression).variable
        left = parse_function_call(variable, variable.source_location)
      end

      break unless binary_operator?(peek) || assign_operator?(peek)
      break if precedence > precedence_of(peek.type)

      operator = advance
      right = parse_expression(precedence_of(operator.type))
      left = parse_binary_expression(left, operator, right)
    end

    return left
  end

  private def parse_binary_expression(left : Expression, operator : Token, right : Expression) : Expression
    if assign_operator?(operator)
      var_expr = left.as(VariableExpression)
      var = var_expr.variable
      if operator.type == TokenType::EQ
        return VarReassignment.new(var, right, var.source_location)
      else
        binary_op_type = desugar_assign_operator(operator.type)
        binary_expr = BinaryExpression.new(var_expr, binary_op_type, right, var.source_location)
        return VarReassignment.new(var, binary_expr, var.source_location)
      end
    else
      return BinaryExpression.new(left, operator.type, right, left.source_location)
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
    when TokenType::MATCH
      parse_match_expression
    when TokenType::NOT, TokenType::SUB
      operator = advance
      right = parse_expression(EXPR_PRECEDENCE[:UNARY])
      UnaryExpression.new(operator.type, right, location(operator))
    when TokenType::L_PAREN
      l_paren_token = advance
      expr = parse_expression
      if match?(TokenType::COMMA)
        expr = parse_tuple_literal(expr, location(l_paren_token))
      else
        consume(TokenType::R_PAREN, "expected ')' to match '(' in expression")
        return expr
      end
    else
      raise error("invalid token in expression", peek)
    end
  end

  private def parse_identifier_expression : Expression
    variable = parse_variable_identifier
    if peek.type == TokenType::L_PAREN
      return parse_procedure_call(variable, variable.source_location)
    elsif match?(TokenType::FN_APPLY)
      return parse_function_call(variable, variable.source_location) 
    else
      return VariableExpression.new(variable, variable.source_location)
    end
  end
  
  private def desugar_assign_operator(type : TokenType) : TokenType
    token_type = DESUGARED_ASSIGN_OPERATORS[type]?
    return token_type if token_type
    return TokenType::EOF # fallback so we have some tokentype to return, should never happen
  end
  
  private def parse_procedure_call(callee : VariableIdentifier, location : SourceLocation) : ProcedureCall
    arguments = parse_arguments
    return ProcedureCall.new(callee, arguments, location)
  end

  private def parse_function_call(callee : VariableIdentifier, location : SourceLocation) : FunctionCall
    arguments = parse_arguments
    return FunctionCall.new(callee, arguments, location)
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

    if_token = consume(TokenType::IF, "expected 'if' to start if expression")
    condition = parse_expression
    then_token = consume(TokenType::THEN, "expected 'then' after if condition")
    body = parse_expression
    branches << IfBranch.new(condition, body, location(then_token))

    while peek.type == TokenType::ELIF
      advance # TokenType::ELIF
      condition = parse_expression
      then_token = consume(TokenType::THEN, "expected 'then' after elif condition")
      body = parse_expression
      branches << IfBranch.new(condition, body, location(then_token))
    end

    else_body = if peek.type == TokenType::ELSE
      advance # TokenType::ELSE
      parse_expression
    else nil end

    consume(TokenType::END, "expected 'end' to end if expression")
    
    return IfExpression.new(branches, else_body, location(if_token))
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