//
//  DocumentsViewController.m
//  Flooz
//
//  Created by jonathan on 2014-03-13.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "DocumentsViewController.h"

#import "AppDelegate.h"

@interface DocumentsViewController (){
    NSArray *documents;
    NSUInteger currentDocumentIndex;
}

@end

@implementation DocumentsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"NAV_DOCUMENTS", nil);
        documents = @[
                      @{ @"CARD_ID_RECTO": @"cniRecto" },
                      @{ @"CARD_ID_VERSO": @"cniVerso" },
                      @{ @"HOME": @"justificatory" }
                      ];
        
        currentDocumentIndex = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Evite barre blanche pendant animation
    self.view.backgroundColor = [UIColor customBackground];
}

#pragma mark - TableView

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (CGFloat)tableView:(FLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 53.;
}

- (UITableViewCell *)tableView:(FLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"DocumentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        cell.backgroundColor = [UIColor customBackground];
        cell.textLabel.font = [UIFont customTitleExtraLight:16];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSString *key = [NSString stringWithFormat:@"DOCUMENTS_%@", [[[documents objectAtIndex:indexPath.row] allKeys] firstObject]];
    cell.textLabel.text = NSLocalizedString(key, nil);
    
    if([[[[[Flooz sharedInstance] currentUser] checkDocuments] objectForKey:key] boolValue]){
        cell.accessoryView = [UIImageView imageNamed:@"document-check"];
    }
    else{
        cell.accessoryView = [UIImageView imageNamed:@"arrow-white-right"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    currentDocumentIndex = indexPath.row;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"GLOBAL_CAMERA", nil), NSLocalizedString(@"GLOBAL_ALBUMS", nil), nil];
    
    [actionSheet showInView:self.view];
}

#pragma mark - ImagePicker

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *cameraUI = [UIImagePickerController new];
    
    if(buttonIndex == 0){
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO){
            DISPLAY_ERROR(FLCameraAccessDenyError);
            return;
        }
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    }else if(buttonIndex == 1){
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO){
            DISPLAY_ERROR(FLAlbumsAccessDenyError);
            return;
        }
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }else{
        return;
    }
    
    cameraUI.delegate = self;
    
    [self presentViewController:cameraUI animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *originalImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *resizedImage = [originalImage resize:CGSizeMake(640, 0)];
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.7);
    
    NSString *key = [[[documents objectAtIndex:currentDocumentIndex] allValues] firstObject];
        
    [picker dismissViewControllerAnimated:YES completion:^{
        [[Flooz sharedInstance] showLoadView];
        [[Flooz sharedInstance] uploadDocument:imageData field:key success:^{
            [_tableView reloadData];
        } failure:NULL];
    }];
}


@end
