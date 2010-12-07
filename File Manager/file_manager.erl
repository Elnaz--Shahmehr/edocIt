-module(file_manager).
-compile(export_all).
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
    %% Size=FileSize-1,

    case file:open(File,[write]) of
        {ok,IoDevice}->
            case file:pwrite(IoDevice,Offset,[0]) of
                ok->
                    file:close(IoDevice),
                    ok;
                {error,Reason}->
                    {error,Reason}
            end;
        {error,Reason}->
            {error,Reason}
    end.

writing(File,Offset,Data)->
    {ok,Io}=file:open(File,[write,read,binary]),
    {ok,_}=file:position(Io,{bof,Offset}), %%absoulute offset
    file:write(Io,Data),
    file:close(Io).

read(File,Offset,Length)->
    {ok, Io} = file:open(File, [read, raw]),
    {ok, ReadData} = file:pread(Io, Offset, Length),
    file:close(Io),
    ReadData.

loop(File,Offset,Data)->
    receive
        {dowloading,File}->
            startDl(File,Offset),
            loop(File,Offset,Data);
        {write,File }->
            writing(File,Offset,Data),
            loop(File,Offset,Data);
        {read,File}->
            read(File,Offset,Data),
            loop(File,Offset,Data)


    end.

