//
//  SRGVersionUpdater.m
//  Example
//
//  Created by Kazuhiro Sakamoto on 2015/01/22.
//  Copyright (c) 2015年 Soragoto. All rights reserved.
//

#import "SRGVersionUpdater.h"
#import "UIAlertView+Blocks.h"
#import "AFHTTPRequestOperationManager.h"

@implementation SRGVersionUpdater {
    NSDictionary *versionInfo;
}

#ifndef SRGVersionUpdaterLocalizedStrings
#define SRGVersionUpdaterLocalizedStrings(key) \
NSLocalizedStringFromTableInBundle(key, @"SRGVersionUpdater", [NSBundle bundleWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"SRGVersionUpdater.bundle"]], nil)
#endif

- (void) executeVersionCheck {
   NSAssert(_endPointUrl, @"Set EndPointUrl Before Execute Check");
    
   AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
   manager.session.configuration.URLCache = nil;
   manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json",nil];
   [manager GET:_endPointUrl parameters:nil
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           versionInfo = responseObject;
           [self showUpdateAnnounceIfNeeded];
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           NSLog(@"Request Operation Error! %@", error);
       }
   ];
}

- (void) showUpdateAnnounceIfNeeded {
    if( ![self isVersionUpNeeded] ) {
        return;
    }
    [self showUpdateAnnounce];
}

- (BOOL) isVersionUpNeeded {
    NSString *currentVersion  = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *requiredVersion = versionInfo[@"required_version"];
    
    
    if(versionInfo[@"title"]){
        _customAlertTitle = versionInfo[@"title"];
    }
    
    if(versionInfo[@"body"]){
        _customAlertBody = versionInfo[@"body"];
    }
    
    return ( [requiredVersion compare:currentVersion options:NSNumericSearch] == NSOrderedDescending );
}

- (void) showUpdateAnnounce {
    BOOL hasCancelButton = [versionInfo[@"type"] isEqualToString:@"optional"];
    NSInteger updateIndex = hasCancelButton ? 1 : 0;
    [UIAlertView showWithTitle:[self alertTitle]
                       message:[self alertBody]
             cancelButtonTitle:hasCancelButton ? [self cancelButtonText] : nil
             otherButtonTitles:@[[self updateButtonText]]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex){
                          if (buttonIndex == updateIndex) {
                              NSURL *updateUrl = [NSURL URLWithString:versionInfo[@"update_url"]];
                              [[UIApplication sharedApplication] openURL:updateUrl];
                          }
                      }];
}

- (NSString *) alertTitle {
    
    return _customAlertTitle ? _customAlertTitle : @"New version arrived";
}

- (NSString *) alertBody {
    
    return _customAlertBody ? _customAlertBody : @"Please download latest version from the Apple App Store";
}

- (NSString *) updateButtonText {
    
    return @"Download";
}

- (NSString *) cancelButtonText {
    
    return @"Update After";
}

- (NSInteger) versionNumberFromString:(NSString *)versionString{
    
    
    return [[versionString stringByReplacingOccurrencesOfString:@"." withString:@""] intValue];
}

- (NSString *) localizedStringWithFormat:(NSString *)format {
    
    return SRGVersionUpdaterLocalizedStrings(format);
}

@end
