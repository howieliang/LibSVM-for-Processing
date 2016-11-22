// Functions for Interfacing Processing to the LibSVM JAVA library

//****
//double[] initGridPrameter(int grid_size, float init, float step)
//: Initialize the parameters of grid searching.
//****
double[] initGridParameter(int grid_size, float init, float step) {
  double[] grid_param = new double[grid_size];
  for (int i = 0; i < grid_size; i++) {
    grid_param[i] = (double) pow(2, init+i*step);
  }
  return grid_param;
}

//****
//double[] runSVM_Linear()
//: Run SVM classification using linear kernel.
//****

double runSVM_Linear(double C) {
  if (dataList.size() > 0) {
    println("SVM (Linear kernel)\nTraining...");
    param   = initSVM_Linear(C);
    problem = initSVMProblem(dataList, featureNum);
    model     = svm.svm_train(problem, param);
    println(dataList.size(),svm.svm_get_nr_class(model));
    int[][] confMatrix = n_fold_cross_validation(problem, param, 5, maxLabel+1);
    printConfusionMatrix(confMatrix);
    double accuracy = evaluateAccuracy(confMatrix);
    println("Done.\nPrediction Accuracy = "+(accuracy *100.)+"%");
    if(featureNum==2)svmBuffer = getModelImage(svmBuffer, model, (double)width, (double)height);
    
    //svmBuffer = getModelImage(svmBuffer, model, (double)width, (double)height);
    //double accuracy = evaluateAccuracy(dataList, model);
    //println("Done.\nPrediction Accuracy = "+(accuracy *100.)+"%");
    //printConfusionMatrix(n_fold_cross_validation(problem, param, 5, svm.svm_get_nr_class(model)));
    
    return accuracy;
  } else {
    println("Error: No Data");
    return -1.;
  }
}

//****
//double[] runSVM_RBF()
//: Run SVM classification using RBF kernel.
//****

double runSVM_RBF(double gamma, double cost) {
  return runSVM_RBF(gamma, cost, true); 
}

double runSVM_RBF(double gamma, double cost, boolean updateImage) {
  if (dataList.size() > 0) {
    println("SVM (RBF kernel): gamma=", gamma, "cost=", cost, "\nTraining...");
    param   = initSVM_RBF(gamma, cost);
    problem = initSVMProblem(dataList, featureNum);
    model     = svm.svm_train(problem, param);
    println(dataList.size(),svm.svm_get_nr_class(model));
    int[][] confMatrix = n_fold_cross_validation(problem, param, 5, maxLabel+1);
    //int[][] confMatrix = n_fold_cross_validation(problem, param, 5, svm.svm_get_nr_class(model));
    printConfusionMatrix(confMatrix);
    double accuracy = evaluateAccuracy(confMatrix);
    if (updateImage && featureNum==2) svmBuffer = getModelImage(svmBuffer, model, (double)width, (double)height);
    println("Done.\nPrediction Accuracy = "+(accuracy *100.)+"%");
    
    //double accuracy = evaluateAccuracy(dataList, model);
    //if (accuracy>=best_accuracy && updateImage) svmBuffer = getModelImage(svmBuffer, model, (double)width, (double)height);
    //println("Done.\nPrediction Accuracy = "+(accuracy *100.)+"%");
    //printConfusionMatrix(n_fold_cross_validation(problem, param, 5, svm.svm_get_nr_class(model)));
    
    
    return accuracy;
  } else {
    println("Error: No Data");
    return -1.;
  }
}

//****
//int[][] n_fold_cross_validation(svm_problem problem, svm_parameter param, int n_fold, int type)
//: Run (n_fold)-Fold Cross Validation
//****

int[][] n_fold_cross_validation(svm_problem problem, svm_parameter param, int n_fold, int type) {
  int[][] confMatrix = new int[type][type];
  double[] target = new double[problem.l];
  svm.svm_cross_validation(problem, param, n_fold, target);

  for (int i = 0; i < target.length; i++) {
    int r = (int)problem.y[i];
    int c = (int)target[i];
    ++confMatrix[r][c];
  }
  return confMatrix;
}

//****
//printConfusionMatrix (int[][] confMatrix)
//: Print confusion matrix in console
//****

void printConfusionMatrix (int[][] confMatrix) {
  int tested = 0;
  int correct = 0;
  println("Confusion Matrix:");
  for (int i = 0; i < confMatrix.length; i++) {
    for (int j = 0; j < confMatrix[i].length; j++) {
      tested += confMatrix[i][j];
      if (i==j) correct += confMatrix[i][j];
      print(confMatrix[i][j]+"\t");
    }
    print("\n");
  }
  println("correct/tested = "+ correct + "/" + tested);
  println("correct = "+((double)correct/(double)tested * 100.) + " %");
}

//****
//svm_parameter initSVM_RBF(double gamma, double C)
//: Get the parameters for RBF-kernel SVM
//****

svm_parameter initSVM_RBF(double gamma, double C) {
  svm_parameter param = initSVMParam(svm_parameter.C_SVC, svm_parameter.RBF, gamma, C, 3);
  return param;
}

//****
//svm_parameter initSVM_Linear(double gamma, double C) 
//: Get the parameters for Linear-kernel SVM
//****

svm_parameter initSVM_Linear(double C) {
  svm_parameter param = initSVMParam(svm_parameter.C_SVC, svm_parameter.LINEAR, 1, C, 1);
  return param;
}

