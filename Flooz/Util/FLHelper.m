//
//  FLHelper.m
//  Flooz
//
//  Created by Olivier on 1/27/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLHelper.h"
#import "YLMoment.h"
#import "NBPhoneNumberUtil.h"

@implementation FLHelper

+ (NSString *)generateRandomString {
    const int randomStringLength = 16;
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:randomStringLength];
    
    for (int i = 0; i < randomStringLength; i++) {
        [randomString appendFormat:@"%C", [letters characterAtIndex:(arc4random() % [letters length])]];
    }
    
    return randomString;
}

+ (NSString *)formatedAmount:(NSNumber *)amount {
    return [self formatedAmount:amount withCurrency:YES withSymbol:YES];
}

+ (NSString *)formatedAmount:(NSNumber *)amount withCurrency:(BOOL)withCurrency {
    return [self formatedAmount:amount withCurrency:withCurrency withSymbol:YES];
}

+ (NSString *)formatedAmount:(NSNumber *)amount withSymbol:(BOOL)withSymbol {
    return [self formatedAmount:amount withCurrency:YES withSymbol:withSymbol];
}

+ (NSString *)formatedAmount:(NSNumber *)amount withCurrency:(BOOL)withCurrency withSymbol:(BOOL)withSymbol;
{
    static NSNumberFormatter *formatter = nil;
    static NSString *currency = nil;
    
    if (!formatter) {
        formatter = [NSNumberFormatter new];
        [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setGroupingSeparator:@""];
        [formatter setDecimalSeparator:@"."];
        [formatter setMinimumFractionDigits:0];
        [formatter setMaximumFractionDigits:2];
        
        currency = NSLocalizedString(@"GLOBAL_EURO", nil);
    }
    
    if (!amount) {
        return nil;
    }
    
    NSString *prefix = @"";
    NSString *suffix = @"";
    
    if (withSymbol) {
        if ([amount floatValue] > 0) {
            prefix = @"+ ";
        }
        else if ([amount floatValue] < 0) {
            prefix = @"- ";
        }
    } else if ([amount floatValue] < 0) {
        prefix = @"- ";
    }
    
    if (withCurrency) {
        suffix = [NSString stringWithFormat:@" %@", currency];
    }
    
    NSNumber *absoluteValue = [NSNumber numberWithFloat:fabsf([amount floatValue])];
    NSString *amountString = [formatter stringFromNumber:absoluteValue];
    
    // Si 1 seul chiffre apres la virguel
    NSRange rangeDot = [amountString rangeOfString:@"."];
    if (rangeDot.location == amountString.length - 2) {
        amountString = [amountString stringByAppendingString:@"0"];
    }
    
    return [NSString stringWithFormat:@"%@%@%@", prefix, amountString, suffix];
}

+ (NSString *)formatedDate:(NSDate *)date {
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"dd MMM 'à' HH:mm"];
    }
    
    if (date) {
        return [dateFormatter stringFromDate:date];
    }
    
    return nil;
}

+ (NSString *)hourInDate:(NSDate *)date {
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"HH:mm"];
    }
    
    if (date) {
        return [dateFormatter stringFromDate:date];
    }
    
    return nil;
}

+ (NSString *)momentWithDate:(NSDate *)date {
    NSString *momentForDate = @"";
    
    NSDate *day = [NSDate date];
    if ([date isEqualToDay:day]) {
        NSString *moment = [self momentWithDate:date compareToDate:day];
        if ([moment length]) {
            momentForDate = [NSString stringWithFormat:@"il y a %@", moment];
        }
        else {
            momentForDate = @"à l'instant";
        }
    }
    else {
        day = [[NSDate date] dateByAddingDays:-1];
        if ([date isEqualToDay:day]) {
            momentForDate = [NSString stringWithFormat:@"hier, %@", [FLHelper hourInDate:date]];
        }
        else {
            day = [[NSDate date] dateByAddingDays:-2];
            if ([date isEqualToDay:day]) {
                momentForDate = [NSString stringWithFormat:@"avant-hier, %@", [FLHelper hourInDate:date]];
            }
            else {
                momentForDate = [FLHelper formatedDate:date];
            }
        }
    }
    return momentForDate;
}

