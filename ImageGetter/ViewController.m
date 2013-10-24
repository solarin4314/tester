//
//  ViewController.m
//  ios7Tester
//
//  Created by 이제민 on 13. 10. 22..
//  Copyright (c) 2013년 이제민. All rights reserved.
//

#import "ViewController.h"

double convertHexToDecimal (NSString *hex)
{
    NSScanner *scanner=[NSScanner scannerWithString:hex];
    unsigned int decimal;
    [scanner scanHexInt:&decimal];
    return decimal / 255.0f;
}
UIColor* convertHexToDecimalRGBA (NSString *r, NSString *g, NSString *b, float a)
{
    return [UIColor colorWithRed:convertHexToDecimal(r) green:convertHexToDecimal(g) blue:convertHexToDecimal(b) alpha:a];
}

@interface ViewController ()

@end

@implementation ViewController



typedef enum {
    BTN_TAG_LOGIN,
    BTN_TAG_POST,
    BTN_TAG_FRIEND,
}BTN_TAG;

-(void)viewWillAppear:(BOOL)animated
{
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded)
    {
        [self openSession];
    }
}
-(void)openSession
{
    NSLog(@"openSession invoked");
    [FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:YES completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         [self sessionStateChanged:session state:state error:error];
     }];
}
-(void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    NSLog(@"sessionStatusChanged");
    switch (state) {
        case FBSessionStateOpen:
            NSLog(@"FBSessionStateOpen");
            [_loginBtn setSelected:YES];
            [_faceContactBtn setEnabled:YES];
            [_faceContactBtn setAlpha:1.0];
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            NSLog(@"FBSessionStateClosed");
            [_loginBtn setSelected:NO];
            [_faceContactBtn setEnabled:NO];
            [_faceContactBtn setAlpha:0.5];
            break;
        default:
            break;
    }
    
    if (error)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self setPageLayout];
    
    //_modiAddress = [[NSMutableArray alloc] init];
    _myAddress = [[NSMutableDictionary alloc] init];
    _fbAddress = [[NSMutableArray alloc] init];
    
    fbState = NO;
    ctState = NO;
    
    _dimmedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    [_dimmedView setBackgroundColor:convertHexToDecimalRGBA(@"ff", @"ff", @"ff", 0.5)];
    
    UILabel *waitLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 236, 320, 21)];
    [waitLbl setText:@"wait"];
    [waitLbl setTextColor:[UIColor whiteColor]];
    [_dimmedView addSubview:waitLbl];
    
    _popViewer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    [_popViewer setBackgroundColor:convertHexToDecimalRGBA(@"ff", @"ff", @"ff", 0.75)];
    
    
    
    
    
}
-(void)setPageLayout
{
    [_loginBtn setTitle:@"Facebook Login" forState:UIControlStateNormal];
    [_loginBtn setTitle:@"Facebook LogOut" forState:UIControlStateSelected];
    [_loginBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_loginBtn setTag:BTN_TAG_LOGIN];
    
    [_faceContactBtn setTitle:@"my Facebook" forState:UIControlStateNormal];
    [_faceContactBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_faceContactBtn setTag:BTN_TAG_FRIEND];
    [self.view addSubview:_faceContactBtn];
    [_faceContactBtn setEnabled:NO];
    [_faceContactBtn setAlpha:0.5];
}
-(void)buttonPressed:(id)sender
{
    UIButton * tempBtn = (UIButton *)sender;
    switch (tempBtn.tag) {
        case BTN_TAG_LOGIN:         // 로그인
        {
            if(tempBtn.isSelected)  // 로그인 -> 로그아웃
            {
                [FBSession.activeSession closeAndClearTokenInformation];
                tempBtn.selected = !tempBtn.selected;
                
                [_loginBtn setSelected:NO];
                [self setPageLayout];
                
            }else                   // 로그아웃 -> 로그인
            {
                [self openSession];
            }
        }
            break;
        case BTN_TAG_FRIEND:
        {
            [self wifiChecker:@"fb"];
        }
    }
}

