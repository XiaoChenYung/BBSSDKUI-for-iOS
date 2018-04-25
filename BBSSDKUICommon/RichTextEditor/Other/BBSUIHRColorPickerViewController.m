
#import "BBSUIHRColorPickerViewController.h"
#import "BBSUIHRColorPickerView.h"

@implementation BBSUIHRColorPickerViewController

@synthesize delegate;


+ (BBSUIHRColorPickerViewController *)colorPickerViewControllerWithColor:(UIColor *)color
{
    return [[BBSUIHRColorPickerViewController alloc] initWithColor:color fullColor:NO saveStyle:BBSUIHCPCSaveStyleSaveAlways];
}

+ (BBSUIHRColorPickerViewController *)cancelableColorPickerViewControllerWithColor:(UIColor *)color
{
    return [[BBSUIHRColorPickerViewController alloc] initWithColor:color fullColor:NO saveStyle:BBSUIHCPCSaveStyleSaveAndCancel];
}

+ (BBSUIHRColorPickerViewController *)fullColorPickerViewControllerWithColor:(UIColor *)color
{
    return [[BBSUIHRColorPickerViewController alloc] initWithColor:color fullColor:YES saveStyle:BBSUIHCPCSaveStyleSaveAlways];
}

+ (BBSUIHRColorPickerViewController *)cancelableFullColorPickerViewControllerWithColor:(UIColor *)color
{
    return [[BBSUIHRColorPickerViewController alloc] initWithColor:color fullColor:YES saveStyle:BBSUIHCPCSaveStyleSaveAndCancel];
}



- (id)initWithDefaultColor:(UIColor *)defaultColor
{
    return [self initWithColor:defaultColor fullColor:NO saveStyle:BBSUIHCPCSaveStyleSaveAlways];
}

- (id)initWithColor:(UIColor*)defaultColor fullColor:(BOOL)fullColor saveStyle:(BBSUIHCPCSaveStyle)saveStyle

{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _color = defaultColor;
        _fullColor = fullColor;
        _saveStyle = saveStyle;
    }
    return self;
}

- (void)loadView
{
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    frame.size.height -= 44.f;
    
    self.view = [[UIView alloc] initWithFrame:frame];
    
    BBSUIHRRGBColor rgbColor;
    RGBColorFromUIColor(_color, &rgbColor);
    
    BBSUIHRColorPickerStyle style;
    if (_fullColor) {
        style = [BBSUIHRColorPickerView fitScreenFullColorStyle];
    }else{
        style = [BBSUIHRColorPickerView fitScreenStyle];
    }
    
    colorPickerView = [[BBSUIHRColorPickerView alloc] initWithStyle:style defaultColor:rgbColor];
    
    [self.view addSubview:colorPickerView];
    
    if (_saveStyle == BBSUIHCPCSaveStyleSaveAndCancel) {
        UIBarButtonItem *buttonItem;
        
        buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
        self.navigationItem.leftBarButtonItem = buttonItem;
        
        buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
        self.navigationItem.rightBarButtonItem = buttonItem;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_saveStyle == BBSUIHCPCSaveStyleSaveAlways) {
        [self save:self];
    }
}

- (void)saveColor:(id)sender{
    [self save];
}

- (void)save
{
    if (self.delegate) {
        BBSUIHRRGBColor rgbColor = [colorPickerView RGBColor];
        [self.delegate setSelectedColor:[UIColor colorWithRed:rgbColor.r green:rgbColor.g blue:rgbColor.b alpha:1.0f] tag:self.tag];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)save:(id)sender
{
    [self save];
}

- (void)cancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
