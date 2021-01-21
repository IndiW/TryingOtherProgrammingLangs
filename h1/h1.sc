//Part 1
//LeafTree children are nodes except for leaves which are value A
//BinTree children are elements A

sealed trait LeafTree[A]
case class Leaf[A](value: A) extends LeafTree[A]
case class Branch[A](left: LeafTree[A], right: LeafTree[A]) extends LeafTree[A]

sealed trait BinTree[A]
case class Node[A](value: A, left: BinTree[A] = null, right: BinTree[A] = null) extends BinTree[A]


sealed trait StructTree
case class SLeaf[B](value: B) extends StructTree
case class SNode[A](value: A, left: StructTree, right: StructTree) extends StructTree


def flatten[A](t: LeafTree[A]): List[A] =
t match{
    case Leaf(value) => List(value)
    case Branch(left, right) => List.concat(flatten(left), flatten(right))
}

def flattenBT[A](t: BinTree[A]): List[A]=
t match{
    //case Empty() => List()
    //case null => List()
    case Node(value, left, right) => List.concat(List.concat(flattenBT(left),List(value)),flattenBT(right))
    case _ => List()
}


def flattenStruct(t: StructTree): List[Any]=
    t match{
        case SNode(value, left, right) => List.concat(List.concat(flattenStruct(left),List(value)),flattenStruct(right))
        case SLeaf(value) => List(value)
        case _ => List()
    }

def orderedElems[A](t: LeafTree[A]): List[A]=
t match{
    case Leaf(value) => List(value)
    case Branch(left, right) => List.concat(flatten(left), flatten(right))
}
