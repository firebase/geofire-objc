//
//  GFRealDataTest.m
//  GeoFire
//
//  Created by Jonny Dimond on 7/9/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "GFRealDataTest.h"

#import "TestHelpers.h"

@import Firebase;

@implementation GFRealDataTest

- (void)setUp
{
    [super setUp];
    NSString *randomFirebaseURL = [NSString stringWithFormat:@"https://%@.firebaseio-demo.com",
                                   [TestHelpers randomAlphaNumericStringWithLength:16]];

    NSString *appname =  [TestHelpers randomAlphaNumericStringWithLength:16];
    NSLog(@"Test url %@", randomFirebaseURL);
    FIROptions *options = [[FIROptions alloc] initWithGoogleAppID:@"googleAPI"
                                                 bundleID:@"com.test.app"
                                            GCMSenderID:@"testid"
                                                   APIKey:nil
                                                clientID:nil
                                               trackingID:nil
                                          androidClientID:nil
                                              databaseURL:randomFirebaseURL
                                            storageBucket:nil
                                        deepLinkURLScheme:nil];


    [FIRApp configureWithName:appname options:options];

    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.firebase.test", NULL);
    [[FIRDatabase databaseForApp:[FIRApp appNamed:appname]]  setCallbackQueue:backgroundQueue];
    self.firebaseRef = [[FIRDatabase databaseForApp:[FIRApp appNamed:appname]] reference];
    self.geoFire = [[GeoFire alloc] initWithFirebaseRef:self.firebaseRef];
    self.geoFire.callbackQueue = backgroundQueue;
}

- (void)tearDown
{
    [super tearDown];
    dispatch_semaphore_t wait = dispatch_semaphore_create(0);

    [self.firebaseRef setValue:nil withCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
        dispatch_semaphore_signal(wait);
    }];

    dispatch_semaphore_wait(wait, dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC));
}

@end
