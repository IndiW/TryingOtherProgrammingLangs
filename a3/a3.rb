
module GCL

    # Integer Expression classes
    class GCExpr
    end

    # GC Constant
    # input n: integer
    class GCConst < GCExpr
        attr_reader :value
        def initialize(n)
            unless n.is_a?(Integer)
                throw "Constructing an integer term out of a non-integer"
            end 
            @value = n
        end
    end

    # GC Variable
    # input s: symbol
    class GCVar < GCExpr
        attr_reader :value
        def initialize(s)
            unless s.is_a?(Symbol)
                throw "Constructing a variable term out of a non-symbol"
            end 
            @value = s
        end
    end

    # GC Operator
    # input e1: GCExpr
    # input e1: GCExpr
    # input e1: symbol
    class GCOp < GCExpr
        attr_reader :e1
        attr_reader :e2
        attr_reader :op 
        def initialize(e1, e2, s)
            unless e1.is_a?(GCExpr)
                throw "Constructing an operator expression with a non GCExpr"
            end
            unless e2.is_a?(GCExpr)
                throw "Constructing an operator expression with a non GCExpr"
            end
            unless s.is_a?(Symbol)
                throw "Constructing an operator expression with a non symbol operator"
            end
            @e1 = e1 
            @e2 = e2
            @op = s # one of :plus, :times, :minus, :div
        end
    end


    # Boolean Test classes
    class GCTest
    end

    # GC Comparison
    # input e1: GCExpr
    # input e1: GCExpr
    # input e1: symbol 
    class GCComp < GCTest
        attr_reader :e1
        attr_reader :e2
        attr_reader :op 
        def initialize(e1, e2, s)
            unless e1.is_a?(GCExpr)
                throw "Constructing a test compare expression with a non GCExpr"
            end
            unless e2.is_a?(GCExpr)
                throw "Constructing a test compare expression with a non GCExpr"
            end
            unless s.is_a?(Symbol)
                throw "Constructing an operator expression with a non symbol operator"
            end
            @e1 = e1 
            @e2 = e2
            @op = s # one of :eq, :less, :greater
        end    
    end

    # GC And
    # input t1: GCTest
    # input t2: GCTest
    class GCAnd < GCTest
        attr_reader :t1
        attr_reader :t2
        def initialize(t1, t2)
            unless t1.is_a?(GCTest)
                throw "Constructing a GCAnd expression with a non GCTest"
            end
            unless t2.is_a?(GCTest)
                throw "Constructing a GCAnd expression with a non GCTest"
            end
            @t1 = t1 
            @t2 = t2
        end  
    end

    # GC Or
    # input t1: GCTest
    # input t2: GCTest
    class GCOr < GCTest
        attr_reader :t1
        attr_reader :t2
        def initialize(t1, t2)
            unless t1.is_a?(GCTest)
                throw "Constructing a GCOr expression with a non GCTest"
            end
            unless t2.is_a?(GCTest)
                throw "Constructing a GCOr expression with a non GCTest"
            end
            @t1 = t1 
            @t2 = t2
        end  
    end

    # GC True
    class GCTrue < GCTest
        attr_reader :value
        def initialize
            @value = true
        end
    end

    # GC True
    class GCFalse < GCTest
        attr_reader :value
        def initialize
            @value = false
        end
    end


    # Statement classes
    class GCStmt
    end

    class GCSkip < GCStmt
        def initialize
        end
    end

    # GC Assign: Assign a expression to a symbol
    class GCAssign < GCStmt
        attr_reader :e # GCExpr
        attr_reader :s # Symbol
        def initialize(s, e)
            unless e.is_a?(GCExpr)
                throw "Constructing an assign expression with a non GCExpr"
            end
            unless s.is_a?(Symbol)
                throw "Constructing an assign expression with a non symbol"
            end
            @e = e
            @s = s 
        end
    end

    # Have one statement after another
    class GCCompose < GCStmt
        attr_reader :st1  # GCStmt
        attr_reader :st2  # GCStmt
        def initialize(st1, st2)
            unless st1.is_a?(GCStmt)
                throw "Constructing an assign expression with a non GCTExpr"
            end
            unless st2.is_a?(GCStmt)
                throw "Constructing an assign expression with a non symbol"
            end
            @st1 = st1 
            @st2 = st2 
        end
    end

    class GCIf < GCStmt
        attr_reader :pairlist # List of GCTest and GCStmt pairs [[GCTest, GCStmt],...]
        def initialize(pairlist)
            unless pairlist.is_a?(Array)
                throw "GCIf requires an array"
            end
            @pairlist = pairlist
        end
    end

    class GCDo < GCStmt
        attr_reader :pairlist # List of GCTest and GCStmt pairs [[GCTest, GCStmt],...]
        def initialize(pairlist)
            unless pairlist.is_a?(Array)
                throw "GCDo requires an array"
            end
            @pairlist = pairlist
        end

    end

    # carries out the evaluation of a GCStmt using a stack machine
    def stackEval(cmdStack, resStack, memState)
        # cmdStack => the command stack implemented using a list
        # resStack => the results stack implemented using a list
        # memState => the memory state implemented using a block. Will contain a map for variable names and their integers

        # create a map to convert vals in resStack to actual operators
        # stack will be an array where elements are added to front and removed from front
        i = 0
        while true do
            if cmdStack.length == 0
                break
            end
            if cmdStack[0].is_a?(GCConst)
                #puts "const"
                #puts cmdStack[0].value
                # add constants from control stack to results stack
                resStack.unshift(cmdStack[0].value) # puts the value from cmdStack[i] into the start of resStack
                cmdStack = cmdStack.drop(1) # remove top value (index 0) from command stack
                i += 1
            elsif cmdStack[0].is_a?(GCTrue)
                # add booleans from control stack to results stack
                resStack.unshift(cmdStack[0].value) # puts the value from cmdStack[i] into the start of resStack
                cmdStack = cmdStack.drop(1)
                i += 1       
            elsif cmdStack[0].is_a?(GCFalse)
                # add booleans from control stack to results stack
                resStack.unshift(cmdStack[0].value) # puts the value from cmdStack[i] into the start of resStack
                cmdStack = cmdStack.drop(1)
                i += 1
            elsif cmdStack[0].is_a?(GCOp)
                #puts "op"
                a = cmdStack[0]
                cmdStack = cmdStack.drop(1) 
                cmdStack.unshift(a.op) #add operator to the stack
                cmdStack.unshift(a.e2) # add second expr to cmdStack
                cmdStack.unshift(a.e1) # add first expr to cmdStack
                i += 1

            # binary operators on cmd stack
            elsif cmdStack[0] == :plus
                b = resStack[0] # get first value from resStack. This will be the second expr in the operator statement
                resStack = resStack.drop(1)
                a = resStack[0] # get next value from resStack. This will be the first expr in the operator statement
                resStack = resStack.drop(1)
                resStack.unshift(a + b) #apply operator and put it back on resStack
                cmdStack = cmdStack.drop(1)
                i += 1
            elsif cmdStack[0] == :minus
                b = resStack[0]
                resStack = resStack.drop(1)
                a = resStack[0]
                resStack = resStack.drop(1)
                resStack.unshift(a - b)
                cmdStack = cmdStack.drop(1)
                i += 1
            elsif cmdStack[0] == :times
                b = resStack[0]
                resStack = resStack.drop(1)
                a = resStack[0]
                resStack = resStack.drop(1)
                resStack.unshift(a * b)
                cmdStack = cmdStack.drop(1)
                i += 1
            elsif cmdStack[0] == :div
                b = resStack[0]
                resStack = resStack.drop(1)
                a = resStack[0]
                resStack = resStack.drop(1)
                resStack.unshift(a / b)
                cmdStack = cmdStack.drop(1)
                i += 1

            # variable
            elsif cmdStack[0].is_a?(GCVar)
                # apply memoryState function to variable and add to resultStack

                x = memState.call(cmdStack[0].value)
                #puts "var"
                #puts x
                resStack.unshift(memState.call(cmdStack[0].value))
                # remove GCVar from commandstack
                cmdStack = cmdStack.drop(1)
                i += 1

            # Test compare
            elsif cmdStack[0].is_a?(GCComp)
                #puts "comp"
                a = cmdStack[0]
                cmdStack = cmdStack.drop(1)
                cmdStack.unshift(a.op) #add operator to the stack
                cmdStack.unshift(a.e2) # add second expr to cmdStack
                cmdStack.unshift(a.e1) # add first expr to cmdStack
                i += 1               

            # less
            elsif cmdStack[0] == :less
                #puts "less"
                a = resStack[1]
                b = resStack[0]
                resStack = resStack.drop(2)
                resStack.unshift(a < b)
                cmdStack = cmdStack.drop(1)

            # greater
            elsif cmdStack[0] == :greater
                a = resStack[1]
                b = resStack[0]
                #puts "greater"
                resStack = resStack.drop(2)
                resStack.unshift(a > b)
                cmdStack = cmdStack.drop(1)

            # eq
            elsif cmdStack[0] == :eq
                a = resStack[0]
                b = resStack[1]
                resStack = resStack.drop(2)
                resStack.unshift(a == b)
                cmdStack = cmdStack.drop(1)

            elsif cmdStack[0].is_a?(GCAnd)
                #puts "and gc"
                a = cmdStack[0]
                cmdStack = cmdStack.drop(1)
                cmdStack.unshift("and")
                cmdStack.unshift(a.t2)
                cmdStack.unshift(a.t1)

            elsif cmdStack[0] == "and"
                a = resStack[0]
                b = resStack[1]
                #puts a&b
                resStack = resStack.drop(2)
                cmdStack = cmdStack.drop(1)
                resStack.unshift(a & b)

            elsif cmdStack[0].is_a?(GCOr)
                a = cmdStack[0]
                cmdStack = cmdStack.drop(1)
                cmdStack.unshift("or")
                cmdStack.unshift(a.t2)
                cmdStack.unshift(a.t1)

            elsif cmdStack[0] == "or"
                a = resStack[0]
                b = resStack[1]
                resStack = resStack.drop(2)
                cmdStack.drop(1)
                resStack.unshift(a | b)



            # skip
            elsif cmdStack[0].is_a?(GCSkip)
                # no changes to result stack or memState
                cmdStack = cmdStack.drop(1)
                break
                i += 1

            # variable assignment
            elsif cmdStack[0].is_a?(GCAssign)
                # add to memState the new variable substitution 
                #puts "assign"
                a = cmdStack[0]
                cmdStack = cmdStack.drop(1) # remove GCAssign from cmdstack
                cmdStack.unshift(a.s) # add symbol to be assigned
                cmdStack.unshift("assign") # add assign statement
                cmdStack.unshift(a.e) # add expression to be evaluated
                i += 1
            
            #assignment operator
            # command stack ["assign",symbol,...]
            # res stack [const,...]
            elsif cmdStack[0] == "assign"
                memState = updateState(memState, cmdStack[1], resStack[0])
                cmdStack = cmdStack.drop(2) # remove assign and symbol
                resStack = resStack.drop(1) # remove constant 
                i += 1

            # compose
            elsif cmdStack[0].is_a?(GCCompose)
                #puts "compose"
                a = cmdStack[0]
                cmdStack = cmdStack.drop(1) # remove GCCompose from command stack
                cmdStack.unshift(a.st2) # add 2nd statement to be evaluated
                cmdStack.unshift(a.st1) # add first statement to be evaluated
                i += 1

            # if statement breakdown
            elsif cmdStack[0].is_a?(GCIf)
                p = cmdStack[0] # top element from stack. Should be of type GCIf
                cmdStack = cmdStack.drop(1) #remove GCIf from cmdStack
                l = p.pairlist # get list from GCIf
                if l.length == 0
                    cmdStack.unshift(GCSkip.new())
                else
                    randval = rand(l.length) # get random value 
                    pair = l[randval]
                    l.delete_at(randval) # remove statement from index randval
                    
                    # re-add broken down GCIf to command stakc
                    cmdStack.unshift(GCIf.new(l)) # add remaining statements
                    cmdStack.unshift(pair[1]) # add statement 
                    cmdStack.unshift("if") # add if
                    cmdStack.unshift(pair[0]) # add boolean guard
                    i += 1
                end
            elsif cmdStack[0] == "if"
                b = resStack[0] # get the boolean that would have been evaluated from result stack
                if b == true 
                    s1 = cmdStack[1] # get the statement to be executed
                    cmdStack = cmdStack.drop(3) # remove the if, s1 and remaining GCIf block 
                    resStack = resStack.drop(1) # remove that boolean check
                    cmdStack.unshift(s1) #place the s1 value back on command stack
                else 
                    cmdStack = cmdStack.drop(2) # remove "if" and s1. The top element on stack should now be the remaining GCIf statements 
                    resStack = resStack.drop(1) # remove the boolean 
                end

            # while loop
            # logic: get random statement from list and place it at top of command stack
            # check if the guard is true. If so then do that statement and repeat
            # if false, can either find another statement or do nothing
            # in this implementation, I will do nothing in the false case
            elsif cmdStack[0].is_a?(GCDo)
                #puts "do"
                w = cmdStack[0] # get Do statement off command stack
                #cmdStack = cmdStack.drop(1) # remove statement
                #cmdStack.unshift(GCDo.new(w.pairlist)) 
                if w.pairlist.length == 0 # if no pairs, do nothing
                    cmdStack.unshift(GCSkip.new())
                else
                    randval = rand(w.pairlist.length) # get random value
                    pair = w.pairlist[randval] # get random pair
                    cmdStack = cmdStack.drop(1) # remove GCDo
                    cmdStack.unshift(pair[1]) # add statement
                    cmdStack.unshift(pair[0]) # add boolean check
                    cmdStack.unshift("while")
                    cmdStack.unshift(pair[0]) # condition
                    i += 1
                    # command stack should look like [guard, "while", guard, statement, ...]
                end
            elsif cmdStack[0] == "while"
                # command stack will be in form ["while", guard, statement, ...]
                # resStack will be in form [true/false, ...]
                b = resStack[0] # check evaluated condition
                g = cmdStack[1] # guard
                s = cmdStack[2] # statement 
                if b == true
                    cmdStack.unshift(g) # place guard to front of stack
                    cmdStack.unshift(s) # place statement to front of stack to be evaluated
                    resStack = resStack.drop(1) # remove previously evaluated condition
                    # new command stack will be in form [statement, guard, "while", guard, statement]
                else
                    #puts "while guard was false"
                    cmdStack.drop(3) #remove while, guard and statement from command stack
                    cmdStack.unshift(GCSkip.new()) #end loop
                    resStack = resStack.drop(1) # remove previously computed bool
                i += 1
                end
            else 
                puts "Invalid input"
                break
            end
        end
        return memState 

    end


    def emptyState
        l = lambda do |x|
            h = Hash.new(0)
            if x == "returnhash"
                return h 
            else
                return h[x] 
            end
        end
        return l
    end

    def updateState(sigma, x, n)
        # sigma => a lambda for the previous memory state
        # x => a variable name (ie a symbol)
        # an integer
        h = sigma.call("returnhash")
        l = lambda do |x|
            h[x] = n
            if x == "returnhash"
                h 
            else
                h[x] 
            end
        end
        return l
    end

