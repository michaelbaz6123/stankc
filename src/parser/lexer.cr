require "./token"

class Lexer
  
  def initialize(@source : String)
    @current = 0 # index
    @line = 1
    @column = 1
  end

  def lex : Array(Token)
    tokens = [] of Token
    while true
      pass_whitespace
      break if eof?
      tokens << single_lex(advance)
    end

    tokens << new_token(TokenType::EOF, "")
    return tokens
  end

  def single_lex(c : Char) : Token
    case c
    when '='
      if match?('=') 
        new_token(TokenType::COMP_EQ, "==")
      elsif match?('>')
        new_token(TokenType::ARROW, "=>")
      else
        new_token(TokenType::EQ, "=")
      end
    when '!'
      if match?('=')
        new_token(TokenType::COMP_NEQ, "!=")
      else
        new_token(TokenType::NOT, "!")
      end
    when '$'
      new_token(TokenType::FN_APPLY, "$")
    when '.'
      new_token(TokenType::PERIOD, ".")
    when '<'
      if match?('=')
        new_token(TokenType::COMP_LTEQ, "<=")
      else
        new_token(TokenType::COMP_LT, "<")
      end
    when '>'
      if match?('=')
        new_token(TokenType::COMP_GTEQ, ">=")
      else
        new_token(TokenType::COMP_GT, ">")
      end
    when '+'
      if match?('=')
        new_token(TokenType::ADD_ASSIGN, "+=")
      else
        new_token(TokenType::ADD, "+")
      end
    when '-'
      if match?('=')
        new_token(TokenType::SUB_ASSIGN, "-=")
      else  
        new_token(TokenType::SUB, "-")
      end
    when '*'
      if match?('=')
        new_token(TokenType::MUL_ASSIGN, "*=")
      else
        new_token(TokenType::MUL, "*")
      end
    when '/'
      if match?('/')
        if match?('=')
          new_token(TokenType::IDIV_ASSIGN, "//=")
        else
          new_token(TokenType::IDIV, "//")
        end
      else
        if match?('=')
          new_token(TokenType::DIV_ASSIGN, "/=")
        else
          new_token(TokenType::DIV, "/")
        end
      end
    when '&'
      if match?('&')
        if match?('=')
          new_token(TokenType::AND_ASSIGN, "&&=")
        else
          new_token(TokenType::AND, "&&")
        end
      else
        if match?('=')
          new_token(TokenType::BITWISE_AND_ASSIGN, "&=")
        else
          new_token(TokenType::BITWISE_AND, "&")
        end
      end
    when '|'
      if match?('|')
        if match?('=')
          new_token(TokenType::OR_ASSIGN, "||=")
        else
          new_token(TokenType::OR, "||")
        end
      else
        if match?('=')
          new_token(TokenType::BITWISE_OR_ASSIGN, "|=")
        else
          new_token(TokenType::BITWISE_OR, "|")
        end
      end
    when '^'
      if match?('=')
        new_token(TokenType::BITWISE_XOR_ASSIGN, "^=")
      else
        new_token(TokenType::BITWISE_XOR, "^")
      end
    when '('
      new_token(TokenType::L_PAREN, "(")
    when ')'
      new_token(TokenType::R_PAREN, ")")
    when ','
      new_token(TokenType::COMMA, ",")
    when '%'
      new_token(TokenType::MODULUS, "%")
    when ':'
      new_token(TokenType::COLON, ":")
    when ';'
      new_token(TokenType::SEMICOLON, ";")
    when '0'..'9'
      number_token(c) 
    when 'a'..'z', 'A'..'Z', '_'
      identifier_token(c)
    when '"'
      string_token
    when '\''
      char_token
    else
      raise "Unknown character #{c}"
    end
  end

  def new_token(type : TokenType, lexeme : String) : Token
    Token.new(type, lexeme, @line, @column - lexeme.size)
  end

  def advance : Char
    c = @source[@current]
    @current += 1
    if c == '\n' @line += 1; @column = 1
    else @column += 1 end
    return c
  end

  # Int or Float literal
  def number_token(first_char : Char) : Token 
    start = @current - 1
    while !eof? && (peek.number? || peek == '.')
      advance
    end
    lexeme = @source[start...@current]
    type = if lexeme.includes?('.') TokenType::FLOAT_LITERAL else TokenType::INT_LITERAL end
    return new_token(type, lexeme)
  end

  # keyword or identifier/operator token
  def identifier_token(first_char : Char) : Token
    start = @current - 1
    while !eof? && (peek.alphanumeric? || peek == '_')
      advance
    end
    lexeme = @source[start...@current]
    type = KEYWORDS[lexeme]? || TokenType::IDENTIFIER
    return new_token(type, lexeme)
  end

  def char_token : Token
    ch = peek
    advance
    if peek != '\''
      raise "character literal cannot have more than one character"
    end
    advance
    return new_token(TokenType::CHAR_LITERAL, "#{ch}")
  end

  def string_token : Token
    start = @current
    start_ln, start_col = @line, @column
    until eof? || peek == '"'
      advance
    end
    raise "Unterminated string literal in program starting at #{start_ln}:#{start_col}" if eof?
    lexeme = @source[start...@current]
    advance
    return new_token(TokenType::STRING_LITERAL, lexeme)
  end

  # tries to match expected and consumes if so
  def match?(expected : Char) : Bool
    return !eof? && @source[@current] == expected && (@current += 1).nil?
  end

  def peek : Char
    @source[@current]
  end

  def pass_whitespace
    while !eof? && [' ', '\t', '\n', '\r'].includes?(peek)
      advance
    end
  end

  def eof?
    @current >= @source.size
  end
end