- (void) phoneGet
{
    
    [self.view addSubview:_dimmedView];
    [_indicator startAnimating];
    ABAddressBookRef addressbook = NULL;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0){
        addressbook = ABAddressBookCreateWithOptions(NULL, NULL);
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressbook,
                                                 ^(bool granted, CFErrorRef error){
                                                     dispatch_semaphore_signal(sema);
                                                 });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    else{
        addressbook = ABAddressBookCreate();
    }
    //
    //    if ( [[[UIDevice currentDevice] systemVersion ] floatValue] < 6.0 )
    //        addressbook = ABAddressBookCreate();
    //    else
    //        addressbook = ABAddressBookCreateWithOptions(NULL, NULL);
    //
    
    int addCount = ABAddressBookGetPersonCount(addressbook);
    
    NSArray *people = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressbook);
    
    dispatch_queue_t dqueue = dispatch_queue_create("test2", NULL);
    
    dispatch_async(dqueue, ^{
        
        
        
        for (int i=0; i<addCount; i++)
        {
            NSString *sung = (__bridge NSString *)ABRecordCopyValue((__bridge ABRecordRef)([people objectAtIndex:i]), kABPersonLastNameProperty);
            NSString *name = (__bridge NSString *)ABRecordCopyValue((__bridge ABRecordRef)([people objectAtIndex:i]), kABPersonFirstNameProperty);
            
            if(sung == nil)
                sung = @"";
            
            if(name == nil)
                name = @"";
            
            NSString *phoneNumber = nil;
            
            ABMultiValueRef multiValue = ABRecordCopyValue((__bridge ABRecordRef)([people objectAtIndex:i]), kABPersonPhoneProperty);
            int size = ABMultiValueGetCount(multiValue);
            CFStringRef pNum = nil;
            if(size < 1)
            {
                phoneNumber = @"";
            }
            else
            {
                pNum = ABMultiValueCopyValueAtIndex(multiValue, 0);
                phoneNumber = (__bridge NSString *)pNum;
            }
            
            if(phoneNumber == nil)
                phoneNumber = @"";
            //      CFRelease(multiValue);
            
            NSDictionary *sungDic = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@%@", sung,name] forKey:@"FULLNAME"];
            NSDictionary *lastName = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", sung] forKey:@"LASTNAME"];
            NSDictionary *firstName = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", name] forKey:@"FIRSTNAME"];
            
            NSDictionary *numberDic = [NSDictionary dictionaryWithObject:phoneNumber forKey:@"PHONENUMBER"];
            
            NSArray *contactInfo = [NSArray arrayWithObjects:sungDic, numberDic, lastName, firstName, nil];
            
            NSLog(@"arr : %@", contactInfo);
            //  CFRelease(people);
            [_myAddress setObject:contactInfo forKey:[NSString stringWithFormat:@"%d", i]];
            
            if (pNum != nil)
                CFRelease((CFTypeRef) pNum);
            
            CFRelease(multiValue);
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"dict : %@", _myAddress);
            
            NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"contact_alert", @"연락처알림"), addCount];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알림" message:msg delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            [alert show];
            
            [_indicator stopAnimating];
            [_dimmedView removeFromSuperview];
            
            ctState = YES;
            
            if(fbState == YES && ctState == YES)
            {
                [_imageMergeBtn setEnabled:YES];
            }
        });
        
        CFRelease(addressbook);
    });
    
    
    
}
- (void)publishToFriend
{
    [self.view addSubview:_dimmedView];
    [_indicator startAnimating];
    
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id data, NSError *error) {
        if(error) {
            NSLog(@"friend error");
            [_indicator stopAnimating];
            [_dimmedView removeFromSuperview];
            return;
        }
        
        NSArray *arr = (NSArray*)[data data];
        
        NSLog(@"friend list : %@", arr);
        NSLog(@"You have %d friends", [arr count]);
        
        [_fbAddress setArray:arr];
        
        NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"fb_alert", @"페북친구가져옴"), [arr count]];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알림" message:msg delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
        [alert show];
        
        [_indicator stopAnimating];
        [_dimmedView removeFromSuperview];
        
        fbState = YES;
        
        if(fbState == YES && ctState == YES)
        {
            [_imageMergeBtn setEnabled:YES];
        }
    }];
    
}
-(BOOL) checkAddressBookAuthWithoutMessage
{
    
    // 주소록 데이터 접근
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if ( version >= 6.0  ) // Version 6.0 이상부터는 연락처 접근시 승인여부를 확인해야 한다. (**예약)
    {
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        
        // 접근권한 변수 생성
        __block BOOL accessGranted = NO;
        
        //  iOS 6 에만 존재하는 메소드 호출해야 한다. 혹시나 해서 널체크 해보고~
        if (ABAddressBookRequestAccessWithCompletion != NULL)
        {
            // 세마포어 생성
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            // 연락처 접근권한 받아오는 메세지박스 띄우는 메소드 호출
            ABAddressBookRequestAccessWithCompletion(addressBook,
                                                     ^(bool granted, CFErrorRef error) {
                                                         accessGranted = granted; // 사용자가 선택한 권한을 넘겨주도록
                                                         dispatch_semaphore_signal(sema); // 세마포어 락을 해제하는 시그널 전송
                                                     } );
            // 해제 명령이 들어오기 전까지 무한 대기하도록 한다.
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            // 세마포어 해제
            //dispatch_release(sema);
        }
        
        if ( accessGranted == NO )
        {
            // 사용자가 접근권한을 제한한 경우
            return NO;
        }
        else
        {
            // 사용자가 접근 권한을 허용한 경우라도 다시 한번 권한이 있는지 체크한다.
            CFIndex addressbookAuth = ABAddressBookGetAuthorizationStatus();
            if ( addressbookAuth != kABAuthorizationStatusAuthorized )
            {
                return NO;
            }
        }
    }
    
    // 이단계까지 문제가 없었다면 연락처 사용가능하도록 리턴
    return YES;
}


