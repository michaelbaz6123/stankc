# 🦨 Stank Lang

## ➡️ Overview, Philosophy
In Stank, we separate what a program computes from what it does.

- Use `fn` for pure computations.

- Use `proc` for impure actions.

A `proc` can succeed or fail, but it cannot return a value.
If a procedure needs to communicate a result, it should do so by:

- Mutating a variable

- Calling another function to compute the value

## ➡️ Comments
- Single-line comments begin with `#`
- Block comments not yet supported.

## ➡️ Typing
- Every value has a type.
- All types are capitalized (e.g., `Int`, `Array`, `MyType`).

## ➡️ Atomic Value Types
- `Int` : `0`, `-3`, `239`, etc.
- `Float` : `1.4`, `-359.1391`, etc.
- `Char` : `'c'`, `'a'`, '`r'`, etc.
- `String` : `"hello"`, `"world!"`, etc.
- `Bool` : `true`, `false`
- `Nil` : `nil`

## ➡️ Bindings and Variables
- Bindings are immutable, while variables can be reassigned.
```
let x : Int = 10; # Binds x of Int to Int 10
# x = 2;          # Type error: Invalid mutation on binding x

var y : Int = 12; # Assigns variable y of Int to Int 12
y = 31;           # Reassigns y to Int 31

let p = 12.3;     # p is inferred to be type Float
var q = "Hello";  # q is inferred to be type String
```
- Bindings must always be initialized.
- Variables can optionally be declared with no initialized value. Access before initialization will still be an error, of course.
- Type annotation optional if the type of the binding/variable can be inferred by its value.

## ➡️ Input and Output
- `print` and `println` (adds newline) are included language procedures that take a value and perform an IO side effect (to stdout, by default).
```
let x = 10;
print(x); print(", ");
println("Hello, world!"); 
# > 10, "Hello, world!"
```
- `input` is a language procedure that takes a value as a reference to have user input stored in:
```
var x : I32;
println("Please enter a number: ");
input(x); 
# < 12

print("You entered: "); println(x); 
# > You entered 12
```

## ➡️ Declaring Types
### Union Types
- Declared as `type MyType is OtherType [ | AnotherType] end`
```
type IntOrString is 
  Int | String 
end

# Also for aliasing!
type MagicNumber is Int end
```
- All unions are structural, and field access on a union is valid only if all branches have the field.
### Product Types
- Declared as `type MyType has field : SomeType end`
```
type IntPoint has
  x : Int,
  y : Int
end
let point : IntPoint = IntPoint(x = 10, y = 13);

println(point.x); 
# > 10

println(point.y); 
# > 13
```

## ➡️ Generic Types
- Types can be generic over other types using angle brackets to declare and parentheses to instantiate.
```
type Point<T> has
  x : T,
  y : T
end
```
- For example, the primitive `T?`, or `Maybe<T>`, used to represent optional values:
  ```
  type Some<T> has value : T end
  type Maybe<T> is Some(T) | Nil end
  ```

## ➡️ Pattern Matching and Unwrapping
- Pattern matching can be used in expressions with `match ... then`:
```
let x : Int? = Some(value = 12);
let y = match x then
  Some(i = value) => Some(value = i + 2);
  Nil     => nil;
end;

println(x); 
# > Some(value = 12)

println(y); 
# > Some(value = 14)
```
- Similarly, in procedures `if let ... do` can be used to unwrap a `var` into mutable references of its fields:
```
var x : String? = Some(value = "something");
if let Some(s) = x do
  s = "another thing"; # mutates x's Some value, (x must be var!)
end

println(x); 
# > Some(value = "another thing") 
```

## ➡️ Collective Types
- All collection types can be mutable or immutable.
- `Array(T)`: dynamic sizing, homogeneous on `T`.
```
var my_array : Array(Int) = [1, 2, 3, 4, 5]; # Array literal
my_array[0] = 12;

println(my_array[2]) 
# > 3
println(my_array[0]) 
# > 12
```
- `Tuple(FirstType, SecondType, ...)`: fixed-size, heterogeneous over listed `FirstType, SecondType, ...`
```
var my_tuple : Tuple(Int, String, Bool) = (10, "Hello", true); # Tuple literal
println(my_tuple[1]) 
# > Hello

