// https://github.com/jigish/slate/wiki/JavaScript-Configs

var console = { log : slate.log };

slate.config('defaultToCurrentScreen', true);
slate.config('nudgePercentOf', 'screenSize');
slate.config('resizePercentOf', 'screenSize');
slate.config("orderScreensLeftToRight", true);

slate.config('gridRoundedCornerSize', 3);
slate.config('gridCellRoundedCornerSize', 3);
slate.config('gridCellBackgroundColor', '75:77:81:0.8');


slate.bind("esc:alt", slate.operation("grid", {
	"grids" : {
		"1920x1200" : {
			"width" : 3,
			"height" : 2
		},
		"2560x1440" : {
			"width" : 3,
			"height" : 3
		},
		"1280x800" : {
			"width" : 3,
			"height" : 3
		},
		"3840x2160" : {
			"width" : 3,
			"height" : 3
		},
		"1680x1050" : {
			"width" : 3,
			"height" : 3
		}
	},
	"padding" : 2
}));

slate.bind("esc:ctrl", slate.operation("relaunch"));

slate.on('screenConfigurationChanged', function (e) {
	console.log('slate screenConfigurationChanged');
});

function getLayoutSignature () {
	var sigs = [];
	slate.eachScreen(function (screen) {
		var rect = screen.rect();
		var sig = rect.width + 'x' + rect.height;
		sigs.push(sig);
	});
	return sigs.join(' ');
}

function detectScreensAndRelocationWindows () {
	console.log('detectScreensAndRelocationWindows');
	var layout = getLayoutSignature();
	console.log(layout);
	if (layout === '1920x1200 2560x1440') {
		slate.eachApp(function (app) {
			var appName = app.name();
			console.log('appName', appName);

			var n = 0; app.eachWindow(function (win) {
				console.log('    window', n, win.title(), win.isMain());
				n++;
			});

			if (appName === 'ターミナル') {
				console.log('Terminal.app');
				app.eachWindow(function (win) {
					var title = win.title();
					if (title.match(/screen/)) {
						win.doOperation(slate.operation("move", {
							"screen": "1",
							"x" : "screenOriginX",
							"y" : "screenOriginY",
							"width" : "screenSizeX",
							"height" : "screenSizeY"
						}));
					} else 
					if (title.match(/ssh/)) {
						win.doOperation(slate.operation("move", {
							"screen": "1",
							"x" : "screenOriginX+1600",
							"y" : "screenOriginY+50",
							"width" : "800",
							"height" : "1000"
						}));
					}
					n++;
				});
			} else
			if (appName === 'IntelliJ IDEA' ||
				appName === 'Xcode') {
				app.eachWindow(function (win) {
					win.doOperation(slate.operation("move", {
						"screen": "1",
						"x" : "screenOriginX",
						"y" : "screenOriginY",
						"width" : "screenSizeX",
						"height" : "screenSizeY"
					}));
				});
			} else
			if (appName === 'Google Chrome') {
				var n = 0; app.eachWindow(function (win) {
					// i want to identify user logged-in on chrome but it can't
				});
			} else
			if (appName === 'Slack') {
				app.eachWindow(function (win) {
					win.doOperation(slate.operation("move", {
						"screen": "1",
						"x" : "screenOriginX",
						"y" : "screenOriginY+(screenSizeY/2)",
						"width" : "screenSizeX/3*2",
						"height" : "screenSizeY/2"
					}));
				});
			} else
			if (appName === 'HipChat') {
				app.eachWindow(function (win) {
					win.doOperation(slate.operation("move", {
						"screen": "1",
						"x" : "screenOriginX",
						"y" : "screenOriginY",
						"width" : "screenSizeX/3*2",
						"height" : "screenSizeY/2"
					}));
				});
			} else
			if (appName === 'Radiant Player' ||
				appName === 'iTunes') {
				app.eachWindow(function (win) {
					win.doOperation(slate.operation("move", {
						"screen": "0",
						"x" : "screenOriginX+200",
						"y" : "screenOriginY+100",
						"width" : "screenSizeX-200*2",
						"height" : "screenSizeY-100*2"
					}));
				});
			}
		});
	} else
	if (layout === '1680x1050') {
		// d
	} else
	if (layout === '2560x1440 1280x800 3840x2160') {
		// do
		slate.eachApp(function (app) {
			var appName = app.name();
			console.log('appName', appName);

			if (appName === 'Radiant Player' ||
				appName === 'iTunes') {
				app.eachWindow(function (win) {
					win.doOperation(slate.operation("move", {
						"screen": "2",
						"x" : "screenOriginX+screenSizeX-1280",
						"y" : "screenOriginY",
						"width" : "1280",
						"height" : "screenSizeY"
					}));
				});
			} else
			if (appName === 'プレビュー') {
				app.eachWindow(function (win) {
					win.doOperation(slate.operation("move", {
						"screen": "2",
						"x" : "screenOriginX",
						"y" : "screenOriginY",
						"width" : "screenSizeX",
						"height" : "screenSizeY"
					}));
				});
			} else
			if (appName === 'Chemr' ||
				appName === 'メール' ) {
				app.eachWindow(function (win) {
					win.doOperation(slate.operation("move", {
						"screen": "0",
						"x" : "screenOriginX+200",
						"y" : "screenOriginY+100",
						"width" : "screenSizeX-200*2",
						"height" : "screenSizeY-100*2"
					}));
				});
			} else
			if (appName === 'Slack') {
				app.eachWindow(function (win) {
					win.doOperation(slate.operation("move", {
						"screen": "1",
						"x" : "screenOriginX",
						"y" : "screenOriginY",
						"width" : "screenSizeX",
						"height" : "screenSizeY"
					}));
				});
			}
		});
	}
}


// show screen info on launch
slate.eachScreen(function (screen) {
	console.log('screen', screen.id(), JSON.stringify(screen.rect()), !!screen.isMain());
});

detectScreensAndRelocationWindows();
