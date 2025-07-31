enum LiteralType
    Char
    String
    Nil
    Bool
    Int
    Float
    Array
    Tuple
    Map
end

abstract class Literal < Expression
    abstract def literal_type : LiteralType
end

abstract class LiteralValue < Literal
end

class StringLiteral < LiteralValue
    getter value : String
    def initialize(@value) end
    def literal_type : LiteralType
        LiteralType::String
    end
end

class CharLiteral < LiteralValue
    getter value : Char 
    def initialize(@value) end
    def literal_type : LiteralType
        LiteralType::Char
    end
end

class NilLiteral < LiteralValue
    getter value : Nil
    def initialize(@value) end
    def literal_type : LiteralType
        LiteralType::Nil
    end
end

class BoolLiteral < LiteralValue
    getter value : Bool
    def initialize(@value) end
    def literal_type : LiteralType
        LiteralType::Bool
    end
end

class IntLiteral < LiteralValue
    getter value : Int128
    def initialize(@value) end
    def literal_type : LiteralType
        LiteralType::Int
    end
end

class FloatLiteral < LiteralValue
    getter value : Float64
    def initialize(@value) end
    def literal_type : LiteralType
        LiteralType::Float
    end
end

abstract class LiteralCollection < Literal
end

class ArrayLiteral < LiteralCollection
    getter items : Array(Expression)

    def initialize(@items : Array(Expression))
    end

    def literal_type : LiteralType
        LiteralType::Array
    end
end

class TupleLiteral < ArrayLiteral
    def literal_type : LiteralType
        LiteralType::Tuple
    end
end

class MapLiteral < LiteralCollection
    getter mappings : Hash(Expression, Expression)

    def initialize(@mappings : Hash(Expression, Expression))
    end
    
    def literal_type : LiteralType
        LiteralType::Map
    end
end