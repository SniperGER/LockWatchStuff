//
//  CCColorDetailTableViewController.m
//  LockWatch
//
//  Created by Janik Schmidt on 25.01.16.
//  Copyright © 2016 Janik Schmidt. All rights reserved.
//

#import "CCColorDetailTableViewController.h"

@implementation CCColorDetailTableViewController
@synthesize bgColorHex, colorName;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = colorName;
    [self.tableView setBackgroundColor:[UIColor darkThemeBaseColor]];
    [self.tableView setSeparatorColor:[UIColor darkThemeSeparatorColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0 && indexPath.row == 0) {
        return 150.0;
    }
    // "Else"
    return 44;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"COLOR_PREVIEW", nil);
            break;
        case 1:
            sectionName = @"Hex";
            break;
        case 2:
            sectionName = @"RGB";
            break;
        case 3:
            sectionName = @"HSV";
            break;
        case 4:
            sectionName = @"CMYK";
            break;
        default:
            break;
    }
    return sectionName;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"colorDetailCell" forIndexPath:indexPath];
    
    // Configure the cell...
    [cell setBackgroundColor:[UIColor darkThemeCellColor]];
    switch ([indexPath section]) {
        case 0:
            cell.backgroundColor = [self colorFromHexString:bgColorHex];
            break;
        case 1:
            cell.textLabel.text = [bgColorHex uppercaseString];
            break;
        case 2:
            cell.textLabel.text = [self colorFromHexToRGB:bgColorHex];
            break;
        case 3:
            cell.textLabel.text = [self colorFromHexToHSV:bgColorHex];
            break;
        case 4:
            cell.textLabel.text = [self colorFromHexToCMYK:bgColorHex];
            break;
        default:
            break;
    }
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UIColor*) colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (NSString*)colorFromHexToRGB:(NSString*)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    
    return [NSString stringWithFormat:@"rgb(%u, %u, %u)", ((rgbValue & 0xFF0000) >> 16), ((rgbValue & 0xFF00) >> 8), (rgbValue & 0xFF)];
}
- (NSString*)colorFromHexToHSV:(NSString*)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    
    float r = ((rgbValue & 0xFF0000) >> 16);
    float g = ((rgbValue & 0xFF00) >> 8);
    float b = (rgbValue & 0xFF);
    
    float computedH = 0;
    float computedS = 0;
    float computedV = 0;
    
    r=r/255; g=g/255; b=b/255;
    
    float minRGB = MIN(r, MAX(g, b));
    float maxRGB = MAX(r, MAX(g, b));
    if (minRGB == maxRGB) {
        return [NSString stringWithFormat:@"hsl(0,0,%f)", maxRGB];
    }
    
    float d = (r==minRGB) ? g-b : ((b==minRGB) ? r-b : b-r);
    float h = (r==minRGB) ? 3 : ((b==minRGB) ? 1 : 5);
    computedH = 60*(h - d/(maxRGB - minRGB));
    computedS = (maxRGB - minRGB)/maxRGB;
    computedV = maxRGB;
    
    return [NSString stringWithFormat:@"hsl(%f, %f, %f)", computedH, computedS, computedV];
}
- (NSString*)colorFromHexToCMYK:(NSString*)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    
    float r = ((rgbValue & 0xFF0000) >> 16);
    float g = ((rgbValue & 0xFF00) >> 8);
    float b = (rgbValue & 0xFF);
    
    float computedC = 0;
    float computedM = 0;
    float computedY = 0;
    float computedK = 0;
    
    if (r == 0 && g == 0 && b == 0) {
        return [NSString stringWithFormat:@"cmyk(0, 0, 0, 0)"];
    }
    
    computedC = 1 - (r/255);
    computedM = 1 - (g/255);
    computedY = 1 - (b/255);
    
    float minCMY = MIN(computedC, MIN(computedM, computedY));
    
    computedC = (computedC - minCMY) / (1 - minCMY);
    computedM = (computedM - minCMY) / (1 - minCMY);
    computedY = (computedY - minCMY) / (1 - minCMY);
    computedK = minCMY;
    
    return [NSString stringWithFormat:@"cmyk(%f, %f, %f, %f)", computedC, computedM, computedY, computedK];
}
@end
