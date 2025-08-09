require "./parser/parser"
require "./parser/lexer"
require "./type_checker/type_checker"

source_path = "./source.stank"
source_file = File.new(source_path)
source = source_file.gets_to_end
source_file.close




begin
  parser = Parser.new(source)
  # pp parser.tokens
  ast = parser.parse
  puts "___________ Parser AST Output _____________"
  pp ast


  TypeChecker.new.check(ast)
  puts
  puts " ____ After Type Checker ____"
  pp ast
rescue parse_error : ParseError
  puts "#{source_path}:#{parse_error.message}"
  parse_error.put_backtrace
rescue type_error : TypeError
  puts type_error.to_s
  type_error.put_backtrace
end