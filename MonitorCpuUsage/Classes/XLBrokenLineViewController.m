//
//  XLBrokenLineViewController.m
//  E-Mobile
//
//  Created by HeXiuLian on 2019/4/25.
//

#import "XLBrokenLineViewController.h"
#import "XLMonitorBrokenLineView.h"
#import "XLMonitorHandle.h"

@interface XLBrokenLineViewController ()
@property (nonatomic, strong) XLMonitorBrokenLineView  *brokenView;
@end

@implementation XLBrokenLineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 11.0, *)) {
        UIScrollView.appearance.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        UITextView.appearance.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.title = @"CPU使用率折线图";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:UIBarButtonItemStylePlain target:self action:@selector(refreshLine)];
    [self xl_addSubviews];
}

- (void)refreshLine {
    self.brokenView.arrData = [[XLMonitorHandle shareInstance] getCpuUsageData];
}

- (void)xl_addSubviews {
    [self.view addSubview:self.brokenView];
}

- (XLMonitorBrokenLineView *)brokenView {
    if (!_brokenView) {
        _brokenView  = [[XLMonitorBrokenLineView alloc] initWithFrame:self.view.bounds brokenLineData:[[XLMonitorHandle shareInstance] getCpuUsageData]];
    }
    return _brokenView;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
