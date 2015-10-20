/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license. See full license at the bottom of this file.
 */

#import "CameraViewController.h"
#import "OneDriveManager.h"
#import "SettingsTableViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SettingsManager.h"
#import <TargetConditionals.h>

// Comment or uncomment to specify running on a simulator as camera does not work on a simulator
//#define TESTING_ON_SIMULATOR

const CGFloat kLeadingSpaceMinConstant = 20;
const CGFloat kLeadingSpaceMaxConstant = 50;

const CGFloat kHideDelay = 3.f;

@interface CameraViewController () {
    AVCaptureSession *session;
    AVCaptureStillImageOutput *stillImageOutput;
    AVCaptureVideoPreviewLayer *previewLayer;
    AVCaptureDevice *captureDevice;
}

@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet UIView *actionView;

@property (weak, nonatomic) IBOutlet UIButton *oneDriveButton;
@property (weak, nonatomic) IBOutlet UIButton *oneDriveBusinessButton;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *statusIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusTextLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;

@property (assign, nonatomic) BOOL photoButtonEnabled;

@property (strong, nonatomic) OneDriveManager *oneDriveManager;

@end

@implementation CameraViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Initialize local variables and properties
    self.oneDriveManager = [[OneDriveManager alloc] init];

    self.photoButtonEnabled = YES;
    self.statusLabel.text = @"";
    
    [self setupGesture];
    [self selectLeft];
    
    [self.takePhotoButton setBackgroundImage:[self imageWithColor:[UIColor redColor]] forState:UIControlStateHighlighted];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startCamera];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopCamera];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - gesture
// Swipe to change account type selected

- (void)setupGesture {
    UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe:)];
    leftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    
    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipe:)];
    rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.actionView addGestureRecognizer:leftRecognizer];
    [self.actionView addGestureRecognizer:rightRecognizer];
}

- (void)leftSwipe:(UIGestureRecognizer*)recognizer {
    [self selectRight];
}

- (void)rightSwipe:(UIGestureRecognizer*)recognizer {
    [self selectLeft];
}


#pragma mark - account type selector
- (IBAction)oneDriveSelected:(id)sender {
    [self selectLeft];
}

- (IBAction)oneDriveBusinessSelected:(id)sender {
    [self selectRight];
}

