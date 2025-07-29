struct Token
  property type : TokenType
  property lexeme : String
  property line : Int32
  property column : Int32
  def initialize(@type, @lexeme, @line, @column)
  end
  def to_s
    "#{@type} '#{@lexeme}' at line #{@line}, column #{@column}"
  end
end

enum TokenType
  IDENTIFIER; EOF
  SEMICOLON; COLON; COMMA; PERIOD; EQ
  LET; VAR; END
  L_PAREN; R_PAREN;
  L_BRACK; R_BRACK;
  L_BRACE; R_BRACE;
  L_CARROT; R_CARROT
  STRUCT; HAS
  INT_LITERAL; FLOAT_LITERAL; STRING_LITERAL; CHAR_LITERAL; NIL; TRUE; FALSE
  AS; #TODO implement 'as'
  ADD; SUB; MUL; DIV; IDIV; MODULUS
  ADD_ASSIGN; SUB_ASSIGN; MUL_ASSIGN; DIV_ASSIGN; IDIV_ASSIGN
  BITWISE_AND; BITWISE_OR; BITWISE_XOR
  BITWISE_AND_ASSIGN; BITWISE_OR_ASSIGN; BITWISE_XOR_ASSIGN
  AND; OR; NOT
  AND_ASSIGN; OR_ASSIGN
  IF; THEN; ELIF; ELSE
  COMP_LT; COMP_GT; COMP_LTEQ; COMP_GTEQ; COMP_NEQ; COMP_EQ
  WHILE; BREAK; RETURN; #TODO add FOR
  FN; PROC; DO; ARROW; FN_APPLY
end

KEYWORDS = {
  %(let)      => TokenType::LET,
  %(var)      => TokenType::VAR,
  %(if)       => TokenType::IF,
  %(else)     => TokenType::ELSE,
  %(elif)     => TokenType::ELIF,
  %(while)    => TokenType::WHILE,
  %(do)       => TokenType::DO,
  %(then)     => TokenType::THEN,
  %(true)     => TokenType::TRUE,
  %(false)    => TokenType::FALSE,
  %(nil)      => TokenType::NIL,
  %(end)      => TokenType::END,
  %(fn)       => TokenType::FN,
  %(proc)     => TokenType::PROC,
  %(break)    => TokenType::BREAK,
  %(return)   => TokenType::RETURN,
  %(struct)   => TokenType::STRUCT,
  %(has)      => TokenType::HAS
}

ASSIGN_OPERATORS = Set {
  TokenType::EQ,
  TokenType::ADD_ASSIGN,
  TokenType::SUB_ASSIGN,
  TokenType::MUL_ASSIGN,
  TokenType::DIV_ASSIGN,
  TokenType::IDIV_ASSIGN,
  TokenType::OR_ASSIGN,
  TokenType::AND_ASSIGN,
  TokenType::BITWISE_OR_ASSIGN,
  TokenType::BITWISE_AND_ASSIGN,
  TokenType::BITWISE_XOR_ASSIGN 
}

DESUGARED_ASSIGN_OPERATORS = {
  TokenType::ADD_ASSIGN         => TokenType::ADD,
  TokenType::SUB_ASSIGN         => TokenType::SUB,
  TokenType::MUL_ASSIGN         => TokenType::MUL,
  TokenType::DIV_ASSIGN         => TokenType::DIV,
  TokenType::IDIV_ASSIGN        => TokenType::IDIV,
  TokenType::BITWISE_OR_ASSIGN  => TokenType::BITWISE_OR,
  TokenType::BITWISE_AND_ASSIGN => TokenType::BITWISE_AND,
  TokenType::BITWISE_XOR_ASSIGN => TokenType::BITWISE_XOR,
  TokenType::AND_ASSIGN         => TokenType::AND,
  TokenType::OR_ASSIGN          => TokenType::OR,
}

EXPR_PRECEDENCE = {
    :UNARY                        => 15,
    TokenType::MUL                => 14,
    TokenType::DIV                => 14,
    TokenType::IDIV               => 14,
    TokenType::MODULUS            => 14,
    TokenType::ADD                => 13,
    TokenType::SUB                => 13,
    TokenType::BITWISE_AND        => 12,
    TokenType::BITWISE_OR         => 11,
    TokenType::BITWISE_XOR        => 11,
    TokenType::COMP_LT            => 10,
    TokenType::COMP_GT            => 10,
    TokenType::COMP_GTEQ          => 10,
    TokenType::COMP_LTEQ          => 10,
    TokenType::COMP_EQ            => 9,
    TokenType::AND                => 8,
    TokenType::OR                 => 7,
    TokenType::EQ                 => 6,
    TokenType::MUL_ASSIGN         => 5,
    TokenType::DIV_ASSIGN         => 5,
    TokenType::IDIV_ASSIGN        => 5,
    TokenType::ADD_ASSIGN         => 4,
    TokenType::SUB_ASSIGN         => 4,
    TokenType::BITWISE_OR_ASSIGN  => 3,
    TokenType::BITWISE_AND_ASSIGN => 2,
    TokenType::AND_ASSIGN         => 1,
    TokenType::OR_ASSIGN          => 0,
    
  }

BINARY_OPERATORS = Set {
  TokenType::ADD, TokenType::SUB,
  TokenType::MUL, TokenType::DIV, TokenType::IDIV, TokenType::MODULUS,
  TokenType::COMP_LT, TokenType::COMP_GT,
  TokenType::COMP_GTEQ, TokenType::COMP_LTEQ,
  TokenType::COMP_EQ,
  TokenType::AND, TokenType::OR, 
  TokenType::EQ
}