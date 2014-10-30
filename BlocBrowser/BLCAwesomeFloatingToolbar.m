//
//  BLCAwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Collin Adler on 10/29/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import "BLCAwesomeFloatingToolbar.h"

@interface BLCAwesomeFloatingToolbar ()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, weak) UILabel *currentLabel;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longGesture;

@end

@implementation BLCAwesomeFloatingToolbar

- (instancetype) initWithFourTitles:(NSArray *)titles {
    //first, call the superclass (UIView)'s initializer, to make sure we do all that setup first
    self = [super init];
    
    if (self) {
        
        //set the NSArray given in the argument to the class property. Then, set the 4 colors using the class property
        self.currentTitles = titles;
        //Put actions here
        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                        [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
        
        NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];
        
        //make the 4 buttons
        for (NSString *currentTitle in self.currentTitles) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.userInteractionEnabled = NO; //a property that indicates whether a UIView (or UIView subclass) receives touch events
            button.alpha = 0.25; //represents a view's opacity between 0 (transparent) and 1 (opaque)
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle]; // 0 through 3
            NSString *titleForThisButton = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor *colorForThisButton = [self.colors objectAtIndex:currentTitleIndex];
            
            button.titleLabel.font = [UIFont systemFontOfSize:10];
            [button setTitle:titleForThisButton forState:normal];
            [button setBackgroundColor:colorForThisButton];
            button.tintColor = [UIColor whiteColor];
            [button addTarget:self action:@selector(tapFired:) forControlEvents:UIControlEventTouchUpInside];
            
            [buttonsArray addObject:button];
        }
        
        //We've created our full NSMutableArray of buttons, so add this to the self.labels NSArray
        self.buttons = buttonsArray;
        
        for (UIButton *thisButton in self.buttons) {
            [self addSubview:thisButton];
        }
    }
    return self;
}

- (void) tapFired:(UIButton *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
            [self.delegate floatingToolbar:self didSelectButtonWithTitle:sender.currentTitle];
        }
    }
}

//- (void) panFired:(UIButton *)sender {
//    if (recognizer.state == UIGestureRecognizerStateRecognized) {
//
//        //A pan gesture recognizer's translation is how far the user's finger has moved in each direction since the touch event began.
//        CGPoint translation = [recognizer translationInView:self];
//        NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
//
//        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
//            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
//        }
//        //At the end, we reset this translation to zero (CGPointZero) such that we are able to get the difference of each mini-pan every time the method is called.
//        [recognizer setTranslation:CGPointZero inView:self];
//    }
//}
//
//- (void) pinchFired:(UIButton *)sender {
//    if (recognizer.state == UIGestureRecognizerStateRecognized) {
//
//        CGFloat pinchScale = recognizer.scale;
//
//        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPinchWithScale:)]) {
//            [self.delegate floatingToolbar:self didTryToPinchWithScale:pinchScale];
//        }
//    }
//}
//
//- (void) pressFired:(UIButton *)sender {
//    if (recognizer.state == UIGestureRecognizerStateRecognized) {
//
//        for (UILabel *buttonLabel in self.labels) {
//            UIColor *currentColor = buttonLabel.backgroundColor;
//        }
//    }
//}

- (void) layoutSubviews { //will get called anytime our view's frame is changed
    //sets the frames for the 4 labels
    
    for (UILabel *thisButton in self.buttons) {
        NSUInteger currentButtonIndex = [self.buttons indexOfObject:thisButton];
        
        CGFloat ButtonHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat ButtonWidth = CGRectGetWidth(self.bounds) / 2;
        CGFloat ButtonX = 0;
        CGFloat ButtonY = 0;
        
        // adjust labelX and labelY for each label
        if (currentButtonIndex < 2) {
            // 0 or 1, so on top
            ButtonY = 0;
        } else {
            // 2 or 3, so on bottom
            ButtonY = CGRectGetHeight(self.bounds) / 2;
        }
        
        if (currentButtonIndex % 2 == 0) { //is currentLabelIndex evenly divisible by 2?
            //0 or 2, so on left
            ButtonX = 0;
        } else {
            // 1 or 3, so on right
            ButtonX = CGRectGetWidth(self.bounds) / 2;
        }
        
        thisButton.frame = CGRectMake(ButtonX, ButtonY, ButtonWidth, ButtonHeight);
    }
}

#pragma  mark - Touch Handling
//UILabels don't respond to touches. So, the touch event will get passed to our toolbar object. Since we want to respond to the touch event, we'll implement methods

//To avoid repeating code in all touch-handling methods below, this method figures out which label was touched
- (UILabel *) labelFromTouches:(NSSet *)touches withEvent:(UIEvent *)event { //UIEvent represents a touch event
    UITouch *touch = [touches anyObject]; //UITouch represents one finger currently touching the screen
    CGPoint location = [touch locationInView:self];
    UIView *subview = [self hitTest:location withEvent:event];
    return (UILabel *)subview;
}

#pragma mark - Button Enabling

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
        UILabel *label = [self.buttons objectAtIndex:index];
        label.userInteractionEnabled = enabled;
        label.alpha = enabled ? 1.0 : 0.25;
    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