//****
//svm_parameter initSVM_Linear(int _svmType, int _kernelType, double _gamma, double _C, int _degree)
//: Get the parameters for a customized SVM 
//****

svm_parameter initSVMParam(int _svmType, int _kernelType, double _gamma, double _C, int _degree) {
  svm_parameter param = new svm_parameter();

  param.svm_type = _svmType;
  //0 -- C-SVC    (multi-class classification)
  //1 -- nu-SVC    (multi-class classification)
  //2 -- one-class SVM  
  //3 -- epsilon-SVR  (regression)
  //4 -- nu-SVR    (regression)
  param.kernel_type = _kernelType;
  //0 -- linear: u'*v
  //1 -- polynomial: (gamma*u'*v + coef0)^degree
  //2 -- radial basis function: exp(-gamma*|u-v|^2)
  //3 -- sigmoid: tanh(gamma*u'*v + coef0)
  //4 -- precomputed kernel (kernel values in training_set_file)
  param.degree = (int)_degree;

  param.gamma = _gamma;
  param.C = _C;

  param.coef0 = 0;
  param.nu = 0.5;
  param.cache_size = 40;
  param.eps = 1e-3;
  param.p = 0.1;
  param.shrinking = 1;
  param.probability = 1;
  param.nr_weight = 0;
  param.weight_label = new int[0];
  param.weight = new double[0]; 
  return param;
}

//****
//svm_node initSVM_Node(int _index, double _value)
//: Get a node with its index and value set. 
//****

svm_node initSVM_Node(int _index, double _value) {
  svm_node n = new svm_node();
  n.index = _index;  
  n.value = _value;
  return n;
}

//****
//svm_problem initSVMProblem(ArrayList<Data> dataList, int _featureNum)
//: Initialize an SVM problem for the solver.
//****

svm_problem initSVMProblem(ArrayList<Data> dataList, int _featureNum) {
  svm_problem problem = new svm_problem();
  int node_amount = dataList.size();
  if (node_amount > 0) {
    int feature_amount = dataList.get(0).dof;
    problem.l = node_amount;
    problem.x = new svm_node[node_amount][feature_amount]; //features
    problem.y = new double[node_amount]; //label
    for (int i=0; i<node_amount; i++) {
      Data p = dataList.get(i);
      problem.y[i] = p.label;
      for (int j=0; j < feature_amount; j++) problem.x[i][j] = initSVM_Node(j, p.features[j]);
    }
  }
  return problem;
}

//****
//void saveSVM_Model(String path, svm_model model)
//: Save an SVM model to a path
//****

void saveSVM_Model(String path, svm_model model) {
  try {
    svm.svm_save_model(path, model);
  } 
  catch (IOException e) {
    System.err.println(e);
  }
}

//****
//svm_model loadSVM_Model(String path)
//: Load an SVM model from a path
//****

svm_model loadSVM_Model(String path) {
  svm_model m = new svm_model();
  try {
    m = svm.svm_load_model(path);
  } 
  catch (IOException e) {
    System.err.println(e);
  }
  return m;
}

//****
//double evaluateTestSet(ArrayList<Data> dataList, svm_model model)
//: Get the accuracy of the SVM based on the given dataset.
//****

double evaluateTestSet(ArrayList<Data> dataList, svm_model model) {
 double correctPredictions = 0;
 for (int i=0; i<dataList.size(); i++) {
   Data p = dataList.get(i);
   int dataLabel = p.label;
   svm_node[] x = new svm_node[p.features.length-1];
   for (int j=0; j < p.features.length-1; j++) x[j] = initSVM_Node(j, p.features[j]);
   int predictLabel = (int) svm.svm_predict(model, x);
   if (predictLabel == dataLabel) correctPredictions++;
 }
 return correctPredictions/(double)dataList.size();
}

//****
//double evaluateAccuracy(int[][] confMatrix)
//: Get the accuracy of the SVM based on the confusionMatrix obtained by cross validation.
//****

double evaluateAccuracy (int[][] confMatrix) {
  int tested = 0;
  int correct = 0;
  //println("Confusion Matrix:");
  for (int i = 0; i < confMatrix.length; i++) {
    for (int j = 0; j < confMatrix[i].length; j++) {
      tested += confMatrix[i][j];
      if (i==j) correct += confMatrix[i][j];
      //print(confMatrix[i][j]+"\t");
    }
    //print("\n");
  }
  //println("correct/tested = "+ correct + "/" + tested);
  //println("correct = "+((double)correct/(double)tested * 100.) + " %");
  return (double)correct/(double)tested;
}

//****
//PGraphics getModelImage (PGraphics buffer, svm_model model, double W, double H)
//: Get the 2D image of a 2-DOF SVM
//****

PGraphics getModelImage (PGraphics buffer, svm_model model, double W, double H) {
  buffer = createGraphics((int)W, (int)H, JAVA2D);
  buffer.beginDraw();
  svm_node[] x = new svm_node[featureNum];
  for (int i=0; i< W; i++) {
    for (int j=0; j<H; j++) {
      x[0] = initSVM_Node(0, (double)i/W);
      x[1] = initSVM_Node(1, (double)j/H);
      double d = svm.svm_predict(model, x);
      buffer.stroke(colors[(int)d]);
      buffer.point(i, j);
    }
  }
  buffer.endDraw();
  return buffer;
}