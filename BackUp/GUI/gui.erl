-module(gui).
-export([start/0]).

-include_lib("wx/include/wx.hrl").

-define(ABOUT, ?wxID_ABOUT).
-define(EXIT, ?wxID_EXIT).
-define(OPEN, ?wxID_OPEN).
-define(PREFERENCES, ?wxID_PREFERENCES).
-define(HELP, ?wxID_HELP).

start()->
    wx: new(),
    itemManager: start(),
    Frame = wxFrame: new(wx: null(), ?wxID_ANY, "LibTorrent", 
			 [{size, {900,600}}]),
    ListCtrl = listCtrl_setup(Frame),
    setup(Frame),
    wxFrame: show(Frame),
    loop(Frame, ListCtrl, -1, normal),
    itemManager: stop(),
    wx: destroy().

setup(Frame)->
    wxFrame: setMenuBar(Frame, toolbarManager: setupMenu()),
    toolbarManager: setupTools(Frame),
    wxFrame: createStatusBar(Frame),
    wxFrame: setStatusText(Frame, "Welcome to LibTorrent"),

% Connect frame to listeners
    wxFrame: connect(Frame, command_dirpicker_changed),
    wxFrame: connect(Frame, command_menu_selected),
    wxFrame: connect(Frame, close_window).
           
loop(Frame, ListCtrl, SelectedItem, View)->
    receive

	#wx{event = #wxClose{}} ->
	    case dialog: openExitDialog(Frame) of
		5103 ->
		    wx: destroy();
		Other ->
		    loop(Frame, ListCtrl, SelectedItem, View)
	    end;

	#wx{id = Id, event = #wxCommand{type = command_menu_selected}} ->
	    case Id of
% MENU EVENTS
		?ABOUT ->
		    dialog: openMsgDialog(Frame, "About LibTorrent", "LibTorrent Downloader for fast sharing of ebooks."),
		    loop(Frame, ListCtrl, SelectedItem, View);
		100 ->
		    Msg = "\n************\n   edocIT\n************\n\n edocIT is a Software Development group at IT-University in Gothenburg that designed and implemented this version of the LibTorrent software.\n\n Members:\n Almir Kapetanovic\n Caroline Bergqvist\n Elnaz Shahmehr\n Sepideh Fazlmashhadi\n Maryam Sepasi\n Navid Amiriarshad",
		    dialog: openMsgDialog(Frame, "About edocIT", Msg),
		    loop(Frame, ListCtrl, SelectedItem, View);
		?EXIT -> 
		    case dialog: openExitDialog(Frame) of
			5103 ->
			    wx: destroy();
			Other ->
			    loop(Frame, ListCtrl, SelectedItem, View)
		    end;
		?OPEN ->
		    case dialog: openFileDialog(Frame) of
			[] ->
			    loop(Frame, ListCtrl, SelectedItem, View);
			Path ->
			    addTorrent(Frame, ListCtrl, View, Path),
			    loop(Frame, ListCtrl, SelectedItem + 1, View)
		    end;
		?PREFERENCES ->
		    case dialog: openPreferences(Frame) of
			null ->
			    loop(Frame, ListCtrl, SelectedItem, View);
			[Folder, Colour, ItemView] ->
			    Dl_folder = Folder,
			    io: format("~p~n", [Colour]),
			    wxListCtrl: setBackgroundColour(ListCtrl, Colour),
			    wxWindow: refresh(Frame),
			    wxWindow: update(Frame),
			    case ItemView of
				1 ->
				    setSeparateView(ListCtrl),
				    loop(Frame, ListCtrl, SelectedItem, separate);
				0 -> 
				    setNormalView(ListCtrl),
				    loop(Frame, ListCtrl, SelectedItem, normal)
			    end
		    end;
% Open activity TOOL
		1000 ->
		    case dialog: openFileDialog(Frame) of
			[] ->
			    loop(Frame, ListCtrl, SelectedItem, View);
			Path ->
			    addTorrent(Frame, ListCtrl, View, Path),
			    loop(Frame, ListCtrl, SelectedItem + 1, View)
		    end;
% Remove activity TOOL	
		1001 ->
		    case dialog: openRemoveDialog(Frame) of
			5103 ->
			    itemManager: removeItem(SelectedItem),
			    wxListCtrl: deleteItem(ListCtrl, SelectedItem),
			    updateView(Frame, ListCtrl, View),
			    loop(Frame, ListCtrl, SelectedItem, View);
			Other ->
			    loop(Frame, ListCtrl, SelectedItem, View)
		    end;
