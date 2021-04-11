// RCTCalendarModule.m
#import "RCTCalendarModule.h"
#import <React/RCTLog.h>
#import <PayFortSDK/PayFortSDK.h>
 
 @implementation RCTCalendarModule{
   RCTResponseSenderBlock onDoneClick;
     RCTResponseSenderBlock onCancelClick;
     NSDictionary *data;
     PayFortController *payfort;
     UIViewController *rootViewController;
     NSString *udidString;
     BOOL asyncSuccessful;
     NSString *signatureString;Ï
 }

 // To export a module named RCTCalendarModule
 RCT_EXPORT_MODULE();



 //open payfort
 RCT_EXPORT_METHOD(openPayfort:(NSDictionary *)indic createDialog:(RCTResponseSenderBlock)doneCallback createDialog:(RCTResponseSenderBlock)cancelCallback) {
   onDoneClick = doneCallback;
   onCancelClick = cancelCallback;
 
   udidString = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
 
   dispatch_async(dispatch_get_main_queue(), ^{
     data = [[NSDictionary alloc] initWithDictionary:indic];
     rootViewController = (UIViewController*)[UIApplication sharedApplication].delegate.window.rootViewController;
     NSString *sdk_token = @"";
     [self openPayfort:sdk_token];
 
   });
 }
 
 //get info amount, currency,... from react native. After open Payfort for payment
 - (void)openPayfort:(NSString *)sdkToken{
   NSMutableDictionary *request = [[NSMutableDictionary alloc]init];
 
   if (data[@"amount"]) {
     [request setValue:data[@"amount"] forKey:@"amount"];
   }
   if (data[@"currency"]) {
     [request setValue:data[@"currency"] forKey:@"currency"];
   }
   if (data[@"customer_email"]) {
     [request setValue:data[@"customer_email"] forKey:@"customer_email"];
   }
   if (data[@"customer_name"]) {
     [request setValue:data[@"customer_name"] forKey:@"customer_name"];
   }
 
   if (data[@"merchant_reference"]) {
     [request setValue:data[@"merchant_reference"] forKey:@"merchant_reference"];
   }
 
   if (data[@"language"]) {
     [request setValue:data[@"language"] forKey:@"language"];
   }else{
     [request setValue:@"en" forKey:@"language"];
   }
 
   if (data[@"sdk_token"]) {
     [request setValue:data[@"sdk_token"] forKey:@"sdk_token"];
   }
 
   if (data[@"payment_option"]) {
     [request setValue:data[@"payment_option"] forKey:@"payment_option"];
   }else{
     [request setValue:@"" forKey:@"payment_option"];
   }
 
   [request setValue:@"PURCHASE" forKey:@"command"];
   [request setValue:@"ECOMMERCE" forKey:@"eci"];
 
   dispatch_async(dispatch_get_main_queue(), ^{
 
     if ([data[@"is_live"] isEqualToString:@"1"]) {
       payfort = [[PayFortController alloc] initWithEnviroment:KPayFortEnviromentProduction];
     }else{
       payfort = [[PayFortController alloc] initWithEnviroment:KPayFortEnviromentSandBox];
     }
     payfort.IsShowResponsePage = true;
 
     NSArray *events = @[];
     [payfort callPayFortWithRequest:request currentViewController:rootViewController
                             Success:^(NSDictionary *requestDic, NSDictionary *responeDic) {
                               //                              NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:responeDic];
                               //                              [dic setValue:signatureString forKey:@"signature"];
 
                               onDoneClick(@[responeDic, events]);
                             }
                            Canceled:^(NSDictionary *requestDic, NSDictionary *responeDic) {
                              onCancelClick(@[@"cancel", events]);
                            }
                               Faild:^(NSDictionary *requestDic, NSDictionary *responeDic, NSString *message) {
                                 onCancelClick(@[message, events]);
                               }];
   });
 }
 
 @end

