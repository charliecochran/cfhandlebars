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
         + oldLines[arrayLen(oldLines) - arrayLen(lines) + 1]).len() - lines[1].len() :
        this.yylloc.first_column - len
    };

    if (isDefined('this.options.ranges') && this.options.ranges) {
      var r = this.yylloc.range;
      this.yylloc.range = [r[1], r[1] + this.yyleng - len];
    }
    this.yyleng = this.yytext.len();
    return this;
  }

}
