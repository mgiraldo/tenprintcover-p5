import http.requests.*;
import controlP5.*;

ControlP5 cp5;

String api  = "http://api.flickr.com/services/rest/?method=flickr.photos.search";
String flickrKey = "";

String photoUrl = "";

PImage img;
PGraphics pg;

int screenWidth = 1200;
int screenHeight = 800;

PFont titleFont;
PFont authorFont;
boolean refresh = true;
boolean autosave = false;

int minTitle = 2;
int maxTitle = 60;

int coverWidth = 200;
int coverHeight = 300;
int currentBook = 0;
int margin = 2;
int titleHeight = 55;
int authorHeight = 25;
int artworkStartX = 400;
int artworkStartY = coverHeight-coverWidth;
int coverStartY = 20;
int titleFontSize = 18;
int authorFontSize = 14;

color coverBaseColor = color(204, 153, 0);
color coverShapeColor = color(50);
color baseColor = coverBaseColor;
color shapeColor = coverShapeColor;

int baseVariation = 100;
int baseSaturation = 100;
int baseBrightness = 90;
int colorDistance = 100;
boolean invert = true;

int gridCount = 7;
int shapeThickness = 10;

String c64Letters = " qQwWeErRtTyYuUiIoOpPaAsSdDfFgGhHjJkKlL:zZxXcCvVbBnNmM1234567890.";

String title = "";
String author = "";
String filename = "";
String[] bookList;


void setup() {
  size(screenWidth, screenHeight);
  background(0);
  noStroke();
  cp5 = new ControlP5(this);
  cp5.addSlider("gridCount")
    .setPosition(10,10)
    .setRange(1,20)
    .setSize(300,10)
    .setId(1)
    ;
  cp5.addSlider("shapeThickness")
    .setPosition(10,30)
    .setRange(1,30)
    .setSize(300,10)
    .setId(2)
    ;
  cp5.addSlider("margin")
    .setPosition(10,50)
    .setRange(1,10)
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
  cp5.addSlider("colorDistance")
    .setPosition(10,110)
    .setRange(0,180)
    .setSize(300,10)
    .setId(3)
    ;
  cp5.addSlider("coverWidth")
    .setPosition(10,130)
    .setRange(200,3600)
    .setSize(300,10)
    .setId(3)
    ;
  cp5.addToggle("invert")
     .setPosition(10,170)
     .setSize(50,20)
     .setMode(ControlP5.SWITCH)
     ;
  String config[] = loadStrings("config.txt");
  flickrKey = config[0];
  loadData();
}

void draw() {
  if (refresh) {
    background(0);
    refresh = false;
    coverHeight = int(coverWidth * 1.5);
    pg = createGraphics(coverWidth, coverHeight);
    artworkStartY = coverHeight - coverWidth;
    titleFontSize = int(coverWidth * 0.08);
    authorFontSize = int(coverWidth * 0.07);
    titleHeight = int((coverHeight - coverWidth - (coverHeight * margin / 100)) * 0.75);
    authorHeight = int((coverHeight - coverWidth - (coverHeight * margin / 100)) * 0.25);
    titleFont = createFont("AvenirNext-Bold", titleFontSize);
    authorFont = createFont("AvenirNext-Regular", authorFontSize);
    getCurrentBook();
    processColors();
    pg.beginDraw();
    pg.noStroke();
    drawBackground();
    drawArtwork();
    drawText();
    pg.endDraw();
    image(pg, artworkStartX, coverStartY);
    if (autosave) {
      saveCurrent();
      currentBook++;
      // println("bookList:" + bookList.length);
      if (currentBook < bookList.length) {
        refresh = true;
      } else {
        autosave = false;
      }
    }
  }
}

void getCurrentBook() {
  JSONObject book = JSONObject.parse(bookList[currentBook]);
  title = book.getString("title");
  String subtitle = "";
  try {
    subtitle = book.getString("subtitle");
  }
  catch (Exception e) {
    println("book has no subtitle");
  }
  if (!subtitle.equals("")) {
    title += ": " + subtitle;
  }
  author = book.getString("authors");
  filename = book.getString("identifier") + ".png";
}

void drawBackground() {
  pg.background(0);
  pg.fill(255);
  pg.rect(0, 0, coverWidth, coverHeight);
}

void drawText() {
  //…
  pg.fill(50);
  pg.textFont(titleFont, titleFontSize);
  pg.textLeading(titleFontSize);
  pg.text(title, 0+(coverHeight * margin / 100), 0+(coverHeight * margin / 100 * 2), coverWidth - (2 * coverHeight * margin / 100), titleHeight);
  // fill(255);
  pg.textFont(authorFont, authorFontSize);
  pg.text(author, 0+(coverHeight * margin / 100), 0+titleHeight, coverWidth - (2 * coverHeight * margin / 100), authorHeight);
}

