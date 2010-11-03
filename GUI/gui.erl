-module(gui).
-compile(export_all).

-include_lib("wx/include/wx.hrl").

-define(ABOUT, ?wxID_ABOUT).
-define(EXIT, ?wxID_EXIT).
-define(OPEN, ?wxID_OPEN).
-define(PREFERENCES, ?wxID_PREFERENCES).
-define(HELP, ?wxID_HELP).

start()->
    wx: new(),
    Frame = wxFrame: new(wx: null(), -1, "LibTorrent", [{size, {900,600}}]),
    setup(Frame),
    wxFrame: show(Frame),
    loop(Frame),
    wx: destroy().

setup(Frame)->
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
            
    wxFrame: setMenuBar(Frame, MenuBar),
   
    AddTorrent = wxBitmap: new(), 
    wxBitmap: loadFile(AddTorrent, "C:\\Users\\KaPa\\Desktop\\edocIT\\Code\\Images\\AddTorrent.png", [{type, ?wxBITMAP_TYPE_PNG}]),
    Remove = wxBitmap: new(),
    wxBitmap: loadFile(Remove, "C:\\Users\\KaPa\\Desktop\\edocIT\\Code\\Images\\Remove.png", [{type, ?wxBITMAP_TYPE_PNG}]),
    Start = wxBitmap: new(),
    wxBitmap: loadFile(Start, "C:\\Users\\KaPa\\Desktop\\edocIT\\Code\\Images\\Start.png", [{type, ?wxBITMAP_TYPE_PNG}]),
    Pause = wxBitmap: new(),
    wxBitmap: loadFile(Pause, "C:\\Users\\KaPa\\Desktop\\edocIT\\Code\\Images\\Pause.png", [{type, ?wxBITMAP_TYPE_PNG}]),
    Stop = wxBitmap: new(),
    wxBitmap: loadFile(Stop, "C:\\Users\\KaPa\\Desktop\\edocIT\\Code\\Images\\Stop.png", [{type, ?wxBITMAP_TYPE_PNG}]),

    Tools = wxFrame : createToolBar(Frame),

    wxToolBar: addTool(Tools, 1000, "Add Torrent", AddTorrent),
    wxToolBar: addSeparator(Tools),
    wxToolBar: addTool(Tools, 1001, "Remove", Remove),
    wxToolBar: addSeparator(Tools),
    wxToolBar: addTool(Tools, 1002, "Start", Start),
    wxToolBar: addTool(Tools, 1003, "Pause", Pause),
    wxToolBar: addTool(Tools, 1004, "Stop", Stop),
    
    wxToolBar: enableTool(Tools, 1001, false),
    wxToolBar: enableTool(Tools, 1002, false),
    wxToolBar: enableTool(Tools, 1003, false),
    wxToolBar: enableTool(Tools, 1004, false),
        
    wxToolBar: setToolShortHelp(Tools, 1000, "Add Torrent"),
    wxToolBar: setToolShortHelp(Tools, 1001, "Remove"), 
    wxToolBar: setToolShortHelp(Tools, 1002, "Start"),
    wxToolBar: setToolShortHelp(Tools, 1003, "Pause"),
    wxToolBar: setToolShortHelp(Tools, 1004, "Stop"),
    wxToolBar: realize(Tools),
        
    ListBox = wxListBox: new(Frame, 5000, [{style, ?wxLB_EXTENDED}]),
    
    MainSizer = wxBoxSizer: new(?wxVERTICAL),
    wxSizer: add(MainSizer, ListBox),

    wxFrame: createStatusBar(Frame),
    wxFrame: setStatusText(Frame, "Welcome to LibTorrent"),
    
    wxFrame: connect(Frame, command_menu_selected),
    wxFrame: connect(Frame, close_window).
   
