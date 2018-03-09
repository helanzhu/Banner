//
//  BannerView.h
//  Banner
//
//  Created by chenqg on 2018/3/9.
//  Copyright © 2018年 helanzhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BannerView,BannerOption;

typedef NS_ENUM(NSUInteger,PageControlAliment) {
    PageControlAlimentLeft   = 1,
    PageControlAlimentCenter = 2,
    PageControlAlimentRight  = 3,
};

typedef void(^BannerCellIndexSelectedBlock)(NSInteger index);
typedef void(^BannerOptionBlock)(BannerOption *option);

@interface BannerOption : NSObject

@property (nonatomic, assign) BOOL shouldLoop;
@property (nonatomic, assign) BOOL autoScroll;
@property (nonatomic, assign) NSTimeInterval timeInterval;
@property (nonatomic, assign) PageControlAliment pageControlAliment;
@property (nonatomic, assign) BOOL shouldHiddenPageControl;

@end

@interface BannerView : UIView

@property (nonatomic, strong, readonly) BannerOption *option;
@property (nonatomic, strong) NSArray *imageGroup;

- (instancetype)cellIndexSelected:(BannerCellIndexSelectedBlock)cellIndexSelectedBlock;
- (instancetype)option:(BannerOptionBlock)option;
- (void)adjustWhenControllerViewWillAppear;

@end

