component {

	null = function () { return; };

	this.EOF = 1;

  public function parseError (str, hash) {
    if (isDefined('this.yy.parser')) {
      this.yy.parser.parseError(str, hash);
    } else {
      throw(message=str);
    }
  }

  public function setInput (input, yy) {
    this.yy = isDefined('arguments.yy') ? arguments.yy : isDefind('this.yy') ? this.yy : {};
    this._input = input;
    this._more = false;
    this._backtrack = false;
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
    if (isDefined('this.options.ranges') && this.options.ranges) {
      this.yylloc.range = [0,0];
    }
    this.offset = 0;
    return this;
  }

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
    if (isDefined('this.options.ranges') && this.options.ranges) {
      this.yylloc.range[2]++;
    }

    this._input = removeChars(this._input, 1, 1);
    return ch;
  }

}