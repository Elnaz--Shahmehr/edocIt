-module(dialog).
-compile(export_all).

-include_lib("wx/include/wx.hrl").

openPreferences(Frame) ->
    Preferences = wxDialog: new(Frame, ?wxID_ANY, "Preferences..."),
    MainSizer = wxBoxSizer: new(?wxVERTICAL),
    OutterSizer = wxStaticBoxSizer:new(?wxVERTICAL, Preferences),
    DirPickerSizer = wxStaticBoxSizer:new(?wxVERTICAL, Preferences, 
					  [{label, "Change Download folder..."}]),
    ColorPickerSizer = wxStaticBoxSizer:new(?wxVERTICAL, Preferences, 
					    [{label, "Change the background color..."}]),
    RadioSizer = wxStaticBoxSizer:new(?wxVERTICAL, Preferences, 
					    [{label, "Set Item view..."}]),
    ButtonSizer = wxStaticBoxSizer:new(?wxHORIZONTAL, Preferences),

    DirPicker = wxDirPickerCtrl: new(Preferences, 1, [{path, "C:/Downloads"}]),
    ColorPicker = wxColourPickerCtrl: new(Preferences, ?wxID_ANY, [{col,{255,255,255,255}}]),
    RadioChoices = ["Normal", "Separated"],
    RadioBox = wxRadioBox: new(Preferences, ?wxID_ANY, "Options",
			      ?wxDefaultPosition, 
			      ?wxDefaultSize,
			      RadioChoices,
			      [{majorDim, 5}, 
			       {style, ?wxHORIZONTAL}]),
    Save = wxButton: new(Preferences, ?wxID_OK),
    Cancel = wxButton: new(Preferences, ?wxID_CANCEL),
    
    Image = wxImage: new("Images/edocIT.png"),
    Bitmap = wxBitmap: new(wxImage:scale(Image,
					 wxImage:getWidth(Image),
					 wxImage:getHeight(Image),
					 [{quality, ?wxIMAGE_QUALITY_HIGH}])),
    StaticBitmap = wxStaticBitmap:new(Preferences, ?wxID_ANY, Bitmap),
    Text = wxStaticText: new(Preferences, ?wxID_ANY, "edocIT � 2010", [{style, ?wxALIGN_CENTRE}]),

    wxSizer: add(DirPickerSizer, DirPicker, 
		 [{border, 5},{flag, ?wxALL bor ?wxEXPAND}]),
    wxSizer: add(ColorPickerSizer, ColorPicker, 
		 [{border, 5},{flag, ?wxALL bor ?wxEXPAND}]),
    wxSizer: add(RadioSizer, RadioBox, 
		 [{border, 5},{flag, ?wxALL bor ?wxEXPAND}]),
    wxSizer: add(ButtonSizer, Save, 
		 [{border, 5},{flag, ?wxALL bor ?wxEXPAND}]),
    wxSizer: add(ButtonSizer, Cancel, 
		 [{border, 5},{flag, ?wxALL bor ?wxEXPAND}]),
    wxSizer: add(OutterSizer, DirPickerSizer, 
		 [{border, 5},{flag, ?wxALL bor ?wxEXPAND}]),
    wxSizer: add(OutterSizer, ColorPickerSizer, 
		 [{border, 5},{flag, ?wxALL bor ?wxEXPAND}]),
    wxSizer: add(OutterSizer, RadioSizer, 
		 [{border, 5},{flag, ?wxALL bor ?wxEXPAND}]),
    wxSizer: add(OutterSizer, ButtonSizer, 
		 [{border, 5},{flag, ?wxALL bor ?wxEXPAND}]),
    wxSizer: add(OutterSizer, StaticBitmap, 
		 [{border, 20},{flag, ?wxALL bor ?wxEXPAND}]),
    wxSizer: add(OutterSizer, Text, 
		 [{border, 15},{flag, ?wxALL bor ?wxEXPAND}]),

    wxSizer: add(MainSizer, OutterSizer, [{flag, ?wxEXPAND}]),
    wxWindow: setSizer(Preferences, MainSizer),

    Return = wxDialog: showModal(Preferences),
    case Return of
	5100 ->
	    [wxDirPickerCtrl: getPath(DirPicker), 
	     wxColourPickerCtrl: getColour(ColorPicker),
	     wxRadioBox: getSelection(RadioBox)];
	Other -> null
    end.
    
openFileDialog(Frame)->
    FileDialog = wxFileDialog: new(Frame, [{message, "Add a torrent file..."}, 
					   {wildCard, "*.torrent"}]),
    Return = wxFileDialog: showModal(FileDialog),
    wxFileDialog: getPath(FileDialog).

openMsgDialog(Frame, Caption, Msg)->
    MsgBox = wxMessageDialog: new(Frame, Msg, [{style, ?wxOK bor ?wxICON_INFORMATION}, 
					       {caption, Caption}]),
    wxDialog: showModal(MsgBox),
    wxDialog: destroy(MsgBox).

openExitDialog(Frame)->
    ExitDialog = wxMessageDialog: new(Frame, "Are you sure you want to end the application?", 
				      [{caption, "LibTorrent"}, {style, ?wxYES_NO}]),
    wxMessageDialog: centreOnParent(ExitDialog),
    wxDialog: showModal(ExitDialog).

openRemoveDialog(Frame)->
    Msg = "Are you sure you want to remove this activity from the queue?",
    RemoveDialog = wxMessageDialog: new(Frame, Msg, [{caption, "LibTorrent"}, {style, ?wxYES_NO}]),
    wxMessageDialog: centreOnParent(RemoveDialog),
    wxDialog: showModal(RemoveDialog).
