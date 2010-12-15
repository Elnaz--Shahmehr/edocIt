%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Records
%
%%%%%%%%%%%%%%%%%%%%%%%%%%
-record(torrent, {id,
		  name,
		  bit_field,
		  state=stopped,
		  info_hash,
		  info_hash_encoded,
                  num_blocks,
		  num_pieces,
		  block_size,
		  piece_size}).


-record(peer,{ip,
                   port,
                    id,
               me_choked = true,
	  peer_choked = true}).

-record(client,{'info_hash', 'peer_id'}).


-record(handshake,
	{
	  reserved = <<0:64>>,
	  info_hash,
	  id
	 }).

-record(keepalive,
                 {}).

-record(choke,
                 {}).

-record(unchoke,
                 {}).

-record(interested,
                 {}).

-record(not_interested,
                 {}).

-record(have,
	{
	  index
	 }).

-record(bitfield,
	{
	  bitfield
	 }).

-record(request,
	{
	  index,
	  offset,
	  length
	 }).

-record(piece,
	{
	  index,
	  offset,
	  block
	 }).

-record(cancel,
	{
	  index,
	  offset,
	  length
	 }).
