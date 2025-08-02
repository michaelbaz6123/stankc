require "./spec_helper"

def parse(source) : AST
  begin
    return Parser.new(source).parse.as(AST)
  rescue pe : ParseError
    raise "parse failed with #{pe.message}"
  end
end

describe Parser do
  describe "#parse" do  
    it "returns an AST with procedure at top level" do
      ast = parse("")
      ast.should be_a AST
      ast.procedure.should be_a Procedure
    end
  end
end