+ (NSString *)momentWithDate:(NSDate *)date compareToDate:(NSDate *)dateToCompare {
    // Compute the time interval
    double referenceTime = [dateToCompare timeIntervalSinceDate:date];
    double seconds       = round(fabs(referenceTime));
    double minutes       = trunc(seconds / 60.0f);
    double hours         = trunc(minutes / 60.0f);
    
    // Build the formatted string
    NSString *formattedString = @"";
    int unit                  = 0;
    if (seconds < 20) {
        formattedString = @"";
    }
    else if (seconds < 60) {
        formattedString = @"sec";
        unit = seconds;
        formattedString = [NSString stringWithFormat:@"%d %@", (int)unit, formattedString];
    }
    else if (minutes < 60) {
        formattedString = @"min";
        unit = minutes;
        formattedString = [NSString stringWithFormat:@"%d %@", (int)unit, formattedString];
    }
    else if (hours < 24) {
        formattedString = @"h";
        unit = hours;
        formattedString = [NSString stringWithFormat:@"%d %@", (int)unit, formattedString];
    }
    else {
        formattedString = [FLHelper formatedDate:date];
    }
    
    return formattedString;
}

+ (NSString *)formatedDateFromNow:(NSDate *)date {
    if (!date) {
        return nil;
    }
    
    YLMoment *moment = [YLMoment momentWithDate:date];
    return [moment fromNow];
}

+ (BOOL)phoneMatch:(NSString *)phone1 withPhone:(NSString *)phone2 {
    NSString *formatedPhone1 = [[[[[[phone1 stringByReplacingOccurrencesOfString:@" " withString:@""]
                                   stringByReplacingOccurrencesOfString:@" " withString:@""]
                                  stringByReplacingOccurrencesOfString:@"." withString:@""]
                                 stringByReplacingOccurrencesOfString:@"-" withString:@""]
                                stringByReplacingOccurrencesOfString:@")" withString:@""]
                               stringByReplacingOccurrencesOfString:@"(" withString:@""];

    NSString *formatedPhone2 = [[[[[[phone2 stringByReplacingOccurrencesOfString:@" " withString:@""]
                                   stringByReplacingOccurrencesOfString:@" " withString:@""]
                                  stringByReplacingOccurrencesOfString:@"." withString:@""]
                                 stringByReplacingOccurrencesOfString:@"-" withString:@""]
                                stringByReplacingOccurrencesOfString:@")" withString:@""]
                               stringByReplacingOccurrencesOfString:@"(" withString:@""];
    
    
    NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
    
    NSError *error1 = nil;
    NBPhoneNumber *number1 = [phoneUtil parse:formatedPhone1 defaultRegion:[Flooz sharedInstance].currentUser.country.code error:&error1];
    
    NSError *error2 = nil;
    NBPhoneNumber *number2 = [phoneUtil parse:formatedPhone2 defaultRegion:[Flooz sharedInstance].currentUser.country.code error:&error2];

    if (!error1 && !error2) {
        formatedPhone1 = [phoneUtil format:number1 numberFormat:NBEPhoneNumberFormatE164 error:&error1];
        formatedPhone2 = [phoneUtil format:number2 numberFormat:NBEPhoneNumberFormatE164 error:&error2];
        
        if (!error1 && !error2) {
            if ([formatedPhone1 rangeOfString:formatedPhone2].location != NSNotFound)
                 return YES;
        }
    }
    
    return NO;
}

+ (NSString *)formatedPhone:(NSString *)phone {
    
    NSString *formatedPhone = [[[[[[phone stringByReplacingOccurrencesOfString:@" " withString:@""]
                                   stringByReplacingOccurrencesOfString:@" " withString:@""]
                                  stringByReplacingOccurrencesOfString:@"." withString:@""]
                                 stringByReplacingOccurrencesOfString:@"-" withString:@""]
                                stringByReplacingOccurrencesOfString:@")" withString:@""]
                               stringByReplacingOccurrencesOfString:@"(" withString:@""];
    
    NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
    
    NSError *error = nil;
    NBPhoneNumber *number = [phoneUtil parse:formatedPhone defaultRegion:[Flooz sharedInstance].currentUser.country.code error:&error];
    
    if (!error) {
        formatedPhone = [phoneUtil format:number numberFormat:NBEPhoneNumberFormatE164 error:&error];
        return formatedPhone;
    }
    
    return nil;
}

+ (NSString *)castNumber:(NSUInteger)number {
    if (!number) {
        return @"";
    }
    
    if ((int)number == 0) {
        return @"";
    }
    
    return [FLHelper abbreviateNumber:(int)number];
}

