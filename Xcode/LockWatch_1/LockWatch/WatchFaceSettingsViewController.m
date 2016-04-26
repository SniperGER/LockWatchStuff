//
//  WatchFaceSettingsViewController.m
//  LockWatch_Test
//
//  Created by Janik Schmidt on 17.11.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import "WatchFaceSettingsViewController.h"

@interface WatchFaceSettingsViewController ()

@end

@implementation WatchFaceSettingsViewController



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = NSLocalizedString(@"SETTINGS_WATCHFACES", nil);
    
    [self loadPlugins];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    switches = [[NSMutableArray alloc] initWithCapacity:5];
    labels = [[NSMutableArray alloc] initWithCapacity:5];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)loadPlugins {
    stockWatchFacePlugins = [[NSMutableArray alloc] init];
    watchFacePlugins = [[NSMutableArray alloc] init];
    
    
    //NSString* pluginLocationString = @"/Library/Application Support/LockWatch/Watch Faces/";
    NSString* pluginLocationString = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/PlugIns/"];
    
    NSURL* pluginLocation = [NSURL fileURLWithPath:pluginLocationString];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:pluginLocation includingPropertiesForKeys:@[NSFileType] options:(NSDirectoryEnumerationOptions)0 error:NULL];
    
    NSArray* defaultPlugins = [[NSArray alloc] initWithObjects:@"Simple.watchface", @"Color.watchface", @"Weather.watchface", @"Chronograph.watchface", @"X-Large.watchface", @"Mickey.watchface", nil];
    
    
    if ([contents count] < 1) {
        NSLog(@"No plugins found");
    }
    
    [defaultPlugins enumerateObjectsUsingBlock:^(id defaultPlugin, NSUInteger i, BOOL* stop) {
        NSURL* filePath = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", pluginLocationString, defaultPlugin]];
        NSBundle* plugin = [[NSBundle alloc] initWithURL:filePath];
        
        BOOL loaded = [plugin load];
        if (loaded) {
            [stockWatchFacePlugins addObject:plugin];
        }
    }];
    
    [contents enumerateObjectsUsingBlock:^ (NSURL *fileURL, NSUInteger idx, BOOL *stop) {
        NSString *fileType = [fileURL resourceValuesForKeys:@[NSURLTypeIdentifierKey] error:NULL][NSURLTypeIdentifierKey];
        if (fileType == nil) {
            return;
        }
        
        NSBundle *plugin = [[NSBundle alloc] initWithURL:fileURL];
        
        NSString *pluginIdentifier = [plugin bundleIdentifier];
        if (pluginIdentifier == nil) {
            NSLog(@"The plugin bundle identifier couldn\u2019t be retrieved.");
            return;
        }
        
        if ([pluginIdentifier isEqualToString:@"de.sniperger.watchface.simple"] ||
            [pluginIdentifier isEqualToString:@"de.sniperger.watchface.color"] ||
            [pluginIdentifier isEqualToString:@"de.sniperger.watchface.weather"] ||
            [pluginIdentifier isEqualToString:@"de.sniperger.watchface.chrono"] ||
            [pluginIdentifier isEqualToString:@"de.sniperger.watchface.xlarge"] ||
            [pluginIdentifier isEqualToString:@"de.sniperger.watchface.mouse"]) {
            return;
        }
        
        BOOL loaded = [plugin load];
        if (!loaded) {
            NSLog(@"The plugin couln't be loaded");
            return;
        }
        
        Class pluginClass = [plugin principalClass];
        if (pluginClass == nil) {
            NSLog(@"The plugin principal class couldn\u2019t be retrieved.");
            return;
        }
        
        [watchFacePlugins addObject:plugin];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.separatorColor = [UIColor colorWithRed:41.0/255.0 green:41.0/255.0 blue:41.0/255.0 alpha:1];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    static NSString *CellIdentifier = @"Cell";
    
    // Reuse/create cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor colorWithRed:28.0/255.0 green:28.0/255.0 blue:29.9/255.0 alpha:1];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *selected = [[UIView alloc] initWithFrame:cell.frame];
        selected.backgroundColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1];
        cell.selectedBackgroundView = selected;
        
        if ([indexPath section] == 0) {
            if ([stockWatchFacePlugins count] > 0) {
                NSBundle* plugin = [stockWatchFacePlugins objectAtIndex:[indexPath row]];
                if ([plugin localizedInfoDictionary]) {
                    [[cell textLabel] setText:[NSString stringWithFormat:@"%@", [plugin localizedInfoDictionary][@"CFBundleDisplayName"]]];
                } else {
                    [[cell textLabel] setText:[NSString stringWithFormat:@"%@", [plugin infoDictionary][@"CFBundleDisplayName"]]];
                }
                
                UISwitch* s = [[UISwitch alloc] init];
                CGSize switchSize = [s sizeThatFits:CGSizeZero];
                s.frame = CGRectMake(cell.contentView.bounds.size.width - switchSize.width - 5.0f,
                                     (cell.contentView.bounds.size.height - switchSize.height) / 2.0f,
                                     switchSize.width,
                                     switchSize.height);
                s.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
                s.tag = [indexPath row];
                switch ([indexPath row]) {
                    case 0:
                        s.on = [defaults boolForKey:@"renderSimpleWatchFace"];
                        break;
                    case 1:
                        s.on = [defaults boolForKey:@"renderColorWatchFace"];
                        break;
                    case 2:
                        s.on = [defaults boolForKey:@"renderWeatherWatchFace"];
                        break;
                    case 3:
                        s.on = [defaults boolForKey:@"renderChronoWatchFace"];
                        break;
                    case 4:
                        s.on = [defaults boolForKey:@"renderXLargeWatchFace"];
                        break;
                    default:
                        s.on = YES;
                        break;
                }
                [s addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
                cell.accessoryView = s;
            } else {
                cell.textLabel.text = NSLocalizedString(@"SETTINGS_WATCHFACES_NO_STOCK", nil);
                cell.textLabel.enabled = NO;
            }
        } else if ([indexPath section] == 1) {
            if ([watchFacePlugins count] > 0) {
                NSBundle* plugin = [watchFacePlugins objectAtIndex:[indexPath row]];
                if ([plugin localizedInfoDictionary]) {
                    [[cell textLabel] setText:[NSString stringWithFormat:@"%@", [plugin localizedInfoDictionary][@"CFBundleDisplayName"]]];
                } else {
                    [[cell textLabel] setText:[NSString stringWithFormat:@"%@", [plugin infoDictionary][@"CFBundleDisplayName"]]];
                }
            } else {
                cell.textLabel.text = NSLocalizedString(@"SETTINGS_WATCHFACES_NO_EXTERNAL", nil);
                cell.textLabel.enabled = NO;
            }
        }
    }
    
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            if ([stockWatchFacePlugins count] > 0) {
                return [stockWatchFacePlugins count];
            } else {
                return 1;
            }
            break;
        case 1:
            if ([watchFacePlugins count] > 0) {
                return [watchFacePlugins count];
            } else {
                return 1;
            }
        default:
            break;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"SETTINGS_WATCHFACES_STOCK", nil);
            break;
        case 1:
            sectionName = NSLocalizedString(@"SETTINGS_WATCHFACES_EXTERNAL", nil);
        default:
            break;
    }
    return sectionName;
}
- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSString *sectionName;
    switch (section)
    {
        case 1:
            sectionName = NSLocalizedString(@"SETTINGS_WATCHFACES_AVAILABLE_FOOTER", nil);
            break;
        default:
            break;
    }
    return sectionName;
}

