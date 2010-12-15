-module(check_piece).
-compile(export_all).
-author("Sepideh Fazlmashhadi").
-define(HASH_SIZE,20).%%macro


check_piece_file(TorrentFileName,PieceNumber)->
    Pieces =piece_handler:get_piece(TorrentFileName),
    Offset=(PieceNumber-1)*?HASH_SIZE,
    NewOffset=Offset+1,
    Piece=lists:sublist(Pieces,NewOffset,?HASH_SIZE),
    dohex(Piece).


check_downloaded_piece(TorrentFileName,FileName,PieceNumber)->
    code: add_path("/home/sepideh/Dropbox/edocIT/Project/Code/Parser"),
    Parsed=parseTorrent:parse(TorrentFileName),
    PieceSize=dict:fetch("piece length",(dict:fetch("info",Parsed))),
   %% io:format("~p",[PieceSize]),
    Offset=(PieceNumber-1) * PieceSize,
    File=file_manager:read(FileName,Offset,PieceSize),
    Piece=infoHash:get_sha([File]),
    %%lists:flatten(lists:map(fun(F) -> io_lib:format("~.16B", [F]) end,D)).
    dohex(Piece).



validate(TorrentFileName,Downloaded_file_name,PieceNumber)->
    Piece1 = check_piece_file(TorrentFileName,PieceNumber),
    Piece2=check_downloaded_piece(TorrentFileName,Downloaded_file_name,PieceNumber),
    Piece1=:= Piece2.



dohex(S)->
    Md5_bin =  erlang:md5(S),
    Md5_list = binary_to_list(Md5_bin),
    lists:flatten(list_to_hex(Md5_list)).
list_to_hex(L) ->
    lists:map(fun(X) -> int_to_hex(X) end, L).
int_to_hex(N) when N < 256 ->
    [hex(N div 16), hex(N rem 16)].

hex(N) when N < 10 ->
    $0+N;
hex(N) when N >= 10, N < 16 ->
    $a + (N-10).
