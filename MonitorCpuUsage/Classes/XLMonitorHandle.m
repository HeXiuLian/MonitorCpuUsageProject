//
//  XLMonitorHandle.m
//  MonitorCpuUsage
//
//  Created by HeXiuLian on 2019/4/25.
//  Copyright © 2019 HeXiuLian. All rights reserved.
//

#import "XLMonitorHandle.h"
#include <sys/sysctl.h>
#include <mach/mach.h>
#import <QuartzCore/QuartzCore.h>
#import "SMCallStack.h"

#define CPUMONITORRATE  90

@interface XLMonitorHandle ()

@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, assign) BOOL  logStatus;

@property (nonatomic, assign) CGFloat  cpuUsageMax;
///存储监测的数据
@property (nonatomic, strong) NSMutableArray  *arrMonitorData;


@end

@implementation XLMonitorHandle

+ (instancetype)shareInstance {
    static XLMonitorHandle *instace = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instace = [[XLMonitorHandle alloc] init];
    });
    return instace;
}

- (void)setCpuUsageMax:(CGFloat)UsageMax {
    _cpuUsageMax = UsageMax;
}

- (void)startMonitorFpsAndCpuUsage {
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(__startMonitor:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stopMonitor {
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)__startMonitor:(CADisplayLink *)displayLink {
    static NSTimeInterval lastTime = 0;
    static int frameCount = 0;
    if (lastTime == 0) {
        lastTime = displayLink.timestamp;
        return;
    }
    //累计帧数
    frameCount++;
    //累计时间
    NSTimeInterval passTime = displayLink.timestamp - lastTime;
    //1秒左右获取一次帧数
    if (passTime > 1) {
        //帧数 = 总帧数/时间
        int fps = round(frameCount/passTime);
        //重置
        lastTime = displayLink.timestamp;
        frameCount = 0;
        int cpuUsage= [self ll_cpuUsage];
        if (self.logStatus) {
            NSLog(@"fps = %d ; cpuUsage = %d",fps,cpuUsage);
        }
        UIViewController *VC = [self getCurrentVC];
        NSString *vcName = NSStringFromClass([VC class]);
        vcName = vcName ? vcName : @"没有VC";
 
        NSDictionary *dict = @{@"index":@(self.arrMonitorData.count),
                               @"cpuUsage":@(cpuUsage),
                               @"time":[self getCurrentDate],
                               @"fps":@(fps),
                               @"vcName":vcName,
                               @"arrThreadInfo":[self getCPUMONITORRATE]
                               };
        [self.arrMonitorData addObject:dict];
    }
}

- (NSMutableArray *)getCPUMONITORRATE {
    //int 组成的数组比如 thread[1] = 5635
    thread_act_array_t threads;
    //mach_msg_type_number_t 是 int 类型
    mach_msg_type_number_t thread_count = 0;
    //int
    const task_t this_task = mach_task_self();
    
    NSMutableArray *arrThreadInfo = [NSMutableArray new];
    //根据当前 task 获取所有线程
    task_threads(this_task, &threads, &thread_count);
    
    for (int i = 0; i < thread_count; i++) {
        thread_info_data_t threadInfo;
        thread_basic_info_t threadBaseInfo;
        mach_msg_type_number_t threadInfoCount = THREAD_INFO_MAX;
        if (thread_info((thread_act_t)threads[i], THREAD_BASIC_INFO, (thread_info_t)threadInfo, &threadInfoCount) == KERN_SUCCESS) {
            threadBaseInfo = (thread_basic_info_t)threadInfo;
            if (!(threadBaseInfo->flags & TH_FLAGS_IDLE)) {
                integer_t cpuUsage = threadBaseInfo->cpu_usage / 10;
                _cpuUsageMax = _cpuUsageMax > 0 ? _cpuUsageMax : CPUMONITORRATE;
                if (cpuUsage > _cpuUsageMax) {
                    //cup 消耗大于设置值时打印和记录堆栈
                    NSString *reStr = smStackOfThread(threads[i]);
                    [arrThreadInfo addObject:reStr];
                }
            }
        }
    }
    return arrThreadInfo;
}

/**
 CPU使用量

 @return 使用量
 */
- (int)ll_cpuUsage {
    kern_return_t kr;
    ///任务信息
    task_info_data_t tinfo;
    ///任务个数
    mach_msg_type_number_t task_info_count;
    ///最大1024
    task_info_count = TASK_INFO_MAX;
    ///获取当前执行的任务信息和个数
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    ///判断是否获取成功
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    ///基础任务
    task_basic_info_t      basic_info;
    ///线程数组
    thread_array_t        thread_list;
    ///线程个数
    mach_msg_type_number_t thread_count;
    ///线程信息
    thread_info_data_t    thinfo;
    ///线程信息个数
    mach_msg_type_number_t thread_info_count;
    ///基础线程信息
    thread_basic_info_t basic_info_th;
    ///存储运行的线程
    uint32_t stat_thread = 0;
    
    basic_info = (task_basic_info_t)tinfo;
    ///获取当前执行的线程数组和个数
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    ///判断是否成功
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    if (thread_count > 0) {
        stat_thread += thread_count;
    }
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    ///遍历所有线程
    for (j = 0; j < (int)thread_count; j++) {
        ///线程信息最大个数
        thread_info_count = THREAD_INFO_MAX;
        ///获取线程的基础信息和信息个数
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        ///判断是否成功
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        ///转换基础信息类型
        basic_info_th = (thread_basic_info_t)thinfo;
        ///判断不是闲置线程信息
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            ///使用时间计算
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->user_time.microseconds + basic_info_th->system_time.microseconds;
            ///使用率计算
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
    }
    ///释放指针
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    ///成功
    assert(kr == KERN_SUCCESS);
    ///返回CPU使用率
    return roundf(tot_cpu);
}

- (void)setLogStatus:(BOOL)logStatus {
    _logStatus = logStatus;
}

- (void)clearMonitorData {
    [self.arrMonitorData removeAllObjects];
}

- (NSString *)getCurrentDate {
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}

//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC {
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    UIView *frontView = [window subviews].lastObject;
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        result = [self getTopControllerWithVC:nextResponder];
    } else {
        result = window.rootViewController;
    }
    return result;
}

/**
 获取最顶层正在显示的VC
 @param vc 底层VC
 @return 顶层VC
 */
- (UIViewController *)getTopControllerWithVC:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)vc;
        vc = nav.viewControllers.lastObject;
        return [self getTopControllerWithVC:vc];
    } else if ([vc isKindOfClass: [UITabBarController class]]) {
        UITabBarController *tabVC = (UITabBarController *)vc;
        vc = tabVC.viewControllers[tabVC.selectedIndex];
        return [self getTopControllerWithVC:vc];
    } else if ([vc isKindOfClass:[UIViewController class]]) {
        if (vc.childViewControllers.count > 0) {
            vc = vc.childViewControllers.lastObject;
            return [self getTopControllerWithVC:vc];
        }
    }
    return vc;
}

- (NSMutableArray *)arrMonitorData {
    if (!_arrMonitorData) {
        _arrMonitorData = [NSMutableArray new];
    }
    return _arrMonitorData;
}

- (NSArray *)getCpuUsageData {
    return [self.arrMonitorData copy];
}

@end
