# Assignment 2 Documentation
---
## Introduction
 
The simply typed lambda calculus adds to the pure untyped lambda calculus with the following syntax
```
⟨typedterm⟩ ∷= var
             | ⟨typedterm⟩ ⟨typedterm⟩
             | λ var : ⟨type⟩ → ⟨typedterm⟩
             | zero
             | suc ⟨typedterm⟩
             | iszero ⟨typedterm⟩
             | true
             | false
             | test ⟨typedterm⟩ ⟨typedterm⟩ ⟨typedterm⟩

⟨type⟩ ∷= ⟨type⟩ → ⟨type⟩
        | nat
        | bool
```

We also introduce the following typing rules

```
 x : A ∈ Γ
–––––––––––– T-Var
 Γ ⊢ x : A


 Γ,(x : A) ⊢ t : B
––––––––––––––––––––––––––––––– T-Abs
 Γ ⊢ (λ x : A → t) : A → B


 Γ ⊢ t₁ : A → B    Γ ⊢ t₂ : A
––––––––––––––––––––––––––––––––– T-App
        Γ ⊢ t₁ t₂ : B


                                   Γ ⊢ t : nat
––––––––––––––––––– T-zero      –––––––––––––––––––– T-suc
 Γ ⊢ zero : nat                  Γ ⊢ suc t : nat
                            
                            
                         
––––––––––––––––––– T-true    –––––––––––––––––––– T-false
 Γ ⊢ true : bool               Γ ⊢ false : bool


    Γ ⊢ t : nat
–––––––––––––––––––––––– T-iszero
 Γ ⊢ iszero t : bool 


 Γ ⊢ b : bool    Γ ⊢ t₁ : A    Γ ⊢ t₂ : A
––––––––––––––––––––––––––––––––––––––––––––– T-test
            Γ ⊢ test b t₁ t₂ : A
```



## Part 1: The Representation
---
### Scala Representation

In the scala represntation, the $\lambda$ calculus ST is defined using case objects for STZero, STTrue and STFalse, and classes for the remaining constructors. Each class takes in an STTerm type as a possible value with the exception of STApp which also takes in a value *typ* which is an STType representing the type of the variable being abstracted. 
```scala

sealed trait STTerm
case object STZero extends STTerm with STType
case object STTrue extends STTerm with STType
case object STFalse extends STTerm with STType
case class STVar(index: Int) extends STTerm
case class STApp(t1: STTerm, t2: STTerm) extends STTerm
case class STAbs(typ: STType,t: STTerm) extends STTerm with STType
case class STSuc(t: STTerm) extends STTerm
case class STIsZero(t: STTerm) extends STTerm
case class STTest(t1: STTerm,t2: STTerm,t3: STTerm ) extends STTerm

```


### Ruby Representation

In the ruby representation the $\lambda$ calculus ST is defined using which inherit from a parent class STTerm. Each class saves the initial parameters in attr_reader variables.
```ruby
class STTerm 
end 

# Creates a variable
class STVar < STTerm
    attr_reader :index 
    attr_reader :typ
    def initialize(i)
        @index = i
        @typ = Integer
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
end


# Zero value
class STZero < STTerm 
    attr_reader :t 
    attr_reader :typ 
    def initialize
        @typ = STNat.new
        @t = 0
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

end 

# Boolean False
class STFalse < STTerm
    attr_reader :t 
    attr_reader :typ 
    def initialize
        @typ = STBool.new
        @t = false
    end
end 


```

## Part 2: Typechecking
---
### Scala Representation
In the scala representation, we utilize a helper function called typeOf which takes in an STTerm and returns an STType. The purpose of this function is to identify the type of a STTerm which can be used to verify the typechecking. The function uses recursive pattern matching to consider each case. 
```scala
def typeOf(t: STTerm): STType = t match{
    case STZero => STNat
    case STTrue => STBool
    case STFalse => STBool
    case STApp(t1,t2) => STFun(typeOf(t1),typeOf(t2))
    case STAbs(typ, t) => t match{
        case STVar(_) => STFun(typ, typ) //first rule
        case _ => STFun(typ, typeOf(t))  // second rule
    }
    case STSuc(_) => STNat  
    case STIsZero(_) => STBool
    case STTest(t1, t2, t3) => t1 match{
        case STTrue => typeOf(t2)
        case STFalse => typeOf(t3)
    }
}
```

