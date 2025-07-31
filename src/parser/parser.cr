require "./expression_parser"
require "./procedure_parser"
require "./token"
require "../ast/ast"
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

  private def parse_variable_identifier : VariableIdentifier 
    first_name = advance.lexeme
    module_names = [] of String
    accessor_names = [] of String
    name = first_name

    if peek.type == TokenType::DOUBLE_COLON # if we have module names to parse...
      module_names << first_name
      while match?(TokenType::DOUBLE_COLON)
        next_name = consume(TokenType::IDENTIFIER, "expect identifier").lexeme
        if peek.type == TokenType::DOUBLE_COLON
          module_names << next_name
        else
          name = next_name # last id after :: is the identifier name
        end
      end
    end

    while match?(TokenType::PERIOD)
      accessor_names << consume(TokenType::IDENTIFIER, "expect identifier for accessor name").lexeme
    end

    return VariableIdentifier.new(name, module_names, accessor_names)
  end

  def parse_type_identifier : TypeIdentifier
    inner_types = [] of TypeIdentifier
    name = consume(TokenType::IDENTIFIER, "expected type identifier").lexeme
    if match?(TokenType::L_PAREN)
      inner_types << parse_type_identifier
      while match?(TokenType::COMMA)
        inner_types << parse_type_identifier
      end
      consume(TokenType::R_PAREN, "expected ')' to end type args")
    end
    if match?(TokenType::QUESTION)
      inner_types = [TypeIdentifier.new(name, inner_types)]
      name = "Maybe"
    end
    return TypeIdentifier.new(name, inner_types)
  end

  private def match?(type : TokenType) : Token?
    advance unless eof? || peek.type != type
  end

  private def consume(type : TokenType, message : String) : Token
    if peek.type == type
      return advance
    else
      bad_token = peek
      raise error(message, bad_token)
    end
  end

  private def advance : Token
    token = @tokens[@current]
    @current += 1
    token
  end

  private def peek : Token
    @tokens[@current]
  end

  private def eof?
    peek.type == TokenType::EOF
  end

  private def error(message, bad_token : Token) : ParseError
    ParseError.new("unexpected #{bad_token.lexeme}, #{message}", bad_token.line, bad_token.column)
  end
end
