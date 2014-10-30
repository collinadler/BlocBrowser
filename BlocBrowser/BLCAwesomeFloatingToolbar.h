//
//  BLCAwesomeFloatingToolbar.h
//  BlocBrowser
//
//  Created by Collin Adler on 10/29/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

//We're about to declare a delegate protocol, which references BLCAwesomeFloatingToolbar. However, BLCAwesomeFloatingToolbar hasn't been defined yet, so we need the `@class`
@class BLCAwesomeFloatingToolbar;

//implements a delegate protocol method, so classes can optionally be informed when one of the titles is pressed. The <NSObject> at the end indicates that this protocol inherits from the NSObject protocol.
@protocol BLCAwesomeFloatingToolbarDelegate <NSObject>

@optional

//One optional delegate method is declared. If the delegate implements it, it will be called when a user taps a button
- (void) floatingToolbar:(BLCAwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title;

@end

@interface BLCAwesomeFloatingToolbar : UIView

//Communicates that the class should be initialized with four titles using the custom initializer, initWithFourTitles:.
- (instancetype) initWithFourTitles:(NSArray *)titles;

//allows other classes to enable and disable its buttons.
- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title;

//if a delegate is desired, this property defines it
@property (nonatomic, weak) id <BLCAwesomeFloatingToolbarDelegate> delegate;

@end
