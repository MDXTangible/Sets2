class Parser {

  // Expr = BinExpr | Name | ( Expr ) |... 
  // BinExpr = Expr Op Expr
  // Name = A | B | ....

  // Op = union | intersect | diff | ...

  // plus: brackets? Unary ops? Empty

  // Want lists of exprs.
  // so parser returns List<Expr>

  //ArrayList<MathsSym> symList = new ArrayList();
  //ExprStack stack = new ExprStack();

  Parser() {
  }


  // parse - return an Expr.
  // How to return a List<Expr>?

  // Better to use a stream over tokens?
  // we only ever look at pos 0 and rest for the recursive call

  ArrayList<Expr> parse(ArrayList<MathsSym> tokens) {
    ExprStack stack = new ExprStack();
    stack.init();
    return parseExp(tokens.iterator(), stack, 0);
  }

  ArrayList<Expr> parseExp(Iterator<MathsSym> tokens, ExprStack stack, int depth) {
    // Nothing left to parse
    //Log("Parsing: " +tokens);
    if (!tokens.hasNext()) { 

      //Log("At End : "+stack);
accumulate(stack);
      if (stack.hasError()) { // incomplete expr
        Log("Err: ");
        return null;
      } else {
        accumulate(stack); // why accumulate here? we've accumulated just above.
        return stack.stack; // ArrayList containing  all expressions
      }
    }

    MathsSym token = tokens.next();
    //Log("Token:"+token);

    // 1 : Name
    if (token.isName()) {
      NameExpr n = new NameExpr();
      n.name=token.text;
      //Log("Name:"+n);
      // within an expr
      stack.push(n); // Just push it.
      accumulate(stack);
      return parseExp(tokens, stack, depth);
    } else if (token.isBinOp()) {

      if (stack.isEmpty()) { 
        Log("No Left Op"); 
        return null;
      }
      if (!stack.top().isComplete()) { 
        Log("Incomplete Left Op"); 
        return null;
      }
      BinExpr e = new BinExpr();
      e.op=token.text;
      e.left=stack.pop();

      stack.push(e);
      return parseExp(tokens, stack, depth);
    } else if (token.isUnaryOp()) {
      UnaryExpr e = new UnaryExpr();
      e.op=token.text;
      stack.push(e);
      return parseExp(tokens, stack, depth);
    } else if (token.isOpen()) {
      // push a bracket. Not really an expression!
      Expr e = new OpenBracket();
      stack.push(e);
      //accumulate(stack); // do we need this here?
      return parseExp(tokens, stack, depth+1); // back from the brackets now - so do the rest. 
      //return stack.stack;
    } else if (token.isClose()) {
      //Log("Close :"+stack.stack);

      if (!processBracketExpr(stack)) { 
        Log("Unmatched Brackets:"+stack.stack);
        return null;
      }

      parseExp(tokens, stack, depth+1);
      //Log("Processed close :"+stack.stack);
      accumulate(stack);  
      //Log("Close-:"+stack.stack);
      if (stack.hasError()) {
        return null;
      } else {
        return stack.stack;
      }
    }
    return null;
  }

  boolean processBracketExpr(ExprStack stack) {
    // just got a close bracket.
    // Need to pop until we get a corresponding open
    // Then push everything back on.
    int s = stack.size();
    if (s<2) { 
      return false;
    } else {
      Expr e1 = stack.pop();
      Expr e2 = stack.pop();
      if (e2.isOpenBracket()) {
        if (e1.isComplete()) {
          stack.push(e1); 
          accumulate(stack);
          return true;
        } else { 
          Log("Incomplete subExpr"); 
          return false;
        }
      } else { 
        Log("No Open for Close");  
        return false;
      }
    }
  }

  void accumulate(ExprStack stack) {
    // pop some things until we can build a complete expr. Then push this.
    // 

    //Log("Accumulate : "+stack);
    if (stack.isEmpty() || !stack.top().isOpenBracket()) {
      if (stack.size()>=2) {
        Expr e1=stack.pop(); // should be complete
        if (stack.top().isBinExpr() && !stack.top().isComplete()) {
          BinExpr e2=(BinExpr)stack.pop(); // should be incomplete
          accumulate(stack);
          e2.right=e1;
          stack.push(e2);
        } else if (stack.top().isUnaryExpr() && !stack.top().isComplete()) {
          UnaryExpr e2=(UnaryExpr)stack.pop(); // should be incomplete
          accumulate(stack);
          e2.exp=e1;
          stack.push(e2);
        } else {  
          accumulate(stack);
          stack.push(e1);
        }
      }
    }

    //Log("A-: "+stack);
  }
}