+ (NSString *)abbreviateNumber:(int)num {
    
    NSString *abbrevNum;
    float number = (float)num;
    
    //Prevent numbers smaller than 1000 to return NULL
    if (num >= 1000) {
        NSArray *abbrev = @[@"K", @"M", @"B"];
        
        for (int i = (int)abbrev.count - 1; i >= 0; i--) {
            
            // Convert array index to "1000", "1000000", etc
            int size = pow(10,(i+1)*3);
            
            if(size <= number) {
                // Removed the round and dec to make sure small numbers are included like: 1.1K instead of 1K
                number = number/size;
                NSString *numberString = [FLHelper floatToString:number];
                
                // Add the letter for the abbreviation
                abbrevNum = [NSString stringWithFormat:@"%@%@", numberString, [abbrev objectAtIndex:i]];
            }
            
        }
    } else {
        abbrevNum = [NSString stringWithFormat:@"%02d", (int)number];
    }
    
    return abbrevNum;
}

+ (NSString *) floatToString:(float) val {
    NSString *ret = [NSString stringWithFormat:@"%.1f", val];
    unichar c = [ret characterAtIndex:[ret length] - 1];
    
    while (c == 48) { // 0
        ret = [ret substringToIndex:[ret length] - 1];
        c = [ret characterAtIndex:[ret length] - 1];
        
        //After finding the "." we know that everything left is the decimal number, so get a substring excluding the "."
        if (c == 46) { // .
            ret = [ret substringToIndex:[ret length] - 1];
        }
    }
    
    return ret;
}

+ (BOOL)isValidPhoneNumber:(NSString *)phone {
    NSString *formatedPhone = [[[[[[phone stringByReplacingOccurrencesOfString:@" " withString:@""]
                                   stringByReplacingOccurrencesOfString:@" " withString:@""]
                                  stringByReplacingOccurrencesOfString:@"." withString:@""]
                                 stringByReplacingOccurrencesOfString:@"-" withString:@""]
                                stringByReplacingOccurrencesOfString:@")" withString:@""]
                               stringByReplacingOccurrencesOfString:@"(" withString:@""];
    
    NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
    
    NSError *error = nil;
    NBPhoneNumber *number = [phoneUtil parse:formatedPhone defaultRegion:[Flooz sharedInstance].currentUser.country.code error:&error];
    
    if (!error) {
        return [phoneUtil isPossibleNumber:number error:nil] && [phoneUtil getNumberType:number] == NBEPhoneNumberTypeMOBILE;
    }
    
    return NO;
}

+ (NSString *)fullPhone:(NSString *)phone withCountry:(NSString *)country {
    NSString *formatedPhone = [[[[[[phone stringByReplacingOccurrencesOfString:@" " withString:@""]
                                   stringByReplacingOccurrencesOfString:@" " withString:@""]
                                  stringByReplacingOccurrencesOfString:@"." withString:@""]
                                 stringByReplacingOccurrencesOfString:@"-" withString:@""]
                                stringByReplacingOccurrencesOfString:@")" withString:@""]
                               stringByReplacingOccurrencesOfString:@"(" withString:@""];
    
    NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
    
    NSError *error = nil;
    NBPhoneNumber *number = [phoneUtil parse:formatedPhone defaultRegion:country error:&error];
    
    if (!error) {
        formatedPhone = [phoneUtil format:number numberFormat:NBEPhoneNumberFormatE164 error:&error];
        return formatedPhone;
    }
    
    return nil;
}

+ (UIImage *)colorImage:(UIImage *)image color:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextDrawImage(context, rect, image.CGImage);
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    [color setFill];
    CGContextFillRect(context, rect);
    
    
    UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return coloredImage;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (void)addMotionEffect:(UIView *)view {
    // Set vertical effect
    UIInterpolatingMotionEffect *verticalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.y"
     type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-20);
    verticalMotionEffect.maximumRelativeValue = @(20);
    
    // Set horizontal effect
    UIInterpolatingMotionEffect *horizontalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.x"
     type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-20);
    horizontalMotionEffect.maximumRelativeValue = @(20);
    
    // Create group to combine both
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    
    [view addMotionEffect:group];
}

+ (UIImage *)createNonInterpolatedUIImageFromCIImage:(CIImage *)image withScale:(CGFloat)scale {
    // Render the CIImage into a CGImage
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:image fromRect:image.extent];
    
    // Now we'll rescale using CoreGraphics
    UIGraphicsBeginImageContext(CGSizeMake(image.extent.size.width * scale, image.extent.size.width * scale));
    CGContextRef context = UIGraphicsGetCurrentContext();
    // We don't want to interpolate (since we've got a pixel-correct image)
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    // Get the image out
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // Tidy up
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    
    return scaledImage;
}

+ (CIImage *)createQRForString:(NSString *)qrString {
    // Need to convert the string to a UTF-8 encoded NSData object
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    
    // Create the filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // Set the message content and error-correction level
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    // Send the image back
    return qrFilter.outputImage;
}

@end
