//
//  ViewController.m
//  Banner
//
//  Created by chenqg on 2018/3/9.
//  Copyright © 2018年 helanzhu. All rights reserved.
//

#import "ViewController.h"
#import "BannerView.h"

#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width//获取设备屏幕的宽
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height//获取设备屏幕的高

@interface ViewController ()

@property (nonatomic, strong) BannerView *bannerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self bannerViewInit];
}

- (void)bannerViewInit
{
    [self.view addSubview:self.bannerView];
    NSArray *imageGropus = [NSArray arrayWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"imageGroups.plist" ofType:nil]];
    self.bannerView.imageGroup = imageGropus;
    [self.bannerView cellIndexSelected:^(NSInteger index) {
        NSLog(@"第%@张图被点击了 ",@(index));
    }];
    
}

- (BannerView *)bannerView
{
    if (!_bannerView) {
        _bannerView = [[BannerView alloc] initWithFrame:CGRectMake((SCREENWIDTH - 300)/2., 200, 300, 160)];
        _bannerView.backgroundColor = [UIColor orangeColor];
    }
    return _bannerView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

