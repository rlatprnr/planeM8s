//
//  MCTTableViewCell.h
//  iOS UI Test
//
//  Created by Paul Young on 14/07/2013.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MailCore/MailCore.h>

@interface MCTTableViewCell : UITableViewCell

@property (nonatomic, strong) MCOIMAPMessageRenderingOperation * messageRenderingOperation;
@property (weak, nonatomic) IBOutlet UILabel *lblSenderName;
@property (weak, nonatomic) IBOutlet UILabel *lblSubject;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UIImageView *flagImageView;

@end
