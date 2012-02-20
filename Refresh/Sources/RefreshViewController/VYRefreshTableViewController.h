//
//  VYRefreshTableViewController.h
//  Refresh
//
//  Created by Vitaly Yurchenko on 20.02.12.
//  Copyright (c) 2012 Vitaly Yurchenko. All rights reserved.
//
// ********************************************************************************************************************************************************** //

#import <UIKit/UIKit.h>

#import "VYRefreshView.h"

// ********************************************************************************************************************************************************** //

@interface VYRefreshTableViewController : UITableViewController <VYRefreshViewDelegate>

- (void)tableViewDataSourceRefreshDidStart;
- (void)tableViewDataSourceRefreshDidFinish;

@end
