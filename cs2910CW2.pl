/* 3.1 Finding a path */

% doorway/2 definitions for the two bedroom house
doorway(livingroom, kitchen).
doorway(kitchen, porch1).
doorway(porch1, outside).

doorway(livingroom, corridor).
doorway(corridor, bedroom).
doorway(corridor, wc).
doorway(corridor, masterbedroom).

doorway(livingroom, porch2).
doorway(porch2, outside).

% connected/2 in terms of doorway and reverse
connected(Location1, Location2) :- 
    doorway(Location1, Location2) ; doorway(Location2, Location1).

% path/3 if origin is not valid
path(Origin, _, _) :- \+ connected(Origin, _), 
    format('~w not a valid origin.', Origin), fail.
% path/3 if destination is not valid
path(_, Destination, _) :- \+ connected(_, Destination), 
    format('~w not a valid destination.', Destination), fail.
% path/3 if both locations are valid
path(Origin, Destination, Path) :-
    find(Origin, Destination, [Origin], Way), % recursive call to find path
    reverse(Way, Path). % reverse backtracking stack

% find/4 backtracking search
find(Location1, Location2, Path, [Location2|Path]) :-
    connected(Location1, Location2).
find(Location1, Location2, Visited, Way) :-
    connected(Location1, Midpoint), 
    Midpoint \== Location2, 
    \+ member(Midpoint, Visited), 
    find(Midpoint, Location2, [Midpoint|Visited], Way).

/* 3.2 Paths ending at a common destination */

% bipath/4 for returning
bipath(Origin1,Origin2,Destination,Path) :-
    path(Origin1,Destination,Path1), % pathfind from origin1 to destination
    path(Origin2,Destination,Path2), % pathfind from origin2 to destination
    reverse(Path2,Path2Rev), % reverse path2 before joining to final path
    delete(Path2Rev,Destination,Path2Fix), % remove destination from path2 to avoid duplicated in result path
    append(Path1,Path2Fix,Path). % join both paths to final path