The typecheck function itself also uses pattern matching, but uses the typeOf method to do all the work of parsing through the elemnts. For functions like STIsZero for example, we check if the type of the parameter passed through the function is correct. An interesting case is STApp, where we have to confirm that the type of the operation being done in t1 matches the type of the element it is being applied to in t2.
```scala

def typecheck(t: STTerm): Boolean = t match{
    case STVar(_) => false
    case STZero => true
    case STTrue => true 
    case STFalse => true
    case STSuc(t) if (typeOf(t) == STNat)  => true
    case STSuc(_) => false
    case STIsZero(t) if (typeOf(t) == STNat) => true
    case STIsZero(_) => false
    case STTest(t1, t2,t3) if (typeOf(t1) == STBool && typeOf(t2) == typeOf(t3)) => true 
    case STTest(_,_,_) => false 
    case STAbs(typ, t) => true //check
    case STApp(t1,t2) => typeOf(t1) match{
        case STFun(STNat,_) if (typeOf(t2) == STNat) => true 
        case STFun(STNat,_) => false
        case STFun(STBool,_) if (typeOf(t2) == STBool) => true 
        case STFun(STBool,_) => false
        case _ => false
    }  
}


```

### Ruby Representation
In the ruby representation, we keep the typeOf method in the parent class, and define individual typecheck methods in each subclass. This is meant to account for each special case while making it easier to include additional classes in the future. Once again, we recursively check the types of each element to ensure they are compatible.
```ruby

class STTerm 
    def typeOf(val, map)
        if val.is_a?(STAbs)

            return STFun.new(val.argTyp, val.t)

        elsif val.is_a?(STApp)
            return STFun.new(typeOf(val.t1,[]),typeOf(val.t2,[])) 
        
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
end 



```

## Part 3: Translation to the untyped $\lambda$ - calculus; type erasure
---
### Scala Representation
In the scala representation, we rely on recursive pattern matching to convert all the elements to their lambda calculus equivalent. For all cases, we include the appropriate translation followed by the additional recursive call in order to account for the new format. 

The translations utilized were:
```
true   = λ t → λ f → t
false  = λ t → λ f → f
test   = λ l → λ m → λ n → l m n
zero   = λ s → λ z → z
suc    = λ n → λ s → λ z → s (n s z)
iszero = λ m → m (λ x → false) true     


```
```scala

def eraseTypes(t: STTerm): ULTerm = t match {
    case STVar(index) => ULVar(index)
    case STTrue => ULAbs(ULAbs(ULVar(1)))
    case STZero => ULAbs( // lambda s .
                    ULAbs( // lambda z .
                    ULVar(0)))
    case STFalse => ULAbs(ULAbs(ULVar(0)))
    case STSuc(t) => ULApp(
                        ULAbs( // lambda n .
                            ULAbs( // lambda s.
                            ULAbs( // lambda z.
                                ULApp(ULVar(1),ULApp(ULApp(ULVar(2),ULVar(1)),ULVar(0)))))), // s (n s z)
                                eraseTypes(t))
    case STApp(t1, t2) => ULApp(eraseTypes(t1),eraseTypes(t2))
    case STAbs(typ, t) => ULAbs(eraseTypes(t))
    case STTest(t1,t2,t3) => ULAbs( // lambda n .
                            ULAbs( // lambda s.
                            ULAbs( // lambda z.
                                ULApp(ULApp(eraseTypes(t1),eraseTypes(t2)),eraseTypes(t3))))) // (l m n)
                                  
    case  STIsZero(t) => ULAbs(ULApp(ULApp(eraseTypes(t),ULApp(ULAbs(ULVar(1)),eraseTypes(STFalse))),eraseTypes(STTrue)))
    
}

```

### Ruby Representation
Likewise, we follow a similar strategy for ruby, but this time we include individual eraseTypes methods for each class.
```ruby
class STTerm 
end 

# Creates a variable
class STVar < STTerm
    attr_reader :index 
    attr_reader :typ
    def initialize(i)
        @index = i
        @typ = Integer
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



    def eraseTypes
        return ULApp.new(
            ULApp.new(
            ULApp.new(
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



    # suc    = λ n → λ s → λ z → s (n s z)
    def eraseTypes
        return ULApp.new(
            # Encoding of suc
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

    def eraseTypes
        return ULAbs.new(ULAbs.new(ULVar.new(0)))
    end

end 



```