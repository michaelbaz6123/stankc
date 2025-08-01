module LiteralParser
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
end