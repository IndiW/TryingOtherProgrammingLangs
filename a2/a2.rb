load 'a2_ulterm.rb'

class STType end

class STNat < STType
    # Comparison and printing methods
    def ==(type); type.is_a?(STNat) end
    def to_s; "nat" end
end
    
class STBool < STType
    # Comparison and printing methods
    def ==(type); type.is_a?(STBool) end
    def to_s; "bool" end
end
    
    # Functions have a domain type and a codomain type.
class STFun < STType
    attr_reader :dom
    attr_reader :codom
    
    def initialize(dom, codom)
        unless dom.is_a?(STType) && dom.is_a?(STType)
        throw "Constructing a type out of non-types"
        end
        @dom = dom; @codom = codom
    end
    
    # Comparison and printing methods
    def ==(type); type.is_a?(STFun) && type.dom == @dom && type.codom == @codom end 
    def to_s; "(" + dom.to_s + ") -> (" + codom.to_s + ")" end
end
    
# Example use: the type "nat -> bool" is written STFun.new(STNat.new,STBool.new)


# Rules
# Variables have the type they are given by the environment
        #free variables do not have any typing rule, so we don't have to typecheck
# Adding "x has type A" to the environment, and t2 has type B, then that means that lambda x: A -> t2 has type A->B
# if t1 has the function type A-> B and t2 has the type A, then t2 applied to t1 has the type B


# App (term1)(term2)        # if t1 has the function type A-> B and t2 has the type A, then t2 applied to t1 has the type B
# Abs (type) -> (term)      # Adding "x has type A" to the environment, and t2 has type B, then that means that lambda x: A -> t2 has type A->B
# Test (term)(term)(term)   # has type term 

# Suc (term)                # has type nat
# IsZero (term)             # has type bool

# Zero (type) -> (type)     # nat
# True (type) -> (type)     # bool
# False (type) -> (type)    # bool




#0 nat, 1 bool, 2 int 
class STTerm 
    def typeOf(val, map)
        if val.is_a?(STAbs)

            return STFun.new(val.argTyp, val.t)

        elsif val.is_a?(STApp)
            return STFun.new(typeOf(val.t1,[]),typeOf(val.t2,[])) #might just be typeOf(val.t1.soemthing)
        
        elsif val.is_a?(STTest)
            if val.t1.is_a?(STTrue)
                return typeOf(val.t2)
            else
                return typeOf(val.t3)
            end

        # STIsZero case
        elsif val.is_a?(STIsZero)

            #check if correct input type
            if val.t.typeOf.is_a?(STNat)
               return STBool.new 
            end
            
            return 0 

        # STSuc case
        elsif val.is_a?(STSuc)

            #check if correct input type
            if val.t.typeOf.is_a?(STNat) 
                return STNat.new
            end
            return 0

        elsif val.is_a?(STTrue)

            return STBool.new    
        elsif val.is_a?(STFalse)

            return STBool.new  
        elsif val.is_a?(STZero)

            return STNat.new  

        elsif val.is_a?(STVar)#variable case
            map.append(val.index)
        else
        
        end
    
    end



end 

# Creates a variable
class STVar < STTerm
    attr_reader :index 
    attr_reader :typ
    def initialize(i)
        @index = i
        @typ = Integer
    end

    def typecheck
        return false
    end

    def eraseTypes
        return ULVar.new(@index)
    end

end 

# Takes in a bool and two lambda terms
class STTest < STTerm 
    attr_reader :t1
    attr_reader :t2
    attr_reader :t3
    #attr_reader :typ
    def initialize(t1,t2,t3)
        unless t1.is_a?(STTerm) && t2.is_a?(STTerm) && t3.is_a?(STTerm) && t1.typ.is_a?(STBool)
            throw "Constructing a type out of non-types"
        end
    
        @t1 = t1
        @t2 = t2
        @t3 = t3
    end

    def typecheck
        return typeOf(@t1,[]).is_a?(STBool) && typeOf(@t2,[]) == typeOf(@t3,[])
    end

    def eraseTypes
        return ULApp.new(
            ULApp.new(
            ULApp.new(
            # Encoding of suc
            ULAbs.new( # lambda n .
              ULAbs.new( # lambda s.
                ULAbs.new( # lambda z.
                  ULApp.new(ULApp.new(ULVar.new(2),ULVar.new(1)),ULVar.new(0))))),@t1.eraseTypes),@t2.eraseTypes),@t3.eraseTypes)
    end


