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

% bipath/4 for returning bi-directional paths from origin1 to destination to origin2
bipath(Origin1, Origin2, Destination, Paths) :-
    path(Origin1, Destination, Path1), % pathfind from origin1 to destination
    path(Destination, Origin2, Path2), % pathfind from origin2 to destination (in reverse)
    delete(Path2, Destination, Path2Fix), % remove destination from path2 to avoid duplicated in result path
    append(Path1, Path2Fix, Paths). % join both paths to final path

% bipath_shortest/4 returns shortest path
bipath_shortest(Origin1, Origin2, Destination, Shortest) :-
    setof(Paths, bipath(Origin1, Origin2, Destination, Paths), PathSet), % get sorted set of possible paths
    PathSet = [Shortest|_]. % select the first path in the set, i.e. the shortest

/* 3.3 Paths with Costs */

doorway(outside,porch1,1).
doorway(porch1,kitchen,1).
doorway(kitchen,livingroom,3).
doorway(porch2,livingroom,5).
doorway(outside,porch2,1).
doorway(corridor,livingroom,1).
doorway(bedroom,corridor,2).
doorway(corridor,wc,2).
doorway(corridor,masterbedroom,2).