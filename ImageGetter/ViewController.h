//
//  ViewController.h
//  ImageGetter
//
//  Created by 이제민 on 13. 10. 23..
//  Copyright (c) 2013년 이제민. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <FacebookSDK/FacebookSDK.h>
#include <dispatch/dispatch.h>
#import "Reachability.h"

@interface ViewController : UIViewController<UIAlertViewDelegate>
{
    NSArray *_modifyAddress;
    
    NSMutableDictionary *_myAddress;
    NSMutableArray *_fbAddress;
    
    BOOL fbState;
    BOOL ctState;
      
    
    IBOutlet UIButton *_loginBtn;
    
    IBOutlet UIButton *_contactBtn;
    
    IBOutlet UIButton *_faceContactBtn;
    
    IBOutlet UIButton *_imageMergeBtn;
    
    UIBackgroundTaskIdentifier taskId;
    
    UIView *_dimmedView;
    UIActivityIndicatorView *_indicator;
    
    UIView *_popViewer;
}

@end
