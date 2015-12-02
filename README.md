# Office 365 iOS CloudRoll



## Introduction

CloudRoll is a sample iOS app that demonstrates how to take a picture with your phone and send it to OneDrive without storing the image locally on the phone. This can be valuable if you're concerned about storage space, or, if you lose your phone, making sure confidential pictures are not lost with it.

![O365-iOS-CloudRoll](https://github.com/OfficeDev/O365-iOS-CloudRoll/blob/master/Images/cloudRoll.jpg)

This sample is built using the [OneDrive SDK for iOS](https://github.com/OneDrive/onedrive-sdk-ios). It shows the power and flexibility of using a unified OneDrive API in an app that can use both consumer and organizational accounts. 

- Authenticating multiple account types, including Microsoft accounts (outlook.com, hotmail.com), or an organizational account (Active Directory-based) to the OneDrive service in Office 365. In this sample you can log into both account types at the same time.
- Using the OneDrive API to upload a captured image to a CloudRoll app folder. 

We'll walk through the code in detail in the wiki.

## Prerequisites
* Install [Xcode](https://developer.apple.com/xcode/downloads/) from Apple
* Install [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)- as a dependency manager.
* An Office 365 account. You can sign up for [an Office 365 Developer subscription](https://portal.office.com/Signup/Signup.aspx?OfferId=6881A1CB-F4EB-4db3-9F18-388898DAF510&DL=DEVELOPERPACK&ali=1#0) that includes the resources that you need to start building Office 365 apps.

     > Note: If you already have a subscription, the previous link sends you to a page with the message *Sorry, you can’t add that to your current account*. In that case, use an account from your current Office 365 subscription.
* A Microsoft Azure Tenant to register your application. Azure Active Directory (AD) provides identity services that applications use for authentication and authorization. A trial subscription can be acquired here: [Microsoft Azure](https://account.windowsazure.com/SignUp).

     > Important: You'll also need to ensure your Azure subscription is bound to your Office 365 tenant. To do this, see the Active Directory team's blog post, [Creating and Managing Multiple Windows Azure Active Directories](http://blogs.technet.com/b/ad/archive/2013/11/08/creating-and-managing-multiple-windows-azure-active-directories.aspx). The section **Adding a new directory** will explain how to do this. You can also see [Set up your Office 365 development environment](https://msdn.microsoft.com/office/office365/howto/setup-development-environment#bk_CreateAzureSubscription) and the section **Associate your Office 365 account with Azure AD to create and manage apps** for more information.
   
   
* Client ID and redirect URI values of an application registered in Microsoft Azure (OneDrive for Business). To create the registration, see [register the CloudRoll App](https://github.com/OfficeDev/O365-iOS-CloudRoll/wiki/register-the-CloudRoll-app).

* A Client ID of an application registered in the Windows Live application management site (OneDrive). To create the registration, see [register the CloudRoll App](https://github.com/OfficeDev/O365-iOS-CloudRoll/wiki/register-the-CloudRoll-app).

## Running this sample using Xcode

1. Clone this repository
2. Use CocoaPods to import the OneDrive dependency:
        
	     pod 'OneDriveSDK'

 	This sample app already contains a podfile that will get the OneDrive components (pods) into  the project. Simply navigate to the project from **Terminal** and run: 
        
        pod install
        
   	For more information, see **Using CocoaPods** in [Additional Resources](#AdditionalResources)
  
3. Open **O365-iOS-CloudRoll.xcworkspace**
4. Retrieve the Client ID and Redirect URI values you created for the Microsoft account registration and the organizational account registration as detailed in [register the CloudRoll App](https://github.com/OfficeDev/O365-iOS-CloudRoll/wiki/register-the-CloudRoll-app). Open **OneDriveManager.m**. You'll see that the **ClientID** and **RedirectUri** values can be added to the top of the file. Supply the necessary values here:

  		// You'll set your application's clientId and redirect URI for Microsoft account authentication (OneDrive)- Microsoft account Developer Center site
		NSString * const kMicrosoftAccountAppId         = @"ENTER_CLIENT_ID_HERE";
		NSString * const kMicrosoftAccountScopesString  = @"wl.signin,onedrive.readwrite,onedrive.appfolder,wl.offline_access";

		// You'll set your application's clientId and redirect URI for organizational account authentication (OneDrive for Business) - Microsoft Azure
		NSString * const kActiveDirectoryAppId          = @"ENTER_CLIENT_ID_HERE";
		NSString * const kActiveDirectoryRedirectURL    = @"ENTER_REDIRECT_URI_HERE";
		NSString * const kActiveDirectoryScopesString   = @"MyFiles.readwrite";



5. Run the sample.

To learn more about the sample, visit our [understanding the code](https://github.com/OfficeDev/O365-iOS-CloudRoll/wiki/understand-the-code) wiki page.



## Questions and comments

We'd love to get your feedback about the Office 365 iOS CloudRoll app. You can send your questions and suggestions to us in the [Issues](https://github.com/OfficeDev/O365-iOS-CloudRoll/issues) section of this repository.

Questions about Office 365 development in general should be posted to [Stack Overflow](http://stackoverflow.com/questions/tagged/Office365+API). Make sure that your questions or comments are tagged with [Office365] and [API].


## Contributing
You will need to sign a [Contributor License Agreement](https://cla.microsoft.com/) before submitting your pull request. To complete the Contributor License Agreement (CLA), you will need to submit a request via the form and then electronically sign the CLA when you receive the email containing the link to the document. 


## Additional resources

* [Office Dev Center](http://dev.office.com/)
* [OneDrive SDK for iOS](https://github.com/OneDrive/onedrive-sdk-ios)
* [O365-iOS-Unified-API-Connect](https://github.com/OfficeDev/O365-iOS-Unified-API-Connect)
* [O365-iOS-Unified-API-Snippets](https://github.com/OfficeDev/O365-iOS-Unified-API-Snippets)
* [Develop with the OneDrive API](https://dev.onedrive.com/README.htm)
* [Office 365 APIs platform overview](https://msdn.microsoft.com/office/office365/howto/platform-development-overview)
* [Getting started with Office 365 APIs](http://dev.office.com/getting-started/office365apis)
* [Using CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

## Copyright
Copyright (c) 2015 Microsoft. All rights reserved.
