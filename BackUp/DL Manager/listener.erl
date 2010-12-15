-module(listener).
-export([start_listening/1, listen/1, ok_connection/1,
	create_socket/0]).
-author("Elnaz Shahmehr,Navid AmiriArshad").


create_socket() ->
    [binary, {reuseaddr, true}, {active, false}].

start_listening(Port) ->
    spawn_link(?MODULE, listen, [Port]).

listen(Port)->
    Options = create_socket(),
      case gen_tcp:listen(Port, Options) of
	{ok, LSocket} ->
	    ok_connection(LSocket);
	{error, Reason} ->
	    io:format("~p~n",[Reason])
    end.

ok_connection(ServerSocket) ->
    {ok, ClientSocket} = gen_tcp:accept(ServerSocket),
    [A,B,C,D] = string:tokens(ServerSocket,"."),
     IP = {list_to_integer(A),list_to_integer(B),list_to_integer(C),list_to_integer(D)},
    gen_event:start({local, IP}),
    gen_event:add_handler(IP, peer,  {ClientSocket, _, _, _, _, _}),
    % Continue listening on the socket.
    ok_connection(ServerSocket).

