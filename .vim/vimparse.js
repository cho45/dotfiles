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

			// 可読性のために意図的にそうしているのでうざいし、そういう最適化は実行エンジンがすべきこと
			if (error.reason.indexOf('is better written in dot notation') != -1) return;

			if (error.evidence) {
				// やたら長い行は圧縮されたJSコードとみなす
				if (error.evidence.length > 1000) return;

				// 閉じブレース前のセミコロンは省略可能に
				if (error.reason.indexOf('Missing semicolon') != -1 && error.evidence.substring(error.character).match(/^\s*\}/)) return;
			}

			console.log([filename, error.line, error.character].join(':') + "\t" + error.reason);
		});
	}
});
