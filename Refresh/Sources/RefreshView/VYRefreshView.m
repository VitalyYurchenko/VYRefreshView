//
//  VYRefreshView.m
//  Refresh
//
//  Created by Vitaly Yurchenko on 20.02.12.
//  Copyright (c) 2012 Vitaly Yurchenko. All rights reserved.
//
// ********************************************************************************************************************************************************** //

#import "VYRefreshView.h"

#import <QuartzCore/QuartzCore.h>

// ********************************************************************************************************************************************************** //

static CGFloat const kRefreshViewHeight = 60.0;
static CGFloat const kRefreshViewActionTopThreshold = -65.0;

static NSTimeInterval const kScrollViewSlideAnimationDuration = 0.3;
static CFTimeInterval const kArrowAnimationDuration = 0.15;

// ********************************************************************************************************************************************************** //

@interface VYRefreshView ()

@property (nonatomic, assign, readwrite) VYRefreshViewState state;

@end

// ********************************************************************************************************************************************************** //

@implementation VYRefreshView
{
    __strong UIScrollView *_scrollView;
    
    __strong UILabel *_statusLabel;
	__strong UILabel *_detailsLabel;
	__strong CALayer *_arrowLayer;
	__strong UIActivityIndicatorView *_activityIndicator;
}

@synthesize state = _state;
@synthesize style = _style;

@synthesize titleForNormalState = _titleForNormalState;
@synthesize titleForPullingState = _titleForPullingState;
@synthesize titleForRefreshingState = _titleForRefreshingState;
@synthesize titleForLastRefreshDate = _titleForLastRefreshDate;

@synthesize delegate = _delegate;

#pragma mark -
#pragma mark Object Lifecycle

+ (VYRefreshView *)refreshViewForScrollView:(UIScrollView *)scrollView
{
    __autoreleasing VYRefreshView *refreshView = [[VYRefreshView alloc] initWithScrollView:scrollView];
    
    return refreshView;
}

+ (VYRefreshView *)refreshViewAddedToScrollView:(UIScrollView *)scrollView
{
    VYRefreshView *refreshView = [self refreshViewForScrollView:scrollView];
    
    [scrollView addSubview:refreshView];
    
    return refreshView;
}

- (id)initWithFrame:(CGRect)frame
{
    NSAssert(_scrollView != nil, @"initWithFrame: is unsupported. Use initWithScrollView: instead.");
    
    self = ((_scrollView != nil) ? [super initWithFrame:frame] : nil);
    
    if (self != nil)
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];
        
        // Add status label.
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        
		[self addSubview:_statusLabel];
        
        // Add details label.
		_detailsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		
        [self addSubview:_detailsLabel];
		
		// Create and set up arrow layer.
		_arrowLayer = [[CALayer alloc] init];
        
		[[self layer] addSublayer:_arrowLayer];
		
        // Create and set up activity indicator.
		_activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
		[self addSubview:_activityIndicator];
        
        // Set default status and date titles.
        self.titleForNormalState = @"Pull down to refresh...";
        self.titleForPullingState = @"Release to refresh...";
        self.titleForRefreshingState = @"Loading...";
        self.titleForLastRefreshDate = @"Last Updated: ";
		
        // Set up refresh view to normal state and default style.
		self.state = VYRefreshViewStateNormal;
        self.style = VYRefreshViewStyleDefault;
    }
    
    return self;
}

- (id)initWithScrollView:(UIScrollView *)scrollView
{
    NSAssert([scrollView isKindOfClass:[UIScrollView class]], @"Scroll view must be a kind of class UIScrollView.");
    
    if (![scrollView isKindOfClass:[UIScrollView class]])
    {
        return nil;
    }
    
    _scrollView = scrollView;
    
    return [self initWithFrame:CGRectMake(0.0, 0.0 - _scrollView.bounds.size.height, _scrollView.bounds.size.width, _scrollView.bounds.size.height)];
}

#pragma mark -
#pragma mark Overridden Methods

- (void)didMoveToSuperview
{
    NSAssert(self.superview == _scrollView, @"Superview must be the same scrollview as specified during initialization.");
}

