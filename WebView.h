#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include <signal.h>

#include "cef_app.h"
#include "cef_browser.h"
#include "cef_command_line.h"
#include "cef_client.h"
#include "cef_render_handler.h"
#include "cef_message_router.h"

// WebView interface
@interface WebView : NSView
{
    cef_browser_t* browser;
    cef_client_t* cef_client;
}

+ (void)initialize;
+ (void)initializeCEFWithArgs:(int)argc argv:(char**)argv;
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