- (void) selectLeft {
    [self.oneDriveButton setSelected:YES];
    [self.oneDriveBusinessButton setSelected:NO];

    [self.takePhotoButton removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    [self.takePhotoButton addTarget:self action:@selector(takePhotoAndUploadToOneDrive) forControlEvents:UIControlEventTouchUpInside];
}


- (void) selectRight {
    [self.oneDriveButton setSelected:NO];
    [self.oneDriveBusinessButton setSelected:YES];

    [self.takePhotoButton removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    [self.takePhotoButton addTarget:self action:@selector(takePhotoAndUploadToOneDriveBusiness) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - camera

- (void)initializeCamera {
    session = [[AVCaptureSession alloc] init];
    [session setSessionPreset:AVCaptureSessionPresetPhoto];
    
    AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    
    captureDevice = inputDevice;
    
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice
                                                                              error:&error];
    
    if ([session canAddInput:deviceInput]) {
        [session addInput:deviceInput];
    }
    
    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    
    CALayer *rootLayer = [self.cameraView layer];
    [rootLayer setMasksToBounds:NO];
    [previewLayer setFrame:CGRectMake(0, 0, rootLayer.bounds.size.width, rootLayer.bounds.size.height)];
    [rootLayer addSublayer:previewLayer];
    
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = @{AVVideoCodecJPEG:AVVideoCodecKey};
    [stillImageOutput setOutputSettings:outputSettings];
    [session addOutput:stillImageOutput];
}

- (void)startCamera {
    if (TARGET_IPHONE_SIMULATOR) {
        return;
    }
    
    if (!session) {
        [self initializeCamera];
    }
    [session startRunning];
}

- (void)stopCamera {
    if (TARGET_IPHONE_SIMULATOR) {
        return;
    }
    
    [session stopRunning];
}


#pragma mark - take photo

- (void)takePhotoAndUploadToOneDriveBusiness {
    [self takePhotoAndUploadIsBusiness:YES];
}

- (void)takePhotoAndUploadToOneDrive {
    [self takePhotoAndUploadIsBusiness:NO];
}

- (void)takePhotoAndUploadIsBusiness:(BOOL)business {
    if (!self.photoButtonEnabled) {
        return;
    }
    
    self.photoButtonEnabled = NO;
    
    [self setStatus:@"Trying to upload a photo image" showLoading:YES];
    
    [self takePhotoWithCompletion:^(NSData *imageData, NSError *error) {
        if (error) {
            NSLog(@"Error\n%@", [error localizedDescription]);
            [self setStatus:@"Error occurred" showLoading:NO hideAfter:kHideDelay];
            [self handleError:error];
            self.photoButtonEnabled = YES;
            return;
        }

        // get image data and create JPEG representation
        CGFloat imageQuality;
        switch ([SettingsManager imageResolution]) {
            case ResolutionLow:
                imageQuality = 0.3;
                break;
                
            case ResolutionMedium:
                imageQuality = 0.5;
                break;
                
            case ResolutionHigh:
                imageQuality = 1.0;
                break;
                
            default:
                break;
        }
        
        NSData *imageDataWithQuality = UIImageJPEGRepresentation([UIImage imageWithData:imageData], imageQuality);
    
        [self uploadImageData:imageDataWithQuality
                   toBusiness:business
                   completion:^(ODItem *response,  float timeElapedForUploadTask, NSError *error) {
                        self.photoButtonEnabled = YES;
                        if (error) {
                            NSLog(@"Error\n%@", [error localizedDescription]);
                            [self setStatus:@"Error occurred" showLoading:NO hideAfter:kHideDelay];
                            [self handleError:error];
                            return;
                        }
                        
                        [self setStatus:[NSString stringWithFormat:@"Success ✓ - %.02f seconds\n%@",
                                         timeElapedForUploadTask, response.name]
                            showLoading:NO
                              hideAfter:kHideDelay];
                    }];
    }];
}

- (void)takePhotoWithCompletion:(void (^)(NSData *imageData, NSError *error))completion {
    if (TARGET_IPHONE_SIMULATOR) {
        completion(UIImagePNGRepresentation([UIImage imageNamed:@"cloudRollLogo.png"]), nil);
    }
    else {
        // Capture image & upload
        AVCaptureConnection *videoConnection = nil;
        
        for (AVCaptureConnection *connection in stillImageOutput.connections) {
            for (AVCaptureInputPort *port in [connection inputPorts]) {
                if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                    videoConnection = connection;
                    break;
                }
            }
            if (videoConnection) {
                break;
            }
        }
        
        [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                      completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                          if (imageDataSampleBuffer) {
                                                              NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                              completion(imageData, nil);
                                                          }
                                                          else{
                                                              completion(nil, error);
                                                          }
                                                      }];
    }
}

- (void)uploadImageData:(NSData *)imageData
             toBusiness:(BOOL)business
              completion:(void (^)(ODItem *response, float timeElapedForUploadTask, NSError *error))completion
{
    [self.oneDriveManager uploadToAccount:business?[SettingsManager activeDirectoryAccountId]:[SettingsManager microsoftAccountId]
                        isBusinessAccount:business
                                imageData:imageData
                               completion:^(ODItem *response, float timeElapsedForUploadTask, NSError *error) {
                                   completion(response, timeElapsedForUploadTask, error);
                               }];
}

#pragma mark - ui helpers

- (void)handleError:(NSError*)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                 message:[NSString stringWithFormat:@"%@\n\nRead log for more details", [error localizedDescription]]
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
      });
}

- (void)setStatus:(NSString*)text showLoading:(BOOL)show {

    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusLabel.alpha = 1.0f;
        self.statusLabel.text = text;
        
        if (show) {
            [self.statusIndicator startAnimating];
            self.statusTextLayoutConstraint.constant = kLeadingSpaceMaxConstant;
        }
        else {
            [self.statusIndicator stopAnimating];
            self.statusTextLayoutConstraint.constant = kLeadingSpaceMinConstant;
        }
    });
}


- (void)setStatus:(NSString*)text showLoading:(BOOL)show hideAfter:(CGFloat)seconds {
    [self setStatus:text showLoading:show];
    [self hideStatusAfter:seconds];
}

- (void)hideStatusAfter:(CGFloat)seconds {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:1.f animations:^{
                self.statusLabel.alpha = 0.0;
            }];
        });
    });
}

#pragma mark - UI helper

- (UIImage*)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showSettings"]) {
        SettingsTableViewController *vc = segue.destinationViewController;
        vc.oneDriveManager = self.oneDriveManager;
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


