/* WebView
 *
 * This class is WebView
 *
 * Copyright (C) 2025 Free Software Foundation, Inc.
 *
 * Author:      Gregory John Casamento <greg.casamento@gmail.com>
 * Date:        2025
 *
 * This file is part of GNUstep.
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02111 USA.
 */

/* This is under the LGPL */

#include <iostream>

#include "cef_app.h"
#include "cef_browser.h"
#include "cef_command_line.h"
#include "cef_client.h"
#include "cef_render_handler.h"
#include "cef_message_router.h"
#include "cef_browser_process_handler.h"
#include "cef_parser.h"

#import "WebView.h"

class MinimalClient : public CefClient
{
 public:
  IMPLEMENT_REFCOUNTING(MinimalClient);
};


class MyCefApp : public CefApp, public CefBrowserProcessHandler
{
 public:
    CefRefPtr<CefBrowserProcessHandler> GetBrowserProcessHandler() override
    {
        return this;
    }

    IMPLEMENT_REFCOUNTING(MyCefApp);
};


void LoadHTML(CefRefPtr<CefFrame> frame, const std::string& html)
{
  if (!frame) return;

  CefString encoded = CefURIEncode(CefString(html), false);
  std::string data_url = "data:text/html;charset=utf-8," + encoded.ToString();

  frame->LoadURL(data_url);
}

@interface GSWebView : WebView
{
  CefRefPtr<CefBrowser> browser_;
  CefRefPtr<MinimalClient> client_;
}

+ (void)initializeCEFWithArgs:(int)argc argv:(char**)argv;

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

- (void)loadRequest: (NSURLRequest*)request
{
}

- (void)loadHTMLString: (NSString*)string baseURL: (NSURL*)baseURL
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

- (NSString*) stringByEvaluatingJavaScriptFromString: (NSString*)script
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

+ (void) initializeCEFWithArgs: (int)argc
			  argv: (char**)argv
{
  CefMainArgs main_args(argc, argv);
  CefRefPtr<MyCefApp> app = new MyCefApp();

  int exit_code = CefExecuteProcess(main_args, app, nullptr);
  if (exit_code >= 0)
    {
      exit(exit_code);
    }

  CefSettings settings;
  settings.no_sandbox = true;
  settings.multi_threaded_message_loop = false;  // same as your original

  CefInitialize(main_args, settings, app, nullptr);
}

- (instancetype) initWithFrame: (NSRect)frameRect
{
  self = [super initWithFrame:frameRect];
  if (self)
    {
    }
  return self;  
}

+ (void)runCEFLoop
{
  CefRunMessageLoop();
}

- (void) awakeFromNib
{
  NSRect frameRect = [self frame];
  CefWindowInfo window_info;
  CefBrowserSettings browser_settings;
  
  // Setup parent window
  NSWindow* parent_window = [self window];
  
  NSLog(@"parent_window = %@", parent_window);
  void* native_handle = (__bridge void*)[parent_window windowHandle];
  // ensure windowHandle returns NSView*
  
  NSLog(@"native_handle = %ld", native_handle);
  CefWindowHandle cef_handle = reinterpret_cast<CefWindowHandle>(native_handle);
  
  NSLog(@"cef_handle = %ld", cef_handle);
  window_info.SetAsChild(cef_handle,
			 CefRect(
				 frameRect.origin.x,
				 frameRect.origin.y,
				 frameRect.size.width,
				 frameRect.size.height
				 ));
  
  CefString start_url = "https://www.gnu.org";
  
  client_ = new MinimalClient();
  NSLog(@"client_ = %ld", &client_);
  
  browser_ = CefBrowserHost::CreateBrowserSync(
					       window_info,
					       client_,
					       start_url,
					       browser_settings,
					       nullptr,
					       nullptr
					       );
  
  [NSThread detachNewThreadSelector: @selector(runCEFLoop)
			   toTarget: self
			 withObject: nil];
  
}

- (void)dealloc
{
  CefShutdown();
  [super dealloc];
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize
{
  [super resizeSubviewsWithOldSize:oldSize];

  if (!browser_)
    return;

  CefRefPtr<CefBrowserHost> host = browser_->GetHost();
  if (host)
    host->WasResized();
}

- (void)loadRequest:(NSURLRequest*)request
{
  NSString* url = [[request URL] absoluteString];
  [self loadURL:url];
}

- (void)loadHTMLString:(NSString*)string baseURL:(NSURL*)baseURL
{
  if (!browser_)
    return;

  std::string html = [string UTF8String];
  std::string base;

  if (baseURL)
    {
      base = [[baseURL absoluteString] UTF8String];
    }

  CefRefPtr<CefFrame> frame = browser_->GetMainFrame();
  if (frame)
    LoadHTML(frame, html);
}

- (void)loadURL:(NSString*)url
{
  if (!browser_)
    return;

  std::string urlStr = [url UTF8String];

  CefRefPtr<CefFrame> frame = browser_->GetMainFrame();
  if (frame)
    frame->LoadURL(urlStr);
}

- (void)reload
{
  if (browser_)
    {
      browser_->Reload();
    }
}

- (void)stopLoading
{
  if (browser_)
    {
      browser_->StopLoad();
    }
}

- (void)goBack
{
  if (browser_)
    {
      browser_->GoBack();
    }
}

- (void)goForward
{
  if (browser_)
    {
      browser_->GoForward();
    }
}

- (BOOL)canGoBack
{
  return browser_ ? browser_->CanGoBack() : NO;
}

- (BOOL)canGoForward
{
  return browser_ ? browser_->CanGoForward() : NO;
}

- (NSString*)stringByEvaluatingJavaScriptFromString:(NSString*)script
{
  if (!browser_)
    return @"";

  std::string jsCode = [script UTF8String];
  CefRefPtr<CefFrame> frame = browser_->GetMainFrame();
  if (frame)
    frame->ExecuteJavaScript(jsCode, frame->GetURL(), 0);

  return @"";  // still async, no result returned  
}

- (NSURL*)mainFrameURL
{
  if (!browser_)
    return nil;

  CefRefPtr<CefFrame> frame = browser_->GetMainFrame();
  if (!frame)
    return nil;

  std::string url = frame->GetURL();
  return [NSURL URLWithString:[NSString stringWithUTF8String:url.c_str()]];
}

- (NSString*)mainFrameTitle
{
  if (!browser_) return @"";
  return @"CEF WebView";
}

@end
