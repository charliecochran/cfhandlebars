component {

  o = function(k,v,o={}) {
    for(var l = ArrayLen(k); --l; o[k[l]]=v);
    return o;
  }

  // INSERT variables (except for o function)
  // INSERT this.symbols_
  // INSERT this.terminals_
  // INSERT this.productions_
  // INSERT this.table
  // INSERT this.defaultActions

  public function init(yy = {}) {
    this.yy = arguments.yy;
    
    // TODO: yy.locInfo

    return this;
  }

  public function trace() {}

  /**
  * @yystate action[1]
  * @$$ vstack 
  * @_$ lstack
  */
  public function performAction(yytext, yyleng, yylineno, yy, yystate /* action[1] */, $$ /* vstack */, _$ /* lstack */) {
    // INSERT performAction switch statement here
  }


}
