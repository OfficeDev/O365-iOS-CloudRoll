/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license. See full license at the bottom of this file.
 */

#import "OneDriveManager.h"
#import <OneDriveSDK/OneDriveSDK.h>
#import "SettingsManager.h"

// You will set your application's clientId and redirect URI for Microsoft Account authentication (OneDrive)
NSString * const kMicrosoftAccountAppId         = @"ENTER_CLIENT_ID_HERE";
NSString * const kMicrosoftAccountScopesString  = @"wl.signin,onedrive.readwrite,onedrive.appfolder,wl.offline_access";

// You will set your application's clientId and redirect URI for Active Directory authentication (OneDrive for
//Business)
NSString * const kActiveDirectoryAppId          = @"ENTER_CLIENT_ID_HERE";
NSString * const kActiveDirectoryRedirectURL    = @"ENTER_REDIRECT_URI_HERE";
NSString * const kActiveDirectoryScopesString   = @"MyFiles.readwrite";
NSString * const kMicrosoftAccountFlag          = @"Microsoft Account";
NSString * const kActiveDirectoryAccountFlag    = @"Active Directory Account";


@implementation OneDriveManager

#pragma mark - Initialization
- (instancetype)init {
    self = [super init];
    if(self){
        [self initOneDrive];
    }
    return self;
}

- (void)initOneDrive {
    NSArray *microsoftAccountScopes = [kMicrosoftAccountScopesString componentsSeparatedByString:@","];
    NSArray *activeDirectoryScopes = [kActiveDirectoryScopesString componentsSeparatedByString:@","];
    
    [ODClient setMicrosoftAccountAppId:kMicrosoftAccountAppId
                microsoftAccountScopes:microsoftAccountScopes
                 microsoftAccountFlags:@{kMicrosoftAccountFlag:@(1)}
                  activeDirectoryAppId:kActiveDirectoryAppId
                 activeDirectoryScopes:activeDirectoryScopes
            activeDirectoryRedirectURL:kActiveDirectoryRedirectURL
                  activeDirectoryFlags:@{kActiveDirectoryAccountFlag:@(1)}];
}


#pragma mark - get OneDrive client (ODClient)

- (void)clientWithAccount:(NSString *)accountId
               completion:(void (^)(ODClient *client, NSError *error))completion {
    
    ODClient *client = [ODClient loadClientWithAccountId:accountId];
    if (client) {
        completion(client, nil);
    }
    else {
        [ODClient authenticatedClientWithCompletion:^(ODClient *client, NSError *error) {
            completion(client, error);
        }];
    }
}

#pragma mark - public uploading task methods


- (void)uploadToConsumerAccount:(NSString *)accountId
                      imageData:(NSData *)imageData
                     completion:(void (^)(ODItem *response, NSError *error))completion {
    [self uploadToAccount:accountId
        isBusinessAccount:NO
                imageData:imageData
               completion:^(ODItem *response, NSError *error) {
                   completion (response, error);
               }];
}

- (void)uploadToBusinessAccount:(NSString *)accountId
                      imageData:(NSData *)imageData
                     completion:(void (^)(ODItem *response, NSError *error))completion {
    [self uploadToAccount:accountId
        isBusinessAccount:YES
                imageData:imageData
               completion:^(ODItem *response, NSError *error) {
                   completion (response, error);
               }];
}



- (void)uploadToAccount:(NSString *)accountId
      isBusinessAccount:(BOOL)business
              imageData:(NSData *)imageData
                     completion:(void (^)(ODItem *response, NSError *error))completion
{
    [self clientWithAccount:accountId
                 completion:^(ODClient *client, NSError *error) {
                     if (error) {
                         completion(nil, error);
                         return;
                     }
                     
                     // Check if the account is linked with a business (Active directory account), check against a
                     // kActiveDirectoryAccountFlag flag set in the ODClient initializer.
                     if ((![client.serviceFlags objectForKey:kActiveDirectoryAccountFlag] && business) ||
                         (![client.serviceFlags objectForKey:kMicrosoftAccountFlag] && !business)) {
                         
                         NSString *errorString = [NSString stringWithFormat:@"Please authenticated with a %@", business?@"Active directory account":@"Microsoft account"];
                         NSError *newError = [NSError errorWithDomain:@"http://microsoft"
                                                                 code:0
                                                             userInfo:@{errorString:NSLocalizedDescriptionKey}];
                         [client signOutWithCompletion:^(NSError *error) {
                             completion(nil, newError);
                         }];
                         return;
                     }
                     
                     [SettingsManager setMicrosoftAccountId:client.accountId];

                     BOOL useAppfolder = !business;
                     
                     [self uploadToClient:client
                                imageData:imageData
                             useAppFolder:useAppfolder
                               completion:^(ODItem *response, NSError *error) {
                                   completion(response, error);
                               }];

                 }];
}


#pragma mark - uploading task

- (void)uploadToClient:(ODClient *)client
             imageData:(NSData *)imageData
          useAppFolder:(BOOL)appFolder
            completion:(void (^)(ODItem *response, NSError *error))completion {
    
    ODItemRequestBuilder *itemRequestBuilder;
    NSString *filePath;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh-mm ss a'.jpg'"];
    
    // Using a special App folder
    if (appFolder) {
        itemRequestBuilder = [[client drive] special:@"approot"];
        filePath = [dateFormatter stringFromDate:[NSDate date]];
    }
    
    // Using a specific path
    else {
        itemRequestBuilder = [client root];
        filePath = [NSString stringWithFormat:@"iOS-CloudRoll/%@", [dateFormatter stringFromDate:[NSDate date]]];
    }
    
    [[[itemRequestBuilder itemByPath:filePath] contentRequest] uploadFromData:imageData completion:^(ODItem *response, NSError *error) {
        completion(response, error);
    }];
}



#pragma mark - sign out
- (void)signOut {
    // iterate through all accounts and sign out
    NSArray *clients = [ODClient loadClients];
 
    for (ODClient *client in clients) {
        [client signOutWithCompletion:nil];
    }
    
    [SettingsManager setActiveDirectoryAccountId:nil];
    [SettingsManager setMicrosoftAccountId:nil];
}

@end

// *********************************************************
//
// CloudRoll for iOS, https://github.com/OfficeDev/
//
// Copyright (c) Microsoft Corporation
// All rights reserved.
//
// MIT License:
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// *********************************************************
