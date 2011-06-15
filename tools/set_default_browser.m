// #!gcc -framework Cocoa set_default_browser.m -o set_default_browser && ./set_default_browser com.google.Chrome

// bundleID = Appbundle.app/Contents/Info.plist CFBundleIdentifier
// eg:
//   com.apple.Safari
//   com.google.Chrome
//   org.mozilla.firefox
//   com.operasoftware.Opera

#import <Cocoa/Cocoa.h>

int main(int argc, char* argv[]) {
	if (argc < 2) return 1;
	printf("Set Default Browser to %s\n", argv[1]);

	CFStringRef bundleID = CFStringCreateWithCString(NULL, argv[1], kCFStringEncodingASCII);
	if (bundleID == NULL) return 2;

	OSStatus httpResult  = LSSetDefaultHandlerForURLScheme(CFSTR("http"),  bundleID);
	OSStatus httpsResult = LSSetDefaultHandlerForURLScheme(CFSTR("https"), bundleID);

	if (httpResult == noErr && httpsResult == noErr) {
		return 0;
	} else {
		return 1;
	}
}


