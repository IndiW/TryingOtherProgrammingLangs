//Author: Indika Wijesundera
//Homework 4

//infinite data type
sealed trait Stream[+A]
case object SNil extends Stream[Nothing]
case class Cons[A](a: A, f: Unit => Stream[A]) extends Stream[A]


//Convert stream to a list
def take[A](n: Int, s: => Stream[A]): List[A] = s match {
  case SNil => Nil
  case Cons(a,f) => n match {
    case n if n > 0 => a :: take(n-1,f()) //prepends a to take(n-1,f())
    case _ => Nil
    }
  }

//Filters values from a stream based on a condition
def filter[A](p: (A) => Boolean, s: => Stream[A]): Stream[A] = s match{
    case SNil => s
    case Cons(a, f) => if (p(a)) Cons(a,_=>filter(p,f())) else filter(p,f())
}

//Combines two streams such that values are saved in tuples
def zip[A](s: => Stream[A], t: => Stream[A]): Stream[(A,A)] = s match{
    //case SNil => (Nil, Nil)
    case Cons(a, f) => t match{
        //case _ => (Nil, Nil)
        case Cons(b, g) => Cons((a, b), _=> zip(f(),g()))
    }
}

//Merges two streams
def merge[A](s: => Stream[A], t: => Stream[A]): Stream[A] = s match{
  case Cons(a, f) => Cons(a, _=> merge(t,f()))
}

//Checks if all values in a stream return True for a given condition
def all[A](p: (A) => Boolean, s: => Stream[A]): Boolean = s match{
    case SNil => True
    case Cons(a, f) => if (p(a)) all(p, f()) else False
}

//Checks if at least one value in a stream returns True for a given condition
def exists[A](p: (A) => Boolean, s: => Stream[A]): Boolean = s match{
    case SNil => False
    case Cons(a, f) => if (p(a)) True else exists(p, f())
}


