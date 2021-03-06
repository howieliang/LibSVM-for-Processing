// Parameters and Functions for Drawing the GUI

color colors[] = {
  color(155, 89, 182), color(63, 195, 128), color(214, 69, 65), 
  color(82, 179, 217), color(244, 208, 63), color(242, 121, 53), 
  color(0, 121, 53), color(128, 128, 0), color(52, 0, 128), 
  color(128, 52, 0), color(52, 128, 0), color(128, 52, 0)
};


void drawModel (PGraphics g, int x, int y) {
  pushStyle();
  noStroke();     
  image(svmBuffer, 0, 0);
  stroke(0);
  popStyle();
}

void drawDataSet (ArrayList<Data> data) {
  pushStyle();
  for (int i=0; i<data.size(); i++) {
    fill(colors[data.get(i).label]);
    ellipse((float)data.get(i).X()*width, (float)data.get(i).Y()*height, 6, 6);
  }
  popStyle();
}

void drawTestNode (int predictLabel, svm_node[] testNode, svm_model model) {
  pushStyle();
  int sampleX = (int)(testNode[0].value*width);
  int sampleY = (int)(testNode[1].value*height);
  fill(colors[predictLabel]);
  stroke(255);
  ellipse(sampleX, sampleY, 50, 50);
  popStyle();
}

void drawInfo(int x, int y) {
  String manual = "\n- Press [ENTER] to Train the SVM"+
      "\n- Press N=[0-9] to Train the SVM with C=2^N"+
      "\n- Press [TAB] to change label color"+
      "\n- Press [/] to clear data"+
      "\n- Press [S] to save model"+
      "\n- Press [I] to toggle info";
  String infoLite;
  if (firstTrained) {
    trainingInfo = "Linear SVM, C = "+ nf ((float)curr_cost, 1, 0) +", In-sample Accuracy = "  + nf ((float)inSample_accuracy*100, 1, 2) + "%, \n Out-of-Sample Accuracy = "+ nf ((float)outOfSample_accuracy*100, 1, 2) + "%" +manual;
    infoLite = "Linear SVM, C = "+ nf ((float)curr_cost, 1, 0) +", In-sample Accuracy = "  + nf ((float)inSample_accuracy*100, 1, 2)+ "%, \n Out-of-Sample Accuracy = "+ nf ((float)outOfSample_accuracy*100, 1, 2) + "% (Press [I] to toggle info)";
  } else {
    trainingInfo = "Linear SVM, C = "+ nf ((float)curr_cost, 1, 0) + manual;
    infoLite = "Linear SVM, C = "+ nf ((float)curr_cost, 1, 0)+
      " (Press [I] to toggle info)";
  }
  pushStyle();
  if (showInfo) {
    stroke(0);
    fill(255,52);
    rect(5,5,390,160);
    noStroke();
    fill(0);
    textSize(12);
    text(trainingInfo,x,y);    
  }else{
    stroke(0);
    fill(255,52);
    rect(5,5,490,40);
    noStroke();
    fill(0);
    textSize(12);
    text(infoLite,x,y);    
  }
  popStyle();
}

void drawCursor(){
  pushStyle();
  noStroke();
  fill(colors[type],52);
  ellipse(mouseX, mouseY, 100, 100);
  popStyle();
}
