#!/usr/bin/env node

var JSHINT = require("./jshint.js").JSHINT;
var fs = require("fs");

var argv = process.argv;
argv.shift();
argv.shift();

argv.forEach(function (filename) {
	var source = fs.readFileSync(filename, 'utf-8');
	var result = JSHINT(source, {
		browser : true,
		jquery  : true,
		evil    : true,
		passfail : false
	});
	if (!result) {
		JSHINT.errors.forEach(function (error) {
			if (!error) return;
			if (error.evidence && error.evidence.length > 1000) return;
			console.log([filename, error.line, error.character].join(':') + "\t" + error.reason);
		});
	}
});
