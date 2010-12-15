-module(itemManager).
-export([start/0, stop/0, init/0, addItem/0, setItem/2, 
	 removeItem/1, getStatus/1]).

start()->
    register(?MODULE, spawn(?MODULE,init,[])),
    ok.

stop()->
    ?MODULE ! stop,
    ok.
    
init()->
    loop([], normal).

addItem()->
    ?MODULE ! add,
    ok.

setItem(Key, Status)->
    ?MODULE ! {set, Key, Status},
    ok.

removeItem(Key)->
    ?MODULE ! {remove, Key},
    ok.
          
getStatus(Key)->
    ?MODULE ! {self(), get, Key},
    receive 
	Reply ->
	    Reply
    end.

loop(Db, View)->
    receive
	add->  
	    NewDb = db_fun: save(0, waiting, Db),
	    loop(NewDb, View);
	{set, Key, Status} ->
	    NewDb = db_fun: replace(Key, Status, Db, []),
	    loop(NewDb, View);
	{remove, Key}->
	    NewDb = db_fun: delete(Key, Db),
	    loop(NewDb, View);
	{Pid, get, Key}->
	    Status = db_fun: read(Key, Db),
	    Pid ! Status,
	    loop(Db, View);
	stop->
	    unregister(?MODULE)
    end.


