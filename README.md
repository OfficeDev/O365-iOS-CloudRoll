# Office 365 iOS CloudRoll



## Introduction

CloudRoll is an iOS app that allows you take a picture and send it to OneDrive without storing the image locally on the phone. This can be valuable if you're concerned about storage space, or, if you lose your phone, making sure confidential pictures are not lost with it.

This sample is built using the [OneDrive SDK for iOS](https://github.com/OneDrive/onedrive-sdk-ios), and  it will demonstrate:

- Authenticating multiple account types including Microsoft Accounts (outlook.com, hotmail.com), or an organizational account (Active Directory-based) to the OneDrive service in Office 365.
- Using the OneDrive API to upload a captured image to a CloudRoll app folder. 

We'll walk through the code in detail in the wiki.

## Prerequisites
* [Xcode](https://developer.apple.com/xcode/downloads/) from Apple
* Installation of [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)  as a dependency manager.
* An Office 365 account. You can sign up for [an Office 365 Developer subscription](https://portal.office.com/Signup/Signup.aspx?OfferId=6881A1CB-F4EB-4db3-9F18-388898DAF510&DL=DEVELOPERPACK&ali=1#0) that includes the resources that you need to start building Office 365 apps.

     > Note: If you already have a subscription, the previous link sends you to a page with the message *Sorry, you can’t add that to your current account*. In that case, use an account from your current Office 365 subscription.
* A Microsoft Azure tenant to register your application. Azure Active Directory (AD) provides identity services that applications use for authentication and authorization. A trial subscription can be acquired here: [Microsoft Azure](https://account.windowsazure.com/SignUp).

     > Important: You will also need to ensure your Azure subscription is bound to your Office 365 tenant. To do this, see the Active Directory team's blog post, [Creating and Managing Multiple Windows Azure Active Directories](http://blogs.technet.com/b/ad/archive/2013/11/08/creating-and-managing-multiple-windows-azure-active-directories.aspx). The section **Adding a new directory** will explain how to do this. You can also see [Set up your Office 365 development environment](https://msdn.microsoft.com/office/office365/howto/setup-development-environment#bk_CreateAzureSubscription) and the section **Associate your Office 365 account with Azure AD to create and manage apps** for more information.
   
   
* Client ID and redirect uri values of an application registered in Microsoft Azure (OneDrive for Business). To create the registration, see [register the CloudRoll App](https://github.com/OfficeDev/O365-iOS-CloudRoll/wiki/register-the-CloudRoll-app).

* A Client ID of an application registered in the Windows Live application management site (OneDrive). To create the registration, see [register the CloudRoll App](https://github.com/OfficeDev/O365-iOS-CloudRoll/wiki/register-the-CloudRoll-app).

## Running this sample using XCode

1. Clone this repository
2. Use CocoaPods to import the OneDrive dependency:
        
	     pod 'OneDriveSDK'

 	This sample app already contains a podfile that will get the OneDrive components (pods) into  the project. Simply navigate to the project From **Terminal** and run: 
        
        pod install
        
   	For more information, see **Using CocoaPods** in [Additional Resources](#AdditionalResources)
  
3. Open **O365-iOS-CloudRoll.xcworkspace**
4. Retrieve the Client ID and Redirect URI values you created for the Microsoft account registration and the organizational account registration as detailed in [register the CloudRoll App](https://github.com/OfficeDev/O365-iOS-CloudRoll/wiki/register-the-CloudRoll-app). Open **OneDriveManager.m**. You'll see that the **ClientID** and **RedirectUri** values can be added to the top of the file. Supply the necessary values here:

  		// You will set your application's clientId and redirect URI for Microsoft Account authentication (OneDrive)- Windows Live application management site
		NSString * const kMicrosoftAccountAppId         = @"ENTER_CLIENT_ID_HERE";
		NSString * const kMicrosoftAccountScopesString  = @"wl.signin,onedrive.readwrite,onedrive.appfolder,wl.offline_access";

		// You will set your application's clientId and redirect URI for organizational account authentication (OneDrive for Business) - Microsoft Azure
		NSString * const kActiveDirectoryAppId          = @"ENTER_CLIENT_ID_HERE";
		NSString * const kActiveDirectoryRedirectURL    = @"ENTER_REDIRECT_URI_HERE";
		NSString * const kActiveDirectoryScopesString   = @"MyFiles.readwrite";



5. Run the sample.

To learn more about the sample, visit our [understanding the code](https://github.com/OfficeDev/O365-iOS-CloudRoll/wiki/understanding-the-code) wiki page.



## Questions and comments

We'd love to get your feedback on the Office 365 iOS CloudRoll app. You can send your questions and suggestions to us in the [Issues](https://github.com/OfficeDev/O365-iOS-CloudRoll/issues) section of this repository.

Questions about Office 365 development in general should be posted to [Stack Overflow](http://stackoverflow.com/questions/tagged/Office365+API). Make sure that your questions or comments are tagged with [Office365] and [API].


## Additional resources

* [Office Dev Center](http://dev.office.com/)
* [Office 365 APIs platform overview](https://msdn.microsoft.com/office/office365/howto/platform-development-overview)
* [Getting started with Office 365 APIs](http://dev.office.com/getting-started/office365apis)
* [Using CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

## Copyright
Copyright (c) 2015 Microsoft. All rights reserved.
