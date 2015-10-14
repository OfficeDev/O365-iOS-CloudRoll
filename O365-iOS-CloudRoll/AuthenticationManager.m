/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license. See full license at the bottom of this file.
 */

#import "AuthenticationManager.h"
#import <OneDriveSDK/OneDriveSDK.h>

// You will set your application's clientId and redirect URI for Microsoft Account authentication (OneDrive)
NSString * const kMicrosoftAccountAppId         = @"ENTER_CLIENT_ID_HERE";
NSString * const kMicrosoftAccountScopesString  = @"wl.signin,onedrive.readwrite,onedrive.appfolder,wl.offline_access";

// You will set your application's clientId and redirect URI for Active Directory authentication (OneDrive for
//Business)
NSString * const kActiveDirectoryAppId          = @"ENTER_CLIENT_ID_HERE";
NSString * const kActiveDirectoryRedirectURL    = @"ENTER_REDIRECT_URI_HERE";
NSString * const kActiveDirectoryScopesString   = @"MyFiles.readwrite";

// External string
NSString * const MicrosoftAccount              = @"Microsoft Account";
NSString * const ActiveDirectoryAccount        = @"ActiveDirectory Account";

@implementation AuthenticationManager

- (instancetype) init {
    self = [super init];
    if(self){
        [self initOneDrive];
    }
    return self;
}

- (void) clientWithType:(AccountType)accountType
             completion:(void (^)(ODClient *client, NSError *error))completion
{
    NSArray *clients = [ODClient loadClients];
    NSString *accountTypeString = (accountType == AccountTypeMicrosoft)?MicrosoftAccount:ActiveDirectoryAccount;
    
    // Look for existing client
    for (ODClient *client in clients){
        if ([client.serviceFlags objectForKey:accountTypeString]) {
            completion(client, nil);
            return;
        }
    }
    
    // If non-existant, authenticate to get a client
    [ODClient authenticatedClientWithCompletion:^(ODClient *client, NSError *error) {
        //handle error
        if (error){
            completion(nil, error);
        }
        else{
            // complete if right account type is authenticated
            if ([client.serviceFlags objectForKey:accountTypeString]) {
                completion(client, nil);
            }
            else {
                // sign out if wrong account type is authenticated
                [client signOutWithCompletion:nil];
                
                // return error
                NSString *errorString = [NSString stringWithFormat:@"Please authenticated with a %@", accountTypeString];
                NSError *newError = [NSError errorWithDomain:@"http://microsoft"
                                                        code:0
                                                    userInfo:@{errorString:NSLocalizedDescriptionKey}];
                completion(nil, newError);
            }
        }
    }];
}

- (void) initOneDrive {
    NSArray *microsoftAccountScopes = [kMicrosoftAccountScopesString componentsSeparatedByString:@","];
    NSArray *activeDirectoryScopes = [kActiveDirectoryScopesString componentsSeparatedByString:@","];
    
    [ODClient setMicrosoftAccountAppId:kMicrosoftAccountAppId
                microsoftAccountScopes:microsoftAccountScopes
                 microsoftAccountFlags:@{MicrosoftAccount:@(1)}
                  activeDirectoryAppId:kActiveDirectoryAppId
                 activeDirectoryScopes:activeDirectoryScopes
            activeDirectoryRedirectURL:kActiveDirectoryRedirectURL
                  activeDirectoryFlags:@{ActiveDirectoryAccount:@(1)}];

}

- (void) signOutOfAllAccounts {
    // iterate through all accounts and sign out
    NSArray *clients = [ODClient loadClients];
    
    for (ODClient *client in clients) {
        [client signOutWithCompletion:nil];
    }
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

