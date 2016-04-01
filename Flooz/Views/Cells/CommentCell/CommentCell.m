//
//  CommentCell.m
//  Flooz
//
//  Created by Olive on 3/15/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "CommentCell.h"

@interface CommentCell () {
    FLUserView *avatar;
    UILabel *content;
    UILabel *dateView;
}

@end

@implementation CommentCell

+ (CGFloat)getHeight:(FLComment *)comment {
    NSAttributedString *attributedText = [[NSAttributedString alloc]
                                          initWithString:comment.content
                                          attributes:@{ NSFontAttributeName: [UIFont customContentLight:13]}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize) {PPScreenWidth() - 65, CGFLOAT_MAX }
                                               options:NSLineBreakByClipping | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                               context:nil];
    
    if (rect.size.height + 18.0f < 35) {
        return 55.0f;
    }
    
    return rect.size.height + 38.0f;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createViews];
    }
    return self;
}

- (void)createViews {
    self.backgroundColor = [UIColor customBackgroundHeader];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    avatar = [[FLUserView alloc] initWithFrame:CGRectMake(10, 10, 35, 35)];
    [avatar setUserInteractionEnabled:true];
    
    [self addSubview:avatar];
    
    [avatar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentUserSelected:)]];
    
    CGFloat MARGE_LEFT = 35 + 20.;
    CGFloat WIDTH = PPScreenWidth() - MARGE_LEFT;
    
    content = [[UILabel alloc] initWithFrame:CGRectMake(MARGE_LEFT, 10, WIDTH, 0)];
    dateView = [[UILabel alloc] initWithFrame:CGRectMake(MARGE_LEFT, 0, WIDTH, 15)];
    
    content.font = [UIFont customContentLight:13];
    content.textColor = [UIColor whiteColor];
    content.numberOfLines = 0;
    
    dateView.textColor = [UIColor customPlaceholder];
    dateView.font = [UIFont customContentLight:10];
    
    CGRectSetHeight(content.frame, [content heightToFit] + 3); // + 3 car quand emoticone ca passe pas
    CGRectSetY(dateView.frame, CGRectGetMaxY(content.frame));
    
    [self addSubview:content];
    [self addSubview:dateView];
}

- (void)commentUserSelected:(UITapGestureRecognizer*)sender {
    FLUserView *tmp = (FLUserView *)sender.view;
    [appDelegate showUser:tmp.user inController:nil];
}

- (void)loadWithComment:(FLComment *)comment {
    [avatar setImageFromUser:comment.user];
    content.text = comment.content;
    dateView.text = [NSString stringWithFormat:@"@%@ - %@", [[comment user] username], [FLHelper momentWithDate:[comment date]]];
    
    CGRectSetHeight(content.frame, [content heightToFit] + 3); // + 3 car quand emoticone ca passe pas
    CGRectSetY(dateView.frame, CGRectGetMaxY(content.frame));
}

@end
