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

static CGFloat const kArrowAnimationDuration = 0.15;

// ********************************************************************************************************************************************************** //

@interface VYRefreshView ()

@property (nonatomic, readwrite) VYRefreshViewState state;

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
@synthesize delegate = _delegate;

#pragma mark -
#pragma mark Object Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self != nil)
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];
        
        // Create and setup status label.
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, frame.size.height - kRefreshViewHeight + 10, frame.size.width, 20.0)];
		_statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _statusLabel.backgroundColor = [UIColor clearColor];
        _statusLabel.font = [UIFont boldSystemFontOfSize:13.0];
		_statusLabel.textColor = [UIColor darkGrayColor];
        _statusLabel.shadowColor = [UIColor colorWithWhite:0.9 alpha:1.0];
		_statusLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        _statusLabel.textAlignment = UITextAlignmentCenter;
        
		[self addSubview:_statusLabel];
        
        // Create and set up details label.
		_detailsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, frame.size.height - kRefreshViewHeight + 30.0, frame.size.width, 20.0)];
		_detailsLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _detailsLabel.backgroundColor = [UIColor clearColor];
		_detailsLabel.font = [UIFont systemFontOfSize:12.0];
		_detailsLabel.textColor = [UIColor darkGrayColor];
		_detailsLabel.shadowColor = [UIColor colorWithWhite:0.9 alpha:1.0];
		_detailsLabel.shadowOffset = CGSizeMake(0.0, 1.0);
		_detailsLabel.textAlignment = UITextAlignmentCenter;
		
        [self addSubview:_detailsLabel];
		
		// Create and set up arrow layer.
		_arrowLayer = [CALayer layer];
		_arrowLayer.frame = CGRectMake(25.0, frame.size.height + kRefreshViewActionTopThreshold, 30.0, kRefreshViewHeight - 10);
		_arrowLayer.contents = (id)[UIImage imageNamed:@"ARROW_GRAY.png"].CGImage;
        _arrowLayer.contentsGravity = kCAGravityResizeAspect;
        _arrowLayer.contentsScale = [UIScreen mainScreen].scale;
        
		[[self layer] addSublayer:_arrowLayer];
		
        // Create and set up activity indicator.
		_activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		_activityIndicator.frame = CGRectMake(25.0, frame.size.height - kRefreshViewHeight/2 - 10.0, 20.0, 20.0);
        
		[self addSubview:_activityIndicator];
		
        // Set to refresh view to normal state.
		self.state = VYRefreshViewStateNormal;
    }
    
    return self;
}

- (id)initWithScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    
    return [self initWithFrame:CGRectMake(0.0, 0.0 - scrollView.bounds.size.height, scrollView.bounds.size.width, scrollView.bounds.size.height)];
}

#pragma mark -
#pragma mark Private Accessors

- (void)setState:(VYRefreshViewState)state
{
	switch (state)
    {
		case VYRefreshViewStateNormal:
        {
            if (_state == VYRefreshViewStatePulling)
            {
                // Animate arrow layer to normal state.
				[CATransaction begin];
				[CATransaction setAnimationDuration:kArrowAnimationDuration];
                
				_arrowLayer.transform = CATransform3DIdentity;
                
				[CATransaction commit];
			}
			
            // Update status label.
			_statusLabel.text = NSLocalizedString(@"Pull down to refresh...", @"");
            
            // Stop animating activity indicator.
			[_activityIndicator stopAnimating];
            
            // Set arrow layer state to normal and unhide it.
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            
            _arrowLayer.transform = CATransform3DIdentity;
			_arrowLayer.hidden = NO;
            
			[CATransaction commit];
			
			[self updateLastRefreshDate];
			
			break;
        }
		case VYRefreshViewStatePulling:
        {
            // Update status label.
            _statusLabel.text = NSLocalizedString(@"Release to refresh...", @"");
            
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
            _statusLabel.text = NSLocalizedString(@"Loading...", @"");
            
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
        if ([self.delegate refreshViewShouldStartRefresh:self])
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
#pragma mark Public Methods

- (void)updateLastRefreshDate
{	
	if ([self.delegate respondsToSelector:@selector(refreshViewLastRefreshDate:)])
    {
		NSDate *date = [self.delegate refreshViewLastRefreshDate:self];
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setAMSymbol:@"AM"];
		[formatter setPMSymbol:@"PM"];
		[formatter setDateFormat:@"MM/dd/yyyy hh:mm:a"];
        
		_detailsLabel.text = [NSString stringWithFormat:@"Last Updated: %@", [formatter stringFromDate:date]];
		[[NSUserDefaults standardUserDefaults] setObject:_detailsLabel.text forKey:@"VYRefreshViewLastRefresh"];
		[[NSUserDefaults standardUserDefaults] synchronize];
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
    [UIView animateWithDuration:0.3 animations:^(void)
    {
        _scrollView.contentInset = UIEdgeInsetsMake(kRefreshViewHeight, 0.0, 0.0, 0.0);
    }];
    
    self.state = VYRefreshViewStateRefreshing;
}

- (void)stopRefreshing
{
    [UIView animateWithDuration:0.3 animations:^(void)
    {
        _scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    }];
    
    self.state = VYRefreshViewStateNormal;
}

- (BOOL)isRefreshing
{
    return self.state == VYRefreshViewStateRefreshing;
}

@end
