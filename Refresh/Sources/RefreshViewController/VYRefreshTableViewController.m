//
//  VYRefreshTableViewController.m
//  Refresh
//
//  Created by Vitaly Yurchenko on 20.02.12.
//  Copyright (c) 2012 Vitaly Yurchenko. All rights reserved.
//
// ********************************************************************************************************************************************************** //

#import "VYRefreshTableViewController.h"

// ********************************************************************************************************************************************************** //

@implementation VYRefreshTableViewController
{
    VYRefreshView *_refreshView;
}

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (_refreshView == nil)
    {
        _refreshView = [[VYRefreshView alloc] initWithScrollView:self.tableView];
        _refreshView.delegate = self;
        
        [self.tableView addSubview:_refreshView];
        
        [_refreshView updateLastRefreshDate];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    _refreshView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark -
#pragma mark <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Section #%i", section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"Row %i", indexPath.row];
    
    return cell;
}

#pragma mark -
#pragma mark <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshView scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshView scrollViewDidEndDragging];
}

#pragma mark -
#pragma mark <VYRefreshViewDelegate>

- (BOOL)refreshViewShouldStartRefresh:(VYRefreshView *)view
{
	[self tableViewDataSourceRefreshDidStart];
    
    return YES;
}

- (NSDate *)refreshViewLastRefreshDate:(VYRefreshView *)view
{
	return [NSDate date];
}

#pragma mark -
#pragma mark Table View Data Source Methods

- (void)tableViewDataSourceRefreshDidStart
{
	double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
    {
        [self tableViewDataSourceRefreshDidFinish];
    });
}

- (void)tableViewDataSourceRefreshDidFinish
{
	[_refreshView stopRefreshing];
}

@end
