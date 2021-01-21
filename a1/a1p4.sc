
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


//Design decision: Since we have to return an Int, the Exp function will round the output
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

def boolExpr[A](e: MixedExpr[A]): Boolean = 
e match{
    case TT => true
    case FF => false
    case Band(left, right) => boolExpr(left) && boolExpr(right)
    case Bor(left, right) => boolExpr(left) || boolExpr(left)
    case Bnot(value) => !boolExpr(value)
}

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