end 

# Application
class STApp < STTerm
    attr_reader :t1
    attr_reader :t2
    #attr_reader :typ 
    def initialize(t1,t2)
      unless t1.is_a?(STTerm) && t2.is_a?(STTerm)
        throw "Constructing a lambda term out of non-lambda terms"
      end
      @t1 = t1
      @t2 = t2
    end

    def typecheck
        return typeOf(@t1,[]).dom == typeOf(@t2,[])
    end

    
    def eraseTypes
        return ULApp.new(@t1.eraseTypes,@t2.eraseTypes)
    end
end

#Abstracted
class STAbs < STTerm
    attr_reader :t 
    attr_reader :typ
    attr_reader :argTyp
    def initialize(argTyp,t)
        unless t.is_a?(STVar)
            throw "Constructing a lambda term out of a non-lambda term"
        end
        unless argTyp.is_a?(STType)
            throw "Constructing a lambda term out of a non-lambda term"
        end
        @t = t 
        @argTyp = argTyp
        @typ = STFun.new(argTyp,t)
    end

    def typecheck #check if type is argTyp -> t.typ
        return @argTyp.is_a?(STType) && @t.is_a?(STVar)
    end

    def eraseTypes
        return ULAbs.new(@t.eraseTypes)
    end


end


# Successor of value
class STSuc < STTerm 
    attr_reader :t 
    attr_reader :typ
    def initialize(t)
        unless t.is_a?(STTerm)
            throw "Constructing a lambda term out of a non-lambda term"
        end
        @t = t #do i add 1?
        @typ = STFun.new(t.typ,t)
    end

    def typecheck
        if @t.is_a?(STTerm)
            if typeOf(@t,[]).is_a?(STNat)
                return true 
            else
                return false
            end
        else
            return false
        end
    end

    # suc    = λ n → λ s → λ z → s (n s z)
    def eraseTypes
        return ULApp.new(
            ULAbs.new( # lambda n .
              ULAbs.new( # lambda s.
                ULAbs.new( # lambda z.
                  ULApp.new(ULVar.new(1),ULApp.new(ULApp.new(ULVar.new(2),ULVar.new(1)),ULVar.new(0)))))),@t.eraseTypes)
    end
end

# Checks if the lambda term is Zero
class STIsZero < STTerm 
    attr_reader :t 
    attr_reader :typ
    def initialize(t)
        unless t.is_a?(STTerm)
            "Constructing a lambda term out of a non-lambda term"
        end
        @t = t
        @typ = STFun.new(t.typ,t)
    end

    def typecheck
        if @t.is_a?(STTerm)
            if typeOf(@t,[]).is_a?(STNat)
                return true 
            else

                return false
            end
        else

            return false
        end
    end

    # iszero = λ m → m (λ x → false) true   
    def eraseTypes
        return ULApp.new( 
            # encode isZero
            ULApp.new(
            ULAbs.new( #lambda x
                ULApp.new(ULVar.new(0),ULApp.new(ULAbs(ULVar.new(1),STFalse.new.eraseTypes)))
            ),STTrue.new.eraseTypes),@t.eraseTypes)
    end

end


# Zero value
class STZero < STTerm 
    attr_reader :t 
    attr_reader :typ 
    def initialize
        @typ = STNat.new
        @t = 0
    end

    def typecheck
        return true
    end

    def eraseTypes
        return ULAbs.new(ULAbs.new(ULVar.new(0)))
    end

end

# Boolean True
class STTrue < STTerm 
    attr_reader :t 
    attr_reader :typ 
    def initialize
        @typ = STBool.new
        @t = true
    end
    def typecheck
        return true
    end
    def eraseTypes
        return ULAbs.new(ULAbs.new(ULVar.new(1)))
    end
end 

# Boolean False
class STFalse < STTerm
    attr_reader :t 
    attr_reader :typ 
    def initialize
        @typ = STBool.new
        @t = false
    end
    def typecheck
        return true
    end

    def eraseTypes
        return ULAbs.new(ULAbs.new(ULVar.new(0)))
    end

end 
