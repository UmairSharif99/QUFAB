//
//  ENTFABCell.h
//  FloatingDemo
//
//  Created by apple on 4/30/18.
//  Copyright © 2018 Syed Qamar Abbas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ENTFABCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *orderImageView;
@property (weak, nonatomic) IBOutlet UILabel *orderNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderStatusNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *accessoryImageView;

@end
