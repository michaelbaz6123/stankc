require "./spec_helper"
describe LiteralParser do
  describe "#parse" do
    it "parses Int literal" do
      ast = parse("5;")

      ast.procedure.statements.first
        .as(ExpressionStatement).expression
        .should be_a IntLiteral
    end

    it "parses Float literal" do
      ast = parse("3.14;")

      ast.procedure.statements.first
        .as(ExpressionStatement).expression
        .should be_a FloatLiteral
    end

    it "parses Char literal" do
      ast = parse("'c';")

      ast.procedure.statements.first
        .as(ExpressionStatement).expression
        .should be_a CharLiteral
    end

    it "parses String literal" do
      ast = parse("\"hello\";")

      ast.procedure.statements.first
        .as(ExpressionStatement).expression
        .should be_a StringLiteral
    end

    it "parses Nil literal" do
      ast = parse("nil;")

      ast.procedure.statements.first
        .as(ExpressionStatement).expression
        .should be_a NilLiteral
    end

    it "parses Bool literal" do
      ast = parse("true; false;")

      ast.procedure.statements.first
        .as(ExpressionStatement).expression
        .should be_a BoolLiteral
    end

    it "parses Array literal" do
      ast = parse("[1, 2, 3];")

      ast.procedure.statements.first
        .as(ExpressionStatement).expression
        .should be_a ArrayLiteral
    end

    it "parses Map literal" do 
      ast = parse("{'a' => 0, 'b' => 1, 'c' => 2};")

      ast.procedure.statements.first
        .as(ExpressionStatement).expression
        .should be_a MapLiteral
    end

    it "parses Tuple literal" do
      ast = parse("(1, 2, 3, 4, 5);")

      ast.procedure.statements.first
        .as(ExpressionStatement).expression
        .should be_a TupleLiteral
    end
  end
end