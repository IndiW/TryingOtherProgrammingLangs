hasDivisorLessThanOrEqualTo(_,1) :- !, false.
hasDivisorLessThanOrEqualTo(X,Y) :- 0 is X mod Y, !.
hasDivisorLessThanOrEqualTo(X,Y) :- Z is Y - 1, hasDivisorLessThanOrEqualTo(X,Z).

isPrime(X) :- X is 2.
isPrime(X) :- not(hasDivisorLessThanOrEqualTo(X, X - 1)).


isDigitList(_,[]) :- false.
isDigitList(X,[X]) :- X is X mod 10.
isDigitList(X,[H|T]) :- H is X mod 10, X1 is X // 10,X1 > 0,isDigitList(X1,T).

isPalindrome(X) :- reverse(X,X).

primePalindrome(X) :- isPrime(X), isDigitList(X,Y), isPalindrome(Y).

