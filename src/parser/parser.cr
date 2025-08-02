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
    token = consume(TokenType::IDENTIFIER, "expected identifier")
    first_name = token.lexeme
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

    return VariableIdentifier.new(name, module_names, accessor_names, location(token))
  end

  def parse_type_identifier : TypeIdentifier
    inner_types = [] of TypeIdentifier
    token = consume(TokenType::IDENTIFIER, "expected type identifier")
    name = token.lexeme
    if match?(TokenType::L_PAREN)
      inner_types << parse_type_identifier
      while match?(TokenType::COMMA)
        inner_types << parse_type_identifier
      end
      consume(TokenType::R_PAREN, "expected ')' to end type args")
    end
    if match?(TokenType::QUESTION)
      inner_types = [TypeIdentifier.new(name, inner_types, location(token))]
      name = "Maybe"
    end
    return TypeIdentifier.new(name, inner_types, location(token))
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

  private def location(token : Token) : SourceLocation
    SourceLocation.new(token.line, token.column)
  end

  private def peek : Token
    @tokens[@current]
  end

  private def eof?
    peek.type == TokenType::EOF
  end

  # wrapper for passing line and column info on from token to node
  private def new_node(node : Node, token : Token) : Node
    node.line = token.line
    node.column = token.column
    return node
  end

  private def error(message, bad_token : Token) : ParseError
    ParseError.new("#{bad_token.line}:#{bad_token.column} : unexpected #{bad_token.lexeme}, #{message}", bad_token.line, bad_token.column)
  end
end
