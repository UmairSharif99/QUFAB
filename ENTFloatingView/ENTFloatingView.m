//
//  ENTFloatingView.m
//  The Entertainer
//
//  Created by Syed Qamar Abbas on 4/30/18.
//  Copyright © 2018 Future Workshops. All rights reserved.
//

#import "ENTFloatingView.h"
#import "ENTFloatingList.h"
#import "ENTFABDismissView.h"
#import "ENTProcessUtil.h"
#import "ENTOutletDetailViewController.h"
@interface ENTFloatingView()<AutolayoutViewDelegate>
{
    BOOL isEnteredInExitRegion;
    AutolayoutView *overlayView;
    BOOL isMoved;
    BOOL isReadyToMove;
    CGFloat halfWidth;
    ENTFABDismissView *endView;
    NSTimeInterval previousTimeInterval;
    NSArray *pendingOrders;
}

@property (nonatomic) ENTFloatingList *floatingListView;
@property (nonatomic) ConstraintType horizontalSide;
@property (nonatomic) ConstraintType verticalSide;
@property (weak, nonatomic) IBOutlet UIImageView *floatingIcon;
@property (weak, nonatomic) IBOutlet UIView *viewCrossButton;

@end
@implementation ENTFloatingView

+(ENTFloatingView *)addFloatingButtonToView:(UIView *)parentView supposedCenterPoints:(CGPoint)centerPoint {
    ENTFloatingView *floatingView = [ENTFloatingView nibInstanceAtIndex:0];
    [parentView addSubview:floatingView];
    [floatingView addGestureToParentView:parentView];
    [UIView performWithoutAnimation:^{
        [floatingView setNewCenterPoints:centerPoint];
    }];
    [floatingView becomeFirstResponder];
    [floatingView changeTintColor];
    return floatingView;
}

-(void)changeTintColor {
    UIColor *tintColot = [UIColor colorWithRed:0.99 green:0.99 blue:0.99 alpha:1.0];
    self.floatingIcon.tintColor = tintColot;
}
-(BOOL)canBecomeFirstResponder {
    return YES;
}
-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        [self shouldEnableCrossButton:!self.viewCrossButton.isHidden];
    }
}

-(void)shouldEnableCrossButton:(BOOL)shouldEnable {
    self.viewCrossButton.hidden = shouldEnable;
}

-(void)setDatasource:(NSArray *)datasource {
    if (datasource != nil) {
        self.badgeCount = datasource.count;
    }
    pendingOrders = datasource;
    [self setFloatingImage];
}
-(NSArray *)datasource {
    return pendingOrders;
}
-(void)setBadgeCount:(NSInteger)badgeCount
{
    [self setFloatingImage];
    self.viewBadge.hidden = badgeCount == 0;
    self.lblBadge.text = [NSString stringWithFormat:@"%ld", badgeCount];
}

-(void)addEndArea {
    if (endView == nil && self.shouldRemoveable) {
        endView = [[ENTFABDismissView alloc]init];
        endView.alpha = 0;
        [UIView performWithoutAnimation:^{
            [self.superview insertSubview:self->endView belowSubview:self];
            self->endView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.1];
            NSArray <NSNumber *>*types = @[@(top),@(left),@(height),@(width)];
            NSArray <NSNumber *>*values = @[@(0),@(0),@(80),@(self.superview.frame.size.width)];
            self->endView.allConstraints = [Autolayout addConstrainsToRefView:self.superview andChildView:self->endView withConstraintTypeArray:types andValues:values];
        }];
    }
}
-(void)showArea {
    if (endView != nil && self.shouldRemoveable) {
        [UIView animateWithDuration:0.3 animations:^{
            self->endView.alpha = 1;
            [self->endView changeConstraintValue:-80 ofType:top];
        }];
    }
}

