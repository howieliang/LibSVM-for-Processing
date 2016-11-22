//*********************************************
// CSV generator
// Rong-Hao Liang: r.liang@tue.nl
//*********************************************
// A tool for translating data into a CSV file.
// Input: Labelled data formed by Click and Drag the mouse cursor on the canvas.
// Output: A Linear SVM model for classifying the mouse position

int featureNum = 2;
int labelIndex = featureNum;
ArrayList<Data> dataList;
boolean showInfo = true; //Show the info of results (or not)
int type = 0;
float noise = 10;

Table table;
String fileName = "data/testData.csv";
boolean b_saveCSV = false;

void setup() {
  size(500, 500);
  ellipseMode(CENTER);
  dataList = new ArrayList<Data>();
  table = new Table();
  table.addColumn("x");
  table.addColumn("y");
  table.addColumn("label");
}

void draw() {
  background(255);
  if (b_saveCSV) {
    saveTable(table, fileName);
    println("Saved as: ", fileName);
    b_saveCSV = false;
  }
  drawData (dataList);
  drawInfo (10, 20);
}

void mouseDragged() {
  if (mouseX < width && mouseY < height) {
    double px = (double)mouseX + (-noise/2.+noise*randomGaussian());
    double py = (double)mouseY + (-noise/2.+noise*randomGaussian());
    if (px>=0 && px<=width && py>=0 && py<=height) { 
      double[] p = {px, py, type};
      dataList.add(new Data(p));
      TableRow newRow = table.addRow();
      newRow.setDouble("x", p[0]);
      newRow.setDouble("y", p[1]);
      newRow.setDouble("label", p[2]);
    }
  }
}

void keyPressed() {
  if (key >= '0' && key <= '9') {
    type = key-'0';
  }
  if (key == '/') {
    dataList.clear();
    type = 0;
  }
  if (key == 'S' || key == 's') {
    b_saveCSV = true;
  }
  if (key == 'I' || key == 'i') {
    showInfo = !showInfo;
  }
}