class MathsSym {
  // Class of tokens - unparsaed symbols of the set notation
  // Letters (A, B, C, ...) to stand for sets & operators (union, intersection, etc)
  // Brackets.
  
  int x, y;
  String text;
  int size=40;
  int rad=10;

  MathsSym() {
  }

  void draw() {
    pushStyle();
    //stroke(255, 0, 0);
    //fill(0);
    textSize(40);
    textAlign(CENTER, CENTER);
    pushMatrix();

    translate(
      (int)Calibration.transformX(x), 
      (int)Calibration.transformY(y));

    // Show symbs all in a line:
    //translate(
    //  (int)Calibration.transformX(x), symbolLine);

    rect(0, 0, 2*size, 2*size, rad, rad, rad, rad);
    popMatrix();

    fill(255);
    text(text, (int)Calibration.transformX(x), (int)Calibration.transformY(y));
    //text(text, (int)Calibration.transformX(x), symbolLine);
    popStyle();
  }

  String toString() {
    //return "."+text+"["+text.length()+"]";
    return text;
  }

  boolean isName() {
    return ( text.equals("a") 
      || text.equals("b") 
      || text.equals("c") 
      || text.equals("d") 
      || text.equals("A") 
      || text.equals("B") 
      || text.equals("C") 
      || text.equals("D") );
  }
  boolean isBinOp() {
    return (text.equals(UNION) || text.equals(INTER) || text.equals(DIFF));
  }  
  boolean isUnaryOp() {
    return (text.equals(COMP) );
  }  
  boolean isOpen() {
    return (text.equals("("));
  }  
  boolean isClose() {
    return (text.equals(")"));
  }
}