-(void)hideEndAreaShouldRemove:(BOOL)shouldRemove {
    if (endView != nil && self.shouldRemoveable) {
        [UIView animateWithDuration:0.3 animations:^{
            self->endView.alpha = 0;
            [self->endView changeConstraintValue:0 ofType:top];
        } completion:^(BOOL finished) {
            if (shouldRemove) {
                [self->endView removeFromSuperview];
                self->endView = nil;
            }
        }];
    }
}
-(void)addGestureToParentView:(UIView *)parentView {
    
    halfWidth = self.frame.size.width/2;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapGestureCalled:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.cancelsTouchesInView = YES;
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(didTapLongGesture:)];
    longGesture.minimumPressDuration = 0.1;
    longGesture.cancelsTouchesInView = NO;
    
    for (UIGestureRecognizer *prevGesture in parentView.gestureRecognizers) {
        if ([prevGesture isKindOfClass:[UITapGestureRecognizer class]]) {
            [parentView removeGestureRecognizer:prevGesture];
        }
        if ([prevGesture isKindOfClass:[UILongPressGestureRecognizer class]]) {
            [parentView removeGestureRecognizer:prevGesture];
        }
    }
    [self addGestureRecognizer:longGesture];
    [self addGestureRecognizer:tapGesture];
}
-(void)didTapLongGesture:(UILongPressGestureRecognizer *)gesture {
    if (self.floatingListView == nil) {
        CGPoint newPoint = [gesture locationInView:self.superview];
        [self startMovingWithPoint:newPoint];
        isReadyToMove = YES;
    }
}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (isReadyToMove) {
        isMoved = YES;
        if (self.floatingListView == nil) {
            UITouch *touch = touches.allObjects.firstObject;
            CGPoint newPoint = [touch locationInView:self.superview];
            [self startMovingWithPoint:newPoint];
        }
    }
}
-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self animateButtonToRestPosition:touches];
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self animateButtonToRestPosition:touches];
}
-(void)startMovingWithPoint:(CGPoint)newPoint {
    [self addEndArea];
    if (_shouldRemoveable) {
        BOOL shouldReturn = [self checkAndManipulateEndArea:newPoint];
        if (shouldReturn) {
            return;
        }
    }else {
        isEnteredInExitRegion = NO;
    }
    if (self.alpha == 1.0) {
        [self impactGenerator];
    }
    [UIView animateWithDuration:0.1 animations:^{
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.75, 0.75);
        self.alpha = 0.5;
        [self setCenter:newPoint];
    }];
}
-(BOOL)checkAndManipulateEndArea:(CGPoint)newPoint {
    if (newPoint.y > (self.superview.frame.size.height - 80)) {
        isEnteredInExitRegion = YES;
        CGPoint point = CGPointMake(self.superview.frame.size.width/2, self.superview.frame.size.height - 40);
        [UIView animateWithDuration:0.4 animations:^{
            self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.75, 0.75);
            self.alpha = 0.5;
            [self setCenter:point];
        }];
        [self showArea];
        return YES;
    }else {
        isEnteredInExitRegion = NO;
        [self hideEndAreaShouldRemove:NO];
        return NO;
    }
}
-(void)impactGenerator {
    UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc]initWithStyle:(UIImpactFeedbackStyleMedium)];
    [gen impactOccurred];
}

-(void)animateButtonToRestPosition:(NSSet<UITouch *> *)touches {
    if (!isReadyToMove) {
        return;
    }
    if (_shouldRemoveable) {
        if (isEnteredInExitRegion) {
            //Remove Everything;
        }else {
            [self hideEndAreaShouldRemove:YES];
        }
    }
    isMoved = NO;
    isReadyToMove = NO;
    if (self.floatingListView == nil) {
        UITouch *touch = touches.allObjects.firstObject;
        CGPoint newPoint = [touch locationInView:self.superview];
        [self setNewCenterPoints:newPoint];
    }
}
-(void)setNewCenterPoints:(CGPoint)point {
    if (self.alpha == 0.5) {
        [self impactGenerator];
    }
    CGPoint newPoint = point;
    if (newPoint.x < (self.superview.frame.size.width/2)) {
        //Should be on left side
        self.horizontalSide = left;
        newPoint = CGPointMake(40, newPoint.y);
    }else {
        self.horizontalSide = right;
        newPoint = CGPointMake(self.superview.frame.size.width - halfWidth, newPoint.y);
    }
    
    if (newPoint.y < (self.superview.frame.size.height/2)) {
        self.verticalSide = top;
    } else {
        self.verticalSide = bottom;
    }
    
    if (newPoint.y >= (self.superview.frame.size.height - halfWidth)) {
        newPoint = CGPointMake(newPoint.x, self.superview.frame.size.height - (halfWidth + 10));
    }else if (newPoint.y <= halfWidth) {
        newPoint = CGPointMake(newPoint.x, (halfWidth + 10));
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
        self.alpha = 1.0;
        [self setCenter:newPoint];
    }];
}
-(void)didChangeGestureValues:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        CGPoint newPoint = [gesture locationInView:self.superview];
        [self setNewCenterPoints:newPoint];
    }
    else {
        CGPoint newPoint = [gesture locationInView:self.superview];
        [UIView animateWithDuration:0.1 animations:^{
            self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.75, 0.75);
            [self setCenter:newPoint];
        }];
    }
}

