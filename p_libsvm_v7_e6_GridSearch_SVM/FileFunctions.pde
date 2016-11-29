// Functions for loading files (SVM, Dataset) into the SVM

ArrayList<Data> loadData(String fileName, int feature_Num) {
  return loadDataScaled(fileName, feature_Num, 1.);
}

ArrayList<Data> loadDataScaled(String fileName, int feature_Num, double scale) {
  ArrayList<Data> d_list = new ArrayList<Data>();
  String lines[] = loadStrings(fileName);
  if (lines!=null) {
    for (int i = 0; i < lines.length; i++) {
      String[] l = splitTokens(lines[i]);
      double[] p = new double[feature_Num+1];
      if (l.length>0) {
        double label = Double.parseDouble(l[0]);
        p[feature_Num] = label;
        for (int j = 1; j < l.length; j++) {
          String[] v = splitTokens(l[j], ":");
          int index = Integer.parseInt(v[0]);
          double value = Double.parseDouble(v[1])/scale;
          p[index-1] = value;
        }
        if (label>maxLabel) maxLabel = (int)label;
      }
      d_list.add(new Data(p));
    }
  } else {
    println("No such file");
  }
  return d_list;
}

ArrayList<Data> loadCSV(String fileName) {
  ArrayList<Data> arrayList = new ArrayList<Data>();
  Table data = loadTable(fileName);
  ArrayList<Double> labelList = new ArrayList<Double>();
  int type = 0;

  if (data != null) {
    for (int i = 1; i < data.getRowCount(); i++) {
      TableRow row = data.getRow(i);
      double[] p = new double[data.getColumnCount()];
      p[0] = row.getDouble(0)/500.; //x: scale from [0 .. 500] to [0 .. 1] 
      p[1] = row.getDouble(1)/500.; //y: scale from [0 .. 500] to [0 .. 1]
      double oldlabel = row.getDouble(2); 
      double newLabel = -1;
      for (int j = 0; j < labelList.size(); j++) {
        if (oldlabel == labelList.get(j)) { 
          newLabel = j; 
          break;
        }
      }
      if (newLabel<0) {
        newLabel = labelList.size();
        labelList.add(oldlabel);
      }
      p[2] = newLabel;    //label: Integer. No scaling is required to perform. 
      arrayList.add(new Data(p));
    }
  }
  return arrayList;
}