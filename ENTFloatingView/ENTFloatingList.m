//
//  ENTFloatingList.m
//  FloatingDemo
//
//  Created by apple on 4/30/18.
//  Copyright © 2018 Syed Qamar Abbas. All rights reserved.
//

#import "ENTFloatingList.h"
#import "ENTFABCell.h"
#import "ENTFABM.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ENTOrderStatusViewController.h"

@interface ENTFloatingList() <UITableViewDelegate, UITableViewDataSource>

@end

@implementation ENTFloatingList

+(ENTFloatingList *)nibInstanceAtIndex:(NSInteger)index {
    UIView *view = [[NSBundle mainBundle] loadNibNamed:@"ENTFloatingView" owner:self options:nil][index];
    ENTFloatingList *floatingView = (ENTFloatingList *)view;
    
    return floatingView;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.tableView setShowsVerticalScrollIndicator:NO];
    [self.tableView setShowsHorizontalScrollIndicator:NO];
    [self.tableView registerNib:[UINib nibWithNibName:@"ENTFABCell" bundle:nil] forCellReuseIdentifier:@"ENTFABCell"];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ENTFABCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ENTFABCell"];
    ENTFABM *order = [_datasource objectAtIndex:indexPath.row];
    cell.orderNameLabel.text = order.outlet_name;
    cell.orderStatusNameLabel.text = order.order_status;
    cell.orderStatusNameLabel.textColor = [UIColor ENTcolorFromHexString:order.status_color];
    NSURL *url = [NSURL URLWithString:order.logo_url];
    if (url != nil) {
        [cell.orderImageView sd_setImageWithURL:url];
    }
    cell.accessoryImageView.tintColor = UIColor.lightGrayColor;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ENTOrderStatusViewController *vc = [[UIStoryboard storyboardWithName:@"DeliveryCashless" bundle:nil] instantiateViewControllerWithIdentifier:@"ENTOrderStatusViewController"];
    vc.isFromFAB = YES;
    UIViewController *viewController = appdelegate.window.rootViewController;
    for (; [viewController presentedViewController] != nil ;) {
        viewController = [viewController presentedViewController];
    }
    [ENTProcessUtil.sharedInstance removeFloatingView];
    UINavigationController *navVC = [[UINavigationController alloc]initWithRootViewController:vc];
    ENTFABM *order = [_datasource objectAtIndex:indexPath.row];
    vc.index = order.order_id.longValue;
    [viewController presentViewController:navVC animated:YES completion:nil];
}

@end
