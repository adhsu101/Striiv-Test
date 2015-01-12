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
    [self generateCSV];

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

}

- (void)generateDataArray
{

    self.arrayOfBinaryStrings = [NSMutableArray array];

    NSInteger totalBits = [self.binaryString length];
    NSInteger totalBytes = totalBits / 8;
    NSInteger totalSets = totalBytes / kBytesPerSequence;
    NSInteger bitsPerSequence = totalBits / totalSets;

    for (int x = 0; x < totalSets; x++)
    {
        NSInteger bitIndex = x * bitsPerSequence;
        NSInteger sequenceNumberLoc = bitIndex + kNumberOfBitsToSkip;
        NSInteger valueBitLoc = sequenceNumberLoc + kSequenceNumberBits;

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

-(void)generateCSV
{

    NSString *path = [self getCSVFilePath];
    [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];

    NSMutableString *writeString = [NSMutableString string];

    // header row
    [writeString appendString:@"x, y, z\n"];

    // convert binary data into decimal values with formatting
    int x = 0;
    int rowCount = 0;
    int sequenceNumber = [[self convertBinaryStringToDecimalString:self.arrayOfBinaryStrings.firstObject] intValue];

    for (NSString *binaryString in self.arrayOfBinaryStrings)
    {
        NSString *decimalString = [self convertBinaryStringToDecimalString:binaryString];

        if (binaryString.length == 16)
        {
            // sanity check
            if ([decimalString intValue] != sequenceNumber)
            {
                NSLog(@"Data integrity check failed");
                return;
            }
            sequenceNumber ++;

        }
        else
        {
            [writeString appendString:decimalString];
            x ++;
        }

        if (x == 3)
        {
            [writeString appendString:@"\n"];
            x = 0;
            rowCount ++;
        }
        else if (x != 0)
        {
            [writeString appendString:@", "];
        }

    }

    NSLog(@"%i rows found. Data integrity check passed.", rowCount);

    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath: [self getCSVFilePath]];
    [handle truncateFileAtOffset:[handle seekToEndOfFile]];
    [handle writeData:[writeString dataUsingEncoding:NSUTF8StringEncoding]];

    NSLog(@"Filepath: %@", [self getCSVFilePath]);

}

-(NSString *)getCSVFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"input.csv"];
}

- (NSString *)convertBinaryStringToDecimalString:(NSString *)binaryString
{
    BOOL isNeg = 0;

    // check for negative number
    if ([binaryString hasPrefix:@"1"])
    {
        isNeg = 1;

        // get bitwise complement
        NSMutableString *binaryStringComplement = [NSMutableString string];
        for (int i = 0; i < binaryString.length; i++)
        {
            if ([[binaryString substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"1"])
            {
                [binaryStringComplement appendString:@"0"];
            }
            else
            {
                [binaryStringComplement appendString:@"1"];
            }

        }

        binaryString = binaryStringComplement;
    }

    int totalValue = 0;
    for (int i = 0; i < binaryString.length; i++)
    {

        totalValue = totalValue + [[binaryString substringWithRange:NSMakeRange(binaryString.length - 1 - i, 1)] intValue] * pow(2, i);

    }

    if (isNeg)
    {
        totalValue = -(totalValue + isNeg);
    }

    return [NSString stringWithFormat:@"%i", totalValue];

}

@end




