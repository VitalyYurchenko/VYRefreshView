//
//  VYRefreshView.h
//  Refresh
//
//  Created by Vitaly Yurchenko on 20.02.12.
//  Copyright (c) 2012 Vitaly Yurchenko. All rights reserved.
//
// ********************************************************************************************************************************************************** //

#import <UIKit/UIKit.h>

// ********************************************************************************************************************************************************** //

@protocol VYRefreshViewDelegate;

// ********************************************************************************************************************************************************** //

typedef NS_ENUM(NSUInteger, VYRefreshViewState)
{
    VYRefreshViewStateNormal = 0,
	VYRefreshViewStatePulling,
	VYRefreshViewStateRefreshing,
};

typedef NS_ENUM(NSUInteger, VYRefreshViewStyle)
{
    VYRefreshViewStyleDefault = 0,
    VYRefreshViewStyleBlue,
	VYRefreshViewStyleWhite,
	VYRefreshViewStyleGray,
    VYRefreshViewStyleBlack
};

// ********************************************************************************************************************************************************** //

@interface VYRefreshView : UIView

@property (nonatomic, readonly) VYRefreshViewState state;
@property (nonatomic) VYRefreshViewStyle style;

@property (nonatomic, copy) NSString *titleForNormalState;
@property (nonatomic, copy) NSString *titleForPullingState;
@property (nonatomic, copy) NSString *titleForRefreshingState;
@property (nonatomic, copy) NSString *titleForLastRefreshDate;

@property (nonatomic, weak) id<VYRefreshViewDelegate> delegate;

+ (VYRefreshView *)refreshViewForScrollView:(UIScrollView *)scrollView;
+ (VYRefreshView *)refreshViewAddedToScrollView:(UIScrollView *)scrollView;

- (id)initWithScrollView:(UIScrollView *)scrollView;

- (void)scrollViewDidScroll;
- (void)scrollViewDidEndDragging;

- (void)updateLastRefreshDate;

- (void)startRefreshing;
- (void)stopRefreshing;
- (BOOL)isRefreshing;

@end

// ********************************************************************************************************************************************************** //

@protocol VYRefreshViewDelegate <NSObject>

@required
- (BOOL)refreshViewShouldStartRefresh:(VYRefreshView *)view;

@optional
- (NSDate *)refreshViewLastRefreshDate:(VYRefreshView *)view;

@end