- (void)didTapGestureCalled:(UITapGestureRecognizer *)gesture {
    if (self.isBasketSelected) {
        [self openOutletDetailVC];
    }else {
        NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
        if (currentTime - previousTimeInterval <= 0.3) {
            return;
        }
        if (self.floatingListView == nil && !isReadyToMove) {
            [UIView performWithoutAnimation:^{
                [self addFloatingList];
            }];
        }else {
            [self removeFloatingList];
        }
        previousTimeInterval = currentTime;
    }
}
-(void)didTouchThisView:(AutolayoutView *)layoutView {
    [self removeFloatingList];
}
- (void)addFloatingList {
    
    overlayView = [[AutolayoutView alloc] init];
    [self.superview insertSubview:overlayView belowSubview:self];
    overlayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    overlayView.delegate = self;
    NSArray <NSNumber *>*oTypes = @[@(top), @(left), @(width), @(height)];
    
    NSArray <NSNumber *>*oValues = @[@(-self.superview.frame.size.height), @(0), @(self.superview.frame.size.width), @(self.superview.frame.size.height)];
    
    overlayView.allConstraints = [Autolayout addConstrainsToRefView:self.superview andChildView:overlayView withConstraintTypeArray:oTypes andValues:oValues];
    
    self.floatingIcon.image = [UIImage imageNamed:@"mystatus_cross"];
    
    self.floatingListView = [ENTFloatingList nibInstanceAtIndex:1];
    self.floatingListView.datasource = pendingOrders;
    
    [self.superview addSubview:self.floatingListView];
    NSArray <NSNumber *>*types = @[@(self.horizontalSide), @(self.verticalSide), @(width), @(height)];
    
    NSArray <NSNumber *>*values = @[@(10), @(5), @(200), @(0)];
    
    self.floatingListView.allConstraints = [Autolayout addConstrainsToRefView:self andChildView:self.floatingListView withConstraintTypeArray:types andValues:values];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
            if (self.floatingListView != nil) {
                [self.floatingListView changeConstraintValue:180 ofType:height];
            }
        } completion:nil];
    });
}
-(void)removeFloatingListWithoutAnimation {
    if (self.floatingListView != nil) {
        [self.floatingListView removeFromSuperview];
        self.floatingListView = nil;
    }
    if (overlayView != nil) {
        [self->overlayView removeFromSuperview];
        self->overlayView = nil;
    }
}
-(void)setFloatingImage {
    if (self.isBasketSelected) {
        self.floatingIcon.image = [UIImage imageNamed:@"basket"];
    }else {
        self.floatingIcon.image = [UIImage imageNamed:@"deliveryImage"];
    }
}
-(void)removeFloatingList {
    [self setFloatingImage];
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.floatingListView changeConstraintValue:0 ofType:height];
    } completion:^(BOOL finished) {
        [self.floatingListView removeFromSuperview];
        self.floatingListView = nil;
        [self->overlayView removeFromSuperview];
        self->overlayView = nil;
    }];
}
- (IBAction)didTapRemoveButton:(id)sender {
    [ENTProcessUtil.sharedInstance removeFloatingView];
}

-(void)openOutletDetailVC {
    ENTOutletDetailViewController *vc = (ENTOutletDetailViewController *)[ENTOutletDetailViewController storyboardReferenceWithClassName:@"ENTOutletDetailViewController"];
    vc.opener = floating;
    UIViewController *viewController = appdelegate.window.rootViewController;
    for (; [viewController presentedViewController] != nil ;) {
        viewController = [viewController presentedViewController];
    }
    if ([viewController isKindOfClass:[UITabBarController class]]) {
        viewController = ((UITabBarController *)viewController).selectedViewController;
    }
    [ENTProcessUtil.sharedInstance removeFloatingView];
    [(UINavigationController *)viewController pushViewController:vc animated:YES];
}

+(ENTFloatingView *)nibInstanceAtIndex:(NSInteger)index {
    UIView *view = [[NSBundle mainBundle] loadNibNamed:@"ENTFloatingView" owner:self options:nil][index];
    ENTFloatingView *floatingView = (ENTFloatingView *)view;
    return floatingView;
}
@end
