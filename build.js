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

console.log('Parser built!');

// LEXER STUFF

// READ src/lexer.cfc
var lexerCfc = fs.readFileSync('./src/lexer.cfc', 'utf-8');

// Replace regex objects with regex strings
var rules = Parser.parser.lexer.rules.map(function(rule) {
  var str = rule.toString();
  
  // remove opening and closing slashes
  // none of the rules have flags so no need to worry about those
  str = str.substring(1, str.length - 1);

  // adjust for ColdFusion special characters
  str = str.replace(/#/g, '##');

  return str;
});
lexerCfc = lexerCfc.replace('@@@rules@@@', 'deserializeJSON("' + JSON.stringify(rules).replace(/"/g, '""') + '")');
lexerCfc = lexerCfc.replace('@@@conditions@@@', JSON.stringify(Parser.parser.lexer.conditions));

// INSERT performAction function body (replace _BACKSLASH_ with \)
var lexerPerformAction = jsFnBody(Parser.parser.lexer.performAction.toString()).replace(/_BACKSLASH_/g, '\\');
lexerCfc = lexerCfc.replace('@@@performAction@@@', lexerPerformAction);

// WRITE lib/lexer.cfc
fs.writeFileSync('./lib/lexer.cfc', lexerCfc);

console.log('Lexer built!');
