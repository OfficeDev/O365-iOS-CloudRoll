/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license. See full license at the bottom of this file.
 */

#import "OneDriveManager.h"
#import <OneDriveSDK/OneDriveSDK.h>
#import "SettingsManager.h"

// You will set your application's clientId for Microsoft Account authentication (OneDrive)
NSString * const kMicrosoftAccountAppId         = @"ENTER_CLIENT_ID_HERE";
NSString * const kMicrosoftAccountScopesString  = @"wl.signin,onedrive.readwrite,onedrive.appfolder,wl.offline_access";

// You will set your application's clientId and redirect URI for Active Directory authentication (OneDrive for
// Business)
NSString * const kActiveDirectoryAppId          = @"ENTER_CLIENT_ID_HERE";
NSString * const kActiveDirectoryRedirectURL    = @"ENTER_REDIRECT_URI_HERE";

// Constant strings for this class
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
    
    [ODClient setMicrosoftAccountAppId:kMicrosoftAccountAppId scopes:microsoftAccountScopes flags:@{kMicrosoftAccountFlag:@(1)}];
    [ODClient setActiveDirectoryAppId:kActiveDirectoryAppId redirectURL:kActiveDirectoryRedirectURL flags:@{kActiveDirectoryAccountFlag:@(1)}];
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

- (void)uploadToAccount:(NSString *)accountId
      isBusinessAccount:(BOOL)business
              imageData:(NSData *)imageData
             completion:(void (^)(ODItem *response,  float timeElapsedForUploadTask, NSError *error))completion
{
    [self clientWithAccount:accountId
                 completion:^(ODClient *client, NSError *error) {
                     if (error) {
                         completion(nil, 0, error);
                         return;
                     }
                     
                     // Check if the account is linked with a business (Active directory account), check against a
                     // kActiveDirectoryAccountFlag flag set in the ODClient initializer.
                     if ((![client.serviceFlags objectForKey:kActiveDirectoryAccountFlag] && business) ||
                         (![client.serviceFlags objectForKey:kMicrosoftAccountFlag] && !business)) {
                         
                         NSString *errorString = [NSString stringWithFormat:@"Please authenticate with %@", business?@"an Active directory account":@"a Microsoft account"];
                         NSError *newError = [NSError errorWithDomain:@"http://microsoft"
                                                                 code:0
                                                             userInfo:@{NSLocalizedDescriptionKey:errorString}];
                         [client signOutWithCompletion:^(NSError *error) {
                             completion(nil, 0, newError);
                         }];
                         return;
                     }
                     
                     if (business) {
                         [SettingsManager setActiveDirectoryAccountId:client.accountId];
                     }
                     else {
                         [SettingsManager setMicrosoftAccountId:client.accountId];
                     }

                     // Use appfolder for a Microsoft account, and a specific path for an active directory account
                     BOOL useAppfolder = !business;
                     
                     [self uploadToClient:client
                                imageData:imageData
                             useAppFolder:useAppfolder
                               completion:^(ODItem *response, float timeElapsedForUploadTask, NSError *error) {
                                   completion(response, timeElapsedForUploadTask, error);
                               }];
                 }];
}


#pragma mark - uploading task

- (void)uploadToClient:(ODClient *)client
             imageData:(NSData *)imageData
          useAppFolder:(BOOL)appFolder
            completion:(void (^)(ODItem *response, float timeElapsedForUploadTask, NSError *error))completion {
    
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
    
    NSDate *startTime = [NSDate date];
    
    // OneDrive API PUT https://api.onedrive.com/v1.0/drive/{filePath}/content
   [[[itemRequestBuilder itemByPath:filePath] contentRequest] uploadFromData:imageData completion:^(ODItem *response, NSError *error){
        if (error) {
            id odError = [error.userInfo objectForKey:ODErrorKey];
            if ([odError matches:ODAccessDeniedError]){
                [self signOut];
                // handle access denied error
                NSError *newError = [NSError errorWithDomain:@"http://microsoft"
                                                        code:0
                                                    userInfo:@{NSLocalizedDescriptionKey:@"Access denied. Please sign in again."}];
                completion(nil, 0, newError);
                return;
            }
        }
        
        completion(response,  [[NSDate date] timeIntervalSinceDate:startTime],  error);
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
// CloudRoll for iOS, https://github.com/OfficeDev/O365-iOS-CloudRoll
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
