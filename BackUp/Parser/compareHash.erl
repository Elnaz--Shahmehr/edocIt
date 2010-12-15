-module(compareHash).
-export([compareHashes/2,compareSha/2]).
-author("sepideh.Fazlmashhadi,Elnaz.Shahmehr").


compareHashes(Sha,Chunk)->
     HashData=infoHash:get_sha(Chunk),
     is_equal(Sha,HashData).

compareSha(Same,Other)->
    is_equal(Same,Other).

is_equal(Same,Same)->
    true;
is_equal(_,_)->
    false.
