//
//  Autolayout.h
//  FloatingDemo
//
//  Created by Syed Qamar Abbas on 4/30/18.
//  Copyright © 2018 Syed Qamar Abbas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, ConstraintType)  {
    top = 0,
    bottom = 1,
    left = 2,
    right = 3,
    height = 4,
    width = 5,
};
@class AutolayoutView;
@protocol AutolayoutViewDelegate <NSObject>
-(void)didTouchThisView:(AutolayoutView *)layoutView;
@end
@interface Autolayout : NSObject
@property (nonatomic) ConstraintType type;
@property (nonatomic) CGFloat value;
@property (strong, nonatomic) UIView *childView;
@property (strong, nonatomic) UIView *parentView;
-(void)changeConstraintValue:(CGFloat)newValue;

+(NSMutableArray <Autolayout *> *)addConstrainsToParentView:(UIView *)parentView andChildView:(UIView *)childView withConstraintTypeArray:(NSArray <NSNumber *>*)types andValues:(NSArray <NSNumber *>*)values;
+(NSMutableArray <Autolayout *> *)addConstrainsToRefView:(UIView *)parentView andChildView:(UIView *)childView withConstraintTypeArray:(NSArray <NSNumber *>*)types andValues:(NSArray <NSNumber *>*)values;

@end
@interface AutolayoutView: UIView
@property (weak, nonatomic) id<AutolayoutViewDelegate> delegate;
@property (nonatomic, strong)NSMutableArray <Autolayout *> *allConstraints;
-(Autolayout *_Nullable)getConstraintWithType:(ConstraintType)type;
-(void)changeConstraintValue:(CGFloat)value ofType:(ConstraintType)type;
@end
