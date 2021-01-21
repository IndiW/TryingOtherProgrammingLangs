sealed trait ULTerm
case class ULVar(index: Int) extends ULTerm
case class ULAbs(t: ULTerm) extends ULTerm
case class ULApp(t1: ULTerm, t2: ULTerm) extends ULTerm


def prettify(t: ULTerm): String = {


    def tracker(t: ULTerm, q: collection.mutable.ArrayDeque[Int],count: Int): String = t match{
        case ULAbs(t) => 
            q.append(count)
            "" + tracker(t, q, count + 1)
        case _ => ""
    }

    val q = collection.mutable.ArrayDeque[Int]()
    tracker(t, q, 97)

    def prettify_helper(t: ULTerm,q: collection.mutable.ArrayDeque[Int], i: Int): String = t match {
        //Var case

        case ULVar(x) if q.isEmpty=> (x + 97).asInstanceOf[Char].toString
        case ULVar(x) => 
            (q.removeLast()).asInstanceOf[Char].toString

        //Abs case
        case ULAbs(t) =>
            "lambda " + (97 + i).asInstanceOf[Char].toString +" . " + prettify_helper(t,q,i + 1)

        //App case

        case ULApp(t1,t2) =>

        "(" + prettify_helper(t1,q,i) + ") (" + prettify_helper(t2,q, i) + ")"
    }

    prettify_helper(t,q,0)
}

