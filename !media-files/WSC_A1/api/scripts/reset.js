const { reset, file } = require('../lib/db');
reset();
console.log(`Banco restaurado: ${file}`);
