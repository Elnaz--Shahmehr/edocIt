-module(parseTorrent).
-export([parse/1]).
-author("Maryam Sepasi & Sepideh Fazlmashhadi").


parse(File) ->
    {ok, Binary} = file:read_file(File),
    Data = binary_to_list(Binary),
    dec(Data).

dec(Data) ->
   {Dictionary,[]} = decode(Data),
    Dictionary.

decode([$l|Tail])->
    decode_list(Tail);
decode([$i|Tail])->
    decode_integer(Tail);
decode([$d|Tail])->
    decode_dic(Tail, dict:new());
decode(Data) ->
    decode_string(Data).

decode_list(Data)->
    decode_list(Data,[]).

decode_list([$e|Tail],Buffer)->
    {lists:reverse(Buffer),Tail};
decode_list(Data,Buffer)->
    {Res,Tail}=decode(Data),
    decode_list(Tail,[Res|Buffer]).

decode_integer([H|T]) when (H > 47) and (H < 58)->
    decode_integer(T,H-48).
decode_integer([H|T],Buffer) when (H > 47) and (H < 58)->
    decode_integer(T,Buffer*10+H-48);
decode_integer([_|T],Buffer)->
    {Buffer,T}.

decode_string(Data) ->
    {Length,Rest}=decode_integer(Data),
    counter(Rest,Length,[]).

counter(T,0,Acc)->
      {lists:reverse(Acc), T};
counter([H|T],Buffer,Acc)->
    counter(T,Buffer-1,[H|Acc]).


decode_dic([$e|T],Dictionary)->
				    {Dictionary,T};
decode_dic(Data,Dictionary)->
				    {Key,Data_Tail} = decode_string(Data),
				    {Value,Tail} = decode(Data_Tail),
				    New_Dictionary = dict:store(Key,Value, Dictionary),
				    decode_dic(Tail,New_Dictionary).

