//
//  XLMonitorHandle.h
//  MonitorCpuUsage
//
//  Created by HeXiuLian on 2019/4/25.
//  Copyright © 2019 HeXiuLian. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XLMonitorHandle : NSObject
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

NS_ASSUME_NONNULL_END
