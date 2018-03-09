//
//  BannerView.m
//  Banner
//
//  Created by chenqg on 2018/3/9.
//  Copyright © 2018年 helanzhu. All rights reserved.
//

#import "BannerView.h"
#import "BannerCell.h"

@implementation BannerOption

@synthesize timeInterval = _timeInterval;
@synthesize autoScroll = _autoScroll;
@synthesize shouldLoop = _shouldLoop;
@synthesize pageControlAliment = _pageControlAliment;
@synthesize shouldHiddenPageControl = _shouldHiddenPageControl;

- (instancetype)init {
    self = [super init];
    if (self) {
        _shouldLoop = YES;
        _autoScroll = YES;
        _timeInterval = 2.0f;
        _pageControlAliment = PageControlAlimentCenter;
        _shouldHiddenPageControl = NO;
    }
    return self;
}

- (void)setTimeInterval:(NSTimeInterval)scrollInterval {
    if (scrollInterval < 0.5) {
        scrollInterval = 0;
        _autoScroll = NO;
    }
    _timeInterval = scrollInterval;
}

- (void)setAutoScroll:(BOOL)autoScroll {
    if (self.timeInterval == 0) {
        autoScroll = NO;
    }
    _autoScroll = autoScroll;
}

@end

@interface BannerView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong, readwrite) BannerOption *option;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, assign) NSInteger itemCount;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) CGRect pageControlFrame;
@property (nonatomic, strong) NSArray *imagePathsGroup;
@property (nonatomic, copy) BannerCellIndexSelectedBlock cellIndexSelectedBlock;

@end

@implementation BannerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self bannerViewInit];
    }
    return self;
}

- (void)bannerViewInit {
    self.option = [[BannerOption alloc] init];
    [self addSubview:self.collectionView];
    [self addSubview:self.pageControl];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateSubviewsFrame];
}

- (void)updateSubviewsFrame {
    
    self.flowLayout.itemSize = self.bounds.size;
    self.collectionView.frame = self.bounds;
    
    if (_collectionView.contentOffset.x == 0 &&  self.itemCount) {
        int targetIndex = 0;
        if (self.option.shouldLoop) {
            targetIndex = self.itemCount * 0.5;
        }else{
            targetIndex = 0;
        }
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
    
    if (self.option.shouldHiddenPageControl) {
        self.pageControl.hidden = YES;
    } else {
        self.pageControl.hidden = NO;
    }
    
    if (self.imagePathsGroup.count <= 1) {
        self.pageControl.hidden = YES;
    }
    
    CGFloat w = self.imagePathsGroup.count * 10 * 1.5;
    CGFloat h = 40;
    CGFloat x = 0;
    CGFloat y = self.frame.size.height - h;
    switch (self.option.pageControlAliment) {
        case PageControlAlimentLeft:
        {
            x = 10 ;
        }
            break;
        case PageControlAlimentCenter:
        {
            x = ( self.bounds.size.width - w ) / 2.0 ;
        }
            break;
        case PageControlAlimentRight:
        {
            x = self.bounds.size.width - w - 10 ;
        }
            break;
            
        default:
            break;
    }
    self.pageControl.frame = CGRectMake(x, y, w, h);
    
}


- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        [self stopTimer];
    }else{
        if (self.option.autoScroll) {
            [self startTimer];
        }
    }
}

- (void)dealloc {
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
}

#pragma mark - public actions

