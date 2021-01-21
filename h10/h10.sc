import scala.concurrent.Future
import scala.concurrent.Await
import scala.concurrent.duration._
import scala.language.postfixOps
import scala.concurrent.ExecutionContext.Implicits.global
import scala.util.{Try, Success, Failure}


def summingPairs(xs: Vector[Int], sum: Int): Future[Vector[Tuple2[Int,Int]]] = {
  def summingPairsHelper(xs: Vector[Int],
                         the_pairs: Future[Vector[Tuple2[Int,Int]]]): Future[Vector[Tuple2[Int,Int]]] =
    xs match {
      case fst +: rest =>
        // Search through `rest` for numbers `snd` such that `fst + snd` is the `sum`.
        val pairs_here = Future { rest.collect({case snd if fst + snd <= sum => (fst,snd)})}
        // Make the recursive call, adding in the pairs we just found.

        summingPairsHelper(rest, Future.reduce(List(pairs_here,the_pairs))(_++_))

    
      case _ => the_pairs
    }
  
  summingPairsHelper(xs,Future{Vector()})
}