- (void)switchChanged:(id)sender {
    UISwitch* tappedSwitch = (UISwitch*)sender;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    BOOL switchIsOn = [tappedSwitch isOn];
    switch ([sender tag]) {
        case 0:
            [defaults setBool:switchIsOn forKey:@"renderSimpleWatchFace"];
            break;
        case 1:
            [defaults setBool:switchIsOn forKey:@"renderColorWatchFace"];
            break;
        case 2:
            [defaults setBool:switchIsOn forKey:@"renderWeatherWatchFace"];
            break;
        case 3:
            [defaults setBool:switchIsOn forKey:@"renderChronoWatchFace"];
            break;
        case 4:
            [defaults setBool:switchIsOn forKey:@"renderXLargeWatchFace"];
            break;
        default:
            break;
    }
    
    int disabledCount = 0;
    for (int i=0; i<[switches count]; i++) {
        UISwitch* currentSwitch = [switches objectAtIndex:i];
        if (!currentSwitch.on) {
            disabledCount++;
        }
    }
    if (disabledCount == 4) {
        for (int i=0; i<[switches count]; i++) {
            UISwitch* currentSwitch = [switches objectAtIndex:i];
            if (currentSwitch.on) {
                currentSwitch.enabled = NO;
                [[labels objectAtIndex:i] setEnabled:NO];
            }
        }
    } else {
        for (int i=0; i<[switches count]; i++) {
            UISwitch* currentSwitch = [switches objectAtIndex:i];
            currentSwitch.enabled = YES;
            [[labels objectAtIndex:i] setEnabled:YES];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"settingsChanged" object:self userInfo:nil];
}

- (IBAction)startEditing:(id)sender {
    self.editing = YES;
}

@end
