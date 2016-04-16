console.log('Building...');

var fs = require('fs');
var Parser = require('./handlebars.js');

function jsFnBody(str) {
  str = str.split('{');
  str.shift();
  str = str.join('{');

  str = str.split('}');
  str.pop();
  str = str.join('}');

  return str;
}

// PARSER STUFF

var parserCfc = fs.readFileSync('./src/parser.cfc', 'utf-8');

parserCfc = parserCfc.replace('@@@symbols@@@', JSON.stringify(Parser.parser.symbols_));
parserCfc = parserCfc.replace('@@@terminals_@@@', JSON.stringify(Parser.parser.terminals_));
parserCfc = parserCfc.replace('@@@productions_@@@', JSON.stringify(Parser.parser.productions_));
parserCfc = parserCfc.replace('@@@table@@@', JSON.stringify(Parser.parser.table));
parserCfc = parserCfc.replace('@@@defaultActions@@@', JSON.stringify(Parser.parser.defaultActions));

// INSERT performAction function body (replace this. with yyval.)
var parserPerformAction = jsFnBody(Parser.parser.performAction.toString()).replace(/this\./g, 'yyval.');
parserCfc = parserCfc.replace('@@@performAction@@@', parserPerformAction);

// WRITE lib/parser.cfc
fs.writeFileSync('./lib/parser.cfc', parserCfc);


// LEXER STUFF

// READ src/lexer.cfc

// INSERT rules / replace regexp objects with regexp strings
// INSERT conditions
// replace _BACKSLASH_ with \
// performAction function body

// WRITE lib/lexer.cfc
