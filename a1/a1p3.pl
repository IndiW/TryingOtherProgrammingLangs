isVarExpr(constE(_)).
isVarExpr(minusE(L,R)) :- isVarExpr(L), isVarExpr(R).
isVarExpr(absE(V)) :- isVarExpr(V).
isVarExpr(plusE(L,R)) :- isVarExpr(L), isVarExpr(R).
isVarExpr(expE(L,R)) :- isVarExpr(L), isVarExpr(R).
isVarExpr(negE(V)) :- isVarExpr(V).
isVarExpr(var(_)).
isVarExpr(subst(E,_,F)) :- isVarExpr(E),isVarExpr(F).


interp(constE(X),Z) :- Z is X.
interp(minusE(L,R), Z) :- interp(L,A),interp(R,B),Z is (A - B).
interp(absE(V),Z) :- interp(V,A), Z is (abs(A)).
interp(plusE(L,R),Z) :- interp(L,A),interp(R,B),Z is (A + B).
interp(expE(L, R),Z) :- interp(L,A),interp(R,B),Z is (A**B).
interp(negE(V),Z) :- interp(V,A), Z is (-A).

interp(var(A), Z) :- Z = A.
interp(subst(E,X,F), Z) :- interp(E,X) ,Z is F.


interpretVarExpr(E, X) :- isVarExpr(E), interp(E, Z), Z is X.