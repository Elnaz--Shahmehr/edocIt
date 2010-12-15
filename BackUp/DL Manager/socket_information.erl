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
-module(socket_information).
-behaviour(gen_server).
-author("Elnaz shahmehr , Navid AmiriArshad").
%%% INCLUDE FILES

%%% START/STOP EXPORTS
-export([start/0,get_socket/0]).

%%% EXTERNAL EXPORTS
-export([]).

%%% INIT/TERMINATE EXPORTS
-export([init/1, terminate/2]).

%%% HANDLE MESSAGES EXPORTS
-export([handle_call/3, handle_cast/2, handle_info/2]).

%%% CODE UPDATE EXPORTS
-export([code_change/3]).

%%% MACROS


%%%-----------------------------------------------------------------------------
%%% START/STOP EXPORTS
%%%-----------------------------------------------------------------------------
start() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%%%-----------------------------------------------------------------------------
%%% EXTERNAL EXPORTS
%%%-----------------------------------------------------------------------------
get_socket()->
    gen_server:call(?MODULE, get_socket).

%%%-----------------------------------------------------------------------------
%%% INIT/TERMINATE EXPORTS
%%%-----------------------------------------------------------------------------
init([]) ->
    {ok, []}.


terminate(_Reason, _State) ->
    {terminate,socket_information}.



%%%-----------------------------------------------------------------------------
%%% HANDLE MESSAGES EXPORTS
%%%-----------------------------------------------------------------------------

handle_call(get_socket, _From, State) ->
   Connection = lists:keydelete(server,1,State),
   {reply,Connection,State}.

handle_cast(stop, State) ->
    {stop,normal,State}.

handle_info(_Info, _State) ->
    ok.

%%%-----------------------------------------------------------------------------
%%% CODE UPDATE EXPORTS
%%%-----------------------------------------------------------------------------
code_change(_OldVsn, _State, _Extra) ->
    ok.

%%%-----------------------------------------------------------------------------
%%% INTERNAL FUNCTIONS
%%%-----------------------------------------------------------------------------
