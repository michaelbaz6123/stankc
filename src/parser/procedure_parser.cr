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
    return parse_assignment    if match?(TokenType::VAR)
    return parse_if_statement  if match?(TokenType::IF)
    return parse_while_loop    if match?(TokenType::WHILE)
    return parse_function_declaration if match?(TokenType::FN)
    return parse_procedure_declaration if match?(TokenType::PROC)
    return parse_struct_declaration if match?(TokenType::STRUCT)
    
    return Break.new if match?(TokenType::BREAK) && match?(TokenType::SEMICOLON)
    return Return.new if match?(TokenType::RETURN) && match?(TokenType::SEMICOLON)

    return parse_expression_statement
  end



  def parse_expression_statement : ExpressionStatement
    expr = parse_expression
    consume(TokenType::SEMICOLON, "Expected ';' after expression statement")
    return ExpressionStatement.new(expr)
  end

  def parse_binding : Statement
    typed_name = parse_typed_name
    consume(TokenType::EQ, "Expect '=' after binding name")
    value_expr = parse_expression
    consume(TokenType::SEMICOLON, "Expect ';' after binding value")
    return Binding.new(typed_name, value_expr)
  end

  def parse_assignment : Statement
    typed_name = parse_typed_name
    consume(TokenType::EQ, "Expect '=' after binding name")
    value_expr = parse_expression
    consume(TokenType::SEMICOLON, "Expect ';' after assigning value")
    return Assignment.new(typed_name, value_expr) 
  end

  def parse_reassignment : ExpressionStatement
    variable = parse_variable
    consume(TokenType::EQ, "Expect '=' for variable assignment")
    value_expr = parse_expression
    consume(TokenType::SEMICOLON, "Expect ';' after assigning value")
    return ExpressionStatement.new(
      Reassignment.new(variable, value_expr)
    )
  end

  def parse_if_statement : IfStatement
    branches = [] of IfBranch

    condition = parse_expression
    consume(TokenType::DO, "Expect 'do' after condition")
    body = parse_procedure(TokenType::ELSE, TokenType::ELIF, TokenType::END)
    branches << IfBranch.new(condition, body)

    while peek.type == TokenType::ELIF
      consume(TokenType::ELIF)
      condition = parse_expression
      consume(TokenType::DO, "Expect 'do' after condition")
      body = parse_procedure(TokenType::ELSE, TokenType::ELIF, TokenType::END)
      branches << IfBranch.new(condition, body)
    end

    else_body = if peek.type == TokenType::ELSE
      consume(TokenType::ELSE)
      consume(TokenType::DO) if peek.type == TokenType::DO
      parse_procedure(TokenType::END)
    else nil end
    consume(TokenType::END, "Expect 'end' to terminate if statement")

    return IfStatement.new(branches, else_body)
  end

  def parse_while_loop
    condition = parse_expression
    consume(TokenType::DO, "Expect 'do' after condition")
    body = parse_procedure(TokenType::END)
    consume(TokenType::END, "Expect 'end' to terminate while loop")
    return WhileLoop.new(condition, body)
  end

  def parse_function_declaration : FunctionDeclaration
    name = parse_name
    consume(TokenType::FN_APPLY, "Expect '$' after function name")

    args = [] of TypedName

    if match?(TokenType::L_PAREN)
      unless peek.type == TokenType::R_PAREN
        args << parse_typed_name
        while match?(TokenType::COMMA)
          args << parse_typed_name
        end
      end
      consume(TokenType::R_PAREN)
    end

    typed_name = TypedName.new(name, parse_type_annotation)

    consume(TokenType::ARROW, "Expect => after before function declaration body")
    body = parse_expression
    consume(TokenType::END, "Expect 'end' to terminate function declaration body")
    return FunctionDeclaration.new(typed_name, args, body)
  end

  def parse_typed_name : TypedName
    TypedName.new(parse_name, parse_type_annotation)
  end

  def parse_name : Name
    Name.new(consume(TokenType::IDENTIFIER, "Expect identifier").lexeme)
  end

  def parse_type_annotation : Type
    consume(TokenType::COLON, "Expect type annotation")
    return Type.new(
      consume(TokenType::IDENTIFIER, "Expect type annotation").lexeme
    )
  end

  def parse_procedure_declaration : ProcedureDeclaration
    name = parse_name
    consume(TokenType::L_PAREN)
    args = [] of TypedName
    unless peek.type == TokenType::R_PAREN
      args << parse_typed_name
      while match?(TokenType::COMMA)
        args << parse_typed_name
      end
    end
    consume(TokenType::R_PAREN)

    consume(TokenType::DO, "Expect 'do' after before procedure declaration body")
    body = parse_procedure(TokenType::END)
    consume(TokenType::END, "Expect 'end' to terminate function declaration body")
    return ProcedureDeclaration.new(name, args, body)
  end

  def parse_struct_declaration : StructDeclaration
    name = parse_name
    consume(TokenType::HAS, "Expect 'has' before struct fields")

    struct_fields = [] of TypedName

    struct_fields << parse_typed_name
    while match?(TokenType::COMMA)
      struct_fields << parse_typed_name
    end
    consume(TokenType::END, "Expect 'end' to terminate struct declaration")
    return StructDeclaration.new(name, struct_fields)
  end
end