end



module GCLe 

    # Program consisting of a list of global variables
    # followed by a statement, which we call the "body" of the program
    class GCProgram
        attr_reader :symbollist 
        attr_reader :stmt
        def initialize(symbollist,stmt)
            unless symbollist.is_a?(Array)
                throw "GCProgram requires an array"
            end
            unless stmt.is_a?(GCStmt)
                throw "GCProgram requires a GCStmt"
            end
            @symbollist = symbollist # list of symbols for the global variable names
            @stmt = stmt  # GCStmt
        end
    end


    # Integer Expression classes
    class GCExpr
    end

    # Integer constants
    class GCConst < GCExpr
        attr_reader :value 
        def initialize(n)
            unless n.is_a?(Integer)
                throw "Constructing an integer term out of a non-integer"
            end 
            @value = n
        end
    end

    # Variable names
    class GCVar < GCExpr
        attr_reader :value
        def initialize(s)
            unless s.is_a?(Symbol)
                throw "Constructing a variable term out of a non-symbol"
            end 
            @value = s
        end
    end

    # Binary Operations
    class GCOp < GCExpr
        attr_reader :e1
        attr_reader :e2
        attr_reader :op 
        def initialize(e1, e2, s)
            unless e1.is_a?(GCExpr)
                throw "Constructing an operator expression with a non GCExpr"
            end
            unless e2.is_a?(GCExpr)
                throw "Constructing an operator expression with a non GCExpr"
            end
            unless s.is_a?(Symbol)
                throw "Constructing an operator expression with a non symbol operator"
            end
            @e1 = e1 
            @e2 = e2
            @op = s # one of :plus, :times, :minus, :div
        end
    end


    # Boolean Test classes
    class GCTest
    end

    # Comparison (equality and inequality)
    class GCComp < GCTest
        attr_reader :e1
        attr_reader :e2
        attr_reader :op 
        def initialize(e1, e2, s)
            unless e1.is_a?(GCExpr)
                throw "Constructing a test compare expression with a non GCExpr"
            end
            unless e2.is_a?(GCExpr)
                throw "Constructing a test compare expression with a non GCExpr"
            end
            unless s.is_a?(Symbol)
                throw "Constructing an operator expression with a non symbol operator"
            end
            @e1 = e1 
            @e2 = e2
            @op = s # one of :eq, :less, :greater
        end    
    end

    # And operator
    class GCAnd < GCTest
        attr_reader :t1
        attr_reader :t2
        def initialize(t1, t2)
            unless t1.is_a?(GCTest)
                throw "Constructing a GCAnd expression with a non GCTest"
            end
            unless t2.is_a?(GCTest)
                throw "Constructing a GCAnd expression with a non GCTest"
            end
            @t1 = t1 
            @t2 = t2
        end  
    end


    # OR operator
    class GCOr < GCTest
        attr_reader :t1
        attr_reader :t2
        def initialize(t1, t2)
            unless t1.is_a?(GCTest)
                throw "Constructing a GCOr expression with a non GCTest"
            end
            unless t2.is_a?(GCTest)
                throw "Constructing a GCOr expression with a non GCTest"
            end
            @t1 = t1 
            @t2 = t2
        end  
    end


    # boolean true
    class GCTrue < GCTest
        attr_reader :value
        def initialize
            @value = true
        end
    end

    # boolean false
    class GCFalse < GCTest
        attr_reader :value
        def initialize
            @value = false
        end
    end


    # Statement classes
    class GCStmt
    end

    # Skip statement that does nothing
    class GCSkip < GCStmt
        def initialize
        end
    end

    # Assignment of an expression to a variable
    class GCAssign < GCStmt
        attr_reader :e # GCExpr
        attr_reader :s # Symbol
        def initialize(s, e)
            unless e.is_a?(GCExpr)
                throw "Constructing an assign expression with a non GCTExpr"
            end
            unless s.is_a?(Symbol)
                throw "Constructing an assign expression with a non symbol"
            end
            @e = e
            @s = s 
        end
    end

    # Composition of two statements
    class GCCompose < GCStmt
        attr_reader :st1 
        attr_reader :st2 
        def initialize(st1, st2)
            unless st1.is_a?(GCStmt)
                throw "Constructing an assign expression with a non GCTExpr"
            end
            unless st2.is_a?(GCStmt)
                throw "Constructing an assign expression with a non symbol"
            end
            @st1 = st1 
            @st2 = st2 
        end
    end

    # Choice construct "if" applied to a list of guarded commands
    class GCIf < GCStmt
        attr_reader :pairlist # List of GCTest and GCStmt pairs [[GCTest, GCStmt],...]
        def initialize(pairlist)
            unless pairlist.is_a?(Array)
                throw "GCIf requires an array"
            end
            @pairlist = pairlist
        end
    end

    # iteration construct "do" applied to a list of guarded commands
    class GCDo < GCStmt
        attr_reader :pairlist # List of GCTest and GCStmt pairs [[GCTest, GCStmt],...]
        def initialize(pairlist)
            unless pairlist.is_a?(Array)
                throw "GCDo requires an array"
            end
            @pairlist = pairlist
        end

    end

    # Declare local variables
    class GCLocal < GCStmt
        attr_reader :s # symbol for the variable name
        attr_reader :stmt # GCStmt
        def initialize(s, stmt)
            unless s.is_a?(Symbol)
                throw "GCLocal requires an Symbol"
            end
            unless stmt.is_a?(GCStmt)
                throw "GCLocal requires a GCStmt"
            end
            @s = s 
            @stmt = stmt 
        end
    end

    # helper function to check the values of each class
    def typeOf(state,glob,loc)
        if state.is_a?(GCLocal)
            loc.append(state.s)
            return typeOf(state.stmt,glob,loc)
        elsif state.is_a?(GCAssign)
            if loc.include?(state.s) | glob.include?(state.s)
                return typeOf(state.e,glob,loc) 
            else 
                return false
            end
        elsif state.is_a?(GCVar)
            if loc.include?(state.value) | glob.include?(state.value)
                return true 
            else 
                return false
            end 

        # can add additonal cases for other GCExpr types
        else
            return false
        end             
    end

    # check scoping
    def wellScoped(prog)
        globs = prog.symbollist
        local = []
        ret = typeOf(prog.stmt,globs,local)
        return ret
        
    end

    def evalHelper(statement, memState, globals, locals)
        if statement.is_a?(GCConst)
            return statement.value
        elsif statement.is_a?(GCAssign)
            if globals.include?(statement.s) | locals.include?(statement.s)
                memState[statement.s] = evalHelper(statement.e, memState, globals, locals)
                #return statement
            else
                throw "Out of scope variable"
            end
        
        elsif statement.is_a?(GCVar)
            return memState[statement.value]

        elsif statement.is_a?(GCOp)
             if statement.op == :plus
                return evalHelper(statement.e1, memState, globals, locals) + evalHelper(statement.e2, memState, globals, locals)
             elsif statement.op == :minus
                return evalHelper(statement.e1, memState, globals, locals) - evalHelper(statement.e2, memState, globals, locals)
            elsif statement.op == :times
                return evalHelper(statement.e1, memState, globals, locals) * evalHelper(statement.e2, memState, globals, locals)
            elsif statement.op == :div
                return evalHelper(statement.e1, memState, globals, locals) / evalHelper(statement.e2, memState, globals, locals)
            end

        elsif statement.is_a?(GCComp)
            if statement.op == :less 
                return evalHelper(statement.e1, memState, globals, locals) < evalHelper(statement.e2, memState, globals, locals)
            elsif statement.op == :greater
                return evalHelper(statement.e1, memState, globals, locals) > evalHelper(statement.e2, memState, globals, locals)
            else 
                return evalHelper(statement.e1, memState, globals, locals) == evalHelper(statement.e2, memState, globals, locals)
            end


        elsif statement.is_a?(GCAnd)
            return evalHelper(statement.t1, memState, globals, locals) & evalHelper(statement.t2, memState, globals, locals)
        elsif statement.is_a?(GCOr)
            return evalHelper(statement.t1, memState, globals, locals) | evalHelper(statement.t2, memState, globals, locals)
        elsif statement.is_a?(GCTrue)
            return statement.value
        elsif statement.is_a?(GCFalse)
            return statement.value
        elsif statement.is_a?(GCSkip)
            return memState
        elsif statement.is_a?(GCCompose)
            m = evalHelper(statement.st1, memState, globals, locals)
            memState = evalHelper(statement.st2, m, globals, locals)
            # return statement
        elsif statement.is_a?(GCIf)
            p = statement.pairlist
            while true
                if p.length == 0
                    break
                end
                randval = rand(p.length) #random number from 0 to p.length-1
                if evalHelper(p[randval][0], memState, globals, locals) # if condition is true, return memState after running the statement
                    return evalHelper(p[randval][1], memState, globals, locals)
                else # otherwise remove that statement and try the next one
                    p.delete_at(randval)
                end
            end
            return memState

        elsif statement.is_a?(GCDo)
            p = statement.pairlist
            if p.length == 0
                return memState
            end
            randval = rand(p.length)
            if evalHelper(p[randval][0], memState, globals, locals)
                #statement.pairlist[0][1] =  evalHelper(p[0][1], memState, globals, locals)
                #return evalHelper(statement,memState, globals, locals)
                return evalHelper(GCCompose.new(p[randval][1],statement),memState, globals, locals)
            #elsif p.length != 0
                #p.delete_at(randval)
                #statement.pairlist = p
                # return evalHelper(statement, memState, globals, locals)
            else
                return memState
            end

        elsif statement.is_a?(GCLocal)
            locals.append(statement.s)
            return evalHelper(statement.stmt, memState, globals, locals)
        else
            throw "invalid input when evaluating"
        end
        return memState

    end


    def eval(prog)
        memState = Hash.new(0) #default to 0 
        globals = prog.symbollist 
        locals = []
        m = evalHelper(prog.stmt, memState, globals, locals)
        puts m 
        return m

    end


end

