import http.requests.*;
import controlP5.*;

ControlP5 cp5;

String api  = "http://api.flickr.com/services/rest/?method=flickr.photos.search";
String flickrKey = "";

String photoUrl = "";

PImage img;

int screenWidth = 800;

PFont titleFont;
PFont authorFont;
boolean refresh = true;

int minTitle = 4;
int maxTitle = 60;

int coverWidth = 400;
int coverHeight = 500;
int currentBook = 0;
int margin = 10;
int titleHeight = 100;
int authorHeight = 50;
int artworkStartX = 400;
int artworkStartY = 150;

color coverBaseColor = color(204, 153, 0);
color coverShapeColor = color(50);
color baseColor = coverBaseColor;
color shapeColor = coverShapeColor;

int baseVariation = 50;
int baseSaturation = 90;
int baseBrightness = 60;

int gridCount = 7;
int shapeThickness = 10;

String c64Letters = " qQwWeErRtTyYuUiIoOpPaAsSdDfFgGhHjJkKlL:zZxXcCvVbBnNmM";

String title = "";
String author = "";

String[][] books = {
  {"Laozi","道德經"},
  {"Rachinskii, Sergei Aleksandrovich","1001 задача для умственного счета"},
  {"Luo, Guanzhong","粉妝樓1-10回"},
  {"Nobre, António Pereira","Só"},
  {"Various","Väinölä"},
  {"Zhang, Chao","幽夢影 — Part 1"},
  {"Sunzi, active 6th century B.C.","兵法 (Bīng Fǎ)"},
  {"Leino, Kasimir","Elämästä"},
  {"Han, Ying, active 150 B.C.","韓詩外傳, Complete"},
  {"Besant, Walter","As we are and as we may be"},
  {"New York Trio","Trio No. 1 in B Flat, Pt. 1"},
  {"Hale, Edward Everett, Sr.","How to do it"},
  {"Milne, A. A. (Alan Alexander)","If I may"},
  {"Lehtonen, Joel","Kuolleet omenapuut Runollista proosaa"},
  {"Hassell, Antti Fredrik","Jaakko Cook'in matkat Tyynellä merellä"},
  {"Hough, Emerson","The Mississippi bubble"},
  {"Smith, George Adam","Four psalms, XXIII, XXXVI, LII, CXXI; interpreted for practical use."},
  {"Canth, Minna","Hanna"},
  {"Malot, Hector","Baccara"},
  {"Bensusan, S. L. (Samuel Levy)","Morocco"},
  {"Gauguin, Paul","Noa Noa"},
  {"Rinehart, Mary Roberts","K"},
  {"Various","Blackwood's Edinburgh Magazine — Volume 53, No. 327, January, 1843"},
  {"Livingstone, David","The Last Journals of David Livingstone, in Central Africa, from 1865 to His Death, Volume II (of  2), 1869-1873"},
  {"Ames, Azel","The Mayflower and Her Log; July 15, 1620-May 6, 1621 — Complete"},
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


void setup() {
  size(screenWidth, coverHeight);
  background(0);
  noStroke();
  cp5 = new ControlP5(this);
  titleFont = loadFont("AvenirNext-Bold.vlw");
  authorFont = loadFont("AvenirNext-Regular.vlw");
  cp5.addSlider("gridCount")
    .setPosition(10,10)
    .setRange(1,20)
    .setSize(300,10)
    .setId(1)
    ;
  cp5.addSlider("shapeThickness")
    .setPosition(10,30)
    .setRange(1,15)
    .setSize(300,10)
    .setId(2)
    ;
  cp5.addSlider("baseVariation")
    .setPosition(10,50)
    .setRange(0,60)
    .setSize(300,10)
    .setId(3)
    ;
  cp5.addSlider("baseSaturation")
    .setPosition(10,70)
    .setRange(0,100)
    .setSize(300,10)
    .setId(3)
    ;
  cp5.addSlider("baseBrightness")
    .setPosition(10,90)
    .setRange(0,100)
    .setSize(300,10)
    .setId(3)
    ;
  String config[] = loadStrings("config.txt");
  flickrKey = config[0];
}

void draw() {
  if (refresh) {
    refresh = false;
    title = books[currentBook][1];
    author = books[currentBook][0];
    background(50);
    fill(255);
    rect(artworkStartX, 0, coverWidth, coverHeight);
    processColors();
    drawArtwork();
    drawText();
    if (photoUrl != "") {
      img = loadImage(photoUrl);
      image(img, 0, artworkStartY);
    }
  }
}

void processColors() {
  int counts = title.length() + author.length();
  int colorSeed = int(map(counts, 0, 80, 0, 360));
  colorMode(HSB, 360, 100, 100);
  int rndSeed = colorSeed + int(random(baseVariation));
  baseColor = color(rndSeed, baseSaturation, baseBrightness);
  shapeColor = color((rndSeed-180)%360, baseSaturation, baseBrightness);
  colorMode(RGB, 255);
}

void processColorsFlickr() {
  photoUrl = getFlickrData(author.replace(' ','+') + "+" + title.replace(' ','+'));
  if (photoUrl != "") {
    try {
      PostRequest post = new PostRequest("http://labs.gaidi.ca/brandr/api.php");
      post.addData("image_url", photoUrl);
      post.send();
      String responseContent = post.getContent();
      println("responseContent: " + responseContent);
      if (responseContent.length()>0) {
        JSONObject colorsResponse = JSONObject.parse(responseContent);
        JSONArray colorsAccents = colorsResponse.getJSONArray("accents");
        println("size:"+colorsAccents.size());
        if (colorsAccents.size()>0) {
          try {
            JSONObject firstColorO = colorsAccents.getJSONObject(0);
            int firstColor = unhex("ff"+firstColorO.getString("color"));
            baseColor = color(firstColor);
          }
          catch (Exception ee) {
            JSONObject firstColorO = colorsAccents.getJSONObject(0);
            int firstColor = unhex("ff"+firstColorO.getInt("color"));
            baseColor = color(firstColor);
          }
        } else {
          baseColor = coverBaseColor;
        }
        println("baseColor: "+baseColor);
        if (colorsAccents.size()>1) {
          try {
            JSONObject secondColorO = colorsAccents.getJSONObject(1);
            int secondColor = unhex("ff"+secondColorO.getString("color"));
            shapeColor = color(secondColor);
          }
          catch (Exception ee) {
            JSONObject secondColorO = colorsAccents.getJSONObject(1);
            int secondColor = unhex("ff"+secondColorO.getInt("color"));
            shapeColor = color(secondColor);
          }
        } else {
          shapeColor = coverShapeColor;
        }
        println("shapeColor: "+shapeColor);
      } else {
        baseColor = coverBaseColor;
        shapeColor = coverShapeColor;
      }
    }
    catch (Exception e) {
      println ("There was an error loading the colors.");
    }
  } else {
    baseColor = coverBaseColor;
    shapeColor = coverShapeColor;
  }
}

void drawText() {
  fill(34, 34, 34);
  textFont(titleFont, 24);
  text(title, artworkStartX+margin, margin, coverWidth - (2 * margin), titleHeight);
  // fill(255);
  textFont(authorFont, 24);
  text(author, artworkStartX+margin, titleHeight+margin, coverWidth - (2 * margin), authorHeight);
}

String c64Convert() {
  // returns a string with all the c64-letter available in the title or a random set if none
  String result = "";
  int i, len = title.length();
  char letter;
  for (i=0; i<len; i++) {
    letter = title.charAt(i);
    if (c64Letters.indexOf(letter) == -1) {
      int anIndex = floor(random(c64Letters.length()));
      letter = c64Letters.charAt(anIndex);
    }
    // println("letter:" + letter);
    result = result + letter;
  }
  // println("result:" + result);
  return result;
}

void drawArtwork() {
  breakGrid();
  int i,j,gridSize=coverWidth/gridCount;
  int item = 0;
  fill(baseColor);
  rect(artworkStartX, artworkStartY, coverWidth, coverHeight);
  String c64Title = c64Convert();
  // println("c64Title.length(): "+c64Title.length());
  for (i=0; i<gridCount; i++) {
    for (j=0; j<gridCount; j++) {
      char character = c64Title.charAt(item%c64Title.length());
      drawShape (character, artworkStartX+(j*gridSize), artworkStartY+(i*gridSize), gridSize);
      item++;
    }
  }
}

void breakGrid() {
  int len = title.length();
  println("title length:"+len);
  if (len < minTitle) len = minTitle;
  if (len > maxTitle) len = maxTitle;
  gridCount = int(map(len, minTitle, maxTitle, 2, 11));
}

void drawShape(char k, int x, int y, int s) {
  ellipseMode(CORNER);
  fill(shapeColor);
  switch (k) {
    case 'q':
    case 'Q':
      ellipse(x, y, s, s);
      break;
    case 'w':
    case 'W':
      ellipse(x, y, s, s);
      s = s-(shapeThickness*2);
      fill(baseColor);
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
      fill(baseColor);
      arc(x+shapeThickness, y+shapeThickness, (s-shapeThickness)*2, (s-shapeThickness)*2, PI, PI+HALF_PI);
      break;
    case 'i':
    case 'I':
      arc(x-s, y, s*2, s*2, PI+HALF_PI, TWO_PI);
      fill(baseColor);
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
      fill(baseColor);
      arc(x+shapeThickness, y-s+shapeThickness, (s-shapeThickness)*2, (s-shapeThickness)*2, HALF_PI, PI);
      break;
    case 'k':
    case 'K':
      arc(x-s, y-s, s*2, s*2, 0, HALF_PI);
      fill(baseColor);
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
      fill(baseColor);
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
      fill(baseColor);
      triangle(x, y, x+s-shapeThickness, y, x, y+s-shapeThickness);
      triangle(x+shapeThickness, y+s, x+s, y+s, x+s, y+shapeThickness);
      break;
    case 'm':
    case 'M':
      rect(x, y, s, s);
      fill(baseColor);
      triangle(x+shapeThickness, y, x+s, y, x+s, y+s-shapeThickness);
      triangle(x, y+shapeThickness, x, y+s, x+s-shapeThickness, y+s);
      break;
    default:
      fill(baseColor);
      rect(x, y, s, s);
      break;
  }
}

void keyPressed() {
  if (key == ' ') {
    refresh = true;
    currentBook++;
    if (currentBook >= books.length) {
      currentBook = 0;
    }
  } else if (key == 's') {
    PImage temp = get(artworkStartX, 0, coverWidth, coverHeight);
    temp.save("cover_" + currentBook + ".png");
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

String getFlickrData(String name) {
  String url = "";
  String request = api + "&text=" + name + "&per_page=1&format=json&nojsoncallback=1&content_type=1&api_key=" + flickrKey;
  // println("--- request ---");
  // println(request);
  try {
    JSONObject flickrData = loadJSONObject(request);
    // println("--- data ---");
    // println( flickrData );
    JSONObject main = flickrData.getJSONObject("photos");
    JSONArray photos = main.getJSONArray("photo");
    // println("--- photos ---");
    // println(photos);
    JSONObject photo = photos.getJSONObject(0);
    // println("--- photo ---");
    // println(photo);
    String photoId = photo.getString("id");
    String secret = photo.getString("secret");
    Integer farmId = photo.getInt("farm");
    String serverId = photo.getString("server");
    url = "https://farm" + farmId + ".staticflickr.com/" + serverId + "/" + photoId + "_" + secret + "_n.jpg";
    println("--- url ---");
    println(url);
  }
  catch (Exception e) {
    println ("There was an error parsing the JSONObject.");
  }
  return url;
}


