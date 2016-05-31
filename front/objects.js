
function Tile(type='blank', clue1='', clue2='') {
  // type is: blank, block, clue, double
  var tile = { 
    type: type,
    clue1: clue1,
    clue2: clue2,
    };  
  return tile;
}

function Packet(boxId, playerName, letter, gameId) {
	var packet = {
		boxId: boxId,
		playerName: playerName,
		letter: letter,
		gameId: gameId,
	};
}