-module(break_up_message).
-export([break_up/1,break_up/2]).
-author("Elnaz shahmehr,Navid AmiriArshad").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%in break_up_message module we have break_up functions
%hat Matched length and id
%then returns type and length/bytes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

break_up(<<0:32>>)->
                io:format("recieved keep_alive~n"),
{keep_alive,0}.
break_up(<<1:32>>,<<0:8>>) ->
    io:format("recieved choke~n"),
    {choke,0};

break_up(<<1:32>>,<<1:8>>) ->
   io:format("recieved unchoke~n"),
    {unchoke,0};

break_up(<<1:32>>,<<2:8>>) ->
  io:format("recieved interested~n"),
      {interested,0};

break_up(<<1:32>>,<<3:8>>) ->
  io:format("recieved not_interested~n"),
    {not_interested,0};

break_up(<<5:32>>,<<4:8>>) ->
  io:format("recieved have~n"),
    {have,4};

break_up(<<Length:32>>,<<5:8>>) ->
  io:format("recieved bitfield~n"),
    {bitfield,Length-1};

break_up(<<13:32>>,<<6:8>>)->
  io:format("recieved request~n"),
    {request,12};

break_up(<<Length:32>>,<<7:8>>)->
  io:format("recieved piece~n"),
    {piece,Length-1};

break_up(<<13:32>>,<<8:8>>)->
  io:format("recieved cancel~n"),
    {cancel,12};

break_up(handshake,Handshake)->
    <<InfoHash:20 , PeerID:20>> = Handshake,
    {InfoHash,PeerID}.


