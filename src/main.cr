require "./parser/parser"
require "./parser/lexer"
require "./type_checker/type_checker"

source_file = File.new("./source.stank")
source = source_file.gets_to_end
source_file.close

puts "___________ Lexer Token Output _____________"
lexer = Lexer.new(source)
tokens = lexer.lex
pp tokens
puts

puts "___________ Parser AST Output _____________"
parser = Parser.new(tokens)
ast = parser.parse
pp ast
# => VariableDeclaration @name="x" @value=5
