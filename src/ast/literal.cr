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

    getter source_location : SourceLocation
    def initialize(@value : String, @source_location : SourceLocation)
    end

    def literal_type : LiteralType
        LiteralType::String
    end
end

class CharLiteral < LiteralValue
    getter value : Char 

    getter source_location : SourceLocation

    def initialize(@value : Char, @source_location : SourceLocation)
    end
    
    def literal_type : LiteralType
        LiteralType::Char
    end
end

class NilLiteral < LiteralValue
    getter value : Nil

    getter source_location : SourceLocation

    def initialize(@value : Nil, @source_location : SourceLocation)
    end

    def literal_type : LiteralType
        LiteralType::Nil
    end
end

class BoolLiteral < LiteralValue
    getter value : Bool

    getter source_location : SourceLocation

    def initialize(@value : Bool, @source_location : SourceLocation) 
    end

    def literal_type : LiteralType
        LiteralType::Bool
    end
end

class IntLiteral < LiteralValue
    getter value : Int128

    getter source_location : SourceLocation

    def initialize(@value : Int128, @source_location : SourceLocation) 
    end

    def literal_type : LiteralType
        LiteralType::Int
    end
end

class FloatLiteral < LiteralValue
    getter value : Float64

    getter source_location : SourceLocation

    def initialize(@value : Float64, @source_location : SourceLocation) end
    
    def literal_type : LiteralType
        LiteralType::Float
    end
end

abstract class LiteralCollection < Literal
end

class ArrayLiteral < LiteralCollection
    getter items : Array(Expression)

    getter source_location : SourceLocation

    def initialize(@items : Array(Expression), @source_location : SourceLocation)
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

    getter source_location : SourceLocation

    def initialize(@mappings : Hash(Expression, Expression), @source_location : SourceLocation)
    end
    
    def literal_type : LiteralType
        LiteralType::Map
    end
end