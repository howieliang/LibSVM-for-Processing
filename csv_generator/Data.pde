//Class Data: Data structure for the data feeding into SVM

class Data {
  double[] features;
  int label;
  int dof;
  double mX = 0;
  double mY = 0;
  Data (double[] _features) {
    features = new double[_features.length];
    dof = _features.length-1;
    for (int i = 0; i < _features.length; i++) features[i] = _features[i];
    label = (int)_features[_features.length-1];
    if (dof==2) { 
      mX = features[0];
      mY = features[1];
    }
  }
  public double X()
  {
    return this.mX;
  }
  public double Y()
  {
    return this.mY;
  }
  public int Label()
  {
    return this.label;
  }
  public double[] Features(){
    return this.features;
  }
  public int DOF(){
    return this.dof;
  }
}