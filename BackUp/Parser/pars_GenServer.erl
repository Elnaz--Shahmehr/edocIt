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
-module(pars_GenServer).
-behaviour(gen_server).
-author("Elnaz Shahmehr & Sepideh Fazlmashhadi").
-export([start_link/1,stop/0,recieve_torrent_data/1,compare_hash/2,get/1]).
-export([handle_cast/2,handle_call/3,init/1,terminate/2,handle_info/2]).
-export([code_change/3]).

%%% MACROS


%%%-----------------------------------------------------------------------------
%%% START/STOP EXPORTS
%%%-----------------------------------------------------------------------------
start_link(File) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [File], []).

stop()->
    gen_server:cast(?MODULE, stop).

%%%-----------------------------------------------------------------------------
%%% EXTERNAL EXPORTS
%%%-----------------------------------------------------------------------------

%%%-----------------------------------------------------------------------------
%%% INIT/TERMINATE EXPORTS
%%%-----------------------------------------------------------------------------
init(File) ->
    {ok,parseTorrent:parse(File)}.


terminate(_Reason, _Something) ->
    ok.

%%%-----------------------------------------------------------------------------
%%% HANDLE MESSAGES EXPORTS
%%%-----------------------------------------------------------------------------
handle_cast(Req, St) ->
    erlang:error(function_clause, [Req, St]).

handle_call({get,Key},_From,State)->
    {reply,dict:fetch(Key,State), State};


handle_call(encoded_hash_info,_From, State)->
	Info = dict:fetch("Info", State),
      Hash = infoHash:url_encode_Hash(Info),
    {reply, Hash ,State}.

handle_info(_Info, St) ->
    {noreply, St}.

code_change(_OldVsn, St, _Extra) ->
    {ok, St}.




%%%-----------------------------------------------------------------------------
%%% CODE UPDATE EXPORTS
%%%-----------------------------------------------------------------------------

%%%-----------------------------------------------------------------------------
%%% INTERNAL FUNCTIONS
%%%-----------------------------------------------------------------------------

get(Key) ->
     gen_server:call(?MODULE, {get,Key}).


recieve_torrent_data(Name_of_torrent)->
    parseTorrent:parse(Name_of_torrent).

compare_hash(Sha,Chunk)->
    compareHash:compareHashes(Sha,Chunk).
