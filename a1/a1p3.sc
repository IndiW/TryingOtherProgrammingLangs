
import scala.math.pow

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

//Design decision: Since we have to return an Int, the Exp function will round the output
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

