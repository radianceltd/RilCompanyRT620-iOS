#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AppDelegate.h"
#import "SceneDelegate.h"
#import "ViewController.h"
#import "DataHandler.h"
#import "UpgradeCode.h"
#import "UpgradeFileParser.h"
#import "UpgradeUtil.h"

FOUNDATION_EXPORT double cysmart_ota_updateVersionNumber;
FOUNDATION_EXPORT const unsigned char cysmart_ota_updateVersionString[];

