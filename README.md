# MonitorCpuUsage

[![CI Status](https://img.shields.io/travis/815009254@qq.com/MonitorCpuUsage.svg?style=flat)](https://travis-ci.org/815009254@qq.com/MonitorCpuUsage)
[![Version](https://img.shields.io/cocoapods/v/MonitorCpuUsage.svg?style=flat)](https://cocoapods.org/pods/MonitorCpuUsage)
[![License](https://img.shields.io/cocoapods/l/MonitorCpuUsage.svg?style=flat)](https://cocoapods.org/pods/MonitorCpuUsage)
[![Platform](https://img.shields.io/cocoapods/p/MonitorCpuUsage.svg?style=flat)](https://cocoapods.org/pods/MonitorCpuUsage)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
![效果图](https://github.com/HeXiuLian/MonitorCpuUsageProject/blob/master/demo.png)


## Installation

MonitorCpuUsage is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'MonitorCpuUsage'
```

## USAGE

	#import <MonitorCpuUsage/XLMonitorHandle.h>
	#import <MonitorCpuUsage/XLBrokenLineViewController.h>
	
开始监控：

	[[XLMonitorHandle shareInstance] setCpuUsageMax:35];
    [[XLMonitorHandle shareInstance] startMonitorFpsAndCpuUsage];
    
显示折线图：

	XLBrokenLineViewController *eblVC = [[XLBrokenLineViewController alloc] init];
    [self.navigationController pushViewController:eblVC animated:YES];


XLMonitorHandle 常用 API:

```
///存储监测的数据
@property (nonatomic, strong) NSMutableArray  *arrMonitorData;

+ (instancetype)shareInstance;

/**
 开始监测
 */
- (void)startMonitorFpsAndCpuUsage;

/**
 停止监测
 */
- (void)stopMonitor;

/**
 是否打印 cpuUsage和fps的值
 @param logStatus 默认NO
 */
- (void)setLogStatus:(BOOL)logStatus;

/**
 清除已经收集的数据
 */
- (void)clearMonitorData;

/**
 设置超过最大cpu使用率的值

 @param UsageMax 最大使用率 默认 90
 */
- (void)setCpuUsageMax:(CGFloat)UsageMax;

@end

```

注意：如果曲线图的左右滚动失效，请修改 <iOS-Echarts> 库 PYZoomEchartsView 类的源码如下：

```

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
#if TARGET_OS_IPHONE
//注释如下代码
//        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchHandle:)];
//        [self addGestureRecognizer:pinchGesture];
//
//        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandle:)];
//        [self addGestureRecognizer:panGesture];
#elif TARGET_OS_MAC
#endif
    }
    return self;
}

```


## Author

815009254@qq.com, xiulian.he@gmail.com

## License

MonitorCpuUsage is available under the MIT license. See the LICENSE file for more info.
