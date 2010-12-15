-module(toolbarManager).
-export([setState/4, setupTools/1, setupMenu/0]).

-include_lib("wx/include/wx.hrl").

-define(ABOUT, ?wxID_ABOUT).
-define(EXIT, ?wxID_EXIT).
-define(OPEN, ?wxID_OPEN).
-define(PREFERENCES, ?wxID_PREFERENCES).
-define(HELP, ?wxID_HELP).

setState(Frame, ListCtrl, ItemId, State)->
    Tools = wxFrame: getToolBar(Frame),
    ID = 1001,
    case State of
	not_selected ->
	    Not_selected = [false, false, false, false],
	    set(Tools, ID, Not_selected);	
	play ->
	    Play = [true, false, true, true],
	    itemManager: setItem(ItemId, play),
	    wxListCtrl: setItem(ListCtrl, ItemId, 2, "Downloading..."),
	    set(Tools, ID, Play);
	pause ->
	    Pause = [true, true, false, true],
	    itemManager: setItem(ItemId, pause),
	    wxListCtrl: setItem(ListCtrl, ItemId, 2, "Paused"),
	    set(Tools, ID, Pause);
	stop ->
	    Stop = [true, true, false, false],
	    itemManager: setItem(ItemId, stop),
	    wxListCtrl: setItem(ListCtrl, ItemId, 2, "Stopped"),
	    set(Tools, ID, Stop);
	waiting ->
	    Waiting = [true, true, false, false],
	    itemManager: setItem(ItemId, waiting),
	    wxListCtrl: setItem(ListCtrl, ItemId, 2, "Waiting"),
	    set(Tools, ID, Waiting)
    end.

set(_,_, []) ->
    ok;
set(Tools, ID, [H|T])->
    wxToolBar: enableTool(Tools, ID, H),
    set(Tools, ID + 1, T).

setupTools(Frame)->
    Tools = wxFrame : createToolBar(Frame),
    AddTorrent = wxBitmap: new(), 
    wxBitmap: loadFile(AddTorrent, "C:\\Users\\KaPa\\Desktop\\edocIT\\Code\\Images\\AddTorrent.png", 
		       [{type, ?wxBITMAP_TYPE_PNG}]),
    Remove = wxBitmap: new(),
    wxBitmap: loadFile(Remove, "C:\\Users\\KaPa\\Desktop\\edocIT\\Code\\Images\\Remove.png", 
		       [{type, ?wxBITMAP_TYPE_PNG}]),
    Start = wxBitmap: new(),
    wxBitmap: loadFile(Start, "C:\\Users\\KaPa\\Desktop\\edocIT\\Code\\Images\\Start.png", 
		       [{type, ?wxBITMAP_TYPE_PNG}]),
    Pause = wxBitmap: new(),
    wxBitmap: loadFile(Pause, "C:\\Users\\KaPa\\Desktop\\edocIT\\Code\\Images\\Pause.png", 
		       [{type, ?wxBITMAP_TYPE_PNG}]),
    Stop = wxBitmap: new(),
    wxBitmap: loadFile(Stop, "C:\\Users\\KaPa\\Desktop\\edocIT\\Code\\Images\\Stop.png", 
		       [{type, ?wxBITMAP_TYPE_PNG}]),

    LabelList = [{1000, "Add Torrent"}, {1001, "Remove"}, {1002, "Start"}, 
		 {1003, "Pause"}, {1004, "Stop"}],
    ImageList = [{1000, AddTorrent}, {1001, Remove}, {1002, Start}, 
		 {1003, Pause}, {1004, Stop}],
    
    Fun = fun(Int)->
		  case Int of
		      1000 -> 
			  wxToolBar: addTool(Tools, Int, db_fun: read(Int, LabelList),
					     db_fun: read(Int, ImageList)),
			  wxToolBar: setToolShortHelp(Tools, Int, db_fun: read(Int, LabelList)),
			  wxToolBar: addSeparator(Tools);
		      1001 -> 
			  wxToolBar: addTool(Tools, Int, db_fun: read(Int, LabelList),
					     db_fun: read(Int, ImageList)),
			  wxToolBar: setToolShortHelp(Tools, Int, db_fun: read(Int, LabelList)),
			  wxToolBar: enableTool(Tools, Int, false),
			  wxToolBar: addSeparator(Tools);
		      Other ->
			  wxToolBar: addTool(Tools, Int, db_fun: read(Int, LabelList),
					     db_fun: read(Int, ImageList)),
			  wxToolBar: setToolShortHelp(Tools, Int, db_fun: read(Int, LabelList)),
			  wxToolBar: enableTool(Tools, Int, false)
		  end
	end,
    lists: map(Fun, lists:seq(1000, 1004)),
    wxToolBar: realize(Tools).

setupMenu()->
    MenuBar = wxMenuBar: new(),
    File = wxMenu: new(),
    Options = wxMenu: new(),
    Help = wxMenu: new(),
      
    wxMenu: append(File, ?OPEN, "Add Torrent...\t Ctrl+O"),
    wxMenu: appendSeparator(File),
    wxMenu: append(File, ?EXIT, "Exit"),
    wxMenu: append(Options, ?PREFERENCES, "Preferences..."),
    wxMenu: append(Help, ?HELP, "Help \t F1"),
    wxMenu: appendSeparator(Help),
    wxMenu: append(Help, ?ABOUT, "About LibTorrent"),
    wxMenu: append(Help, 100, "About edocIT"),

    wxMenuBar: append(MenuBar, File, "&File"),
    wxMenuBar: append(MenuBar, Options, "&Options"),
    wxMenuBar: append(MenuBar, Help, "&Help"),
    MenuBar.
