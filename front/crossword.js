function updateBox(event) {
  var data = JSON.parse(event.data);
  if (data.action === "update") {
    if(data.letter === "1") {
      // batman symbol
      $("#" + data.box).text('');
      $("#" + data.box).prepend('<img src="images/batman.png" />');

    }
    else {
      $("#" + data.box).text(data.letter);
    }
  }
}

function sendCreateGame(player, game, socket) {
  var packet = new Packet("create", undefined, player, undefined, game); //action, box, player, letter, game
  var strPacket = JSON.stringify(packet);
  socket.send(strPacket);
}

function sendJoinGame(player, game, socket) {
  var packet = new Packet("join", undefined, player, undefined, game); //action, box, player, letter, game
  var strPacket = JSON.stringify(packet);
  socket.send(strPacket);
}
var Crossword = {
  initialize: function(gameId, playerName, socket) {
    this.puzzle = test_crossword;
    this.createNewPuzzle(this.puzzle);
    this.x = 0;
    this.y = 0;
    this.orientation = 'h'; // h or v, horizontal vertical
    // Initialize x and y to the top left corner and hilight that square
    this.active = '#' + this.getId(this.x, this.y);
    this.hilightActive();
    this.moveToFirstEmpty();
    this.playerName = playerName;
    this.gameId = gameId;
    if(this.gameId == "") {
      this.gameId = "I_LOVE_JUSSI";
    }
    this.socket = socket;
    this.socket.onopen = function() {
    };
    this.socket.onmessage = updateBox;
  },

//  sendCreateGame: function(player, game, socket) {
//    var packet = new Packet("create", undefined, player, undefined, game); //action, box, player, letter, game
//    var strPacket = JSON.stringify(packet);
//    socket.send(strPacket);
//  },

  createNewPuzzle: function(puzzle) {
    for (y = 0; y < puzzle.length; y++) {
      for (x = 0; x < puzzle[y].length; x++) {
        // Create the div object but add stuff to it later
        var div = document.createElement('div');
        var container = document.getElementById('containerId');
        div.id = this.getId(x, y);

        // Check type of tile
        var tile = puzzle[y][x];
        var type = tile.type;
        if (type === 'blank') {
          // blank tile
          div.className = 'square bigtext';
          div.onclick = function(e) {
            var coords = Crossword.getCoords(e.target.id);
            Crossword.selectSquare(coords.x, coords.y);
          };
        }
        else if (type === 'block') {
          // block tile
          div.className = 'empty_square';
        }
        else if (type === 'clue') {
          // single clue
          var clue1 = tile.clue1;
          div.className = 'square';
          div.innerHTML = '<div class="clue">' + clue1 + '</div>';
        }
        else if (type === 'double') {
          // double clue
          var clue1 = tile.clue1;
          var clue2 = tile.clue2;
          div.className = 'square';
          var innerDiv1 = document.createElement('div');
          innerDiv1.className = 'half_square';
          innerDiv1.innerHTML = '<div class="clue">' +  clue1 + '</div>';
          var innerDiv2 = document.createElement('div');
          innerDiv2.className = 'half_square';
          innerDiv2.innerHTML = '<div class="clue">' + clue2 + '</div>';
          div.appendChild(innerDiv1);
          div.appendChild(innerDiv2);
        }
        container.appendChild(div);
      }
      var br = document.createElement('br');
      br.style.clear = 'left';
      container.appendChild(br);
    }
  },

  moveToFirstEmpty: function() {
    for(tmpY = 0; tmpY < this.puzzle.length; tmpY++) {
      for(tmpX = 0; tmpX < this.puzzle[tmpY].length; tmpX++) {
        if (this.isValidSquare(tmpX, tmpY)) {
          this.x = tmpX;
          this.y = tmpY;
          this.hilightActive();
          return;
        }
      }
    }
  },

  getId: function(x, y) {
    // Make an ID string format xxyy from two integers
    if (x < 10) {
      xStr = '0' + x;
    }
    else {
      xStr = x;
    }

    if (y < 10) {
      yStr = '0' + y;
    }
    else {
      yStr = y;
    }
    return '' + xStr + yStr
  },

  getCoords: function(id) {
    // Parse the id from xxyy to ints x and y and put them in an object
    var xStr = id.substring(0,2);
    var yStr = id.substring(2,4);
    return {
      x: parseInt(xStr),
      y: parseInt(yStr),
    };
  },

  hilightActive: function() {
    // hilight the square at the current x and y coordinates
    if ($(this.active).hasClass('active')) {
      $(this.active).removeClass('active');
    }
    this.active = '#' + this.getId(this.x, this.y);
    $(this.active).addClass('active');

    // hilight the closest squares on the path
    $('.active_path').removeClass('active_path');
    if(this.orientation == 'h') {
      if(this.isValidSquare(this.x + 1, this.y)) {
        var nextSquare = '#' + this.getId(this.x + 1, this.y);
        $(nextSquare).addClass('active_path');
      }
      if(this.isValidSquare(this.x - 1, this.y)) {
        var nextSquare = '#' + this.getId(this.x - 1, this.y);
        $(nextSquare).addClass('active_path');
      }
    }
    else {
      if(this.isValidSquare(this.x, this.y + 1)) {
        var nextSquare = '#' + this.getId(this.x, this.y + 1);
        $(nextSquare).addClass('active_path');
      }
      if(this.isValidSquare(this.x, this.y - 1)) {
        var nextSquare = '#' + this.getId(this.x, this.y - 1);
        $(nextSquare).addClass('active_path');
      }
    }
  },

  clearActive: function() {
    // Removes any letter at the active square
    $(this.active).text('');
    var packet = new Packet("put", $(this.active).attr("id"), this.playerName, " ", this.gameId); // action, box, player, letter, game
    var strPacket = JSON.stringify(packet);
    this.socket.send(strPacket);
  },

  moveBack: function() {
    if (this.orientation == 'h') {
      if (this.isValidSquare(this.x-1, this.y)) {
        this.x = this.x-1;
        this.hilightActive();
      }
    }
    else {
      if (this.isValidSquare(this.x, this.y-1)) {
        this.y = this.y-1;
        this.hilightActive();
      }
    }
  },

  moveForward: function() {
    if (this.orientation == 'h') {
      if (this.isValidSquare(this.x+1, this.y)) {
        this.x = this.x+1;
        this.hilightActive();
      }
    }
    else {
      if (this.isValidSquare(this.x, this.y+1)) {
        this.y = this.y+1;
        this.hilightActive();
      }
    }
  },
  changeOrientation: function() {
    if(this.orientation == 'v') {
      this.orientation = 'h';
    }
    else {
      this.orientation = 'v';
    }
    this.hilightActive();
  },

  selectSquare: function(x, y) {
    // change x and y and hilight (for mouse clicks)
    this.x = x;
    this.y = y;
    this.hilightActive();
  },

  isValidSquare: function(x, y) {
    // checks if the coordinates are at one of the editable squares
    if(this.puzzle[y]) {
      if (this.puzzle[y][x]) {
        if (this.puzzle[y][x].type == 'blank') {
          return true;
        }
      }
    }
    return false;
  },

  changeActiveChar: function(letter) {
    $(this.active).text(letter);
    var packet = new Packet("put", $(this.active).attr("id"), this.playerName, letter, this.gameId); // action, box, player, letter, game
    var strPacket = JSON.stringify(packet);
    this.socket.send(strPacket);
  },

  // the batman symbol
  batman: function() {
    $(this.active).text('');
    $(this.active).prepend('<img src="images/batman.png" />');

    // Send the bat signal to the server
    var packet = new Packet("put", $(this.active).attr("id"), this.playerName, '1', this.gameId); // action, box, player, letter, game
    var strPacket = JSON.stringify(packet);
    this.socket.send(strPacket);
  },

  joinGame: function() {
    console.log("player: " + this.playerName + ", game: " + this.gameId + ", socket: " + this.socket);
    sendJoinGame(this.playerName, this.gameId, this.socket);
  },

  createGame: function() {
    sendCreateGame(this.playerName, this.gameId, this.socket);
  }
};
