//
//  ENTFABDismissView.m
//  FloatingDemo
//
//  Created by apple on 5/1/18.
//  Copyright © 2018 Syed Qamar Abbas. All rights reserved.
//

#import "ENTFABDismissView.h"

@implementation ENTFABDismissView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self addCrossImageViewToParentView];
    [self addCrossImageContainerViewToParentView];
}
-(void)addCrossImageViewToParentView {
    if (self.crossImageView == nil) {
        self.crossImageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width/2 - 15, 25, 30, 30)];
        self.crossImageView.image = [UIImage imageNamed:@"cross-Icon"];
        [self addSubview:_crossImageView];
    }
}
-(void)addCrossImageContainerViewToParentView {
    if (self.crossImageContainerView == nil) {
        self.crossImageContainerView = [[UIView alloc]initWithFrame:CGRectMake(self.frame.size.width/2 - 40, 0, 80, 80)];
        self.crossImageContainerView.layer.cornerRadius = 40;
        self.crossImageContainerView.layer.borderColor = UIColor.whiteColor.CGColor;
        self.crossImageContainerView.layer.borderWidth = 1;
        self.crossImageContainerView.clipsToBounds = YES;
        [self addSubview:_crossImageContainerView];
    }
}


@end
