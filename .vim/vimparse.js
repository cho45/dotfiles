#!/usr/bin/env node


var JSHINT = require("./jshint.js").JSHINT;
var fs = require("fs");

var argv = process.argv;
argv.shift();
argv.shift();

argv.forEach(function (filename) {
	var source = fs.readFileSync(filename, 'utf-8');
	var result = JSHINT(source, {
		browser   : true,
		jquery    : true,
		evil      : true,
		devel     : true,
		lastsemic : true,
		smarttabs : true,
		onecase   : true,
		passfail  : false
	});
	if (!result) {
		JSHINT.errors.forEach(function (error) {
			if (!error) return;

			if (error.reason.indexOf('Stopping, unable to continue.') != -1) return;

			if (error.reason.indexOf("Bad escapement") != -1) return;
			if (error.reason.indexOf("Weird construction. Delete 'new'") != -1) return;

			if (error.reason.indexOf("Use the array literal notation [].") != -1) return;

			// いや…… 必要なときに言われても……
			if (error.reason.indexOf("Unnecessary escapement.") != -1) return;

			// 何これ？
			if (error.reason.indexOf("Confusing use of '!'.") != -1) return;

			// for (var i...) は何度も書きたい
			if (error.reason.indexOf("'i' is already defined.") != -1) return;
			if (error.reason.indexOf("'it' is already defined.") != -1) return;
			if (error.reason.indexOf("'key' is already defined.") != -1) return;

			// 可読性のために意図的にそうしているのでうざいし、そういう最適化は実行エンジンがすべきこと
			if (error.reason.indexOf('is better written in dot notation') != -1) return;

			// 可読性を損う程の根拠がわからないので保留
			if (error.reason.indexOf("Don't make functions within a loop") != -1) return;

			if (error.evidence) {
				error.evidence = error.evidence.replace(/\t/g, '    ');

				// 明示的に抑止されてるなら無視
				if (error.evidence.indexOf('no warnings') != -1) return;

				// やたら長い行は圧縮されたJSコードとみなす
				if (error.evidence.length > 1000) return;
			}

			console.log([filename, error.line, error.character].join(':') + "\t" + error.reason);
		});
	}
});