```
- `Hash(K, V)`: maps keys of `K` to `V`
```
var my_hash : Hash(String, Int) = { "foo" => 0 } # Hash literal
println(my_hash["foo"]) 
# > 0

my_hash["bar"] = 34
println(my_hash["bar"]) 
# > 34

```

## ➡️ Functions and Procedures 

  ### The Difference and Syntax
  - **Functions** use `=> ... end` to declare an expression a function evaluates.
  - **Expressions** exist to be evaluated in context of function bodies, conditional expressions, etc.
  - **Procedures** use `do ... end` to declare a list of statements that perform side effects.
  - **Statements** must end with semicolon `;`


  ### Functions
  - Pure: no side effects allowed. Defined to be a single expression.
  - "Applicator" `$` is required after function name in declaration and when calling.
  ```
  # Declare a function foo that takes Int's a, b, and c => returns an Int
  fn foo $ (a : Int, b : Int, c : Int) : Int =>
      a + b + c
  end

  # Call foo with arguments
  let x = foo$(2, 11, -3); # x == 10

  # Parentheses optional for no arg functions
  fn bar $ => "something" end  # Inferred to evaluate to String
  print(bar$);
  ```

### Lambdas and Higher Order Functions
- Functions can be passed around like values as first class objects.
- A function that takes an `x : Int` and evaluates to a `Int` would have type `$ Int => Int`
```
fn double$(i : Int) : Int => 2 * i end;

proc apply_and_print(x : Int, f : $ Int => Int) do
  let applied = f$(x);
  println(applied);
end

apply_and_print(13, double); 
# > 26
```
- Functions can be unnamed as lambda expressions with `$`:
```
# Continuing from above:

