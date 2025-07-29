require "./expression_parser"
require "./procedure_parser"
require "./token"
require "./ast/ast"

class Parser
  include ExpressionParser
  include ProcedureParser

  def initialize(@tokens : Array(Token))
    @current = 0
  end

  def parse : AST
    AST.new(parse_procedure(TokenType::EOF))
  end

  def parse_variable : Variable
    names = [] of Name
    names << Name.new(consume(TokenType::IDENTIFIER).lexeme)
    while match?(TokenType::PERIOD)
      names << Name.new(consume(TokenType::IDENTIFIER).lexeme)
    end
    return Variable.new(names)
  end

  def match?(type : TokenType) : Token?
    if !eof? && peek.type == type
      return consume(type)
    end
    return nil
  end

  def consume(type : TokenType, message = "INTERNAL_ERR") : Token
    if peek.type == type
      return advance
    else
      bad_token = peek
      raise "Parse error: #{bad_token.to_s}, #{message}"
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
end
