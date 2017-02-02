//
//  LoginViewController.m
//
//  Created by bb on 11/25/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "LoginViewController.h"
#import "ServicesManager.h"
#import "ProfileViewController.h"
#import "IQKeyboardManager.h"

@interface LoginViewController ()
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([ServicesManager instance].currentUser) {
        [SVProgressHUD show];
        [[ServicesManager instance] logoutWithCompletion:^{
            [SVProgressHUD dismiss];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)clickLogin:(id)sender {
    
    NSString *username = [self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([username isEqualToString:@""]) {
        [SVProgressHUD showInfoWithStatus:@"Please enter username"];
        return;
    }
    [SVProgressHUD showWithStatus:@"Logging in..."];
    
    QBUUser *user = [QBUUser user];
    user.login = username;
    user.password = self.passwordTextField.text;
    
    __weak __typeof(self)weakSelf = self;
    [ServicesManager.instance logInWithUser:user completion:^(BOOL success, NSString *errorMessage) {
        if (success) {
            UIViewController *welcomeController = [self.storyboard instantiateViewControllerWithIdentifier:kWelcomeControllerIdentifier];
            weakSelf.view.window.rootViewController = welcomeController;
        } else {
            [SVProgressHUD showErrorWithStatus:@"Can not login"];
        }
    }];
}

- (IBAction)clickSignup:(id)sender {
    ProfileViewController *profileViewController = [self.storyboard instantiateViewControllerWithIdentifier:cProfileViewController];
    [self presentViewController:profileViewController animated:YES completion:nil];
}

@end
