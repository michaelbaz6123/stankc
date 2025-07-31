module ProcedureParser

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
    return parse_if_statement  if match?(TokenType::IF)
    return parse_while_loop    if match?(TokenType::WHILE)
    return parse_function_declaration if match?(TokenType::FN)
    return parse_type_declaration if match?(TokenType::TYPE)
    return parse_module_declaration if match?(TokenType::MODULE)

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

  private def parse_binding : Statement 
    name = consume(TokenType::IDENTIFIER, "expected binding identifier name").lexeme
    type_identifier = if match?(TokenType::COLON)
      parse_type_identifier
    else nil end
    consume(TokenType::EQ, "expected '=' after binding name")
    value_expr = parse_expression
    consume(TokenType::SEMICOLON, "expected ';' after binding value")
    return Binding.new(name, value_expr, type_identifier)
  end

  private def parse_var_declaration : Statement # TODO
    name = consume(TokenType::IDENTIFIER, "expected variable identifier name").lexeme
    
    type_identifier = if match?(TokenType::COLON)
      parse_type_identifier
    else nil end

    value_expr = if match?(TokenType::EQ)
      parse_expression
    else nil end
    consume(TokenType::SEMICOLON, "expected ';' after declaring var")
    return VarDeclaration.new(name, value_expr) 
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
    else nil end
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

  private def parse_function_declaration : FunctionDeclaration
    name = consume(TokenType::IDENTIFIER, "expected function name for declaration").lexeme
    generics = parse_generics
    consume(TokenType::FN_APPLY, "expected '$' after function name")
    parameters = parse_parameters

    return_type_identifier = if match?(TokenType::COLON)
      parse_type_identifier
    else nil end

    consume(TokenType::ARROW, "expected => before function declaration body")
    body = parse_expression
    consume(TokenType::END, "expected 'end' to terminate function declaration body")
    return FunctionDeclaration.new(name, parameters, generics, body, return_type_identifier)
  end

  private def parse_parameters : Array(Parameter)
    parameters = [] of Parameter
    if match?(TokenType::L_PAREN)
      unless peek.type == TokenType::R_PAREN
        parameters << parse_parameter
        while match?(TokenType::COMMA)
          parameters << parse_parameter
        end
      end
      consume(TokenType::R_PAREN, "expected ')' to end fuction args list")
    end
    return parameters
  end

  private def parse_parameter : Parameter
    name = consume(TokenType::IDENTIFIER, "expected parameter identifier name").lexeme
    consume(TokenType::COLON, "expected ':' followed by type annotation")
    type_identifier = parse_type_identifier
    Parameter.new(name, type_identifier)
  end

  private def parse_procedure_declaration : ProcedureDeclaration
    name = consume(TokenType::IDENTIFIER, "expected procedure name identifier").lexeme
    generics = parse_generics
    parameters = parse_parameters

    consume(TokenType::DO, "expected 'do' after before procedure declaration body")
    body = parse_procedure(TokenType::END)
    consume(TokenType::END, "expected 'end' to terminate function declaration body")
    return ProcedureDeclaration.new(name, parameters, generics, body)
  end

  private def parse_type_declaration : Declaration
    name = consume(TokenType::IDENTIFIER, "expected type identifier name for type declaration").lexeme
    pp 1, peek
    generics = parse_generics
    pp 3, peek
    return ProductTypeDeclaration.new(name, generics, parse_fields) if match?(TokenType::HAS)
    return UnionTypeDeclaration.new(name, generics, parse_variants) if match?(TokenType::IS)
    raise error("expected `has` or `is` after type declaration name", peek)
  end

  private def parse_generics : Array(String)
    generics = [] of String
    pp 2, peek
    if match?(TokenType::COMP_LT)
      generics << consume(TokenType::IDENTIFIER, "expected generic type identifier").lexeme
      while match?(TokenType::COMMA)
        generics << consume(TokenType::IDENTIFIER, "expected generic type identifier").lexeme
      end
      consume(TokenType::COMP_GT, "expected '>' to end generic list")
    end
    return generics
  end

  private def parse_fields
    fields = [] of Field

    fields << parse_field
    while match?(TokenType::COMMA)
      fields << parse_field
    end
    consume(TokenType::END, "expected 'end' to terminate product type declaration")
    return fields
  end

  private def parse_field : Field
    name = consume(TokenType::IDENTIFIER, "expected field name identifier").lexeme
    consume(TokenType::COLON, "expected : for field type annotation")
    type_identifier = parse_type_identifier
    return Field.new(name, type_identifier)
  end

  private def parse_variants : Array(TypeIdentifier)
    variants = [] of TypeIdentifier
    
    variants << parse_type_identifier
    while match?(TokenType::BAR)
      variants << parse_type_identifier
    end
    consume(TokenType::END, "expected `end` to terminate union type declaration")
    return variants
  end

  private def parse_module_declaration : ModuleDeclaration
    name = consume(TokenType::IDENTIFIER, "expected module name identifier").lexeme
    consume(TokenType::HAS, "expected `has` after module name")
    procedure = parse_procedure(TokenType::END)
    consume(TokenType::END, "expected `end` to end module declaration")
    return ModuleDeclaration.new(name, procedure)
  end
end