var Crossword = {
  init: function() {
    this.puzzle = [
      ['M', 'O', 'N', 'K', 'E', 'Y'],
      ['O', 'R', '.', 'E', '.', '.'],
      ['O', 'B', 'E', 'Y', '.', '.'],
      ['N', '.', '.', 'S', 'K', 'A'],];
    this.createPuzzle(this.puzzle, false);
    this.x = 0;
    this.y = 0;
    this.orientation = 'h'; // h or v, horizontal vertical
    // Initialize x and y to the top left corner and hilight that square
    this.active = '#' + this.getId(this.x, this.y);
    this.hilightActive();
  },

  createPuzzle: function(puzzle, showLetters) {
    // Create the puzzle
    for (y = 0; y < puzzle.length; y++) {
      for (x = 0; x < puzzle[y].length; x++) {
        var content = puzzle[y][x];

        var div = document.createElement('div');
        var container = document.getElementById('containerId');
        div.id = this.getId(x, y);
        if (content != '.') {
          div.className = 'square';
          if(showLetters) {
            div.innerHTML = content;
          }
          div.onclick = function(e) {
            var coords = Crossword.getCoords(e.target.id);
            Crossword.selectSquare(coords.x, coords.y)
          }
        }
        else {
          div.className = 'empty_square';
        }
        container.appendChild(div);
      }
      var br = document.createElement('br');
      br.style.clear = 'left';
      container.appendChild(br);
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
    // Removes any letter at the active square and move cursor "back"
    $(this.active).text('');
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
        if (this.puzzle[y][x] != '.') {
          return true;
        }
      }
    }
    return false;
  },

  changeActiveChar: function(letter) {
    $(this.active).text(letter);
  },

  // the batman symbol
  batman: function() {
    $(this.active).text('');
    $(this.active).prepend('<img src="images/batman.png" />');
  },
};