% Play activity TOOL
		1002 ->
		    toolbarManager: setState(Frame, ListCtrl, SelectedItem, play),
		    loop(Frame, ListCtrl, SelectedItem, View);
% Pause activity TOOL
		1003 -> 
		    toolbarManager: setState(Frame, ListCtrl, SelectedItem, pause),
		    loop(Frame, ListCtrl, SelectedItem, View);
% Stop activity TOOL
		1004 -> 
		    toolbarManager: setState(Frame, ListCtrl, SelectedItem, stop),
		    loop(Frame, ListCtrl, SelectedItem, View);
		Other ->
		    ok
	    end;
% DE/SELECTED
	#wx{event = #wxList{type = Type, itemIndex = ItemId}} ->
	    case Type of
		command_list_item_selected ->
		    toolbarManager: setState(Frame, ListCtrl, ItemId, itemManager: getStatus(ItemId)),
		    loop(Frame, ListCtrl, ItemId, View); 
		command_list_item_deselected ->
		    toolbarManager: setState(Frame, ListCtrl, ItemId, not_selected),
		    loop(Frame, ListCtrl, SelectedItem, View);
		Other -> ok
	    end;

	#wx{event = #wxColourPicker{type = command_colourpicker_changed, colour = Colour}} ->
	    io: format("Color")
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
listCtrl_setup(Parent) ->
    ListCtrl = wxListCtrl: new(Parent, [{style, ?wxLC_REPORT bor ?wxLC_SINGLE_SEL}]),
    ImageList = wxImageList: new(15, 15),
    wxImageList: add(ImageList, wxArtProvider: getBitmap("wxART_EXECUTABLE_FILE", [{size, {15, 15}}])),
    wxListCtrl: assignImageList(ListCtrl, ImageList, ?wxIMAGE_LIST_SMALL),

    LabelList = [{0, "Name"}, {1, "Size"}, {2, "Status"}, {3, "Progress"}, {4, "DL Speed"}, 
		 {5, "Seeds/Peers"}, {6, "Tracker"}],
    
    Fun = fun(Int)->
		wxListCtrl: insertColumn(ListCtrl, Int, db_fun: read(Int, LabelList))
	end,
    lists: map(Fun, lists:seq(0, 6)),

    wxListCtrl: setColumnWidth(ListCtrl, 0, 350),
    wxListCtrl: setColumnWidth(ListCtrl, 2, 100),
    wxListCtrl: setColumnWidth(ListCtrl, 6, 300),

    wxListCtrl: connect(ListCtrl, command_list_item_selected),
    wxListCtrl: connect(ListCtrl, command_list_item_deselected),
    ListCtrl.

addTorrent(Frame, ListCtrl, View, Path)->
    TorrentInfo = parseTorrent: parse(Path),
    Item = wxListItem: new(),
    wxListItem: setImage(Item, 0),
    wxListCtrl: insertItem(ListCtrl, Item),
    wxListCtrl: setItem(ListCtrl, 0, 0, dict: fetch("name", dict: fetch("info", TorrentInfo))),
    wxListCtrl: setItem(ListCtrl, 0, 2, "Waiting"),
    wxListCtrl: setItem(ListCtrl, 0, 6, dict: fetch("announce", TorrentInfo)),
    itemManager: addItem(),
    updateView(Frame, ListCtrl, View).

setSeparateView(ListCtrl)->
    Fun = fun(Int)->
		  Rem = Int rem 2,
		  case Rem of
		      0 ->
			  wxListCtrl: setItemBackgroundColour(ListCtrl, Int, {232,243,247,255});
		      Other -> ok
		  end
	  end,
    lists: map(Fun, lists: seq(0, wxListCtrl: getItemCount(ListCtrl) - 1)).

setNormalView(ListCtrl)->
    Fun = fun(Int)->
		  wxListCtrl: setItemBackgroundColour(ListCtrl, Int, {255,255,255,255})
	  end,
    lists: map(Fun, lists: seq(0, wxListCtrl: getItemCount(ListCtrl) - 1)).

updateView(Frame, ListCtrl, View)->
    setNormalView(ListCtrl),
    case View of
	normal ->
	    setNormalView(ListCtrl),
	    wxWindow: refresh(Frame),
	    wxWindow: update(Frame);
	separate ->
	    setSeparateView(ListCtrl),
	    wxWindow: refresh(Frame),
	    wxWindow: update(Frame);
 	Other -> ok
    end.  


		


      
