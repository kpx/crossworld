
function Tile(type='blank', clue1='', clue2='') {
  // type is: blank, block, clue, double
  var tile = { 
    type: type,
    clue1: clue1,
    clue2: clue2,
    };  
  return tile;
}

function Packet(action, box, player, letter, game) {
	var packet = {
    action: action,
		box: box,
		player: player,
		letter: letter,
		game: game,
	};
  return packet;
}