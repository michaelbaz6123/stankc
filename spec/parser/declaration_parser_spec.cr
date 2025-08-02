require "./spec_helper"
describe DeclarationParser do
  describe "#parse" do
    it "parses binding" do
      ast = parse("let x = \"Hello\";")

      stmt = ast.procedure.statements.first
      stmt.should be_a Binding
    end

    it "parses variable declaration" do
      ast = parse("var x = 0;")

      stmt = ast.procedure.statements.first
      stmt.should be_a VarDeclaration
    end

    it "parses module declaration" do
      ast = parse("module MyModule has var x : Int; end")

      stmt = ast.procedure.statements.first
      stmt.should be_a ModuleDeclaration
    end

    
  end
end
