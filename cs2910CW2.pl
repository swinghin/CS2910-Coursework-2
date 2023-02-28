% 3.1 Finding a path

% doorway/2 definitions for the two bedroom house
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

% path/3 definition, returns path from origin to destination if exists
path(Origin,Destination,Path) :-
    orig_valid(Origin), % check if origin is valid
    dest_valid(Destination), % check if destination is valid
    find(Origin,Destination,[Origin],Way), % recursive call to find path
    reverse(Way,Path). % reverse backtracking stack

% find/4 backtracking search
find(Location1,Location2,Path,[Location2|Path]) :-
    connected(Location1,Location2).
find(Location1,Location2,Visited,Way) :-
    connected(Location1,Midpoint),
    Midpoint \== Location2,
    \+ member(Midpoint,Visited),
    find(Midpoint,Location2,[Midpoint|Visited],Way).

% locations/1 defines a list of valid locations
locations([outside,porch1,porch2,livingroom,kitchen,corridor,wc,bedroom,masterbedroom]).

% location_valid/1 returns if location exists in locations list
location_valid(Location) :-
    locations(Locations), % loads locations list
    member(Location, Locations), !. % check variable is member of list
location_valid(_) :- fail. % return false if not valid

orig_valid(Location) :- location_valid(Location), !.
orig_valid(Location) :- \+ location_valid(Location),
    format('~w not a valid origin.', Location), fail.

dest_valid(Location) :- location_valid(Location), !.
dest_valid(Location) :- \+ location_valid(Location),
    format('~w not a valid destination.', Location), fail.
    