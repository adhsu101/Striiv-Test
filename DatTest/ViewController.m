//
//  ViewController.m
//  DatTest
//
//  Created by Mobile Making on 1/11/15.
//  Copyright (c) 2015 Alex Hsu. All rights reserved.
//

#import "ViewController.h"

#define kBytesPerSequence 22
#define kNumberOfBitsToSkip 16
#define kSequenceNumberBits 16
#define kValueNumberOfBits 12

@interface ViewController ()

@property NSMutableString *binaryString;
@property NSMutableArray *arrayOfBinaryStrings;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self loadInput];
    [self generateDataArray];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)loadInput
{

    NSString *path = [[NSBundle mainBundle] pathForResource:@"input"
                                                     ofType:@"dat"];
    NSData *inputData = [NSData dataWithContentsOfFile:path];

    const uint8_t *bytes = [inputData bytes];

    NSInteger length = [inputData length];
//
//    Byte *byteData = (Byte *)malloc(length);
//
//    memcpy(byteData, bytes, length);

    self.binaryString = [NSMutableString string];

    for (int x = 0; x < length; x++)
    {
        [self getBitStringForInt:(uint8_t)bytes[x]];
    }

}

- (void)getBitStringForInt:(int)value
{
    NSString *bits = @"";
    for(int i = 0; i < 8; i ++)
    {
        bits = [NSString stringWithFormat:@"%i%@", value & (1 << i) ? 1 : 0, bits];
    }

    [self.binaryString appendString:bits];

//    NSLog(@"%@", bits);
}

- (void)generateDataArray
{

    self.arrayOfBinaryStrings = [NSMutableArray array];

    NSUInteger totalBits = [self.binaryString length];
    NSUInteger totalBytes = totalBits / 8;
    NSUInteger totalSets = totalBytes / kBytesPerSequence;
    NSUInteger bitsPerSequence = totalBits / totalSets;

    for (int x = 0; x < totalSets; x++)
    {
        NSUInteger bitIndex = x * bitsPerSequence;
        NSUInteger sequenceNumberLoc = bitIndex + kNumberOfBitsToSkip;
        NSUInteger valueBitLoc = sequenceNumberLoc + kSequenceNumberBits;

        // range of sequence number
        NSRange sequenceNumberBitRange = NSMakeRange(sequenceNumberLoc, kSequenceNumberBits);

        [self.arrayOfBinaryStrings addObject:[self.binaryString substringWithRange:sequenceNumberBitRange]];

        // 4 sets of 3 values
        for (int i = 0; i < 12; i++)
        {
            NSRange valueBitRange = NSMakeRange(valueBitLoc, kValueNumberOfBits);

            [self.arrayOfBinaryStrings addObject:[self.binaryString substringWithRange:valueBitRange]];

            valueBitLoc = valueBitLoc + kValueNumberOfBits;
            
        }

    }

}

-(void)convertBinaryString:(NSString *)string
{

    // check for negative number
    

}

+ (NSNumber *)convertBinaryStringToDecimalNumber:(NSString *)binaryString {
    NSUInteger totalValue = 0;
    for (int i = 0; i < binaryString.length; i++) {
        totalValue += (int)([binaryString characterAtIndex:(binaryString.length - 1 - i)] - 48) * pow(2, i);
    }
    return @(totalValue);
}
@end
