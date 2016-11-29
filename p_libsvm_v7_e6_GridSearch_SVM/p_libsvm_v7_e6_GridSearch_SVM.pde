//*********************************************
// LibSVM for Processing (v6)
// Example 6. GridSearch the best parameters for SVM
// Rong-Hao Liang: r.liang@tue.nl
// The Example is based on the original LibSVM library
// LibSVM Website: http://www.csie.ntu.edu.tw/~cjlin/libsvm/
//*********************************************
// A toy example that demonstrates the capability of multi-class classification on a 2D SVM.
// Input: Labelled data formed by Click and Drag the mouse cursor on the canvas.
// Output: A RBF- or Linear-Kernelded SVM model for classifying the mouse position

import libsvm.*; // Import the LibSVM JAVA library

//SVM Global Parameters 
int kernel_Type = svm_parameter.RBF;
int featureNum = 2; //[mouse_x, mouse_y]
ArrayList<Data> dataList = new ArrayList<Data>(); //ArrayList for storing the labeled test data.
int maxLabel = 0; //The maximum label among the dataset.
PGraphics svmBuffer;
svm_parameter param;
svm_problem problem;
svm_model model;
double best_accuracy = 0.;
double curr_cost = 256.;
double curr_gamma = 1.;

//GUI Global Parameters 
int type = 0; //Current type of data
int tCnt = 0; //Data count of the current label
String trainingInfo = "";
boolean showInfo = true; //Show the info of results (or not)
boolean svmTrained = false;
boolean firstTrained = false;

//Grid parameters
double[] test_gamma = {1, 0.5, 0.25, 0.125};
double[] test_C = {4, 16, 256, 1024};

void setup() {
  size(500, 500);
  ellipseMode(CENTER);
  //initialize the SVM
  initSVM();
}

void draw() {
  background(255);
  if (!svmTrained && firstTrained) {
    if (kernel_Type == svm_parameter.RBF) {
      //perform grid search to identify the best gamma and C for a RBF SVM
      for (int i = 0; i < test_gamma.length; i++) {
        for (int j = 0; j < test_C.length; j++) {
          trainRBFSVM(test_gamma[i], test_C[j], false); //do not update the model image
          int index = (int)(i+j*test_gamma.length)+1;
          int total = (int)(test_gamma.length*test_C.length);
          println("Parameter grid searching ("+index+"/"+ total +"): gamma = "+test_gamma[i]+", C = "+ test_C[j]);
        }
      }
      //train an RBF SVM with the identified gamma and C
      trainRBFSVM(curr_gamma, curr_cost, true);
      svmTrained = true;
    }
    if (kernel_Type == svm_parameter.LINEAR) {
      //perform grid search to identify the best C for a linear SVM
      for (int j = 0; j < test_C.length; j++) {
        trainLinearSVM(test_C[j], false); //do not update the model image
        int index = (int)j+1;
        int total = (int)(test_C.length);
        println("Parameter searching ("+index+"/"+ total +"): C = "+ test_C[j]);
      }
      //train a Linear SVM with the identified  C
      trainLinearSVM(curr_cost, true);
      svmTrained = true;
    }
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

void trainRBFSVM(double Gamma, double C, boolean updateImage) {
  double cv_accuracy = runSVM_RBF(Gamma, C, updateImage);
  if (cv_accuracy>best_accuracy) { 
    best_accuracy = cv_accuracy;
    curr_cost = C;
    curr_gamma = Gamma;
  }
}

void trainLinearSVM(double C, boolean updateImage) {
  double cv_accuracy = runSVM_Linear(C, updateImage);
  if (cv_accuracy>best_accuracy) { 
    best_accuracy = cv_accuracy;
    curr_cost = C;
  }
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
  drawInfo(kernel_Type, 10, 20);
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
    kernel_Type = svm_parameter.RBF;
    if (tCnt>0 || type>0) {
      svmTrained = false;
      best_accuracy = 0.;
      if (!firstTrained) firstTrained = true;
      maxLabel = type;
    } else {
      println("Error: No Data");
    }
  }
  if (key == 'I' || key == 'i') {
    showInfo = !showInfo;
  }
  if (key == '0') {
    kernel_Type = svm_parameter.LINEAR;
    svmTrained = false;
    best_accuracy = 0.;
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