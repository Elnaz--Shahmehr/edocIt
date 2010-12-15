-module(infoHash).
-export([get_sha/1, url_encode_Hash/1]).
-author("Elnaz Shahmehr").


get_sha(Data) ->

   crypto:start(),
    Sha_List = binary_to_list(crypto:sha(Data)),
    crypto:stop(),
    Sha_List.


url_encode_Hash(Data) ->

   lists:flatten([ "%" | string:join([string:right(Element, 2, $0) || Element <- [erlang:integer_to_list(Element, 16) || Element <- Data]], "%")]).




