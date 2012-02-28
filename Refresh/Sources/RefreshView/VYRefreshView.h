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

enum
{
    VYRefreshViewStateNormal = 0,
	VYRefreshViewStatePulling,
	VYRefreshViewStateRefreshing,
};
typedef NSUInteger VYRefreshViewState;

enum
{
    VYRefreshViewStyleDefault = 0,
    VYRefreshViewStyleBlue,
	VYRefreshViewStyleWhite,
	VYRefreshViewStyleGray,
    VYRefreshViewStyleBlack
};
typedef NSUInteger VYRefreshViewStyle;

// ********************************************************************************************************************************************************** //

@interface VYRefreshView : UIView
{
@private
	VYRefreshViewState _state;
    VYRefreshViewStyle _style;
    
    NSString *_titleForNormalState;
    NSString *_titleForPullingState;
    NSString *_titleForRefreshingState;
    
    __weak id<VYRefreshViewDelegate> _delegate;
}

@property (nonatomic, readonly) VYRefreshViewState state;
@property (nonatomic, assign) VYRefreshViewStyle style;

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
