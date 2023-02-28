% 3.1 Finding a path

location(outside).
location(porch1).
location(porch2).
location(livingroom).
location(kitchen).
location(corridor).
location(wc).
location(bedroom).
location(masterbedroom).

% doorway definitions for the two bedroom house
doorway(livingroom,kitchen).
doorway(kitchen,porch1).
doorway(porch1,outside).

doorway(livingroom,corridor).
doorway(corridor,bedroom).
doorway(corridor,wc).
doorway(corridor,masterbedroom).

doorway(livingroom,porch2).
doorway(porch2,outside).

% connected/2 in terms of doorway and reverse
connected(Location1,Location2) :- doorway(Location1,Location2) ; doorway(Location2,Location1).

% path/3 definition
path(Origin,Destination,Path) :-
    find(Origin,Destination,[Origin],Way),
    reverse(Way,Path).

% find/4 backtracking search
find(Origin,Destination,Path,[Destination|Path]) :-
    connected(Origin,Destination).
find(Origin,Destination,Visited,Way) :-
    connected(Origin,Midpoint),
    Midpoint \== Destination,
    \+ member(Midpoint,Visited),
    find(Midpoint,Destination,[Midpoint|Visited],Way).
