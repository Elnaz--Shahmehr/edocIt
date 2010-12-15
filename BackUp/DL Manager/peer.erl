-module(peer).
-compile(export_all).
-include("metaInfo.hrl").
-define(PORT,6881).
-author("Maryam Sepasi,Elnaz shahmehr").
% opens a connection

send_handshake(Host,Port,Handshake)->
[A,B,C,D] = string:tokens(Host,"."),
Ip = {list_to_integer(A),list_to_integer(B),list_to_integer(C),list_to_integer(D)},
io:format("Sending handshake to ~p at port ~p (~p)\n",[Ip,Port,Handshake]),
case gen_tcp:connect(Ip,Port,[binary,{packet,0},{active,false}])of
	 {ok,Socket}->
	     io:format("Connected to socket ~p\n",[Socket]),
	     ok = gen_tcp:send(Socket,Handshake),
	     get_request(Socket,[]),
	     io:format("sent handshake~n");
	 {error,Reason} ->
	     io:format("~p~n",[Reason])
     end.

get_request(Socket,BinaryList)->
    case gen_tcp:recv(Socket,0) of
	{ok,Binary}->
	    LeftOver = handle_message(list_to_binary([BinaryList|Binary]),Socket),
	    get_request(Socket,LeftOver);
	{error,Error} ->
	    io:format("Error: ~p\n",[Error]),
	    handle_message(BinaryList,Socket)
	end.

wait_for_handshake()->
    {ok,ListenSocket}= gen_tcp:listen(?PORT,[binary,{packet,0},{active,false}]),
    wait_connect(ListenSocket).

wait_connect(ListenSocket)->
    case gen_tcp:accept(ListenSocket) of
	{ok, Socket}->
	    spawn(?MODULE,get_request,[Socket,[]]),
	    wait_connect(ListenSocket);
	Other ->
	    io:format("accept returned~w- goodbye!~n",[Other]),
	    ok
    end.



handle_message(<<0,0,0,0,Rest/binary>>, Socket) ->
    io:format("recieved keepalive~n"),
    gen_tcp:send(Socket,<<0,0,0,0>>),
    Rest;

handle_message(<<0,0,0,1,0,Rest/binary>>, _Socket) ->
    io:format("recieved choke~n"),
    Rest;

handle_message(<<0,0,0,1,1,Rest/binary>>,Socket)->
    io:format("recieved unchoke~n"),
    gen_tcp:send(Socket,<<0,0,0,13,6,0,0,5,59,0,0,0,0,0,0,4,0>>),
    gen_tcp:send(Socket,<<0,0,0,13,6,0,0,9,89,0,0,0,1,0,0,4,0>>),
    Rest;

handle_message(<<0,0,0,1,2,Rest/binary>>, _Socket) ->
    io:format("recieved interested~n"),
    Rest;


handle_message(<<0,0,0,1,3,Rest/binary>>, _Socket) ->
    io:format("recieved notinterested~n"),
    Rest;

handle_message(<<0,0,0,5,4,Have:4/binary,Rest/binary>>,_Socket) ->
    io:format("recieved have on piece (~p)~n", [Have]),
    Rest;


handle_message(<<19,66,105,116,84,111,114,114,101,110,116,32,112,114,111,116,111,99,111,108,_Reserved:8/binary,InfoHash:20/binary,PeerId:20/binary,Rest/binary>>, Socket) ->
    io:format("recieved handshake on infohash (~s) from peer (~s)~n",[infoHash:url_encode_Hash(binary_to_list(InfoHash)),binary_to_list(PeerId)]),
    gen_tcp:send(Socket,<<0,0,0,1,2>>),
    Rest;


handle_message(<<19,66,105,116,84,111,114,114,101,110,116,32,112,114,111,116,111,99,111,108,_Reserved:8/binary,InfoHash:20/binary,Rest/binary>>, Socket) ->
    io:format("recieved handshake on infohash (~s) from peer anonymous~n",[infoHash:url_encode_Hash(binary_to_list(InfoHash))]),
    gen_tcp:send(Socket,<<0,0,0,1,2>>),
    Rest;


handle_message(<<Len:32/integer,5,More/binary>>,_Socket) ->
    NewLen=Len-1,
    case More of
	<<BitField:NewLen/binary,Rest/binary>> ->
	    io:format("recieved bitfild ~p bytes~n~p~n",[NewLen,BitField]),
	    Rest;
	Other ->
	    <<Len:32/integer,5,Other/binary>>
    end;

handle_message(<<Len:32/integer,7,Piece_index:4/binary,Block_offset:4/binary,More/binary>>,_Socket)->
    NewLen=Len-9,
    case More of
	<<Data:NewLen/binary,Rest/binary>> ->
	    io:format("recieved pieces on index ~p with offset ~p file data ~n~p~n",[Piece_index,Block_offset,Data]),
	    Rest;
	Other ->
	    <<Len:32/integer,7,Piece_index:1/binary,Block_offset:1/binary,Other/binary>>
    end;

handle_message(Message, _Socket) ->
    io:format("~p~n", [Message]),
    Message.

generate_handshake(Info_hash,Peer_id)->
    list_to_binary([19,"BitTorrent protocol",0,0,0,0,0,0,0,0,Info_hash,Peer_id]).
