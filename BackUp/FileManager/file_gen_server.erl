%%% Copyright (c) 2009 Nomasystems, S.L., All Rights Reserved
%%%
%%% This file contains Original Code and/or Modifications of Original Code as
%%% defined in and that are subject to the Nomasystems Public License version
%%% 1.0 (the 'License'). You may not use this file except in compliance with
%%% the License. BY USING THIS FILE YOU AGREE TO ALL TERMS AND CONDITIONS OF
%%% THE LICENSE. A copy of the License is provided with the Original Code and
%%% Modifications, and is also available at www.nomasystems.com/license.txt.
%%%
%%% The Original Code and all software distributed under the License are
%%% distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
%%% EXPRESS OR IMPLIED, AND NOMASYSTEMS AND ALL CONTRIBUTORS HEREBY DISCLAIM
%%% ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF
%%% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR
%%% NON-INFRINGEMENT. Please see the License for the specific language
%%% governing rights and limitations under the License.
-module(file_gen_server).
-behaviour(gen_server).
-author("Sepideh Fazlmashhadi").

%%% INCLUDE FILES

%%% START/STOP EXPORTS
-export([start_link/0,stop/0,write/4,read/3]).

%%% INIT/TERMINATE EXPORTS
-export([init/1,terminate/2]).

%%% HANDLE MESSAGES EXPORTS
-export([handle_call/3, handle_cast/2, handle_info/2]).

-export([code_change/3]).


%%%-----------------------------------------------------------------------------
%%% START/STOP EXPORTS
%%%-----------------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%%%-----------------------------------------------------------------------------
%%% EXTERNAL EXPORTS
%%%-----------------------------------------------------------------------------
stop() ->
    gen_server:cast(?MODULE, stop).

write(File,Path,Offset,Data) ->
    gen_server:cast(?MODULE, {write, File,Path,Offset,Data}).

read(File,Offset,Length) ->
    gen_server:call(?MODULE, {read,File,Offset,Length}).

%%%-----------------------------------------------------------------------------
%%% INIT/TERMINATE EXPORTS
%%%-----------------------------------------------------------------------------
init([]) ->
   {ok, io:format("init")}.


terminate(_Reason, _St) ->
    io:format("In terminate\n").

%%%-----------------------------------------------------------------------------
%%% HANDLE MESSAGES EXPORTS
%%%-----------------------------------------------------------------------------
handle_call({read,File,Offset,Length}, _From,St) ->
    {reply,read_function(File,Offset,Length),St}.

handle_cast(stop, St) ->
    io:format("In handle_cast\n"),
    {stop, normal, St};

handle_cast({write,File,Path,Offset,Data }, _St) ->
    io:format("In write\n"),
    {noreply, write_function(File,Path,Offset,Data)}.

handle_info(_Info, St) ->
    {noreply, St}.

%%%-----------------------------------------------------------------------------
%%% CODE UPDATE EXPORTS
%%%----------------------------------------------------------------------------
code_change(_OldVsn, St, _Extra) ->
    {ok, St}.

%%%-----------------------------------------------------------------------------
%%% INTERNAL FUNCTIONS
%%%-----------------------------------------------------------------------------
write_function(File,Path,Offset,Data)->
    file:set_cwd(Path),
    {ok,Io}=file:open(File,[write,read,binary]),
    {ok,_}=file:position(Io,{bof,Offset}), %%absoulute offset
    file:write(Io,Data),
    file:close(Io).

read_function(File,Offset,Length)->
    io:format("inRead\n"),
    {ok, Io1} = file:open(File, [read, raw]),
    {ok, ReadData} = file:pread(Io1, Offset, Length),
    file:close(Io1),
    ReadData.
