/* 3.1 Finding a path

To get possible path(s) P from O to D, run

    path(O, D, P).

For example, to find path(s) from the bedroom to the kitchen, the command will be

    path(bedroom, kitchen, P).

which returns two possible paths:

    P = [bedroom, corridor, livingroom, kitchen] ;
    P = [bedroom, corridor, livingroom, porch2, outside, porch1, kitchen] .

path/3 also handles wrong input. If we enter an invalid location, for example:

    path(bedroom, garden, P).

it returns

    garden not a valid destination.
    false.

 */

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

% find/4 backtracking search, referenced from Tutorial 4.1
find(Location1, Location2, Path, [Location2|Path]) :-
    connected(Location1, Location2).
find(Location1, Location2, Visited, Way) :-
    connected(Location1, Midpoint), 
    Midpoint \== Location2, 
    \+ member(Midpoint, Visited), 
    find(Midpoint, Location2, [Midpoint|Visited], Way).

/* 3.2 Paths ending at a common destination 

To get possible path(s) between O1, D, O2, run

    bipath(O1, O2, D, P).

For example, to get path(s) from bedroom, via kitchen, to outside, the command looks like this:

    bipath(bedroom, outside, kitchen, P).

which returns: 

    P = [bedroom, corridor, livingroom, kitchen, porch1, outside] ;
    P = [bedroom, corridor, livingroom, kitchen, livingroom, porch2, outside] ;
    P = [bedroom, corridor, livingroom, porch2, outside, porch1, kitchen, porch1, outside] ;
    P = [bedroom, corridor, livingroom, porch2, outside, porch1, kitchen, livingroom, porch2, outside] .

By reusing path/3 from 3.1, there is error checking for locations as well.

*/

% bipath/4 for returning bi-directional paths from origin1 to destination to origin2
bipath(Origin1, Origin2, Destination, Paths) :-
    path(Origin1, Destination, Path1), % pathfind from origin1 to destination
    path(Destination, Origin2, Path2), % pathfind from origin2 to destination (in reverse)
    delete(Path2, Destination, Path2Fix), % remove destination from path2 to avoid duplicated in result path
    append(Path1, Path2Fix, Paths). % join both paths to final path

% bipath_shortest/4 returns shortest path
bipath_shortest(Origin1, Origin2, Destination, Shortest) :-
    setof(Paths, bipath(Origin1, Origin2, Destination, Paths), PathSet), % get set of possible paths
    list_shortest(PathSet, Shortest). % call predicate to get shortest list from set of paths

% list_shortest/2 returns shortest list out of a given set
list_shortest(Set, Shortest) :-
    maplist(length, Set, LengthList), % make a list of lengths of lists from set
    min_list(LengthList, ShortestLength), % get the shortest length of the set
    member(Shortest, Set), % limit Shortest item to be member of orignal set
    length(Shortest, ShortestLength). % get the SHortest item with the shortest length

/* 3.3 Paths with Costs */

% doorway/3 definitions for the two bedroom house with cost
doorway(outside, porch1, 1).
doorway(porch1, kitchen, 1).
doorway(kitchen, livingroom, 3).
doorway(porch2, livingroom, 5).
doorway(outside, porch2, 1).
doorway(corridor, livingroom, 1).
doorway(bedroom, corridor, 2).
doorway(corridor, wc, 2).
doorway(corridor, masterbedroom, 2).

% connected/3 in terms of doorway/3 and reverse
connected(Location1, Location2, Cost) :- 
    doorway(Location1, Location2, Cost) ; doorway(Location2, Location1, Cost).

% path/4 if origin is not valid
path(Origin, _, _, _) :- \+ connected(Origin, _), 
    format('~w not a valid origin.', Origin), fail.
% path/4 if destination is not valid
path(_, Destination, _, _) :- \+ connected(_, Destination), 
    format('~w not a valid destination.', Destination), fail.
% path/4 if both locations are valid
path(Origin, Destination, Path, Cost) :-
    find(Origin, Destination, [Origin], Way, Cost), % recursive call to find path
    reverse(Way, Path). % reverse backtracking stack

% find/5 backtracking search, referenced from Tutorial 4.2
find(Location1, Location2, Path, [Location2|Path], Cost) :-
    connected(Location1, Location2, Cost).
find(Location1, Location2, Visited, Way, Cost) :-
    connected(Location1, Midpoint, Distance), 
    Midpoint \== Location2, 
    \+ member(Midpoint, Visited), 
    find(Midpoint, Location2, [Midpoint|Visited], Way, NextDistance), 
    Cost is Distance + NextDistance.

% path_ranked/3 returns a list of paths ranked by cost
path_ranked(Origin, Destination, RankedPaths) :-
    findall((Costs-Paths), path(Origin, Destination, Paths, Costs), PathPairs), % get pairs of possible paths and cost
    keysort(PathPairs, RankedPairs), % sort the pair with cost (key)
    pairs_values(RankedPairs, RankedPaths). % get only the path (value) from the pairs

% bipath_same_cost/4 for returning bi-directional paths only if O1>D cost == O2>D cost
bipath_same_cost(Origin1, Origin2, Destination, Paths) :-
    path(Origin1, Destination, Path1, Cost1), % pathfind and cost from origin1 to destination
    path(Destination, Origin2, Path2, Cost2), % pathfind and cost from origin2 to destination (in reverse)
    Cost1 == Cost2, % check if costs from both sides are the same
    delete(Path2, Destination, Path2Fix), % if cost same, remove destination from path2 to avoid duplication
    append(Path1, Path2Fix, Paths). % join both paths to final path