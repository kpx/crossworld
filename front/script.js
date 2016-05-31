// I don't know
Crossword.init();

// Register keyboard event listener
document.onkeydown = checkKey;

function getChar(charCode) {
  // handle special characters from key presses
  if (charCode >= 65 && charCode <= 90) {
    return String.fromCharCode(charCode);
  }
  else if (charCode == 221) {
    return 'Å';
  }
  else if (charCode == 222) {
    return 'Ä';
  }
  else if (charCode == 192) {
    return 'Ö';
  }
  else {
    return null;
  }
}

function checkKey(e) {
  // keyboard input, up down left right to move around and letters to put letters
  e = e || window.event;

  if (e.keyCode == '38') {
    // console.log('up arrow');
    if (Crossword.isValidSquare(Crossword.x, Crossword.y-1)) {
      Crossword.y = Crossword.y-1;
      Crossword.hilightActive();
    }
  }
  else if (e.keyCode == '40') {
    // console.log('down arrow');
    if (Crossword.isValidSquare(Crossword.x, Crossword.y+1)) {
      Crossword.y = Crossword.y+1;
      Crossword.hilightActive();
    }
  }
  else if (e.keyCode == '37') {
    // console.log('left arrow');
    if (Crossword.isValidSquare(Crossword.x-1, Crossword.y)) {
      Crossword.x = Crossword.x-1;
      Crossword.hilightActive();
    }
  }
  else if (e.keyCode == '39') {
    // console.log('right arrow');
    if (Crossword.isValidSquare(Crossword.x+1, Crossword.y)) {
      Crossword.x = Crossword.x+1;
      Crossword.hilightActive();
    }
  }
  else if (e.keyCode == 8) {
    // console.log('backspace');
    e.preventDefault();
    Crossword.clearActive();
    Crossword.moveBack();
  }
  else if (e.keyCode == 46) {
    // console.log('del');
    Crossword.clearActive();
  }
  else if (e.keyCode == 32) {
    Crossword.changeOrientation();
  }
  else {
    var charCode = e.which || e.keyCode;
    var letter = getChar(charCode);
    if (letter) {
      Crossword.changeActiveChar(letter);
      Crossword.moveForward();
    }
  }
}

function batman() {
  Crossword.batman();
}

