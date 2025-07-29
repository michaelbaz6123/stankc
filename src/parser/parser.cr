require "./expression_parser"
require "./procedure_parser"
require "./token"
require "./ast/ast"
require "./parse_error"

class Parser
  include ExpressionParser
  include ProcedureParser
  # TODO this getter is here for peeking at tokens from lexer output / debugging
  getter tokens : Array(Token)

  def initialize(source : String)
    @tokens = Lexer.new(source).lex
    @current = 0
  end

  def parse : AST | Exception
    AST.new(parse_procedure(TokenType::EOF))
  end

  def parse_variable : Variable
    names = [] of Name
    names << Name.new(advance.lexeme) 
    while match?(TokenType::PERIOD)
      names << Name.new(advance.lexeme)
    end
    return Variable.new(names)
  end

  def match?(type : TokenType) : Token?
    advance unless eof? || peek.type != type
  end

  def consume(type : TokenType, message : String) : Token
    if peek.type == type
      return advance
    else
      bad_token = peek
      raise error("unexpected #{bad_token.lexeme}, #{message}", bad_token)
    end
  end

  def advance : Token
    token = @tokens[@current]
    @current += 1
    token
  end

  def peek : Token
    @tokens[@current]
  end

  def double_peek : Token
    return @tokens[@current+1] unless eof?
    @tokens[@current] # fallback to EOF if already at end 
  end

  def eof?
    peek.type == TokenType::EOF
  end

  def error(message, bad_token : Token) : ParseError
    ParseError.new(message, bad_token.line, bad_token.column)
  end
end
