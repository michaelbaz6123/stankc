require "./declaration_parser"
require "./pattern_parser"
module ProcedureParser
  include DeclarationParser
  include PatternParser

  private def parse_procedure(*delimiters) : Procedure
    statements = [] of Statement
    until delimiters.includes?(peek.type)
      statement = parse_statement
      statements << statement if statement
    end
    return Procedure.new(statements)
  end

  private def parse_statement : Statement?
    return parse_binding       if match?(TokenType::LET)
    return parse_var_declaration    if match?(TokenType::VAR)
    return parse_while_loop    if match?(TokenType::WHILE)
    return parse_function_declaration if match?(TokenType::FN)
    return parse_type_declaration if match?(TokenType::TYPE)
    return parse_module_declaration if match?(TokenType::MODULE)

    if match?(TokenType::IF)
      if match?(TokenType::LET)
        return parse_if_let_statement
      else
        return parse_if_statement
      end
    end
    
    # special handle syntactic sugar making 'proc' before main optional
    if match?(TokenType::PROC) || peek.lexeme == "main"
      return parse_procedure_declaration
    end
    
    return Break.new if match?(TokenType::BREAK) && match?(TokenType::SEMICOLON)
    return Return.new if match?(TokenType::RETURN) && match?(TokenType::SEMICOLON)

    return parse_expression_statement
  end

  private def parse_expression_statement : ExpressionStatement
    expr = parse_expression
    consume(TokenType::SEMICOLON, "expected ';' after expression statement")
    return ExpressionStatement.new(expr)
  end

  private def parse_var_reassignment : ExpressionStatement
    variable = parse_variable
    consume(TokenType::EQ, "expected '=' for variable assignment")
    value_expr = parse_expression
    consume(TokenType::SEMICOLON, "expected ';' after assigning value")
    return ExpressionStatement.new(
      VarReassignment.new(variable, value_expr)
    )
  end

  private def parse_if_statement : IfStatement
    branches = [] of IfBranch(Procedure)

    condition = parse_expression
    consume(TokenType::DO, "expected 'do' after if condition")
    body = parse_procedure(TokenType::ELSE, TokenType::ELIF, TokenType::END)
    branches << IfBranch.new(condition, body)

    while peek.type == TokenType::ELIF
      advance # TokenType::ELIF
      condition = parse_expression
      consume(TokenType::DO, "expected 'do' after elif condition")
      body = parse_procedure(TokenType::ELSE, TokenType::ELIF, TokenType::END)
      branches << IfBranch.new(condition, body)
    end

    else_body = if peek.type == TokenType::ELSE
      advance # TokenType::ELSE
      parse_procedure(TokenType::END)
    end
    consume(TokenType::END, "expected 'end' to end if statement")

    return IfStatement.new(branches, else_body)
  end

  private def parse_while_loop
    condition = parse_expression
    consume(TokenType::DO, "expected 'do' after condition")
    body = parse_procedure(TokenType::END)
    consume(TokenType::END, "expected 'end' to end while loop")
    return WhileLoop.new(condition, body)
  end
  
end