String c64Convert() {
  // returns a string with all the c64-letter available in the title or a random set if none
  String result = "";
  int i, len = title.length();
  char letter;
  for (i=0; i<len; i++) {
    letter = title.charAt(i);
    // println("letter:" + letter + " num:" + int(letter));
    if (c64Letters.indexOf(letter) == -1) {
      int anIndex = int(letter)%c64Letters.length();//floor(random(c64Letters.length()));
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
  pg.fill(baseColor);
  pg.rect(0, 0, coverWidth, coverHeight * margin / 100);
  pg.rect(0, 0+artworkStartY, coverWidth, coverWidth);
  // pg.rect(0, 0, coverHeight * margin / 100 * 0.5, coverHeight);
  // pg.rect(coverWidth - (coverHeight * margin / 100 * 0.5), 0, coverHeight * margin / 100 * 0.5, coverHeight);
  String c64Title = c64Convert();
  // println("c64Title.length(): "+c64Title.length());
  for (i=0; i<gridCount; i++) {
    for (j=0; j<gridCount; j++) {
      char character = c64Title.charAt(item%c64Title.length());
      drawShape (character, 0+(j*gridSize), 0+artworkStartY+(i*gridSize), gridSize);
      item++;
    }
  }
}

void breakGrid() {
  int len = title.length();
  // println("title length:"+len);
  if (len < minTitle) len = minTitle;
  if (len > maxTitle) len = maxTitle;
  gridCount = int(map(len, minTitle, maxTitle, 2, 11));
}

void processColors() {
  int counts = title.length() + author.length();
  int colorSeed = int(map(counts, 2, 80, 10, 360));
  colorMode(HSB, 360, 100, 100);
  // int rndSeed = colorSeed + int(random(baseVariation));
  // int darkOnLight = (floor(random(2))==0) ? 1 : -1;
  shapeColor = color(colorSeed, baseSaturation, baseBrightness-(counts%20));// 55+(darkOnLight*25));
  baseColor = color((colorSeed+colorDistance)%360, baseSaturation, baseBrightness);// 55-(darkOnLight*25));
  if (invert) {
    color tempColor = shapeColor;
    shapeColor = baseColor;
    baseColor = tempColor;
  }
  // println("inverted:"+(counts%10));
  // if length of title+author is multiple of 10 make it inverted
  if (counts%10==0) {
    color tmpColor = baseColor;
    baseColor = shapeColor;
    shapeColor = tmpColor;
  }
  println("baseColor:"+baseColor);
  println("shapeColor:"+shapeColor);
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

void loadData() {
  bookList = loadStrings("covers.json2");
  println("bookList:" + bookList.length);
}

void drawShape(char k, int x, int y, int s) {
  pg.ellipseMode(CORNER);
  pg.fill(shapeColor);
  int thick = int(s * shapeThickness / 100);
  switch (k) {
    case 'q':
    case 'Q':
      pg.ellipse(x, y, s, s);
      break;
    case 'w':
    case 'W':
      pg.ellipse(x, y, s, s);
      s = s-(thick*2);
      pg.fill(baseColor);
      pg.ellipse(x+thick, y+thick, s, s);
      break;
    case 'e':
    case 'E':
      pg.rect(x, y+thick, s, thick);
      break;
    case 'r':
    case 'R':
      pg.rect(x, y+s-(thick*2), s, thick);
      break;
    case 't':
    case 'T':
      pg.rect(x+thick, y, thick, s);
      break;
    case 'y':
    case 'Y':
      pg.rect(x+s-(thick*2), y, thick, s);
      break;
    case 'u':
    case 'U':
      pg.arc(x, y, s*2, s*2, PI, PI+HALF_PI);
      pg.fill(baseColor);
      pg.arc(x+thick, y+thick, (s-thick)*2, (s-thick)*2, PI, PI+HALF_PI);
      break;
    case 'i':
    case 'I':
      pg.arc(x-s, y, s*2, s*2, PI+HALF_PI, TWO_PI);
      pg.fill(baseColor);
      pg.arc(x-s+thick, y+thick, (s-thick)*2, (s-thick)*2, PI+HALF_PI, TWO_PI);
      break;
    case 'o':
    case 'O':
      pg.rect(x, y, s, thick);
      pg.rect(x, y, thick, s);
      break;
    case 'p':
    case 'P':
      pg.rect(x, y, s, thick);
      pg.rect(x+s-thick, y, thick, s);
      break;
    case 'a':
    case 'A':
      pg.triangle(x, y+s, x+(s/2), y, x+s, y+s);
      break;
    case 's':
    case 'S':
      pg.triangle(x, y, x+(s/2), y+s, x+s, y);
      break;
    case 'd':
    case 'D':
      pg.rect(x, y+(thick*2), s, thick);
      break;
    case 'f':
    case 'F':
      pg.rect(x, y+s-(thick*3), s, thick);
      break;
    case 'g':
    case 'G':
      pg.rect(x+(thick*2), y, thick, s);
      break;
    case 'h':
    case 'H':
      pg.rect(x+s-(thick*3), y, thick, s);
      break;
    case 'j':
    case 'J':
      pg.arc(x, y-s, s*2, s*2, HALF_PI, PI);
      pg.fill(baseColor);
      pg.arc(x+thick, y-s+thick, (s-thick)*2, (s-thick)*2, HALF_PI, PI);
      break;
    case 'k':
    case 'K':
      pg.arc(x-s, y-s, s*2, s*2, 0, HALF_PI);
      pg.fill(baseColor);
      pg.arc(x-s+thick, y-s+thick, (s-thick)*2, (s-thick)*2, 0, HALF_PI);
      break;
    case 'l':
    case 'L':
      pg.rect(x, y, thick, s);
      pg.rect(x, y+s-thick, s, thick);
      break;
    case ':':
      pg.rect(x+s-thick, y, thick, s);
      pg.rect(x, y+s-thick, s, thick);
      break;
    case 'z':
    case 'Z':
      pg.triangle(x, y+(s/2), x+(s/2), y, x+s, y+(s/2));
      pg.triangle(x, y+(s/2), x+(s/2), y+s, x+s, y+(s/2));
      break;
    case 'x':
    case 'X':
      pg.ellipseMode(CENTER);
      pg.ellipse(x+(s/2), y+(s/3), thick*2, thick*2);
      pg.ellipse(x+(s/3), y+s-(s/3), thick*2, thick*2);
      pg.ellipse(x+s-(s/3), y+s-(s/3), thick*2, thick*2);
      pg.ellipseMode(CORNER);
      break;
    case 'c':
    case 'C':
      pg.rect(x, y+(thick*3), s, thick);
      break;
    case 'v':
    case 'V':
      pg.rect(x, y, s, s);
      pg.fill(baseColor);
      pg.triangle(x+thick, y, x+(s/2), y+(s/2)-thick, x+s-thick, y);
      pg.triangle(x, y+thick, x+(s/2)-thick, y+(s/2), x, y+s-thick);
      pg.triangle(x+thick, y+s, x+(s/2), y+(s/2)+thick, x+s-thick, y+s);
      pg.triangle(x+s, y+thick, x+s, y+s-thick, x+(s/2)+thick, y+(s/2));
      break;
    case 'b':
    case 'B':
      pg.rect(x+(thick*3), y, thick, s);
      break;
    case 'n':
    case 'N':
      pg.rect(x, y, s, s);
      pg.fill(baseColor);
      pg.triangle(x, y, x+s-thick, y, x, y+s-thick);
      pg.triangle(x+thick, y+s, x+s, y+s, x+s, y+thick);
      break;
    case 'm':
    case 'M':
      pg.rect(x, y, s, s);
      pg.fill(baseColor);
      pg.triangle(x+thick, y, x+s, y, x+s, y+s-thick);
      pg.triangle(x, y+thick, x, y+s, x+s-thick, y+s);
      break;
    case '7':
      pg.rect(x, y, s, thick*2);
      break;
    case '8':
      pg.rect(x, y, s, thick*3);
      break;
    case '9':
      pg.rect(x, y, thick, s);
      pg.rect(x, y+s-(thick*3), s, thick*3);
      break;
    case '4':
      pg.rect(x, y, thick*2, s);
      break;
    case '5':
      pg.rect(x, y, thick*3, s);
      break;
    case '6':
      pg.rect(x+s-(thick*3), y, thick*3, s);
      break;
    case '1':
      pg.rect(x, y+(s/2)-(thick/2), s, thick);
      pg.rect(x+(s/2)-(thick/2), y, thick, s/2+thick/2);
      break;
    case '2':
      pg.rect(x, y+(s/2)-(thick/2), s, thick);
      pg.rect(x+(s/2)-(thick/2), y+(s/2)-(thick/2), thick, s/2+thick/2);
      break;
    case '3':
      pg.rect(x, y+(s/2)-(thick/2), s/2+thick/2, thick);
      pg.rect(x+(s/2)-(thick/2), y, thick, s);
      break;
    case '0':
      pg.rect(x+(s/2)-(thick/2), y+(s/2)-(thick/2), thick, s/2+thick/2);
      pg.rect(x+(s/2)-(thick/2), y+(s/2)-(thick/2), s/2+thick/2, thick);
      break;
    case '.':
      pg.rect(x+(s/2)-(thick/2), y+(s/2)-(thick/2), thick, s/2+thick/2);
      pg.rect(x, y+(s/2)-(thick/2), s/2+thick/2, thick);
      break;
    default:
      pg.fill(baseColor);
      pg.rect(x, y, s, s);
      break;
  }
}

void saveCurrent() {
  // PImage temp = get(artworkStartX, coverStartY, coverWidth, coverHeight);
  if (filename.equals("")) {
    pg.save("output/cover_" + currentBook + ".png");
  } else {
    pg.save("output/" + filename);
  }
}

void keyPressed() {
  if (key == ' ') {
    refresh = true;
    currentBook++;
  } else if (key == 's') {
    saveCurrent();
  }
  if (key == CODED) {
    refresh = true;
    if (keyCode == LEFT) {
      currentBook--;
    } else if (keyCode == RIGHT) {
      currentBook++;
    }
  }
  if (currentBook >= bookList.length) {
    currentBook = 0;
  }
  if (currentBook < 0) {
    currentBook = bookList.length-1;
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