#pragma mark -
#pragma mark Private Accessors

- (void)setState:(VYRefreshViewState)state
{
	switch (state)
    {
		case VYRefreshViewStateNormal:
        {
            // Check transition from another state.
            if (_state == VYRefreshViewStatePulling)
            {
                // Animate arrow layer to normal state.
                [CATransaction begin];
                [CATransaction setAnimationDuration:kArrowAnimationDuration];
                
                _arrowLayer.transform = CATransform3DIdentity;
                
                [CATransaction commit];
            }
			
            // Update status label.
			_statusLabel.text = self.titleForNormalState;
            
            // Stop animating activity indicator.
			[_activityIndicator stopAnimating];
            
            // Set arrow layer state to normal and unhide it.
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            
            _arrowLayer.transform = CATransform3DIdentity;
			_arrowLayer.hidden = NO;
            
			[CATransaction commit];
			
			break;
        }
		case VYRefreshViewStatePulling:
        {
            // Update status label.
            _statusLabel.text = self.titleForPullingState;
            
            // Animate arrow layer to pulling state.
			[CATransaction begin];
			[CATransaction setAnimationDuration:kArrowAnimationDuration];
            
			_arrowLayer.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0, 0.0, 0.0, 1.0);
            
			[CATransaction commit];
			
			break;
        }
		case VYRefreshViewStateRefreshing:
        {
            // Update status label.
            _statusLabel.text = self.titleForRefreshingState;
            
            // Start animating activity indicator.
			[_activityIndicator startAnimating];
            
            // Hide arrow layer.
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
            
			_arrowLayer.hidden = YES;
            
			[CATransaction commit];
			
			break;
        }
		default:
			break;
	}
	
	_state = state;
}

#pragma mark -
#pragma mark Public Accessors

- (void)setStyle:(VYRefreshViewStyle)style
{
    UIColor *labelColor = nil;
    UIColor *labelShadowColor = nil;
    UIImage *arrowImage = nil;
    UIActivityIndicatorViewStyle activityIndicatorStyle = UIActivityIndicatorViewStyleWhite;
    
    switch (style)
    {
        case VYRefreshViewStyleDefault:
        case VYRefreshViewStyleBlue:
        {
            labelColor = [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0];
            labelShadowColor = [UIColor colorWithWhite:0.9 alpha:1.0];
            arrowImage = [UIImage imageNamed:@"ARROW_BLUE.png"];
            activityIndicatorStyle = UIActivityIndicatorViewStyleGray;
            
            break;
        }
        case VYRefreshViewStyleWhite:
        {
            labelColor = [UIColor whiteColor];
            labelShadowColor = [UIColor colorWithWhite:0.3 alpha:1.0];
            arrowImage = [UIImage imageNamed:@"ARROW_WHITE.png"];
            activityIndicatorStyle = UIActivityIndicatorViewStyleWhite;
            
            break;
        }
        case VYRefreshViewStyleGray:
        {
            labelColor = [UIColor darkGrayColor];
            labelShadowColor = [UIColor colorWithWhite:0.9 alpha:1.0];
            arrowImage = [UIImage imageNamed:@"ARROW_GRAY.png"];
            activityIndicatorStyle = UIActivityIndicatorViewStyleGray;
            
            break;
        }
        case VYRefreshViewStyleBlack:
        {
            labelColor = [UIColor blackColor];
            labelShadowColor = [UIColor colorWithWhite:0.9 alpha:1.0];
            arrowImage = [UIImage imageNamed:@"ARROW_BLACK.png"];
            activityIndicatorStyle = UIActivityIndicatorViewStyleGray;
            
            break;
        }
        default:
            break;
    }
    
    // Set status label properties.
    _statusLabel.frame = CGRectMake(0.0, self.bounds.size.height - kRefreshViewHeight + 10, self.bounds.size.width, 20.0);
    _statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _statusLabel.backgroundColor = [UIColor clearColor];
    _statusLabel.font = [UIFont boldSystemFontOfSize:13.0];
    _statusLabel.textColor = labelColor;
    _statusLabel.shadowColor = labelShadowColor;
    _statusLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    _statusLabel.textAlignment = UITextAlignmentCenter;
    
    // Set details label properties.
    _detailsLabel.frame = CGRectMake(0.0, self.bounds.size.height - kRefreshViewHeight + 30.0, self.bounds.size.width, 20.0);
    _detailsLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _detailsLabel.backgroundColor = [UIColor clearColor];
    _detailsLabel.font = [UIFont systemFontOfSize:12.0];
    _detailsLabel.textColor = labelColor;
    _detailsLabel.shadowColor = labelShadowColor;
    _detailsLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    _detailsLabel.textAlignment = UITextAlignmentCenter;
    
    // Set arrow layer properties.
    _arrowLayer.frame = CGRectMake(25.0, self.bounds.size.height + kRefreshViewActionTopThreshold, 30.0, kRefreshViewHeight - 10);
    _arrowLayer.contents = (id)arrowImage.CGImage;
    _arrowLayer.contentsGravity = kCAGravityResizeAspect;
    _arrowLayer.contentsScale = [UIScreen mainScreen].scale;
    
    // Set activity indicator properties.
    _activityIndicator.frame = CGRectMake(25.0, self.bounds.size.height - kRefreshViewHeight/2 - 10.0, 20.0, 20.0);
    _activityIndicator.activityIndicatorViewStyle = activityIndicatorStyle;
    
    _style = style;
}

