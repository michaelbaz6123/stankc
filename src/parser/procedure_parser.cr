module ProcedureParser

  def parse_procedure(*delimiters) : Procedure
    statements = [] of Statement
    until delimiters.includes?(peek.type)
      statement = parse_statement
      statements << statement if statement
    end
    return Procedure.new(statements)
  end

  def parse_statement : Statement?
    return parse_binding       if match?(TokenType::LET)
    return parse_var_declaration    if match?(TokenType::VAR)
    return parse_if_statement  if match?(TokenType::IF)
    return parse_while_loop    if match?(TokenType::WHILE)
    return parse_function_declaration if match?(TokenType::FN)
    return parse_struct_declaration if match?(TokenType::STRUCT)

    # special handle syntactic sugar making 'proc' before main optional
    if match?(TokenType::PROC) || peek.lexeme == "main"
      return parse_procedure_declaration
    end
    
    return Break.new if match?(TokenType::BREAK) && match?(TokenType::SEMICOLON)
    return Return.new if match?(TokenType::RETURN) && match?(TokenType::SEMICOLON)

    return parse_expression_statement
  end



  def parse_expression_statement : ExpressionStatement
    expr = parse_expression
    consume(TokenType::SEMICOLON, "expected ';' after expression statement")
    return ExpressionStatement.new(expr)
  end

  def parse_binding : Statement
    typed_name = parse_typed_name
    consume(TokenType::EQ, "expected '=' after binding name")
    value_expr = parse_expression
    consume(TokenType::SEMICOLON, "expected ';' after binding value")
    return Binding.new(typed_name, value_expr)
  end

  def parse_var_declaration : Statement
    typed_name = parse_typed_name
    value_expr = if match?(TokenType::EQ)
      parse_expression
    else nil end
    consume(TokenType::SEMICOLON, "expected ';' after declaring var")
    return VarDeclaration.new(typed_name, value_expr) 
  end

  def parse_var_reassignment : ExpressionStatement
    variable = parse_variable
    consume(TokenType::EQ, "expected '=' for variable assignment")
    value_expr = parse_expression
    consume(TokenType::SEMICOLON, "expected ';' after assigning value")
    return ExpressionStatement.new(
      VarReassignment.new(variable, value_expr)
    )
  end

  def parse_if_statement : IfStatement
    branches = [] of IfBranch

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
    else nil end
    consume(TokenType::END, "expected 'end' to end if statement")

    return IfStatement.new(branches, else_body)
  end

  def parse_while_loop
    condition = parse_expression
    consume(TokenType::DO, "expected 'do' after condition")
    body = parse_procedure(TokenType::END)
    consume(TokenType::END, "expected 'end' to end while loop")
    return WhileLoop.new(condition, body)
  end

  def parse_function_declaration : FunctionDeclaration
    name = parse_name
    consume(TokenType::FN_APPLY, "expected '$' after function name")

    args = [] of TypedName

    if match?(TokenType::L_PAREN)
      unless peek.type == TokenType::R_PAREN
        args << parse_typed_name
        while match?(TokenType::COMMA)
          args << parse_typed_name
        end
      end
      consume(TokenType::R_PAREN, "expected ')' to end fuction args list")
    end

    consume(TokenType::COLON, "expected ':' followed by type annotation")
    typed_name = TypedName.new(name, parse_type)

    consume(TokenType::ARROW, "expected => before function declaration body")
    body = parse_expression
    consume(TokenType::END, "expected 'end' to terminate function declaration body")
    return FunctionDeclaration.new(typed_name, args, body)
  end

  def parse_typed_name : TypedName
    name = parse_name
    consume(TokenType::COLON, "expected ':' followed by type annotation")
    type = parse_type
    TypedName.new(name, type)
  end

  def parse_name : Name
    Name.new(consume(TokenType::IDENTIFIER, "expected identifier name").lexeme)
  end

  def parse_procedure_declaration : ProcedureDeclaration
    name = parse_name
    consume(TokenType::L_PAREN, "expected '(' after procedure name")
    args = [] of TypedName
    unless peek.type == TokenType::R_PAREN
      args << parse_typed_name
      while match?(TokenType::COMMA)
        args << parse_typed_name
      end
    end
    consume(TokenType::R_PAREN, "expected ')' after procedure args list")

    consume(TokenType::DO, "expected 'do' after before procedure declaration body")
    body = parse_procedure(TokenType::END)
    consume(TokenType::END, "expected 'end' to terminate function declaration body")
    return ProcedureDeclaration.new(name, args, body)
  end

  def parse_struct_declaration : StructDeclaration
    name = parse_name
    consume(TokenType::HAS, "expected 'has' before struct fields")

    struct_fields = [] of TypedName

    struct_fields << parse_typed_name
    while match?(TokenType::COMMA)
      struct_fields << parse_typed_name
    end
    consume(TokenType::END, "expected 'end' to terminate struct declaration")
    return StructDeclaration.new(name, struct_fields)
  end
end