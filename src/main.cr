require "./parser/parser"
require "./parser/lexer"
require "./type_checker/type_checker"

source_file = File.new("./source.stank")
source = source_file.gets_to_end
source_file.close


puts "___________ Parser AST Output _____________"

begin
  parser = Parser.new(source)
  ast = parser.parse
  pp ast
  TypeChecker.new.check(ast)
rescue parse_error : ParseError
  puts parse_error.to_s
  parse_error.put_backtrace
end