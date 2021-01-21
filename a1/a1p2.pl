isExpr(constE(_)).
isExpr(minusE(L,R)) :- isExpr(L), isExpr(R).
isExpr(absE(V)) :- isExpr(V).
isExpr(plusE(L,R)) :- isExpr(L), isExpr(R).
isExpr(expE(L,R)) :- isExpr(L), isExpr(R).
isExpr(negE(V)) :- isExpr(V).



interp(constE(X),Z) :- Z is X.
interp(minusE(L,R), Z) :- interp(L,A),interp(R,B),Z is (A - B).
interp(absE(V),Z) :- interp(V,A), Z is (abs(A)).
interp(plusE(L,R),Z) :- interp(L,A),interp(R,B),Z is (A + B).
interp(expE(L, R),Z) :- interp(L,A),interp(R,B),Z is (A**B).
interp(negE(V),Z) :- interp(V,A), Z is (-A).
interpretExpr(E, X) :- isExpr(E), interp(E, Z), Z is X.