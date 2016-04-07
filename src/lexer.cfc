component {

  null = function () { return; };
  br = CreateObject("java", "java.lang.System").getProperty("line.separator");

  this.EOF = 1;

  // INSERT RULES
  // INSERT CONDITIONS

  public function parseError (str, hash) {
    if (isDefined('this.yy.parser')) {
      this.yy.parser.parseError(str, hash);
    } else {
      throw(message=str);
    }
  }

  // resets the lexer, sets new input
  public function setInput (input, yy) {
    this.yy = isDefined('arguments.yy') ? arguments.yy : (isDefined('this.yy') ? this.yy : {});
    this._input = input;
    this._more = false;
    this.done = false;
    this.yylineno = 0;
    this.yyleng = 0;
    this.yytext = '';
    this.matched = '';
    this.match = '';
    this.conditionStack = ['INITIAL'];
    this.yylloc = {
      first_line: 1,
      first_column: 0,
      last_line: 1,
      last_column: 0
    };
    this.offset = 0;
    return this;
  }

  // consumes and returns one char from the input
  public function input () {
    var ch = this._input.left(1);
    this.yytext &= ch;
    this.yyleng++;
    this.offset++;
    this.match &= ch;
    this.matched &= ch;
    var lines = reMatch("(?:\r\n?|\n).*", ch);
    if (lines.len()) {
      this.yylineno++;
      this.yylloc.last_line++;
    } else {
      this.yylloc.last_column++;
    }

    this._input = removeChars(this._input, 1, 1);
    return ch;
  }

  // unshifts one char (or a string) into the input
  public function unput (ch) {
    var len = ch.len();
    var lines = ch.split("(?:\r\n?|\n)");

    this._input = ch & this._input;
    this.yytext = left(this.yytext, this.yytext.len() - len)
    this.offset -= len;
    var oldLines = this.match.split("(?:\r\n?|\n)");
    this.match = left(this.match, this.match.len() - 1);
    this.matched = left(this.matched, this.matched.len() - 1);

    if (arrayLen(lines) - 1) {
      this.yylineno -= arrayLen(lines) - 1;
    }

    this.yylloc = {
      first_line: this.yylloc.first_line,
      last_line: this.yylineno + 1,
      first_column: this.yylloc.first_column,
      last_column: arraylen(lines) ?
        (arrayLen(lines) == arrayLen(oldLines) ? this.yylloc.first_column : 0)
         + oldLines[arrayLen(oldLines) - arrayLen(lines) + 1].len() - lines[1].len() :
        this.yylloc.first_column - len
    };

    this.yyleng = this.yytext.len();
    return this;
  }

  // When called from action, caches matched text and appends it on next action
  public function more () {
    this._more = true;
    return this;
  }

  // When called from action, signals the lexer that this rule fails to match the input, so the next matching rule (regex) should be tested instead.
  public function reject () {
    return this.parseError('Lexical error on line #this.yylineno + 1#.#br##this.showPosition()#', {
      text: "",
      token: null(),
      line: this.yylineno
    });
  }

  // retain first n characters of the match
  public function less (n) {
    this.unput(right(this.match, this.match.len() - n));
  }

  // displays already matched input, i.e. for error messages
  public function pastInput () {
    var past = left(this.matched, this.matched.len() - this.match.len());
    return (past.len() > 20 ? '...' : '') & REReplace(right(past, 20), "[\n\r]", "", "all");
  }

  // displays upcoming input, i.e. for error messages
  public function upcomingInput () {
    var next = this.match;
    if (next.len() < 20) {
      next &= left(this._input, 20 - next.len());
    }
    return REReplace(left(next, 20) & (next.len() > 20 ? '...' : ''), "[\n\r]", "", "all");
  }

  // displays the character position where the lexing error occurred, i.e. for error messages
  public function showPosition () {
    var pre = this.pastInput();
    var c = repeatString('-', pre.len());
    return pre & this.upcomingInput() & br & c & '^';
  }

  // test the lexed token: return FALSE when not a match, otherwise return token
  public function test_match (match, indexed_rule) {
    var token = null();
    var lines = reMatch("(?:\r\n?|\n).*", match[1]);

    if (lines.len()) {
      this.yylineno += lines.len();
    }
    this.yylloc = {
      first_line: this.yylloc.last_line,
      last_line: this.yylineno + 1,
      first_column: this.yylloc.last_column,
      last_column: lines.len() ?
             lines[lines.len()].len() - reMatch("(?:\r\n?|\n).*", lines[lines.len()])[1].len() :
             this.yylloc.last_column + match[1].len()
    };
    this.yytext &= match[1];
    this.match &= match[1];
    this.matches = match;
    this.yyleng = this.yytext.len();
    this._more = false;
    this._input = right(this._input, this._input.len() - match[1].len());
    this.matched &= match[1];
    token = this.performAction(this.yy, this, indexed_rule, this.conditionStack[this.conditionStack.len()]);
    if (this.done && this._input.len()) {
      this.done = false;
    }
    if (isDefined(token)) {
      return token;
    }
    return false;
  }

  // return next match in input
  public function next () {
    if (this.done) {
      return this.EOF;
    }
    if (!this._input.len()) {
      this.done = true;
    }

    var token = null();
    var match = null();
    var tempMatch = null();
    var index = null();
    if (!this._more) {
      this.yytext = '';
      this.match = '';
    }
    var rules = this._currentRules();
    for (var i = 1; i <= rules.len(); i++) {
      tempMatch = reMatch(this._input, this.rules[rules[i]+1]);
      if (tempMatch.len() && (!isDefined('match') || tempMatch[1].len() > match[1].len())) {
        match = tempMatch;
        index = i;
        break;
      }
    }
    if (isDefined('match') && match.len()) {
      token = this.test_match(match, rules[index]);
      if (token != false) {
        return token;
      }
      // else: this is a lexer rule which consumes input without producing a token (e.g. whitespace)
      return false;
    }
    if (this._input == "") {
      return this.EOF;
    } else {
      return this.parseError('Lexical error on line #this.yylineno + 1#. Unrecognized text.#br##this.showPosition()#', {
        text: "",
        token: null(),
        line: this.yylineno
      });
    }
  }

  // return next match that has a token
  public function lex () {
    var r = this.next();
    if (r) {
      return r;
    } else {
      return this.lex();
    }
  }

  // activates a new lexer condition state (pushes the new lexer condition state onto the condition stack)
  public function begin (condition) {
    this.conditionStack.append(condition);
  }

  // pop the previously active lexer condition state off the condition stack
  public function popState () {
    var n = this.conditionStack.len();
    if (n > 1) {
      var popped = this.conditionStack[n];
      this.conditionStack.deleteAt(n);
      return popped;
    } else {
      return this.conditionStack[1];
    }
  }

  // produce the lexer rule set which is active for the currently active lexer condition state
  public function _currentRules () {
    if (this.conditionStack.len() && this.conditionStack[this.conditionStack.len()].len()) {
      return this.conditions[this.conditionStack[this.conditionStack.len()]].rules;
    } else {
      return this.conditions["INITIAL"].rules;
    }
  }

  // return the currently active lexer condition state; when an index argument is provided it produces the N-th previous condition state, if available
  public function topState (n) {
    n = this.conditionStack.len() - (isDefined('n') ? abs(val(n)) : 0);
    if (n >= 1) {
      return this.conditionStack[n];
    } else {
      return "INITIAL";
    }
  }

  // alias for begin(condition)
  public function pushState (condition) {
    this.begin(condition);
  }

  // return the number of states currently on the stack
  public function stateStackSize () {
    return this.conditionStack.len();
  }

  public function performAction (yy,yy_,$avoiding_name_collisions,YY_START) {

    function strip(start, end) {
      return yy_.yytext = mid(yy_.yytext, start, yy_.yyleng-end);
    }

    var YYSTATE = YY_START;

    // INSERT BIG SWITCH STATEMENT HERE
  }


}
