//
//  XLViewController.m
//  MonitorCpuUsage
//
//  Created by 815009254@qq.com on 04/26/2019.
//  Copyright (c) 2019 815009254@qq.com. All rights reserved.
//

#import "XLViewController.h"
#import "XLBrokenLineViewController.h"


@interface XLViewController ()

@end

@implementation XLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Demo";
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"查看CPU使用率" forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, 300, 40);
    btn.center = self.view.center;
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(showBrokenLine) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)showBrokenLine {
    XLBrokenLineViewController *eblVC = [[XLBrokenLineViewController alloc] init];
    [self.navigationController pushViewController:eblVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
