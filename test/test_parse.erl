-module(test_parse).
-include_lib("eunit/include/eunit.hrl").
-compile(export_all).


parse_test_() ->
	{setup, fun setup/0, fun teardown/1,
     [fun ?MODULE:parse/0,
      fun ?MODULE:get_sha/0,
      fun ?MODULE:url_encode_hash/0]
	}.





%%---------------------------------------
%%---------------------------------------

setup() ->
    application:start(parseTorrent).

teardown(_) ->
    application:stop(parseTorrent).


parse() ->
    code:add_path("/home/maryam/Desktop/test_edocIT/test_codes/Parser"),
    A = parseTorrent:parse(book.torrent),
    [?assertEqual("udp://tracker.openbittorrent.com:80/announce",dict:fetch("announce",A)),
     ?assertEqual("kubuntu-9.10-netbook-i386.iso",dict:fetch("name",dict:fetch("info",A))),
     ?assertEqual(817016832,dict:fetch("length",dict:fetch("info",A)))].

get_sha()->
    ?assertEqual([200,25,203,44,77,202,121,123,161,201,68,200,173,106,85,53,140,25,224,113],
                 infoHash:get_sha("book.torrent")).

url_encode_hash()->
    ?assertEqual("%62%6F%6F%6B%2E%74%6F%72%72%65%6E%74",infoHash:url_encode_Hash("book.torrent")).

