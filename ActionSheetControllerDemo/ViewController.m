//
//  ViewController.m
//  ActionSheetControllerDemo
//
//  Created by Geddam Subramanyam, Jeevan Kumar on 11/30/15.
//  Copyright © 2015 Honeywell. All rights reserved.
//

#import "ViewController.h"
#import "LCHActionViewController.h"

@interface ViewController ()<UIViewControllerTransitioningDelegate>

@property UIButton *actionSheetButton;
@property UIBarButtonItem *barButtonItem;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"Hello";
    self.view.backgroundColor = [UIColor greenColor];
    
    self.actionSheetButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 100, 100, 50)];
    [self.actionSheetButton setTitle:@"ActionSheet" forState:UIControlStateNormal];
    [self.view addSubview:self.actionSheetButton];
    
    [self.actionSheetButton addTarget:self action:@selector(actionSheetButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    self.barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(actionSheetButtonTapped1:)];
    self.navigationItem.rightBarButtonItem = self.barButtonItem;
}

- (void) actionSheetButtonTapped1:(id)sender{
    LCHActionViewController *actionViewController = [LCHActionViewController initWithTitle:nil message:nil]; //@"A very very very long message has to be displayed here in order to test the character limit"
    actionViewController.backgroundTapDismissalGestureEnabled = YES;
    actionViewController.separatorColor = [UIColor grayColor];
    
    LCHActionItem *actionItem = [LCHActionItem actionWithTitle:@"Test" image:nil style:LCHActionStyleDefault handler:^(LCHActionItem *action) {
        NSLog(@"Action item  is selected");
    }];
    [actionViewController addAction:actionItem];
    
    LCHActionItem *actionItem2 = [LCHActionItem actionWithTitle:@"Create new schedule" image:[UIImage imageNamed:@"notification_batteries"] style:LCHActionStyleDefault handler:^(LCHActionItem *action) {
        NSLog(@"Create new schedule is selected");
    }];
    [actionViewController addAction:actionItem2];
    
    LCHActionItem *actionItem3 = [LCHActionItem actionWithTitle:@"Cancel" image:nil style:LCHActionStyleCancel handler:^(LCHActionItem *action) {
        NSLog(@"Cancel button selected");
    }];
    [actionViewController addAction:actionItem3];
    [self presentViewController:actionViewController animated:YES completion:nil];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        UIPopoverPresentationController *popOverPresentationController = actionViewController.popoverPresentationController;
        popOverPresentationController.barButtonItem = self.barButtonItem;
    }
}

- (void)actionSheetButtonTapped{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Title" message:@"A very long message has to go here" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"Create new schedule" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"The create new schedule has been selected");
    }];
    [alertController addAction:alertAction];
    
    UIAlertAction *alertAction2 = [UIAlertAction actionWithTitle:@"Switch to saved schedule" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"The switch to new schedule has been selected");
    }];
    [alertController addAction:alertAction2];
    
    UIAlertAction *alertAction3 = [UIAlertAction actionWithTitle:@"Pause Schedule" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"The pause schedule has been selected");
    }];
    [alertController addAction:alertAction3];
    
    UIAlertAction *alertAction4 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"The cancel button has been selected");
        [self dismissViewControllerAnimated:alertController completion:nil];
    }];
    [alertController addAction:alertAction4];
    
    
    //[alertAction setValue:[[UIImage imageNamed:@"notification_airfilter"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]  forKey:@"image"];
    
    //[alertAction2 setValue:[[UIImage imageNamed:@"notification_alert"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    
    //[alertAction3 setValue:[[UIImage imageNamed:@"notification_batteries"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    
    alertController.view.tintColor = [UIColor blackColor];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        alertController.popoverPresentationController.barButtonItem = self.barButtonItem;
        alertController.popoverPresentationController.sourceView   = self.view;
    }
    
    //alertController.popoverPresentationController.so
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
