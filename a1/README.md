# Assignment 1 Documentation
---
## Part 1: Interpreter written in Scala
We define the sealed trait Expr which takes in any type A.
The constant Const takes in 1 value.
All operators take in either 1 or 2 values which correspond to another expression.

```scala

sealed trait Expr[A]
case class Const[A](value: A) extends Expr[A]
case class Neg[A](express: Expr[A]) extends Expr[A]
case class Abs[A](express: Expr[A]) extends Expr[A]
case class Plus[A](left: Expr[A], right: Expr[A]) extends Expr[A]
case class Minus[A](left: Expr[A], right: Expr[A]) extends Expr[A]
case class Times[A](left: Expr[A], right: Expr[A]) extends Expr[A]
case class Exp[A](left: Expr[A], right: Expr[A]) extends Expr[A]


```
The interpreter method uses pattern matching to check all the 
possible cases for a given expression. If the expression is of type
Const, we return the value, being sure to convert it to an integer.
For all operators, we recursively call the interpreter on each sub-expression
within the parent expression. We utilize the pow function from scala.math.pow 
in order to calculate the exponent. We also make a design decision to convert the
output of the pow function to an integer in the case that a negative number is used as 
the exponent. 


```scala
def interpretExpr[A](e: Expr[A]): Int = 
e match{
    case Const(value) => value.asInstanceOf[Int]
    case Neg(express) => -interpretExpr(express)
    case Abs(express) => interpretExpr(express).abs
    case Plus(left, right) => interpretExpr(left) + interpretExpr(right)
    case Minus(left, right) => interpretExpr(left) - interpretExpr(right)
    case Times(left, right) => interpretExpr(left) * interpretExpr(right)
    case Exp(left, right) => pow(interpretExpr(left),interpretExpr(right)).toInt
}

```

## Part 2: Interpreter written in Prolog
The predicate isExpr checks whether a given expression is valid.
We work towards the base case that a constant constE(_) is always an expression.
For each operator, we check the components of the operator and call the isExpr predicate
on each component. If all the components of an expression are valid expressions, then the expression itself is valid. 

```prolog
isExpr(constE(_)).
isExpr(minusE(L,R)) :- isExpr(L), isExpr(R).
isExpr(absE(V)) :- isExpr(V).
isExpr(plusE(L,R)) :- isExpr(L), isExpr(R).
isExpr(expE(L,R)) :- isExpr(L), isExpr(R).
isExpr(negE(V)) :- isExpr(V).
```
The interpretExpr predicate first checks if the given expression is a valid expression. It then computes what the result of the expression is and checks if that value is equal to the inputted value X. When creating the interpreter, we focus on computing each sub-expression and checking whether that value is the same as the value we are looking for. The base case in this scenario is the constant where we check if the input X is the same as the output Z. 

For example, in plusE there contains a left expression L and a right expression R. The result of L + R should be the value Z. To compute this, we call the interpreter on L and R and expect the results to be stored in A and B respectively. We can then compute A + B and it should be the same value of Z (assuming the predicate is meant to be true). 
```prolog
interp(constE(X),Z) :- Z is X.
interp(minusE(L,R), Z) :- interp(L,A),interp(R,B),Z is (A - B).
interp(absE(V),Z) :- interp(V,A), Z is (abs(A)).
interp(plusE(L,R),Z) :- interp(L,A),interp(R,B),Z is (A + B).
interp(expE(L, R),Z) :- interp(L,A),interp(R,B),Z is (A**B).
interp(negE(V),Z) :- interp(V,A), Z is (-A).
interpretExpr(E, X) :- isExpr(E), interp(E, Z), Z is X.
```

## Part 3: Variables and substitution

Our VarExpr trait contains the new classes Var which takes in a value of type symbol and Subst which takes in an expression for which the substitution will take place, a symbol for the variable to be substituted and a substitution which denotes the new value for the substituted variable. We set the type of subst to be VarExpr to consider both the simple case of a Const and the more complex case of substituting another expression.
```scala
sealed trait VarExpr[A]
case class Const[A](value: A) extends VarExpr[A];
case class Neg[A](express: VarExpr[A]) extends VarExpr[A];
case class Abs[A](express: VarExpr[A]) extends VarExpr[A];
case class Plus[A](left: VarExpr[A], right: VarExpr[A]) extends VarExpr[A];
case class Minus[A](left: VarExpr[A], right: VarExpr[A]) extends VarExpr[A];
case class Times[A](left: VarExpr[A], right: VarExpr[A]) extends VarExpr[A];
case class Exp[A](left: VarExpr[A], right: VarExpr[A]) extends VarExpr[A];
case class Var[A](value: Symbol) extends VarExpr[A];
case class Subst[A](express: VarExpr[A], v: Symbol,subst: VarExpr[A]) extends VarExpr[A] 
```

