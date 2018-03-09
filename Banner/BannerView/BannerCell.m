//
//  BannerCell.m
//  Banner
//
//  Created by chenqg on 2018/3/9.
//  Copyright © 2018年 helanzhu. All rights reserved.
//

#import "BannerCell.h"
#import <YYKit/YYKit.h>

@interface BannerCell ()

@property (nonatomic, strong) UIImageView *itemView;

@end

@implementation BannerCell

@synthesize itemView = _itemView;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.itemView.frame = self.bounds;
}

- (void)setImagePathString:(NSString *)imagePathString {
    if (imagePathString == nil) {
        return;
    }
    
    if (_itemView) {
        [_itemView removeFromSuperview];
    }
    
    _itemView = self.itemView;
    
    [self addSubview:_itemView];
    
    _imagePathString = imagePathString;
    if ([imagePathString hasPrefix:@"http://"] ||
        [imagePathString hasPrefix:@"https://"]) {
        [_itemView setImageWithURL:[NSURL URLWithString:_imagePathString]
                       placeholder:[UIImage imageWithColor:[UIColor lightGrayColor]]
                           options:YYWebImageOptionProgressive|YYWebImageOptionProgressiveBlur|YYWebImageOptionAllowInvalidSSLCertificates
                        completion:NULL];
        
    } else {
        [_itemView setImage:[UIImage imageNamed:imagePathString]];
    }
}

- (UIView *)itemView {
    if (!_itemView) {
        _itemView = [[UIImageView alloc] init];
        _itemView.userInteractionEnabled = YES;
        _itemView.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    return _itemView;
}

@end

