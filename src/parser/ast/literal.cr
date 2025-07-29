enum LiteralType
    Char
    String
    Nil
    Bool
    Int
    Float
end

abstract class LiteralValue
    abstract def type : LiteralType
end

class StringLiteral < LiteralValue
    getter value : String
    def initialize(@value) end
    def type : LiteralType
        StankType::String
    end
end

class CharLiteral < LiteralValue
    getter value : Char 
    def initialize(@value) end
    def type : LiteralType
        StankType::Char
    end
end

class NilLiteral < LiteralValue
    getter value : Nil
    def initialize(@value) end
    def type : LiteralType
        StankType::Nil
    end
end

class BoolLiteral < LiteralValue
    getter value : Bool
    def initialize(@value) end
    def type : LiteralType
        StankType::Bool
    end
end

class IntLiteral < LiteralValue
    getter value : Int128
    def initialize(@value) end
    def type : LiteralType
        StankType::Int
    end
end

class FloatLiteral < LiteralValue
    getter value : Float64
    def initialize(@value) end
    def type : LiteralType
        StankType::Float
    end
end
