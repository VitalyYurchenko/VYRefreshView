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

typedef enum
{
    VYRefreshViewStateNormal = 0,
	VYRefreshViewStatePulling,
	VYRefreshViewStateRefreshing,
} VYRefreshViewState;

// ********************************************************************************************************************************************************** //

@interface VYRefreshView : UIView
{
@private
	VYRefreshViewState _state;
    __weak id<VYRefreshViewDelegate> _delegate;
}

@property (nonatomic, readonly) VYRefreshViewState state;
@property(nonatomic, weak) id<VYRefreshViewDelegate> delegate;

- (id)initWithScrollView:(UIScrollView *)scrollView;

- (void)startRefreshing;
- (void)stopRefreshing;
- (BOOL)isRefreshing;

@end

// ********************************************************************************************************************************************************** //

@protocol VYRefreshViewDelegate <NSObject>

@required
- (BOOL)refreshViewShouldStartRefresh:(VYRefreshView *)view;

@optional
- (NSDate *)refreshLastRefreshDate:(VYRefreshView *)view;

@end