- (IBAction)click:(id)sender
{
    if(IS_IOS_VER)
    {
        if([self checkAddressBookAuthWithoutMessage])
            [self phoneGet];
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알림" message:@"연락처 접근 권한이 없습니다. 설정에서 연락처 권한을 켜주세요" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    else
        [self phoneGet];
}

- (IBAction)contactFBMerge:(id)sender
{
    if(ctState == YES && fbState == YES)
    {
        
        [self wifiChecker:@"merge"];
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알림" message:@"연락처 또는 페이스북 친구를 먼저 가져오세요" delegate:nil cancelButtonTitle:@"예" otherButtonTitles:nil, nil];
        [alert show];
        
        return;
        
    }
    
}

- (IBAction)helperView:(id)sender
{
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 0)
    {
        if(buttonIndex == 1)
        {
            UITextView *txtView = [[UITextView alloc] init];
            [txtView setFrame:CGRectMake(30, 100, 260, self.view.frame.size.height-100-100)];
            //txtView.center = _popViewer.center;
            [txtView setText:[NSString stringWithFormat:@"%@", _modifyAddress]];
            [txtView setFont:[UIFont systemFontOfSize:20]];
            [txtView setEditable:NO];
            [_popViewer addSubview:txtView];
            
            
            UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [closeBtn setTitle:@"Close" forState:UIControlStateNormal];
            [closeBtn setFrame:CGRectMake(60, 100 + txtView.frame.size.height + 10 , 200, 30)];
            [closeBtn addTarget:self action:@selector(closeView:) forControlEvents:UIControlEventTouchUpInside];
            [_popViewer addSubview:closeBtn];
            
            [self.view addSubview:_popViewer];
            
            
        }
        
    }
    else if (alertView.tag < 4)
    {
        if(buttonIndex == 1)
        {
            if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound)
            {
                // 퍼블리싱을 위한 퍼미션이 없는 경우 퍼미션 요청
                [FBSession.activeSession reauthorizeWithPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]                  defaultAudience:FBSessionDefaultAudienceFriends completionHandler:^(FBSession *session, NSError *error)
                 {
                     if (!error)
                     {
                         // 정상적으로 퍼미션을 가져온 경우 퍼블리시
                         [self publishToFriend];
                     }
                 }];
            } else {
                // 퍼미션이 있는 경우 퍼블리시
                [self publishToFriend];
            }
            
        }
    }
    else
    {
        if(buttonIndex == 1)
        {
            NSLog(@"Upload Button Pressed");
            
            // backgroune execution 은 iOS 4 이후 지원 (특정 디바이스 미지원),  확인 작업 필요
            
            UIDevice* device = [UIDevice currentDevice];
            
            BOOL backgroundSupported = NO;
            
            if ([device respondsToSelector:@selector(isMultitaskingSupported)]){
                
                backgroundSupported = device.multitaskingSupported;
                
            }
            
            // background 작업을 지원하면
            
            if(backgroundSupported){
                
                // System 에 background 작업이 필요함을 알림. 작업의 id 반환
                
                taskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                    
                    NSLog(@"Backgrouund task ran out of time and was terminated");
                    
                    [[UIApplication sharedApplication] endBackgroundTask:taskId];
                    
                }];
                
            }
            
            
            [self merging];
            //ABAddressBookSave(addressBook, nil);
        }
    }
    
}
- (void) merging
{
    [self.view addSubview:_dimmedView];
    [_indicator startAnimating];
    
    NSLog(@"%@", _myAddress);
    
    NSMutableArray *modifiedArray = [NSMutableArray array];
    
    __block int delcont = 0;
    
    dispatch_queue_t dqueue = dispatch_queue_create("test", NULL);
    dispatch_semaphore_t exsignal = dispatch_semaphore_create(10);
    
    dispatch_async(dqueue, ^{
        dispatch_semaphore_wait(exsignal, DISPATCH_TIME_FOREVER);
        
        for (int i=0; i<[_myAddress count]; i++)
        {
            NSString *contactCnt = [NSString stringWithFormat:@"%@", [[[_myAddress objectForKey:[NSString stringWithFormat:@"%d", i]] objectAtIndex:0] objectForKey:@"FULLNAME"]];
            
            NSLog(@"contactCnt : %@", contactCnt);
            
            for (int k=0; k<[_fbAddress count]; k++)
            {
                NSString *fbCnt = [NSString stringWithFormat:@"%@%@", [[_fbAddress objectAtIndex:k] objectForKey:@"last_name"], [[_fbAddress objectAtIndex:k] objectForKey:@"first_name"]];
                
                NSString *fbCntReverse = [NSString stringWithFormat:@"%@%@", [[_fbAddress objectAtIndex:k] objectForKey:@"first_name"], [[_fbAddress objectAtIndex:k] objectForKey:@"last_name"]];
                
                NSString *fbCnt02 = [NSString stringWithFormat:@"%@", [[_fbAddress objectAtIndex:k] objectForKey:@"name"]];
                
                NSString *fbId = [NSString stringWithFormat:@"%@", [[_fbAddress objectAtIndex:k] objectForKey:@"id"]];
                
                if([contactCnt isEqualToString:fbCnt] || [contactCnt isEqualToString:fbCntReverse] || [contactCnt isEqualToString:fbCnt02])
                {
                    NSLog(@"같다");
                    
                    [modifiedArray addObject:contactCnt];
                    
                    delcont++;
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        
                        
                        // 수정
                        ABAddressBookRef addressbook = ABAddressBookCreate();
                        NSArray *people = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressbook);
                        ABRecordRef aPerson = (__bridge ABRecordRef)([people objectAtIndex:i]);
                        
                        NSString *imgStr = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", fbId];
                        
                        NSData *data1 = UIImagePNGRepresentation([self DownloadThumeNail:imgStr]);
                        // 이미지
                        ABPersonSetImageData(aPerson, (__bridge CFDataRef)data1, NULL);
                        
                        ABAddressBookAddRecord(addressbook, aPerson, NULL);
                        ABAddressBookSave(addressbook, NULL);
                        
                        CFRelease(addressbook);
                    });
                    
                    break;
                }
                
                
            }
            
            
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            [[UIApplication sharedApplication] endBackgroundTask:taskId];
            
            
            NSString *str = [NSString stringWithFormat:NSLocalizedString(@"merge_alert", @"합쳐알림"), delcont];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알림" message:str delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"보기", nil];
            [alert setTag:0];
            [alert show];
            
            [_indicator stopAnimating];
            [_dimmedView removeFromSuperview];
        });
        
        _modifyAddress = [[modifiedArray sortedArrayUsingSelector:@selector(compare:)] copy];
        
        NSLog(@"바뀐사람 : %@", _modifyAddress);
        
    });
    
}
- (void) closeView:(id)sender
{
    [_popViewer removeFromSuperview];
}

