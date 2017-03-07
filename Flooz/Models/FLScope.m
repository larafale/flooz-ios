//
//  FLScope.m
//  Flooz
//
//  Created by Olive on 28/02/2017.
//  Copyright © 2017 Flooz. All rights reserved.
//

#import "FLScope.h"

@implementation FLScope

- (id)initWithJSON:(NSDictionary *)json {
    self = [super init];
    if (self) {
        [self setJSON:json];
    }
    return self;
}

//@property (strong, nonatomic) FLScopeKey key;
//@property (strong, nonatomic) NSString *keyString;
//@property (strong, nonatomic) NSString *name;
//@property (strong, nonatomic) NSString *desc;
//@property (strong, nonatomic) NSString *imageURL;
//@property (strong, nonatomic) NSString *image;
//@property (strong, nonatomic) NSString *imageName;
//@property (strong, nonatomic) NSNumber *numLength;

- (void)setJSON:(NSDictionary*)jsonData {
    self.json = jsonData;
    if (jsonData) {
        
        self.keyString = jsonData[@"key"];
        self.key = [FLScope scopeKeyFromString:self.keyString];
        self.name = jsonData[@"name"];
        self.desc = jsonData[@"desc"];

        if (jsonData[@"imageURL"] && ((NSString *)jsonData[@"imageURL"]).length > 0) {
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:jsonData[@"imageURL"]] options:SDWebImageDownloaderHighPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                if (image)
                    self.image = image;
            }];
        } else if (jsonData[@"imageName"] && ((NSString *)jsonData[@"imageName"]).length > 0) {
            self.image = [UIImage imageNamed:jsonData[@"imageName"]];
        } else {
            NSString *imageName = nil;
            
            switch (self.key) {
                case FLScopeFriend:
                    imageName = @"transaction-scope-friend";
                    break;
                case FLScopePublic:
                    imageName = @"transaction-scope-public";
                    break;
                case FLScopePrivate:
                    imageName = @"transaction-scope-private";
                    break;
                default:
                    break;
            }
            
            self.image = [UIImage imageNamed:imageName];
        }
    }
}


+ (FLScope *)defaultScope:(FLScopeKey)scopeKey {
    switch (scopeKey) {
        case FLScopeFriend:
            return [FLScope scopeFromJSON:@{@"key": @"friend", @"name": [FLScope textFromKey:scopeKey], @"desc": [FLScope descFromKey:scopeKey forPot:NO]}];
        case FLScopePrivate:
            return [FLScope scopeFromJSON:@{@"key": @"private", @"name": [FLScope textFromKey:scopeKey], @"desc": [FLScope descFromKey:scopeKey forPot:NO]}];
        case FLScopePublic:
            return [FLScope scopeFromJSON:@{@"key": @"public", @"name": [FLScope textFromKey:scopeKey], @"desc": [FLScope descFromKey:scopeKey forPot:NO]}];
        case FLScopeAll:
            return [FLScope scopeFromJSON:@{@"key": @"all", @"name": [FLScope textFromKey:scopeKey], @"desc": [FLScope descFromKey:scopeKey forPot:NO]}];
        default:
            break;
    }
    return nil;
}

+ (FLScope *)scopeFromObject:(id)object {
    if ([object isKindOfClass:[NSNumber class]]) {
        return [FLScope scopeFromID:object];
    } else if ([object isKindOfClass:[NSString class]]) {
        return [FLScope scopeFromKey:object];
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        return [FLScope scopeFromJSON:object];
    }
    
    return nil;
}

+ (FLScope *)scopeFromJSON:(NSDictionary *)json {
    return [[FLScope alloc] initWithJSON:json];
}

+ (FLScope *)scopeFromID:(NSNumber *)scopeId {
    return [FLScope defaultScope:[FLScope scopeKeyFromID:scopeId]];
}

+ (FLScope *)scopeFromKey:(NSString *)keyString {
    return [FLScope defaultScope:[FLScope scopeKeyFromString:keyString]];
}

+ (FLScopeKey)scopeKeyFromID:(NSNumber *)scopeId {
    if (scopeId) {
        if ([scopeId isEqualToNumber:@0])
            return FLScopePublic;
        if ([scopeId isEqualToNumber:@01])
            return FLScopeFriend;
        if ([scopeId isEqualToNumber:@2])
            return FLScopePrivate;
        if ([scopeId isEqualToNumber:@3])
            return FLScopeAll;
    }
    return FLScopeNone;
}

+ (FLScopeKey)scopeKeyFromString:(NSString *)keyString {
    if (keyString) {
        if ([keyString isEqualToString:@"public"])
            return FLScopePublic;
        if ([keyString isEqualToString:@"friend"])
            return FLScopeFriend;
        if ([keyString isEqualToString:@"private"])
            return FLScopePrivate;
        if ([keyString isEqualToString:@"all"])
            return FLScopeAll;
    }
    return FLScopeNone;
}

+ (NSArray<FLScope *> *)defaultScopeList {
    return @[[FLScope defaultScope:FLScopePublic], [FLScope defaultScope:FLScopeFriend], [FLScope defaultScope:FLScopePrivate]];
}

+ (NSString *)textFromKey:(FLScopeKey)scopeKey {
    NSString *key = nil;
    
    switch (scopeKey) {
        case FLScopeFriend:
            key = @"FRIEND";
            break;
        case FLScopePrivate:
            key = @"PRIVATE";
            break;
        case FLScopePublic:
            key = @"PUBLIC";
            break;
        default:
            return @"";
    }

    return NSLocalizedString([@"TRANSACTION_SCOPE_" stringByAppendingString: key], nil);
}

+ (NSString *)descFromKey:(FLScopeKey)scopeKey forPot:(Boolean)isPot {
    NSString *key = nil;
    
    switch (scopeKey) {
        case FLScopeFriend:
            key = @"FRIEND";
            break;
        case FLScopePrivate:
            key = @"PRIVATE";
            break;
        case FLScopePublic:
            key = @"PUBLIC";
            break;
        default:
            return @"";
    }
    
    if (isPot)
        return NSLocalizedString([@"TRANSACTION_SCOPE_SUB_POT_" stringByAppendingString: key], nil);
    
    return NSLocalizedString([@"TRANSACTION_SCOPE_SUB_" stringByAppendingString: key], nil);
}

@end
