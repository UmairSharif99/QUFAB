//
//  ENTFloatingView.h
//  The Entertainer
//
//  Created by Syed Qamar Abbas on 4/30/18.
//  Copyright © 2018 Future Workshops. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Autolayout.h"


@interface ENTFloatingView : AutolayoutView

@property (nonatomic) NSInteger badgeCount;
@property (weak, nonatomic) IBOutlet UILabel *lblBadge;
@property (weak, nonatomic) IBOutlet UIView *viewBadge;

@property BOOL shouldRemoveable;
@property BOOL isBasketSelected;
@property (nonatomic) NSArray *datasource;

-(void)removeFloatingListWithoutAnimation;
-(void)addGestureToParentView:(UIView *)parentView;
-(void)shouldEnableCrossButton:(BOOL)shouldEnable;
+(ENTFloatingView *)addFloatingButtonToView:(UIView *)parentView supposedCenterPoints:(CGPoint)centerPoint;
@end
