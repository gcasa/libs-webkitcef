#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>

// WebView interface
@interface WebView : NSView

- (void)loadRequest:(NSURLRequest*)request;
- (void)loadHTMLString:(NSString*)string baseURL:(NSURL*)baseURL;
- (void)reload;
- (void)stopLoading;
- (void)goBack;
- (void)goForward;
- (BOOL)canGoBack;
- (BOOL)canGoForward;
- (NSString*)stringByEvaluatingJavaScriptFromString:(NSString*)script;
- (NSURL*)mainFrameURL;
- (NSString*)mainFrameTitle;

@end