loop(Frame)->
    receive
	#wx{event=#wxClose{}} ->
	    openExitDialog(Frame);

	#wx{id = ?ABOUT, event = #wxCommand{type = command_menu_selected}}->
	    openMsgDialog(Frame, "LibTorrent Downloader for fast sharing of ebooks."),
	    loop(Frame);

	#wx{id = 100, event = #wxCommand{type = command_menu_selected}}->
	    openMsgDialog(Frame, "edocIT bla bla...."),
	    loop(Frame);

	#wx{id = ?EXIT, event = #wxCommand{type = command_menu_selected}} -> 
	    openExitDialog(Frame);		    

	#wx{id = ?OPEN, event = #wxCommand{type = command_menu_selected}} ->
	    openFileDialog(Frame),
	    loop(Frame);

	#wx{id = ?PREFERENCES, event = #wxCommand{type = command_menu_selected}}->
	    Preferences = wxDialog: new(Frame, 4000, "Preferences..."),
	    wxDialog: showModal(Preferences),
	    wxDialog: destroy(Preferences),
	    loop(Frame);

	#wx{id = 1000} ->
	    %AddTorrent button action here!
	    openFileDialog(Frame),
	    loop(Frame);

	#wx{id = 1001} -> 
	    remove(Frame),
	    loop(Frame);

	#wx{id = 1002} -> 
	    start(Frame),
	    loop(Frame);
	
	#wx{id = 1003} -> 
	    pause(Frame),
	    loop(Frame);

	#wx{id = 1004} -> 
	    stop(Frame),
	    loop(Frame)
    end.

openFileDialog(Frame)->
    FileDialog = wxFileDialog: new(Frame, [{message, "Add a torrent file..."}, {wildCard, "*.torrent"}, {style, ?wxFD_MULTIPLE}]),
    Return = wxFileDialog: showModal(FileDialog),
    Path = wxFileDialog: getPaths(FileDialog),
    if
	Return == 5100 ->
	    io:format("~p~n", [Path]),
	    torrentLoaded(Frame),
	    %openTorrentDialog(Frame, Path),
	    loop(Frame);
	Return == 5101 ->
	    loop(Frame)
    end.

openTorrentDialog(Frame, Title)->
    TorrentDialog = wxDialog: new(Frame, 4000, Title),
    wxDialog: showModal(TorrentDialog),
    wxDialog: destroy(TorrentDialog),
    loop(Frame).

openMsgDialog(Frame, Msg)->
    MsgBox = wxMessageDialog: new(Frame, Msg, [{style, ?wxOK bor ?wxICON_INFORMATION}, {caption, "About LibTorrent"}]),
    wxDialog: showModal(MsgBox),
    wxDialog: destroy(MsgBox).

openExitDialog(Frame)->
    ExitDialog = wxMessageDialog: new(Frame, "Are you sure you want to end the application?", [{caption, "LibTorrent"}, {style, ?wxYES_NO}]),	            
    Return = wxDialog: showModal(ExitDialog),
    if
	Return == 5103 ->
	    wx: destroy();
	Return == 5104 ->
	    loop(Frame)
    end.

torrentLoaded(Frame) ->
    Tools = wxFrame: getToolBar(Frame),
    wxToolBar: enableTool(Tools, 1001, true),
    wxToolBar: enableTool(Tools, 1003, true),
    wxToolBar: enableTool(Tools, 1004, true).

remove(Frame) ->
    Tools = wxFrame: getToolBar(Frame),
    wxToolBar: enableTool(Tools, 1001, false),
    wxToolBar: enableTool(Tools, 1002, false),
    wxToolBar: enableTool(Tools, 1003, false),
    wxToolBar: enableTool(Tools, 1004, false).
start(Frame) ->
    Tools = wxFrame: getToolBar(Frame),
    wxToolBar: enableTool(Tools, 1001, true),
    wxToolBar: enableTool(Tools, 1002, false),
    wxToolBar: enableTool(Tools, 1003, true),
    wxToolBar: enableTool(Tools, 1004, true).

pause(Frame) ->
    Tools = wxFrame: getToolBar(Frame),
    wxToolBar: enableTool(Tools, 1001, true),
    wxToolBar: enableTool(Tools, 1002, true),
    wxToolBar: enableTool(Tools, 1003, false),
    wxToolBar: enableTool(Tools, 1004, true).

stop(Frame) ->
    Tools = wxFrame: getToolBar(Frame),
    wxToolBar: enableTool(Tools, 1001, true),
    wxToolBar: enableTool(Tools, 1002, true),
    wxToolBar: enableTool(Tools, 1003, false),
    wxToolBar: enableTool(Tools, 1004, false).
    
    
