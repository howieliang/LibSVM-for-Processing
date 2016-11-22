color colors[] = {
  color(155, 89, 182), color(63, 195, 128), color(214, 69, 65), 
  color(82, 179, 217), color(244, 208, 63), color(242, 121, 53), 
  color(0, 121, 53), color(128, 128, 0), color(52, 0, 128), 
  color(128, 52, 0), color(52, 128, 0), color(128, 52, 0)
};


void drawData (ArrayList<Data> list) {
  for (Data d : list) {
    double[] p = d.features;
    fill(colors[(int)p[2]]);
    ellipse((float)p[0], (float)p[1], 10, 10);
  }
}

void drawInfo(int x, int y) {
  String manual = "\n- Press N=[0-9] to Change the Label"+
    "\n- Press [/] to clear data"+
    "\n- Press [S] to save model";
  String info = "Press [I] to toggle info" + manual;
  String infoLite = "Press [I] to toggle info";

  pushStyle();
  textSize(12);
  stroke(0);
  fill(255, 52);
  if (showInfo) {
    rect(5, 5, 390, 80);
    noStroke();
    fill(0);
    text(info, x, y);
  } else {
    rect(5, 5, 490, 20);
    noStroke();
    fill(0);
    text(infoLite, x, y);
  }
  popStyle();
}