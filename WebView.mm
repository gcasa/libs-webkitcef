/* This is under the LGPL */

#include <signal.h>

#include "cef_app.h"
#include "cef_browser.h"
#include "cef_command_line.h"
#include "cef_client.h"
#include "cef_render_handler.h"
#include "cef_message_router.h"
#include "capi/cef_browser_capi.h"
#include "capi/cef_client_capi.h"

#import "WebView.h"

@interface GSWebView : WebView
{
  cef_browser_t* browser;
  cef_client_t* cef_client;
}

+ (void)initilizeCEFWithArgs:(int)argc argv:(char**)argv;

@end

@implementation WebView

+ (id) allocWithZone: (NSZone *)zone
{
  if (self == [WebView class])
  {
    return [GSWebView allocWithZone: zone];
  }
  return [super allocWithZone: zone];
}

- (void)loadRequest:(NSURLRequest*)request
{
}

- (void)loadHTMLString:(NSString*)string baseURL:(NSURL*)baseURL
{
}

- (void)reload
{
}

- (void)stopLoading
{
}

- (void)goBack
{
}

- (void)goForward
{
}

- (BOOL)canGoBack
{
  return NO;
}

- (BOOL)canGoForward
{
  return NO;
}

- (NSString*)stringByEvaluatingJavaScriptFromString:(NSString*)script
{
  return @"";
}

- (NSURL*)mainFrameURL
{
  return nil;
}

- (NSString*)mainFrameTitle
{
  return @"";
}

@end

@implementation GSWebView

+ (void)initialize
{
  signal(SIGINT, signal_handler);
  signal(SIGTERM, signal_handler);
}

+ (void)initializeCEFWithArgs:(int)argc argv:(char**)argv
{
  struct _cef_main_args args = {0};
  args.argc = argc;
  args.argv = argv;

  cef_app_t* app_handler = create_cef_app();

  int exit_code = cef_execute_process(&args, app_handler, NULL);
  if (exit_code >= 0) {
    exit(exit_code);
  }

  struct _cef_settings_t settings = {0};
  settings.size = sizeof(settings);
  settings.multi_threaded_message_loop = 0;

  cef_initialize(&args, &settings, app_handler, NULL);
}

- (instancetype)initWithFrame:(NSRect)frameRect
{
  self = [super initWithFrame:frameRect];
  if (self)
    {
      cef_window_info_t window_info = {0};
      cef_browser_settings_t browser_settings = {0};

      browser_settings.size = sizeof(browser_settings);
      window_info.windowless_rendering_enabled = 0;

      NSWindow* parent_window = [self window];
      void* native_handle = (__bridge void*)[parent_window windowHandle]; // pseudo
      window_info.parent_window = (cef_window_handle_t)native_handle;
      window_info.bounds.x = frameRect.origin.x;
      window_info.bounds.y = frameRect.origin.y;
      window_info.bounds.width = frameRect.size.width;
      window_info.bounds.height = frameRect.size.height;

      cef_string_t start_url = {}; cef_string_from_ascii("https://www.gnu.org", &start_url);

      cef_client = create_minimal_client();
      browser = cef_browser_host_create_browser_sync(&window_info, cef_client, &start_url, &browser_settings, NULL, NULL);

      [NSThread detachNewThreadSelector:@selector(runCEFLoop) toTarget:self withObject:nil];
    }
  return self;
}

+ (void)runCEFLoop
{
  @autoreleasepool {
    cef_run_loop_thread(nil);
  }
}

- (void)dealloc
{
  stop_signal = 1;
  cef_shutdown();
  [super dealloc];
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize
{
  [super resizeSubviewsWithOldSize:oldSize];
  if (browser)
    {
      cef_browser_host_t* host = browser->get_host(browser);
      host->was_resized(host);
    }
}

- (void)loadRequest:(NSURLRequest*)request
{
  NSString* url = [[request URL] absoluteString];
  [self loadURL:url];
}

- (void)loadHTMLString:(NSString*)string baseURL:(NSURL*)baseURL
{
  if (browser)
    {
      const char* utf8_str = [string UTF8String];
      cef_string_t html = {};
      cef_string_t base = {};

      cef_string_set(utf8_str, strlen(utf8_str), &html, 1);
      if (baseURL)
	{
	  NSString *baseString = [baseURL absoluteString];
	  const char* utf8_str_base = [baseString UTF8String];
	  cef_string_set(utf8_str_base, strlen(utf8_str_base), &base, 1);
	}

      cef_frame_t* frame = browser->get_main_frame(browser);
      frame->load_string(frame, &html, &base);
    }
}

- (void)loadURL:(NSString*)url
{
  if (browser)
    {
      cef_string_t c_url = {};
      const char* utf8_str = [url UTF8String];
      cef_string_set(utf8_str, strlen(utf8_str), &c_url, 1);
      cef_frame_t* frame = browser->get_main_frame(browser);
      frame->load_url(frame, &c_url);
    }
}

- (void)reload
{
  if (browser)
    {
      browser->reload(browser);
    }
}

- (void)stopLoading
{
  if (browser)
    {
      browser->stop_load(browser);
    }
}

- (void)goBack
{
  if (browser)
    {
      browser->go_back(browser);
    }
}

- (void)goForward
{
  if (browser)
    {
      browser->go_forward(browser);
    }
}

- (BOOL)canGoBack
{
  return browser ? browser->can_go_back(browser) : NO;
}

- (BOOL)canGoForward
{
  return browser ? browser->can_go_forward(browser) : NO;
}

- (NSString*)stringByEvaluatingJavaScriptFromString:(NSString*)script
{
  if (browser)
    {
      cef_string_t js = {};
      const char* utf8_str = [script UTF8String];
      cef_string_set(utf8_str, strlen(utf8_str), &js, 1);

      cef_frame_t* frame = browser->get_main_frame(browser);
      frame->execute_java_script(frame, &js, NULL, 0);
      return @""; // async, no return
    }
  return @"";
}

- (NSURL*)mainFrameURL
{
  if (browser)
    {
      cef_frame_t* frame = browser->get_main_frame(browser);
      cef_string_userfree_t url = frame->get_url(frame);
      NSString* ns_url = (__bridge_transfer NSString*)cef_string_userfree_to_cfstring(url);
      return [NSURL URLWithString: ns_url];
    }
  return nil;
}

- (NSString*)mainFrameTitle
{
  if (!browser) return @"";
  return @"CEF WebView";
}

@end
