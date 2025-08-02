require "./spec_helper"
describe ProcedureParser do
  describe "#parse" do

    it "parses a procedure" do
      ast = parse("")
      ast.procedure.should be_a(Procedure)
    end

    it "parses expression statement" do
      ast = parse("nil;")
      ast.procedure.statements.first
        .should be_a(ExpressionStatement)
    end
    
    it "parses while loop" do
      ast = parse("while true do something; end");
      ast.procedure.statements.first
        .as(WhileLoop).body
        .should be_a(Procedure)
    end

    it "parses variable reassignment" do
      ast = parse("x = 10;");
      ast.procedure.statements.first
        .as(ExpressionStatement).expression
        .should be_a(VarReassignment)
    end

    it "parses if statement" do
      ast = parse("if condition do something; else something_else; end")
      ast.procedure.statements.first
        .should be_a(IfStatement)
    end

  end
end