In our new interpreter method, we include a helper function when we meet the case for Subst. This helper function subVal aims to make the substitution and then continue the recursive calls to the interpreter from where it left off.
```scala
def interpretVarExpr[A](e: VarExpr[A]): Int = 
e match{
    case Const(value) => value.asInstanceOf[Int]
    case Neg(express) => -interpretVarExpr(express)
    case Abs(express) => interpretVarExpr(express).abs
    case Plus(left, right) => interpretVarExpr(left) + interpretVarExpr(right)
    case Minus(left, right) => interpretVarExpr(left) - interpretVarExpr(right)
    case Times(left, right) => interpretVarExpr(left) * interpretVarExpr(right)
    case Exp(left, right) => pow(interpretVarExpr(left),interpretVarExpr(right)).toInt
    case Subst(express, v, subst) => interpretVarExpr(subVal(express, v, subst))

}
```

The helper function subVal should return an expression for the interpreter to continue working with. We can see, if the Var case is met, we check whether the value of the Var is equal to the variable symbol we want to substitute. If it is, we return the substituted value to be used. Otherwise we return the expression as is. In all other cases, if an operator is found we return that operator except we make sure to call subVal on the expression within the operator. This way we can continue in the scope of the substitution and ultimately return to the interpreter from where we left off.
```scala
def subVal[A](e: VarExpr[A], v: Symbol, s: VarExpr[A]): VarExpr[A] = 
e match{
        case Const(value) => Const(value)
        case Var(value) => if (value.eq(v)) s else e
        case Neg(express) => subVal(express, v, s)
        case Abs(express) => subVal(express, v, s)
        case Plus(left, right) => Plus(subVal(left, v, s),subVal(right, v, s))
        case Minus(left, right) => Minus(subVal(left, v, s),subVal(right, v, s))
        case Times(left, right) => Times(subVal(left, v, s),subVal(right, v, s))
        case Exp(left, right) => Exp(subVal(left, v, s),subVal(right, v, s))
        case Subst(express, v2, subst) => Subst(subVal(express, v, s),v2,subst)
}

```

In prolog, we check if a substitution is valid by checking the expression where the substitution is occurring, and the expression that is being substituted for the variable. If both are valid, the substitution is valid. 
```prolog
isVarExpr(constE(_)).
isVarExpr(minusE(L,R)) :- isVarExpr(L), isVarExpr(R).
isVarExpr(absE(V)) :- isVarExpr(V).
isVarExpr(plusE(L,R)) :- isVarExpr(L), isVarExpr(R).
isVarExpr(expE(L,R)) :- isVarExpr(L), isVarExpr(R).
isVarExpr(negE(V)) :- isVarExpr(V).
isVarExpr(var(_)).
isVarExpr(subst(E,_,F)) :- isVarExpr(E),isVarExpr(F).
```

## Part 4 - Boolean Expressions

Our new MixedExpr trait must now consider more than one value for the classes hence the +A in the definition. The case objects TT and FF don't take any parameters and thus we have them as objects and extend MixedExpr[Nothing]. The two boolean operators Band and Bor take two MixedExpr left and right whereas the operator Bnot takes in just one MixedExpr.
```scala
import scala.math.pow

sealed trait MixedExpr[+A]
case class Const[A](value: A) extends MixedExpr[A]
case class Neg[A](express: MixedExpr[A]) extends MixedExpr[A]
case class Abs[A](express: MixedExpr[A]) extends MixedExpr[A]
case class Plus[A](left: MixedExpr[A], right: MixedExpr[A]) extends MixedExpr[A]
case class Minus[A](left: MixedExpr[A], right: MixedExpr[A]) extends MixedExpr[A]
case class Times[A](left: MixedExpr[A], right: MixedExpr[A]) extends MixedExpr[A]
case class Exp[A](left: MixedExpr[A], right: MixedExpr[A]) extends MixedExpr[A]
case object TT extends MixedExpr[Nothing]
case object FF extends MixedExpr[Nothing]
case class Band[A](left: MixedExpr[A], right: MixedExpr[A])extends MixedExpr[A]
case class Bor[A](left: MixedExpr[A], right: MixedExpr[A])extends MixedExpr[A]
case class Bnot[A](value: MixedExpr[A])extends MixedExpr[A]
```

