//
//  BLCWebBrowserViewController.m
//  BlocBrowser
//
//  Created by Collin Adler on 10/28/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import "BLCWebBrowserViewController.h"

@interface BLCWebBrowserViewController () <UIWebViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *forwardButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *refreshButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, assign) NSUInteger frameCount;

@end

@implementation BLCWebBrowserViewController

#pragma mark - UIViewController

- (void)loadView {
    
    //create the main container view
    UIView *mainView = [[UIView alloc] init];
    self.view = mainView;

    //create the subviews (also use our view controller as the delegate for the UIWebView)
    self.webview = [[UIWebView alloc] init];
    self.webview.delegate = self;

    self.textField = [[UITextField alloc] init];
    self.textField.keyboardType = UIKeyboardTypeURL;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.placeholder = @"Type Website URL or Google Search";
    self.textField.backgroundColor = [UIColor colorWithWhite:220/255.0f alpha:1];
    self.textField.delegate = self;
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backButton setEnabled:NO];

    self.forwardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.forwardButton setEnabled:NO];

    self.stopButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.stopButton setEnabled:NO];

    self.refreshButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.refreshButton setEnabled:NO];

    //set targets and actions
    [self.backButton setTitle:@"Back"
                     forState:UIControlStateNormal];
    
    [self.forwardButton setTitle:@"Forward"
                     forState:UIControlStateNormal];
    
    [self.stopButton setTitle:@"Stop"
                     forState:UIControlStateNormal];
    
    [self.refreshButton setTitle:@"Refresh"
                        forState:UIControlStateNormal];

    [self addButtonTargets];
    
    //add the subviews to the main view
    for (UIView *viewToAdd in @[self.webview, self.textField, self.backButton, self.forwardButton, self.stopButton, self.refreshButton]) {
        [mainView addSubview:viewToAdd];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone; //Some apps scroll their content up under the navigation bar and behind the status bar. Setting edgesForExtendedLayout to UIRectEdgeNone opts out of this behavior.
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    
    //Dispaly a welcome message
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Welcome!" message:@"Get excited to use the best web browser ever!" delegate:nil cancelButtonTitle:@"OK, I'm excited!" otherButtonTitles:nil];
    
    [alert show];
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    //first, calculate some dimensions
    static const CGFloat itemHeight = 50; //`static` keeps the value the same between invocations of the method. `const` tells the compiler that this value won't change, allowing for additional speed optimizations
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight - itemHeight;
    CGFloat buttonWidth = CGRectGetWidth(self.view.bounds) / 4;
    
    //now, assign the frames
    self.textField.frame = CGRectMake(0, 0, width, itemHeight);
    self.webview.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
    
    CGFloat currentButtonX = 0;
    
    for (UIButton *thisButton in @[self.backButton, self.forwardButton, self.stopButton, self.refreshButton]) {
        thisButton.frame = CGRectMake(currentButtonX, CGRectGetMaxY(self.webview.frame), buttonWidth, itemHeight);
        currentButtonX += buttonWidth;
    }
}

- (void) resetWebView {
    [self.webview removeFromSuperview];
    
    UIWebView *newWebView = [[UIWebView alloc] init];
    newWebView.delegate = self;
    [self.view addSubview:newWebView];
    
    self.webview = newWebView;
    
    [self addButtonTargets];
    
    self.textField.text = nil;
    [self updateButtonsAndTitle];
}

//We need this method because the buttons will point to the old web view. If we don't tell them when we switch the web view, they will try to communicate with a web view that no longer exists, and cause a crash.
- (void) addButtonTargets {
    //loop through all four of our buttons and remove the reference to the old web view
    for (UIButton *button in @[self.backButton, self.forwardButton, self.stopButton, self.refreshButton]) {
        [button removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.backButton addTarget:self.webview action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.forwardButton addTarget:self.webview action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
    [self.stopButton addTarget:self.webview action:@selector(stopLoading) forControlEvents:UIControlEventTouchUpInside];
    [self.refreshButton addTarget:self.webview action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    NSString *URLString = textField.text;
    NSRange spaceRange = [URLString rangeOfString:@" "];
    
    if (spaceRange.length == 0) {
        //There is no space, so this is a normal URL
        NSURL *URL = [NSURL URLWithString:URLString];
        if (!URL.scheme ) {
            URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", URLString]];
        }
        
        if (URL) {
            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
            [self.webview loadRequest:request];
        }
    } else {
        //There is a space, so perform a search
        NSString *plusString = [URLString stringByReplacingOccurrencesOfString:@" "
                                                                            withString:@"+"];
        
        NSString *searchString = [NSString stringWithFormat:@"https://www.google.com/search?q=%@", plusString];
        NSURL *URL = [NSURL URLWithString:searchString];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [self.webview loadRequest:request];
    }
    
    return NO;
}

#pragma mark - UIWebViewDelegate


//We need to call this method whenever a page starts or stops loading. We'll use the the UIWebViewDelegate methods webViewDidStartLoad, and webViewDidFinishLoad: to do this:

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.frameCount++;
    [self updateButtonsAndTitle];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.frameCount--;
    [self updateButtonsAndTitle];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (error.code != -999) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
    [self updateButtonsAndTitle];
    self.frameCount--;
}

- (void) updateButtonsAndTitle {
    NSString *webpageTitle = [self.webview stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    if (webpageTitle) {
        self.title = webpageTitle;
    } else {
        self.title = self.webview.request.URL.absoluteString;
    }
    
    if (self.frameCount) {
        [self.activityIndicator startAnimating];
    } else {
        [self.activityIndicator stopAnimating];
    }
    
    self.backButton.enabled = [self.webview canGoBack];
    self.forwardButton.enabled = [self.webview canGoForward];
    self.stopButton.enabled = self.frameCount > 0;
    self.refreshButton.enabled = self.webview.request.URL && self.frameCount == 0;
}

@end
