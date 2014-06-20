import controlP5.*;

ControlP5 cp5;

PFont titleFont;
PFont authorFont;
boolean refresh = true;
int coverWidth = 400;
int coverHeight = 500;
int currentBook = 0;
int margin = 10;
int titleHeight = 100;
int authorHeight = 50;
int artworkStart = 150;

color coverBaseColor = color(204, 153, 0);

int gridCount = 7;
int shapeThickness = 10;

String[][] books = {
  {"Jane Austen","Pride and Prejudice"},
  {"Arthur Conan Doyle","The Adventures of Sherlock Holmes"},
  {"Franz Kafka","Metamorphosis"},
  {"Miguel de Cervantes Saavedra","Don Quixote"},
  {"Oscar Wilde","The Importance of Being Earnest: A Trivial Comedy for Serious People"},
  {"Frederick Douglass","Narrative of the Life of Frederick Douglass, an American Slave"},
  {"E.M. Berens","Myths and Legends of Ancient Greece and Rome"},
  {"Ambrose Bierce","The Devil's Dictionary"},
  {"Edgar Rice Burroughs","A Princess of Mars"},
  {"Ludwig Wittgenstein","Tractatus Logico-Philosophicus"},
  {"Mark Twain","Life on the Mississippi"},
  {"John Cleland","Memoirs of Fanny Hill"},
  {"Joshua Rose","Mechanical Drawing Self-Taught"},
  {"P.G. Wodwhouse","Right Ho, Jeeves"},
  {"Andre Norton","All Cats Are Grey"}
};


void setup () {
  size(coverWidth, coverHeight);
  background(255);
  noStroke();
  cp5 = new ControlP5(this);
  titleFont = loadFont("AvenirNext-Bold.vlw");
  authorFont = loadFont("AvenirNext-Regular.vlw");
  cp5.addSlider("gridCount")
     .setPosition(300,0)
     .setRange(1,20)
     .setSize(100,10)
     .setId(1)
     ;
  cp5.addSlider("shapeThickness")
     .setPosition(300,10)
     .setRange(1,15)
     .setSize(100,10)
     .setId(2)
     ;
}

void draw () {
  if (refresh) {
    refresh = false;
    background(255);
    drawArtwork();
    drawText();
  }
}

void drawText () {
  fill(34, 34, 34);
  textFont(titleFont, 24);
  text(books[currentBook][1], margin, margin, coverWidth - (2 * margin), titleHeight);
  // fill(255);
  textFont(authorFont, 24);
  text(books[currentBook][0], margin, titleHeight + margin, coverWidth - (2 * margin), authorHeight);
}

void drawArtwork () {
  int i,j,gridSize=coverWidth/gridCount;
  int[] fillColor = {50,205};
  int item = 0;
  fill(coverBaseColor);
  rect(0, artworkStart, coverWidth, coverHeight);
  for (i=0; i<gridCount; i++) {
    for (j=0; j<gridCount; j++) {
      char character = books[currentBook][1].charAt(item%books[currentBook][1].length());
      fill(fillColor[item%2]);
      fill(fillColor[0]);
      drawShape (character, j*gridSize, artworkStart+(i*gridSize), gridSize);
      item++;
    }
  }
}

