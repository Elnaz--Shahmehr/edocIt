-module(db_fun).
-compile(export_all).

save(Key, Element, Db)->
    [{Key, Element}|increase_key(Db)].   

read(_,[]) -> stop;
read(Key, [{Key, Element}|_]) ->
    Element;
read(Key, [_|T]) ->
    read(Key, T).

replace(_, _, [], NewList) -> 
    NewList;
replace(Key, Status, [{Key, _}|T], NewList) ->
    lists: reverse(NewList) ++ [{Key, Status}] ++ T;
replace(Key, Status, [H|T], NewList)->
    replace(Key, Status, T, [H|NewList]).

delete(Key, [{Key,_}|T])->
    reduce_key(T);
delete(Key, [H|T])->
    [H|delete(Key, T)];
delete(_Key, []) ->
    [].

reduce_key([])->
    [];
reduce_key([{Key, Element}|T]) ->
    [{Key - 1, Element}|reduce_key(T)].

increase_key([])->
    [];
increase_key([{Key, Element}|T]) ->
    [{Key + 1, Element}|increase_key(T)].
