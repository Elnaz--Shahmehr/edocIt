-module(file_manager).
-compile(export_all).
-include("piece.hrl").
-author("Sepideh Fazlmashhadi").

start(File,Offset,Data)->
    case startDl(File,Offset) of
        ok->
            spawn(?MODULE,loop,[File,Offset,Data]);
        %% io:format("dowloading in progress  ");
        {error,Reason}->
            {error,Reason}
    end.

startDl(File,Offset)->
     Size=Offset-1,

    case file:open(File,[write]) of
        {ok,IoDevice}->
            case file:pwrite(IoDevice,Size,[0]) of
                ok->
                    file:close(IoDevice),
                    ok;
                {error,Reason}->
                    {error,Reason}
            end;
        {error,Reason}->
            {error,Reason}
    end.

write(File,Path,Offset,Data)->
    file:set_cwd(Path),
    {ok,Io}=file:open(File,[write,read,binary]),
    {ok,_}=file:position(Io,{bof,Offset}), %%absoulute offset
    file:write(Io,Data),
    file:close(Io).

read(File,Offset,Length)->
    {ok, Io} = file:open(File, [read, raw]),
    {ok, ReadData} = file:pread(Io, Offset, Length),
    file:close(Io),
    ReadData.


check(TorrentFileName,Downloaded_file_name,PieceNumber)->
    case(check_piece:validate(TorrentFileName,Downloaded_file_name,PieceNumber)) of
        true->
            NewPiece=#piece{verified=true, status=downloaded},
            io:format("~p",[NewPiece]);

        false->
            NewPiece=#piece{verified=false, status=not_downloading},
            io:format("~p",[NewPiece])
    end.
