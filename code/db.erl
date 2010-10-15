%% Author: Jon Kristensen
%% Created: Sep 10, 2010
%% Description: [...]
%%This is arif from maryams computer!
-module(db).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([new/0, destroy/1, write/3, delete/2, read/2, match/2]).

%%
%% API Functions
%%
new() -> [].

destroy(_) -> ok.

write(Key, Element, Db) -> [{Key, Element}|Db].

delete(Key, Db) -> delete(Key, Db, []).

read(_Key, [{_Key, Element}|_]) -> {ok, Element};
read(Key, [_|T])                -> read(Key, T);
read(_, [])                     -> {error, instance}.

match(Element, Db) -> match(Element, Db, []).

%%
%% Local Functions
%%
delete(_, [], NewDb)             -> NewDb;
delete(Key, [{Key, _}|T], NewDb) -> delete(Key, T, NewDb);
delete(Key, [H|T], NewDb)        -> delete(Key, T, [H|NewDb]).

match(_, [], Selection)                       -> Selection;
match(Element, [{Key, Element}|T], Selection) -> match(Element, T, [Key|Selection]);
match(Element, [_|T], Selection)              -> match(Element, T, Selection).

