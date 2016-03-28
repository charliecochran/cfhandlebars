component {

  null = function() { return; };
  br = CreateObject("java", "java.lang.System").getProperty("line.separator");

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
    var $0 = $$.len();
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

  public function parse(input) {
    var stack = [0];
    var tstack = [];
    var vstack = [null()];
    var lstack = [];
    var yytext = '';
    var yylineno = 0;
    var yyleng = 0;
    var recovering = 0;
    var TERROR = 2;
    var EOF = 1;
    var args = arraySlice(arguments, 2);
    var lexer = new lexer();
    var sharedState = { yy: {} };
    for (var k in this.yy) {
      sharedState.yy[k] = this.yy[k];
    }
    lexer.setInput(input, sharedState.yy);
    sharedState.yy.lexer = lexer;
    sharedState.yy.parser = this;
    if (!isDefined('lexer.yylloc')) {
      lexer.yylloc = {};
    }
    var yyloc = lexer.yylloc;
    lstack.append(yyloc);
    if (isDefined('lexer.options.ranges')) {
      var ranges = lexer.options.ranges;
    }
    if (isDefined('sharedState.yy.parseError') && isCustomFunction(sharedState.yy.parseError)) {
      this.parseError = sharedState.yy.parseError;
    }

    var lex = function () {
      var token = lexer.lex();
      if (!token) {
        token = EOF;
      }
      if (!isNumber(token)) {
        token = this.symbols_.keyExists(token) && this.symbols_.token ? this.symbols_[token] : token;
      }
      return token;
    };

    var symbol = null();
    var preErrorSymbol = null();
    var state = null();
    var action = null();
    var a = null();
    var r = null();
    var yyval = {};
    var p = null();
    var len = null();
    var newState = null();
    var expected = null();

    while (true) {
      state = stack[stack.len()];
      if (this.defaultActions.keyExists(state)) {
        action = this.defaultActions[state];
      } else {
        if (!isDefined('symbol')) {
          symbol = lex();
        }
        if(isDefined('state') && isDefined('this.table[#state#]') && isDefined('symbol') && isDefined('this.table[#state#][#symbol#]')) {
          action = this.table[state][symbol];
        }
      }
      if (!isDefined('action') || !isArray(action) || !action.len()) {
          var errStr = '';
          var symbolStr = isDefined('symbol') ? (this.terminals_.keyExists(symbol) ? this.terminals_[symbol] : symbol) : '';
          expected = [];
          for (p in this.table[state]) {
            if (this.terminals_.keyExists(p) && p > TERROR) {
              expected.append("'#this.terminals_[p]#'");
            }
          }
          if (lexer.showPosition) {
            errStr = "Parse error on line #(yylineno + 1)#:#br##lexer.showPosition()##br#Expecting #arrayToList(expected, ', ')#, got '#symbolStr#'";
          } else {
            errStr = 'Parse error on line #(yylineno + 1)#: Unexpected ' & (isDefined('symbol') && symbol == EOF ? 'end of input' : "'#symbolStr#'");
          }
          this.parseError(errStr, {
            text: lexer.match,
            token: symbolStr,
            line: lexer.yylineno,
            loc: yyloc,
            expected: expected
          });
        }
// TODO: translate rest of this function
      if (isArray(action[1]) && action.len() > 1) {
        throw('Parse Error: multiple actions possible at state: ' + state + ', token: ' + symbol);
      }
      switch (action[0]) {
        case 1:
          stack.append(symbol);
          vstack.append(lexer.yytext);
          lstack.append(lexer.yylloc);
          stack.append(action[1]);
          symbol = null();
          preErrorSymbol = true;
          if (!preErrorSymbol) {
            yyleng = lexer.yyleng;
            yytext = lexer.yytext;
            yylineno = lexer.yylineno;
            yyloc = lexer.yylloc;
            if (recovering > 0) {
              recovering--;
            }
          } else {
            symbol = preErrorSymbol;
            preErrorSymbol = null;
          }
          break;
        case 2:
          len = this.productions_[action[1]][1];
          yyval.$ = vstack[vstack.length - len];
          yyval._$ = {
            first_line: lstack[lstack.length - (len || 1)].first_line,
            last_line: lstack[lstack.length - 1].last_line,
            first_column: lstack[lstack.length - (len || 1)].first_column,
            last_column: lstack[lstack.length - 1].last_column
          };
          if (isDefined(ranges)) {
            yyval._$.range = [
              lstack[lstack.length - (len || 1)].range[0],
              lstack[lstack.length - 1].range[1]
            ];
          }
          r = this.performAction.apply(yyval, [
            yytext,
            yyleng,
            yylineno,
            sharedState.yy,
            action[1],
            vstack,
            lstack
          ].concat(args));
          if (typeof r !== 'undefined') {
            return r;
          }
          if (len) {
            stack = stack.slice(0, -1 * len * 2);
            vstack = vstack.slice(0, -1 * len);
            lstack = lstack.slice(0, -1 * len);
          }
          stack.append(this.productions_[action[1]][0]);
          vstack.append(yyval.$);
          lstack.append(yyval._$);
          newState = this.table[stack[stack.length - 2]][stack[stack.length - 1]];
          stack.append(newState);
          break;
        case 3:
          return true;
      }
    }
    return true;
  }


}
