-module(piece_handler).
-export([get_info/1,get_piece/1]).
-author("Sepideh Fazlmashhadi").

get_info(File) ->
    code: add_path("/home/sepideh/Dropbox/edocIT/Project/Code/Parser"),
	{ok,Data} = file:read_file(File),
	[_,Info]= re:split(Data, "info"),
   %% io:format("Info: ~w~n",[Info]),
	[Info_Data,_] = re:split(Info, "pieces"),
    Pieces=get_piece(File),
   %% io:format("pieces: ~w~n",[Pieces]),
	NumberOfPieces= length(Pieces),
    io:format("Number of pieces: ~w~n",[NumberOfPieces]),
    Info2 = binary_to_list(Info_Data) ++ "pieces" ++ integer_to_list(NumberOfPieces) ++ ":" ++ Pieces ++ "e",
	Sha = infoHash:get_sha(Info2),
    Sha.

get_piece(File)->
    code: add_path("/home/sepideh/Dropbox/edocIT/Project/Code/Parser"),
    ParsedData=parseTorrent:parse(File),
    Pieces = dict:fetch("pieces",(dict:fetch("info",ParsedData))),
    Pieces.
