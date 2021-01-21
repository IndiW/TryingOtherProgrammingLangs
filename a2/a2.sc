import $file.a2_ulterm, a2_ulterm._

sealed trait STType
case object STNat extends STType {
  override def toString() = "nat"
}
case object STBool extends STType {
  override def toString() = "bool"
}
// Functions have a domain type and a codomain type.
case class STFun(dom: STType, codom: STType) extends STType {
  override def toString() = "(" + dom.toString + ") -> (" + codom.toString + ")"
}

// Example use: the type "nat -> bool" is written STFun(STNat,STBool)



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

def eraseTypes(t: STTerm): ULTerm = t match {
    case STVar(index) => ULVar(index)
    case STTrue => ULAbs(ULAbs(ULVar(1)))
    case STZero => ULAbs( // lambda s .
                    ULAbs( // lambda z .
                    ULVar(0)))
    case STFalse => ULAbs(ULAbs(ULVar(0)))
    case STSuc(t) => ULApp(
                        // Encoding of suc
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

