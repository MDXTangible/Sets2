// -------------------------------------------------------------
abstract class Expr {

  // Expr = BinExpr | UnaryExpr| NameExpr  ... 
  // BinExpr = Expr Op Expr
  // UnaryExpr = UnaryOp Expr
  // NameExpr = A | B | ....

  // Op = \ union | \ intersect | \ diff | ...
  // UnaryOp = Comp

  // plus: brackets?  Empty

  MathsSym sym; 

  abstract String toString();

  boolean isBinExpr() {
    return false;
  } 
  boolean isUnaryExpr() {
    return false;
  } 

  boolean isNumExpr() {
    return false;
  }
  boolean isNameExpr() {
    return false;
  }
  boolean isComplete() {
    return true;
  }

  abstract boolean contains(int x, int y);

  void calcCircles(int x, int y) {
    ArrayList<NameExpr> ns = getNamesList();

    switch(ns.size()) {
    case 0: 
      break;
    case 1: 
      ns.get(0).setLoc(x, y); 
      break;
    case 2: 
      ns.get(0).setLoc(x-cOffset, y);  
      ns.get(1).setLoc(x+cOffset, y); 
      break;

    case 3: 
      ns.get(0).setLoc(x, y-cOffset);  
      ns.get(1).setLoc(x-cOffset, y+cOffset); 
      ns.get(2).setLoc(x+cOffset, y+cOffset); 
      break;
    case 4: // what to do here?
      break;
    }
  }

  void drawCircles() {
    ArrayList<NameExpr> ns = getNamesList();

    for (NameExpr e : ns) {
      e.drawCircle();
    }
  }

  abstract HashSet<NameExpr> getNames();

  ArrayList<NameExpr> getNamesList() {
    ArrayList<NameExpr>  l = new ArrayList(getNames());
    Collections.sort(l);
    return l;
  }

  abstract void drawSet(color inCol, color outCol, SetContext ctxt);
  // drawSet() is an attempt to draw and shade the Venn diag in a cleverer way.
  // Haven't figured out how to do it. 
  // Need some representation of sets 
  // to which Union, Intersection etc can be applied. I.e. some way of 
  // representing the region in an intersection.
}


// -------------------------------------------------------------

class NameExpr extends Expr implements Comparable {
  String name="";

  int xLoc, yLoc; // Location of the circle for this name

  int compareTo(Object o) {
    return name.compareTo(((NameExpr)o).name);
  }
  boolean equals(Object o) {
    if (o.getClass() == this.getClass()) {
      return (name.equals(((NameExpr)o).name));
    }
    return super.equals(o);
  }

  String toString() {
    return name;
  }


  HashSet<NameExpr> getNames() {
    HashSet a =  new HashSet();
    a.add(this);
    return a;
  }
  void setLoc(int x, int y) {
    xLoc=x; // record where we're drawing this!
    yLoc=y;
  }

  void drawCircle() {
    push();
    ellipseMode(CENTER);
    textAlign(CENTER, CENTER);

    noFill();
    strokeWeight(2);
    stroke(0);
    ellipse(xLoc, yLoc, cRad, cRad);
    fill(0);
    text(name, xLoc, yLoc-10);
    pop();
  }

  void drawSet(color inCol, color outCol, SetContext ctxt) {
    fill(inCol);
    ellipse(xLoc, yLoc, cRad, cRad);
  }

  boolean contains(int x, int y) {
    return (2* dist(x, y, xLoc, yLoc)) < cRad;
  }
}

// -------------------------------------------------------------
class BinExpr extends Expr {
  Expr left;
  String op;
  Expr right;

  String toString() {

    String r = (right==null)?"null":right.toString();
    return "(" + left.toString() + 
      " " + op + " " + 
      r+")";
  }
  boolean isBinExpr() {
    return true;
  }
  boolean isComplete() {
    return (left!=null && op !=null && right !=null);// text if left & right complete?
  }

  HashSet<NameExpr> getNames() {
    HashSet a =  new HashSet();
    if (left != null) {
      a.addAll(left.getNames());
    }
    if (right != null) {
      a.addAll(right.getNames());
    }
    return a;
  }

  void drawSet(color inCol, color outCol, SetContext ctxt) {
    if(op == UNION){
    
    left.drawSet( inCol, outCol, ctxt);
    right.drawSet( inCol, outCol, ctxt);
    } else if (op==DIFF){ 
    left.drawSet( inCol, outCol, ctxt);
    right.drawSet( outCol, 0, ctxt);
    }else if (op==INTER){ 
    left.drawSet(  outCol, inCol, ctxt);
    right.drawSet( outCol, inCol, ctxt);
    }
  }


  boolean contains(int x, int y) {
    boolean r=false;
    if (isComplete()) {
      switch (op) {
      case UNION:
        r = left.contains(x, y) || right.contains(x, y) ;
        break;
      case INTER:
        r = left.contains(x, y) && right.contains(x, y) ;
        break;
      case DIFF:
        r = left.contains(x, y) && !right.contains(x, y) ;
        break;
      }
    }
    return r;
  }
}


// -------------------------------------------------------------
class UnaryExpr extends Expr {
  String op;
  Expr exp;

  String toString() {

    return 
      " " + op + " " +  exp+" ";
  }

  boolean isUnaryExpr() {
    return true;
  }
  boolean isComplete() {
    return (op !=null && exp !=null);// text if exp complete?
  }

  HashSet<NameExpr> getNames() {
    HashSet<NameExpr> ns = new HashSet<NameExpr>();
    if (isComplete()) {
      ns =  exp.getNames();
    } else {
    }
    return ns;
  }

  void drawSet(color inCol, color outCol, SetContext ctxt) {
    fill(inCol);
    exp.drawSet( inCol, outCol, ctxt);
  }

  boolean contains(int x, int y) {
    boolean r=true;
    if (isComplete() && op == COMP) {
      r=!exp.contains(x, y); // actually, should we negate this? As it's complement
    }
    return r;
  }
}
