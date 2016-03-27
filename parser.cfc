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
  public function performAction(yyval, yytext, yyleng, yylineno, yy, yystate, $$, _$) {
    // INSERT performAction switch statement here
    // TODO replace "this." with "yyval." when inserting since we can't use function context binding in CF
  }

  public function parseError(str, hash) {
    if (hash.recoverable) {
      this.trace(str);
    } else {
      throw(message=msg, detail=hash, type="ParseError");
    }
  }

}