apply_and_print(5, $ (x : Int) => 10 * x end); 
# > 50
```


 ### Procedures
  ```
  proc my_proc([<name> : <Type>, ...]) do 
    ... 
  end 

  my_proc();
  ```
  #### The `Result` Type and `raise`ing Errors
  - Procedures always implicitly return: `Result`
  - Procedures either finish with `Ok` or `Err(message : String)`
  ```
  type Result is Ok | Err end
  type Ok is Nil end
  type Err has message : String end
  ```
  - Use `raise msg;` to exit procedure and implicitly return `Err(message = msg)`
  ```
  proc my_proc(x : Int) do 
    if x > 0
      println(x);
    else
      raise "Error occurred";
    end
  end 

  result = my_proc(-1);
  println(result.message) 
  # > Error occurred
  ```
  - Use `?` operator on a procedure call inside another procedure to pass through errors:
  ```
  proc print_non_zero(x : Int) do
    if x != 0 do
      println(x);
    else
      raise "x is zero!"
    end
  end

  proc do_stuff(x : Int) do
    print_non_zero(x)?;
    # Expands to:
    #   if let print_non_zero(x) = Err(message) do
    #     raise message;
    #   end
    #
    # otherwise, continues procedure...


    println("Doing some stuff...");
  end

  let good_result : Result = do_stuff(20); # good_result = Ok
  # > 20
  # > Doing some stuff...

  let bad_result : Result = do_stuff(0); # bad_result = Err(message = "x is zero!")
  ```

  ### Generics
  - Both functions and procedures can be generic over more than one type.
    ```
    fn foo<T> $ 
    (p : Point(T)) : T => 
      p.x 
    end

    proc bar<T>(x : T) do
      # Type inference will check if x's type has field at call
      println(x.field) 
    end
    ```

## 🔸 Procedural Control Flow
- `if ... do ... else ... end`
  - Procedural conditional block.
  - Used inside procedures (`proc`).
  - Allows side effects inside branches.
  - `do` indicates the start of an impure procedure block.
  - `else` optional.
  - Example:
    ```
    proc printSign(x : Int) do
        if x < 0 do
            println("negative");
        else
            println("non-negative");
        end
    end
    ```
- `while <cond_expr> do ... end`
  - Loop a procedure while `cond_expr` is true.
  - Example:
    ```
      while x > 0 do
        println(x);
        x -= 1;
      end
    ```
- `for var <id_init> <cond_expr> [by <statement>] do ... end`
  - Loop a procedure over a range from `<start>` to `<end>`, counter stored in `<identifier>`.
  - Example:
    ```
      for var i = 0; i < 5 do
        println(i);
      end
      # > 0
      # > 1
      # > 2
      # > 3
      # > 4

      # Increment alteratively (default increments declared var by 1)
      for var j = 0; j < 10 by j += 2; do
        println(j);
      end
      # > 0
      # > 2
      # > 4
      # > 6
      # > 8
    ```
### Looping Over Collective Types
- Looping over an array:
  ```
  let my_array : Array(Int) = [12, 24, 36];
  for Int : i = 0; my_array.length do
    println(i)
    println(my_array[i])
  end
  ```
- Looping over a set:
  ```
  type Set<T> has items : Array(T) end

  let my_set : Set(Int);
  my_set.insert(1); my_set.insert(2); my_set.insert(3);
  for var i = 0; my_set.items.length do
    println(my_set.items[i]);
  end
  ```
- Looping over a hash:
  ```
  type Entry<K, V> has 
    key : K, 
    value : V 
  end

  type Hash<K, V> has
    keys : Array(K),
    values : Array(V),
    entries : Array(Entry(K, V))
  end

  let my_hash = {2 => 10, 4 => 100};

  for var i = 0; i < my_hash.keys.length do
    println(my_hash.keys[i]);
  end
  # > 2
  # > 4

  for var i = 0; i < my_hash.values.length do
    println(my_hash.values[i]);
  end
  # > 100
  # > 10

  for var i = 0; i < my_hash.entries.length do
    let entry = my_hash.entries[i];
    let result = entry.key + entry.value;
    println(result);
  end
  # > 104
  # > 12
  ```

## ➡️ Expressions

### Atomic Operators
- Arithmetic
  - Addition, subtraction, multiplication, division, and integer division.
    ```
    let a : Int = x + y;
    let b : Int = x - y;
    let c : Int = x * y;
    let d : Float = x / y;
    let e : Int = x // y;
    let f : Int = x % y;
    ```
- Boolean Logic
  - And, or, not
    ```
    let x : Bool = true && false; # false
    let y : Bool = true || false; # true
    let z : Bool = !false;        # true
    ```
- Bitwise Logic
  - Bitwise and, bitwise or, bitwise xor
    ```
    let x : Int = 12 & 8;   # 8
    let y : Int = 12 | 32;  # 44
    let z : Int = 31 ^ 12;  # 19
    ```
- Reassignment operators
  - For all arithmetic (except modulo), boolean, and bitwise binary operators.
    ```
    x += 1; y -= 2; y *= 3; z /= 4; p //= 5;
    
    a &&= p; b ||= q; 

    x &= 2; y |= 4; z ^= 8
    ```

- `if ... then ... else ... end`
  - Pure conditional expression.
  - Used inside expressions, functions.
  - Evaluates to something.
  - `then` indicates the start of the pure expression branch.
  - `else` branch optional, returns `Maybe<T>` if not included
  - Example:
    ```
    fn abs $ (x : Int) : Int =>
      if x < 0 then -x else x end
    end

    fn foo $ (y : Int) : String? =>
      if y == 0 then "zero" end
    end 
    ```

## ➡️ Modules
- Declared using `module MyModule has ... end`.
- Files may define multiple modules.
- Each file may optionally define a `main` procedure declared on outermost scope.
- Work like namespaces in other languages, use `SomeModule::symbol` to access a definition inside the module.
```
module MyModule has
  fn foo $ (x : Int): Int =>
    x + 1
  end
end

let module_result : Int = MyModule::foo$(12)
```

## ➡️ Program Structure
- A single `.stank` program can be:
  - A **program** with `proc main()` that compiles to an executable.
    - Optional `proc main(args : Array(String))` for command line arguments.
  - A **library** that declares a single `module`


### Importing Modules
my_library.stank:
```
module MyModule has
  proc foo() do
    println("Hello world!");
  end

  fn bar $ (x : Int) =>
    x + 1
  end
end
```
my_program.stank:
```
import MyModule from "/path/to/my_library";

proc main() do
  MyModule::foo();          # Hello, world!
  println(MyModule::bar(12)); # 12
end
```

## ➡️ Memory andHow Stank is Implemented
- Stank is compiled via transpilation to C code that is then compiled into machine code. 
- All values in Stank are allocated on the heap, memory is managed via Boehm-Demers-Weiser Garbage Collector.


