#include <Foundation/NSString.h>
@interface NSFramework_WebKit : NSObject
+ (NSString *)frameworkVersion;
+ (NSString *const*)frameworkClasses;
@end
@implementation NSFramework_WebKit
+ (NSString *)frameworkVersion { return @"0.1"; }
static NSString *allClasses[] = {@"WebKit", NULL};
+ (NSString *const*)frameworkClasses { return allClasses; }
@end
