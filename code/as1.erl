-module(as1).
-export([[new/0, destroy/1, write/3, delete/2, read/2, match/2,]).

new() -> [].

destroy(_) -> ok.

write(Key, Element, Db)->

    [{Key, Element}|Db].

delete(Key, Db) ->

      delete(Key, Db, []).

read(_Key, [{_Key, Element}|_]) -> 
       {ok, Element};read(Key, [_|T] -> 
    read(Key, T);
read(_, [])-> 
    {error, instance}.

match(Element, Db)-> 
    match(Element, Db, []).




    

    
    
    







    



    
    
