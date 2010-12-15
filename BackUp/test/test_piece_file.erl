-module(test_piece_file).
-include_lib("eunit/include/eunit.hrl").
-compile(export_all).
-author('Maryam Sepasi').


piece_file_test_() ->
	{setup, fun setup/0, fun teardown/1,
     [fun ?MODULE:validating/0,
      fun ?MODULE:checking_piece_file/0,
      fun ?MODULE:checking_downloaded_piece/0,
      fun ?MODULE:reading/0,
      fun ?MODULE:writing/0
     ]
	}.


%%-----------------------------------------------
%%-----------------------------------------------


setup() ->
    application:start(check_piece).

teardown(_) ->
    application:stop(check_piece).


validatig()->
    %%      code:add_path("/home/maryam/Dropbox/edocIT/Project/Code/test/FileManager"),
    [
     ?assertMatch(true,check_piece:validate("book.torrent","kubunto-9.10-netbook-i386.iso",5))


     %% %% %%     %% ?assertError(badarith,check_piece:validate("book.torrent","kubunto-9.10-netbook-i386.iso",-1))
    ].
checking_piece_file()->
    ?assertEqual("4f0fe17616eb4b86a0dbe02b798debb7",check_piece:check_piece_file("book.torrent",5)).

checking_downloaded_piece()->
    [ ?assertEqual("4f0fe17616eb4b86a0dbe02b798debb7" ,check_piece:check_downloaded_piece("book.torrent","kubuntu-9.10-netbook-i386.iso",5))].

reading()->
    [?assertEqual("e44:udp://track",file_manager:read("book.torrent",10,15))].

writing()->
    [?assertEqual(ok,file_manager:write(testWrite,"/home/maryam/Dropbox/edocIT/Project/Code/test",5,<<hello>>))].