void drawShape (char k, int x, int y, int s) {
  ellipseMode(CORNER);
  switch (k) {
    case 'q':
    case 'Q':
      ellipse(x, y, s, s);
      break;
    case 'w':
    case 'W':
      ellipse(x, y, s, s);
      s = s-(shapeThickness*2);
      fill(coverBaseColor);
      ellipse(x+shapeThickness, y+shapeThickness, s, s);
      break;
    case 'e':
    case 'E':
      rect(x, y+shapeThickness, s, shapeThickness);
      break;
    case 'r':
    case 'R':
      rect(x, y+s-(shapeThickness*2), s, shapeThickness);
      break;
    case 't':
    case 'T':
      rect(x+shapeThickness, y, shapeThickness, s);
      break;
    case 'y':
    case 'Y':
      rect(x+s-(shapeThickness*2), y, shapeThickness, s);
      break;
    case 'u':
    case 'U':
      arc(x, y, s*2, s*2, PI, PI+HALF_PI);
      fill(coverBaseColor);
      arc(x+shapeThickness, y+shapeThickness, (s-shapeThickness)*2, (s-shapeThickness)*2, PI, PI+HALF_PI);
      break;
    case 'i':
    case 'I':
      arc(x-s, y, s*2, s*2, PI+HALF_PI, TWO_PI);
      fill(coverBaseColor);
      arc(x-s+shapeThickness, y+shapeThickness, (s-shapeThickness)*2, (s-shapeThickness)*2, PI+HALF_PI, TWO_PI);
      break;
    case 'o':
    case 'O':
      rect(x, y, s, shapeThickness);
      rect(x, y, shapeThickness, s);
      break;
    case 'p':
    case 'P':
      rect(x, y, s, shapeThickness);
      rect(x+s-shapeThickness, y, shapeThickness, s);
      break;
    case 'a':
    case 'A':
      triangle(x, y+s, x+(s/2), y, x+s, y+s);
      break;
    case 's':
    case 'S':
      triangle(x, y, x+(s/2), y+s, x+s, y);
      break;
    case 'd':
    case 'D':
      rect(x, y+(shapeThickness*2), s, shapeThickness);
      break;
    case 'f':
    case 'F':
      rect(x, y+s-(shapeThickness*3), s, shapeThickness);
      break;
    case 'g':
    case 'G':
      rect(x+(shapeThickness*2), y, shapeThickness, s);
      break;
    case 'h':
    case 'H':
      rect(x+s-(shapeThickness*3), y, shapeThickness, s);
      break;
    case 'j':
    case 'J':
      arc(x, y-s, s*2, s*2, HALF_PI, PI);
      fill(coverBaseColor);
      arc(x+shapeThickness, y-s+shapeThickness, (s-shapeThickness)*2, (s-shapeThickness)*2, HALF_PI, PI);
      break;
    case 'k':
    case 'K':
      arc(x-s, y-s, s*2, s*2, 0, HALF_PI);
      fill(coverBaseColor);
      arc(x-s+shapeThickness, y-s+shapeThickness, (s-shapeThickness)*2, (s-shapeThickness)*2, 0, HALF_PI);
      break;
    case 'l':
    case 'L':
      rect(x, y, shapeThickness, s);
      rect(x, y+s-shapeThickness, s, shapeThickness);
      break;
    case ':':
      rect(x+s-shapeThickness, y, shapeThickness, s);
      rect(x, y+s-shapeThickness, s, shapeThickness);
      break;
    case 'z':
    case 'Z':
      triangle(x, y+(s/2), x+(s/2), y, x+s, y+(s/2));
      triangle(x, y+(s/2), x+(s/2), y+s, x+s, y+(s/2));
      break;
    case 'x':
    case 'X':
      ellipseMode(CENTER);
      ellipse(x+(s/2), y+(s/3), shapeThickness*2, shapeThickness*2);
      ellipse(x+(s/3), y+s-(s/3), shapeThickness*2, shapeThickness*2);
      ellipse(x+s-(s/3), y+s-(s/3), shapeThickness*2, shapeThickness*2);
      ellipseMode(CORNER);
      break;
    case 'c':
    case 'C':
      rect(x, y+(shapeThickness*3), s, shapeThickness);
      break;
    case 'v':
    case 'V':
      rect(x, y, s, s);
      fill(coverBaseColor);
      triangle(x+shapeThickness, y, x+(s/2), y+(s/2)-shapeThickness, x+s-shapeThickness, y);
      triangle(x, y+shapeThickness, x+(s/2)-shapeThickness, y+(s/2), x, y+s-shapeThickness);
      triangle(x+shapeThickness, y+s, x+(s/2), y+(s/2)+shapeThickness, x+s-shapeThickness, y+s);
      triangle(x+s, y+shapeThickness, x+s, y+s-shapeThickness, x+(s/2)+shapeThickness, y+(s/2));
      break;
    case 'b':
    case 'B':
      rect(x+(shapeThickness*3), y, shapeThickness, s);
      break;
    case 'n':
    case 'N':
      rect(x, y, s, s);
      fill(coverBaseColor);
      triangle(x, y, x+s-shapeThickness, y, x, y+s-shapeThickness);
      triangle(x+shapeThickness, y+s, x+s, y+s, x+s, y+shapeThickness);
      break;
    case 'm':
    case 'M':
      rect(x, y, s, s);
      fill(coverBaseColor);
      triangle(x+shapeThickness, y, x+s, y, x+s, y+s-shapeThickness);
      triangle(x, y+shapeThickness, x, y+s, x+s-shapeThickness, y+s);
      break;
    default:
      fill(coverBaseColor);
      rect(x, y, s, s);
      break;
  }
}

void keyPressed () {
  if (key == ' ') {
    refresh = true;
    currentBook++;
    if (currentBook >= books.length) {
      currentBook = 0;
    }
  }
}

void controlEvent(ControlEvent theEvent) {
  refresh = true;
  // println("got a control event from controller with id "+theEvent.getController().getId());

  // switch(theEvent.getController().getId()) {
  //   default :
  //   println(theEvent.getController().getValue());
  //   break;
  // }
}
