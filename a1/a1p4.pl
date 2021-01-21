
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