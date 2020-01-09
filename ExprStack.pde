class ExprStack {
  // Make into a class

  ArrayList<Expr> stack = new ArrayList();
  
  void init() {
    stack = new ArrayList();
  }

  void push (Expr e) {
    stack.add(e);
  }
  Expr pop() {
    //Log("Pop");
    return stack.remove(stack.size()-1);
  }
  Expr top() {
    //Log("Top");
    return stack.get(stack.size()-1);
  }
  boolean isEmpty() {
    return (stack.size()==0);
  }
  
  boolean hasError(){
    boolean err=false;
    for(Expr e:stack){
      if(!e.isComplete()){ err=true; }
    }
    //Log("Stack: "+ stack + " Err: "+ err);
    return (isEmpty() || err);
  }
  
  int size(){
    return stack.size();
  }
  
  String toString(){
    return stack.toString();
  }
}
