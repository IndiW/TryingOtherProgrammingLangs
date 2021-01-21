// const
// neg
// abs
// plus
// times
// minus
// exponent
import scala.math.pow

sealed trait Expr[A]
case class Const[A](value: A) extends Expr[A]
case class Neg[A](express: Expr[A]) extends Expr[A]
case class Abs[A](express: Expr[A]) extends Expr[A]
case class Plus[A](left: Expr[A], right: Expr[A]) extends Expr[A]
case class Minus[A](left: Expr[A], right: Expr[A]) extends Expr[A]
case class Times[A](left: Expr[A], right: Expr[A]) extends Expr[A]
case class Exp[A](left: Expr[A], right: Expr[A]) extends Expr[A]



//Design decision: Since we have to return an Int, the Exp function will round the output
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