#pragma mark -
#pragma mark Scroll View Callbacks

- (void)scrollViewDidScroll
{
	if ([self isRefreshing])
    {
		CGFloat topOffset = MAX(-_scrollView.contentOffset.y, 0);
		topOffset = MIN(topOffset, kRefreshViewHeight);
        
		_scrollView.contentInset = UIEdgeInsetsMake(topOffset, 0.0, 0.0, 0.0);
	}
    else if ([_scrollView isDragging])
    {
        if ((self.state == VYRefreshViewStatePulling) && (_scrollView.contentOffset.y > kRefreshViewActionTopThreshold) && (_scrollView.contentOffset.y < 0.0))
        {
            self.state = VYRefreshViewStateNormal;
        }
        else if ((self.state == VYRefreshViewStateNormal) && (_scrollView.contentOffset.y < kRefreshViewActionTopThreshold))
        {
            self.state = VYRefreshViewStatePulling;
        }
		
		if (_scrollView.contentInset.top != 0)
        {
			_scrollView.contentInset = UIEdgeInsetsZero;
		}
	}
}

- (void)scrollViewDidEndDragging
{
	if (![self isRefreshing] && (_scrollView.contentOffset.y <= kRefreshViewActionTopThreshold))
    {
        if (!self.hidden && [self.delegate refreshViewShouldStartRefresh:self])
        {
            [self startRefreshing];
        }
        else
        {
            self.state = VYRefreshViewStateNormal;
        }
	}
}

#pragma mark -
#pragma mark Date Management

- (void)updateLastRefreshDate
{	
	if ([self.delegate respondsToSelector:@selector(refreshViewLastRefreshDate:)])
    {
		NSDate *date = [self.delegate refreshViewLastRefreshDate:self];
        
        NSString *dateString = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
        
        _detailsLabel.text = ((dateString != nil) ? [self.titleForLastRefreshDate stringByAppendingString:dateString] : nil);
	}
    else
    {
		_detailsLabel.text = nil;
	}
}

#pragma mark -
#pragma mark Managing an Refresh View

- (void)startRefreshing
{
    [UIView animateWithDuration:kScrollViewSlideAnimationDuration animations:^(void)
    {
        _scrollView.contentInset = UIEdgeInsetsMake(kRefreshViewHeight, 0.0, 0.0, 0.0);
    }];
    
    self.state = VYRefreshViewStateRefreshing;
}

- (void)stopRefreshing
{
    [UIView animateWithDuration:kScrollViewSlideAnimationDuration animations:^(void)
    {
        _scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    }];
    
    self.state = VYRefreshViewStateNormal;
    
    [self updateLastRefreshDate];
}

- (BOOL)isRefreshing
{
    return self.state == VYRefreshViewStateRefreshing;
}

@end
