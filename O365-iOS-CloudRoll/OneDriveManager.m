/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license. See full license at the bottom of this file.
 */

#import "OneDriveManager.h"
#import "AuthenticationManager.h"
#import <OneDriveSDK/OneDriveSDK.h>

@implementation OneDriveManager

// OneDrive account to use a special folder called the App Folder.
// The App Folder is typically named after your app, and is found in the Apps folder in the user's OneDrive
// For more detail, read https://dev.onedrive.com/misc/appfolder.htm
// Note: App Folder is currently not supported in OneDrive for Business
//
// OneDrive for Business will use a specific folder named "iOS-CloudRoll" for this sample.
// This also works in OneDrive account (non business) if desired.
+ (void)uploadToClient:(ODClient*)client
             imageData:(NSData*)imageData
            completion:(void (^)(ODItem *response, NSError *error))completion {
    
    ODItemRequestBuilder *itemRequestBuilder;
    NSString *filePath;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh-mm ss a'.jpg'"];

    // Using special app folder
    if ([client.serviceFlags objectForKey:MicrosoftAccount]) {
        itemRequestBuilder = [[client drive] special:@"approot"];
        filePath = [dateFormatter stringFromDate:[NSDate date]];
    }
    
    // Using specific path
    else{
        itemRequestBuilder = [client root];
        filePath = [NSString stringWithFormat:@"iOS-CloudRoll/%@", [dateFormatter stringFromDate:[NSDate date]]];
    }
    
    [[[itemRequestBuilder itemByPath:filePath] contentRequest] uploadFromData:imageData completion:^(ODItem *response, NSError *error) {
        completion(response, error);
    }];
    
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