- (UIImage*)DownloadThumeNail:(NSString*)Url
{
	NSURL *imageURL = [NSURL URLWithString:Url];
    
	NSData *imageData = nil;
    
	if(imageURL != nil)
    {
		imageData = [NSData dataWithContentsOfURL:imageURL];
		UIImage *tempThumeNailImage = [UIImage imageWithData:imageData];
		
		if(imageData != nil)
        {
			return tempThumeNailImage;
		}
	}
    return 0;
}
- (void) wifiChecker:(NSString *)str
{
    NetworkStatus netStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    BOOL connectionRequired= [[Reachability reachabilityForInternetConnection] connectionRequired];
    NSString *msg = nil;
    switch (netStatus)
    {
        case NotReachable:
        {
            break;
        }
            
        case ReachableViaWWAN:
        {
            msg = NSLocalizedString(@"3g_Network", @"");
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알림" message:msg delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil];
            
            if([str isEqualToString:@"fb"])
                [alert setTag:2];
            else
                [alert setTag:4];
            
            [alert show];
            
            break;
        }
        case ReachableViaWiFi:
        {
            msg = NSLocalizedString(@"wifi_Network", @"");
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알림" message:msg delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil];
            if([str isEqualToString:@"fb"])
                [alert setTag:3];
            else
                [alert setTag:5];
            
            [alert show];
            break;
        }
        default:
            break;
    }
    
    if(connectionRequired)
    {
        msg = NSLocalizedString(@"not_Network", @"");
        connectionRequired= NO;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알림" message:msg delegate:nil cancelButtonTitle:@"취소" otherButtonTitles:nil, nil];
        [alert show];
        
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
