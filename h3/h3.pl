
isBinTree(empty).
isBinTree(node(L,_,R)) :- isBinTree(L), isBinTree(R).

isLeafTree(leaf(_)).
isLeafTree(branch(L,R)) :- isLeafTree(L), isLeafTree(R).


/*convert a tree into a list*/
/*BinTree flatten*/
flatten(empty,[]).
flatten(node(L,T,R),Z) :- isBinTree(node(L,T,R)), flatten(L,A), flatten(R,B), append(A,[T],Z1),append(Z1,B,Z).

/*LeafTree flatten*/
flatten(leaf(T),[T]).
flatten(branch(L,R),Z) :- isLeafTree(branch(L,R)), flatten(L,A), flatten(R,B), append(A,B,Z). 

/*Bubble sort */
bubbleSort(Unsorted, [H|Out]):-  swap(Unsorted, [H|T]),  bubbleSort(T, Out).
bubbleSort([],[]).

swap([],[]).
swap([A],[A]).
swap([H|T],[H,X|Y]):-swap(T,[X|Y]),H=<X.
swap([H|T],[X,H|Y]):-swap(T,[X|Y]),H>X.

/*convert a tree into a sorted list*/
elemsOrdered(T, L) :-  flatten(T, Z), bubbleSort(Z, L).

