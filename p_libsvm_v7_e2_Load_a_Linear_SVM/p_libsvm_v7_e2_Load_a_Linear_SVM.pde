//*********************************************
// LibSVM for Processing (v7)
// Example 2. Load a Linear SVM
// Rong-Hao Liang: r.liang@tue.nl
// The Example is based on the original LibSVM library
// LibSVM Website: http://www.csie.ntu.edu.tw/~cjlin/libsvm/
//*********************************************
// A toy example that demonstrates the capability of multi-class classification on a 2D SVM.
// Input: A SVM model.
// Output: Classifying the mouse position based on the model loaded.

import libsvm.*; // Import the LibSVM JAVA library

//SVM Global Parameters 
int kernel_Type = svm_parameter.LINEAR; //svm_parameter.RBF;
int featureNum = 2; //[mouse_x, mouse_y]
ArrayList<Data> dataList = new ArrayList<Data>(); //ArrayList for storing the labeled test data.
int maxLabel = 0; //The maximum label among the dataset.
PGraphics svmBuffer;
svm_parameter param;
svm_problem problem;
svm_model model;
double best_accuracy = 0.;
double curr_cost = 64;

//GUI Global Parameters 
int type = 0; //Current type of data
int tCnt = 0; //Data count of the current label
String trainingInfo = "";
boolean showInfo = true; //Show the info of results (or not)
boolean svmTrained = false;
boolean firstTrained = false;

void setup() {
  size(500, 500);
  ellipseMode(CENTER);
  //initialize the SVM
  initSVM();
  
  model = loadSVM_Model(sketchPath()+"/data/test.model");
  svmBuffer = getModelImage(svmBuffer, model, (double)width, (double)height);
  svmTrained = true;
  firstTrained = false;
}

void draw() {
  background(255);
  if (!svmTrained && firstTrained) {
    //train a linear SVM with a given cost
    trainLinearSVM(curr_cost);
  }
  //draw the SVM
  drawSVM();
}

void initSVM() {
  //graphical representation of the model
  svmBuffer = new PGraphics(); 
  // Disable the unwanted svm console output
  svm.svm_set_print_string_function(new libsvm.svm_print_interface() {
    @Override public void print(String s) {
    }
  }
  );
  println("SVM initialized");
}

void trainLinearSVM(double C) {
  kernel_Type = svm_parameter.LINEAR;
  best_accuracy = runSVM_Linear(C); //Run Linear SVM and get the cross-validation accuracy
  svmTrained = true;
}

void clearSVM() {
  dataList.clear();
  svmBuffer.beginDraw(); 
  svmBuffer.clear();
  svmBuffer.endDraw();
  model = null;
  println("SVM cleared");
}

void drawSVM() {
  if (featureNum == 2) {
    drawModel(svmBuffer, 0, 0);
    drawDataSet(dataList);
    if (svmTrained) {
      //Form the current mouse position as an SVM node (svm_node) 
      double mouseXRatio = (double)mouseX/(double)width;
      double mouseYRatio = (double)mouseY/(double)height;
      svm_node[] x = {initSVM_Node(0, mouseXRatio), initSVM_Node(1, mouseYRatio)};
      //Test the SVM node
      int predictLabel = (int)svm.svm_predict(model, x);
      //Draw the results (The function in Graphics)
      drawTestNode(predictLabel, x, model);
    } else {
      drawCursor();
    }
  }
  //Draw the information (The function in Graphics)
  drawInfo(10, 20);
}


void mouseDragged() {
  if (mouseX < width && mouseY < height) {
    double px = (double)mouseX/(double)width + (-0.02+0.04*randomGaussian());
    double py = (double)mouseY/(double)height + (-0.02+0.04*randomGaussian());
    if (px>=0 && px<=1 && py>=0 && py<=1) { 
      double[] p = {px, py, type};
      Data newData = new Data(p);
      dataList.add(newData);
      ++tCnt;
    }
  }
}

void keyPressed() {
  if (key == ENTER || key == ENTER) {
    if (tCnt>0 || type>0) {
      svmTrained = false;
      if (!firstTrained) firstTrained = true;
      maxLabel = type;
    } else {
      println("Error: No Data");
    }
  }
  if (key == 'I' || key == 'i') {
    showInfo = !showInfo;
  }
  if (key >= '0' && key <= '9') {
    curr_cost = pow(2, key - '0');
    svmTrained = false;
    if (!firstTrained) firstTrained = true;
    maxLabel = type;
  }
  if (key == TAB) {
    if (tCnt>0) { 
      if (type<(colors.length-1))++type;
      tCnt = 0;
    }
  }
  if (key == '/') {
    type = 0;
    firstTrained = false;
    svmTrained = false;
    clearSVM();
  }
  if (key == 'S' || key == 's') {
    if (model!=null) saveSVM_Model(sketchPath()+"/data/test.model", model);
  }
}