Because we are returning a type Option[Either[Int,Boolean]], we need to be careful with how we make our recursive calls. Two helper functions, boolExpr and intExpr, are used to evaluate boolean and integer expressions respectively. The Some method takes care of the Option whereas the Right and Left methods choose which of the two possible types to return. This implementation assumes there will be no mixing between integer and boolean operations.
```scala
def interpretMixedExpr[A](e: MixedExpr[A]): Option[Either[Int,Boolean]] = 
e match{
    case TT => Some(Right(true))
    case FF => Some(Right(false))
    case Band(left, right) => Some(Right(boolExpr(Band(left,right))))
    case Bor(left, right) => Some(Right(boolExpr(Bor(left,right))))
    case Bnot(value) => Some(Right(boolExpr(Bnot(value))))
    case Const(value) => Some(Left(value.asInstanceOf[Int]))
    case Neg(express) => Some(Left(intExpr(Neg(express))))
    case Abs(express) => Some(Left(intExpr(Abs(express))))
    case Plus(left, right) => Some(Left(intExpr(Plus(left, right))))
    case Minus(left,right) => Some(Left(intExpr(Minus(left, right))))
    case Times(left,right) => Some(Left(intExpr(Times(left, right))))
    case Exp(left,right) => Some(Left(intExpr(Exp(left, right))))
}
```
Once the first expression is interpretted, the helper boolExpr will handle all the recursive calls to break down the funciton and ultimately return the result.
```scala
def boolExpr[A](e: MixedExpr[A]): Boolean = 
e match{
    case TT => true
    case FF => false
    case Band(left, right) => boolExpr(left) && boolExpr(right)
    case Bor(left, right) => boolExpr(left) || boolExpr(left)
    case Bnot(value) => !boolExpr(value)
}
```
The same is done with the intExpr helper function.  These helper functions made it easier to return objects of type Option[Either[Int, Boolean]].
```scala
def intExpr[A](e: MixedExpr[A]): Int = 
e match{
    case Const(value) => value.asInstanceOf[Int]
    case Neg(express) => -intExpr(express)
    case Abs(express) => intExpr(express).abs
    case Plus(left, right) => intExpr(left) + intExpr(right)
    case Minus(left, right) => intExpr(left) - intExpr(right)
    case Times(left, right) => intExpr(left) * intExpr(right)
    case Exp(left, right) => pow(intExpr(left),intExpr(right)).toInt
}
```

Following the same convention, we whether each subexpression is true in order to evaluate if the entire expression is true. We also set tt as True and ff as False. 
```prolog

isMixedExpr(constE(_)).
isMixedExpr(minusE(L,R)) :- isMixedExpr(L), isMixedExpr(R).
isMixedExpr(absE(V)) :- isMixedExpr(V).
isMixedExpr(plusE(L,R)) :- isMixedExpr(L), isMixedExpr(R).
isMixedExpr(expE(L,R)) :- isMixedExpr(L), isMixedExpr(R).
isMixedExpr(negE(V)) :- isMixedExpr(V).
isMixedExpr(var(_)).
isMixedExpr(subst(E,_,F)) :- isMixedExpr(E),isMixedExpr(F).

isMixedExpr(tt).
isMixedExpr(ff) :- false.
isMixedExpr(band(L,R)) :- isMixedExpr(L) , isMixedExpr(R).
isMixedExpr(bor(L,R)) :- isMixedExpr(L) ; isMixedExpr(R).
isMixedExpr(bnot(X)) :- not(isMixedExpr(X)).
```


In the interpreter, we create two new predicates 'and' and 'or' which can then be used to set the ouput of an interp of band or bor to Z. 

```prolog

a(A, B) :- A, B.
b(A, B) :- A;B.

interp(constE(X),Z) :- Z is X.
interp(minusE(L,R), Z) :- interp(L,A),interp(R,B),Z is (A - B).
interp(absE(V),Z) :- interp(V,A), Z is (abs(A)).
interp(plusE(L,R),Z) :- interp(L,A),interp(R,B),Z is (A + B).
interp(expE(L, R),Z) :- interp(L,A),interp(R,B),Z is (A**B).
interp(negE(V),Z) :- interp(V,A), Z is (-A).
interp(var(A), Z) :- Z = A.
interp(subst(E,X,F), Z) :- interp(E,X) ,Z is F.
interp(tt,Z) :- Z is true.
interp(ff,Z) :- Z is false.
interp(band(L,R),Z) :- interp(L,A),interp(R,B),Z is a(A,B).
interp(bor(L,R),Z) :- interp(L,A),interp(R,B),Z is b(A,B).
interp(bnot(X),Z) :- Z is not(X).

interpretVarExpr(E, X) :- isMixedExpr(E), interp(E, Z), Z is X.

```