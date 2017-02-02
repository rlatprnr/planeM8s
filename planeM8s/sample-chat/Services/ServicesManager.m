//
//  QBServiceManager.m
//  planeM8s
//
//  Created by Andrey Moskvin on 5/19/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "ServicesManager.h"
#import "_CDMessage.h"
#import <TWMessageBarManager/TWMessageBarManager.h>

@interface ServicesManager ()

@property (nonatomic, strong) QMContactListService* contactListService;

@end

@implementation ServicesManager

- (NSArray *)unsortedUsers
{
    return [self.usersService.usersMemoryStorage unsortedUsers];
}

- (instancetype)init {
	self = [super init];
    
	if (self) {
        _notificationService = [[NotificationService alloc] init];
	}
    
	return self;
}

- (void)chatServiceChatDidLogin
{
    for (QBChatDialog *dialog in [self.chatService.dialogsMemoryStorage unsortedDialogs]) {
        if (dialog.type == QBChatDialogTypeGroup && !dialog.isJoined) {
            // Joining to group chat dialogs.
            [self.chatService joinToGroupDialog:dialog completion:^(NSError * _Nullable error) {
                //
                if (error != nil) {
                    NSLog(@"Failed to join room with error: %@", error.localizedDescription);
                }
            }];
        }
    }
}

- (void)showNotificationForMessage:(QBChatMessage *)message inDialogID:(NSString *)dialogID
{
    if ([self.currentDialogID isEqualToString:dialogID]) return;
    
    if (message.senderID == self.currentUser.ID) return;
    
    NSString* dialogName = @"New message";
    
    QBChatDialog* dialog = [self.chatService.dialogsMemoryStorage chatDialogWithID:dialogID];
    
    if (dialog.type != QBChatDialogTypePrivate) {
        dialogName = dialog.name;
    } else {
        QBUUser* user = [self.usersService.usersMemoryStorage userWithID:dialog.recipientID];
        if (user != nil) {
            dialogName = user.login;
        }
    }
    
    [[TWMessageBarManager sharedInstance] hideAll];
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:dialogName description:message.text type:TWMessageBarMessageTypeInfo];
}

- (void)handleErrorResponse:(QBResponse *)response {
    
    [super handleErrorResponse:response];
    
    if (![self isAuthorized]) return;
	NSString *errorMessage = [[response.error description] stringByReplacingOccurrencesOfString:@"(" withString:@""];
	errorMessage = [errorMessage stringByReplacingOccurrencesOfString:@")" withString:@""];
	
	if( response.status == 502 ) { // bad gateway, server error
		errorMessage = @"Bad Gateway, please try again";
	}
	else if( response.status == 0 ) { // bad gateway, server error
		errorMessage = @"Connection network error, please try again";
	}
    
    [[TWMessageBarManager sharedInstance] hideAll];
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Errors" description:errorMessage type:TWMessageBarMessageTypeError];
}

- (void)downloadLatestUsersWithSuccessBlock:(void(^)(NSArray *latestUsers))successBlock errorBlock:(void(^)(NSError *error))errorBlock {
    
    //QBGeneralResponsePage *responsePage = [QBGeneralResponsePage responsePageWithCurrentPage:page perPage:pageSize];
    [QBRequest usersWithSuccessBlock:^(QBResponse * _Nonnull response, QBGeneralResponsePage * _Nullable page, NSArray<QBUUser *> * _Nullable users) {
       
        [self.usersService.usersMemoryStorage addUsers:users];
        
        NSMutableArray* mutableUsers = [users mutableCopy];
        [mutableUsers sortUsingComparator:^NSComparisonResult(QBUUser *obj1, QBUUser *obj2) {
            return [obj1.login compare:obj2.login options:NSNumericSearch];
        }];
        
        if (successBlock != nil) {
            successBlock([mutableUsers copy]);
        }
    } errorBlock:^(QBResponse * _Nonnull response) {
        errorBlock(response.error.error);
    }];
}

#pragma mark - dialogs utils

- (void)joinAllGroupDialogs {
    NSArray *dialogObjects = [self.chatService.dialogsMemoryStorage unsortedDialogs];
    for (QBChatDialog* dialog in dialogObjects) {
        if (dialog.type != QBChatDialogTypePrivate) {
            // Joining to group chat dialogs.
            [self.chatService joinToGroupDialog:dialog completion:^(NSError * _Nullable error) {
                //
                if (error != nil) {
                    NSLog(@"Failed to join room with error: %@", error.localizedDescription);
                }
            }];
        }
    }
}

#pragma mark - Last activity date

- (void)setLastActivityDate:(NSDate *)lastActivityDate
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:lastActivityDate forKey:kLastActivityDateKey];
    [defaults synchronize];
}

- (NSDate *)lastActivityDate
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:kLastActivityDateKey];
}

#pragma mark QMChatServiceCache delegate

- (void)chatService:(QMChatService *)chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    [super chatService:chatService didAddMessageToMemoryStorage:message forDialogID:dialogID];
    
    [self showNotificationForMessage:message inDialogID:dialogID];
}

@end
