module PatternParser

  private def parse_if_let_statement : IfLetStatement
    pattern = parse_pattern
    consume(TokenType::EQ, "expected `=` to pattern match in `if let`")
    scrutinee = parse_expression
    consume(TokenType::DO, "expected `do` in before `if let` body")
    body = parse_procedure(TokenType::ELSE, TokenType::END)
    else_body = if match?(TokenType::ELSE)
      parse_procedure(TokenType::END)
    end
    consume(TokenType::END, "expected `end` to end `if let` statement")
    
    return IfLetStatement.new(pattern, scrutinee, body, else_body)
  end

  private def parse_match_expression : MatchExpression
    consume(TokenType::MATCH, "expected `match` to begin match expression")
    scrutinee = parse_expression 
    consume(TokenType::THEN, "expected `then` before branches in match expression")
    branches = [] of MatchBranch
    branches << parse_match_branch
    while match?(TokenType::COMMA)
      branches << parse_match_branch
    end
    consume(TokenType::END, "expected `end` to end `match` expression")
    return MatchExpression.new(scrutinee, branches)
  end

  private def parse_match_branch : MatchBranch
    pattern = parse_pattern
    consume(TokenType::ARROW, "expected `=>` after pattern match")
    body = parse_expression
    return MatchBranch.new(pattern, body)
  end

  private def parse_pattern : Pattern
    if match?(TokenType::UNDERSCORE)
      WildCardPattern.new
    else
      name = peek.lexeme
      if name[0].ascii_uppercase? # type variant like (value = Nil)
        parse_variant_pattern
      else # binding like (value = x)
        BindingPattern.new(consume(TokenType::IDENTIFIER, "expected identifier for variant constructor or binding").lexeme)
      end
    end
  end

  private def parse_variant_pattern : VariantPattern
    variant_name = consume(TokenType::IDENTIFIER, "expected type variant name in if let pattern match").lexeme
    field_patterns = parse_field_patterns
    return VariantPattern.new(variant_name, field_patterns)
  end

  private def parse_field_patterns : Array(NamedFieldPattern)
    field_patterns = [] of NamedFieldPattern
    if match?(TokenType::L_PAREN)
      field_patterns << parse_field_pattern
      while match?(TokenType::COMMA)
        field_patterns << parse_field_pattern
      end
      consume(TokenType::R_PAREN, "expected `)` to end field patterns")
    end
    return field_patterns
  end

  private def parse_field_pattern : NamedFieldPattern
    field_name = consume(TokenType::IDENTIFIER, "expected field name in pattern match").lexeme
    consume(TokenType::EQ, "Expected `=` after field name in pattern match")
    pattern = parse_pattern
    NamedFieldPattern.new(field_name, pattern)
  end

end