//
//  ENTFloatingList.h
//  FloatingDemo
//
//  Created by apple on 4/30/18.
//  Copyright © 2018 Syed Qamar Abbas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Autolayout.h"

@interface ENTFloatingList : AutolayoutView 

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *datasource;

+(ENTFloatingList *)nibInstanceAtIndex:(NSInteger)index;

@end
