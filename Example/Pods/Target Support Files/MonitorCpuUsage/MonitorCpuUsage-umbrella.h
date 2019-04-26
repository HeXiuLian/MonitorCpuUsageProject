#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "SMCallLib.h"
#import "SMCallStack.h"
#import "XLBrokenLineViewController.h"
#import "XLMonitorBrokenLineView.h"
#import "XLMonitorHandle.h"

FOUNDATION_EXPORT double MonitorCpuUsageVersionNumber;
FOUNDATION_EXPORT const unsigned char MonitorCpuUsageVersionString[];

