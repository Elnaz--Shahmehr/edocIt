-module(make_message).
-export([make/1,make/2,make/3]).
-author("Navid AmiriArshad , Elnaz Shahmehr").

make(keep_alive)->
    <<0:32>>;

make(choke)->
    <<1:32, 0:8>>;

make(unchoke)->
    <<1:32, 1:8>>;

make(interested)->
    <<1:32, 2:8>>;

make(uninterested)->
    <<1:32, 3:8>>.
make(have,PiceNum)->
    <<5:32,4:8,PiceNum:32>>.

make(request,PieceIndex,PieceOffset,PieceLength) ->
    <<13:32,6:8,PieceIndex:32,PieceOffset:32,PieceLength:32>>;

make(piece,PieceIndex,PieceOffset,BlockData)->
    <<(9+BlockData):32, 7:8,PieceIndex:32,PieceOffset:32,BlockData/bitstring>>.


make(handshake,InfoHash,PeerId)->
    <<19:8, "BitTorrent protocol", 0:8,InfoHash:20, PeerId:20>> .