- (void)adjustWhenControllerViewWillAppear
{
    long targetIndex = [self currentIndex];
    if (targetIndex < self.itemCount) {
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}

#pragma mark - Reload

- (void)reloadData {
    self.pageControl.numberOfPages = self.imagePathsGroup.count;
    int indexOnPageControl = self.imagePathsGroup.count > 0 ? [self pageControlIndexWithCurrentCellIndex:[self currentIndex]] : 0;
    self.pageControl.currentPage = indexOnPageControl;
    [self.collectionView reloadData];
    
    [self layoutSubviews];
}

#pragma mark - NSTimer

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)startTimer {
    if (!self.option.autoScroll) return;
    [self stopTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.option.timeInterval target:self selector:@selector(automaticScroll) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)automaticScroll {
    if (self.imagePathsGroup.count <= 1) {
        return;
    }
    
    if (self.itemCount == 0 ||
        self.itemCount == 1 ||
        !self.option.autoScroll)
    {
        return;
    }
    
    int currentIndex = [self currentIndex];
    int targetIndex = currentIndex + 1;
    
    if (targetIndex >= self.itemCount) {
        targetIndex = self.option.shouldLoop ? self.itemCount * 0.5 : 0;
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }else{
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }
}

- (int)currentIndex {
    if (_collectionView.frame.size.width == 0 || _collectionView.frame.size.height == 0) {
        return 0;
    }
    
    int index = 0;
    index = (_collectionView.contentOffset.x + _flowLayout.itemSize.width * 0.5) / _flowLayout.itemSize.width;
    
    return MAX(0, index);
}

#pragma mark -

- (instancetype)cellIndexSelected:(BannerCellIndexSelectedBlock)cellIndexSelectedBlock{
    self.cellIndexSelectedBlock = cellIndexSelectedBlock;
    return self;
}

- (instancetype)option:(BannerOptionBlock)option {
    if (self.option.autoScroll) [self stopTimer];
    option(self.option);
    if (self.option.autoScroll) [self startTimer];
    return self;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.option.shouldLoop ? self.itemCount : self.imagePathsGroup.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BannerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BannerIdentify" forIndexPath:indexPath];
    NSInteger indexRow = [self pageControlIndexWithCurrentCellIndex:indexPath.item];
    cell.imagePathString = self.imagePathsGroup[indexRow];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.cellIndexSelectedBlock) {
        self.cellIndexSelectedBlock([self pageControlIndexWithCurrentCellIndex:indexPath.item]);
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.imagePathsGroup.count) return;
    int itemIndex = [self currentIndex];
    int indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:itemIndex];
    
    self.pageControl.currentPage = indexOnPageControl;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.option.autoScroll) {
        [self stopTimer];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.option.autoScroll) {
        [self startTimer];
    }
}

#pragma mark - setter

- (void)setImageGroup:(NSArray *)imageGroup {
    [self stopTimer];
    
    _imageGroup = imageGroup;
    
    NSMutableArray *temp = [NSMutableArray new];
    [_imageGroup enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * stop) {
        NSString *urlString;
        if ([obj isKindOfClass:[NSString class]]) {
            urlString = obj;
        } else if ([obj isKindOfClass:[NSURL class]]) {
            NSURL *url = (NSURL *)obj;
            urlString = [url absoluteString];
        }
        if (urlString) {
            [temp addObject:urlString];
        }
    }];
    self.imagePathsGroup = [temp copy];
    
    if (imageGroup.count != 1) {
        self.collectionView.scrollEnabled = YES;
        [self startTimer];
    } else {
        self.collectionView.scrollEnabled = NO;
    }
    
    [self reloadData];
}

- (void)setPageControlFrame:(CGRect)pageControlFrame {
    _pageControlFrame = pageControlFrame;
    self.pageControl.frame = pageControlFrame;
}

#pragma mark - getter

- (int)pageControlIndexWithCurrentCellIndex:(NSInteger)index {
    return (int)index % self.imagePathsGroup.count;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.flowLayout];
        _collectionView.pagingEnabled = YES;
        _collectionView.alwaysBounceHorizontal = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.scrollsToTop = NO;
        _collectionView.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollsToTop = NO;
        [_collectionView registerClass:[BannerCell class] forCellWithReuseIdentifier:@"BannerIdentify"];
        
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.minimumInteritemSpacing = 0;
        _flowLayout.minimumLineSpacing = 0;
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.sectionInset = UIEdgeInsetsZero;
    }
    return _flowLayout;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.userInteractionEnabled = NO;
        _pageControl.autoresizingMask = UIViewAutoresizingNone;
    }
    return _pageControl;
}

- (NSInteger)itemCount {
    if (!self.imagePathsGroup) return 0;
    return self.option.shouldLoop ? self.imagePathsGroup.count * 10000 : self.imagePathsGroup.count;
}

@end

