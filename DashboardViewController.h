/*
 * DashboardViewController.h
 * GlucoTrac
 *
 * Created by Mohammad Khan on 4/26/16.
 * Copyright © 2016 CoreHealth. All rights reserved.
 *
 * Abstract:
 * DashboardViewController is a subclass of UIViewController. The class
 * is responsible for displaying patient information as well as the patient's
 * most recent blood glucose reading from GlucoWatch.
 *
 */
 


#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <QuartzCore/QuartzCore.h>





@interface DashboardViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate>



/***************************** Property Declarations For CoreBluetooth *****************************/


/*!
 * @brief Used to manage discovered bluetooth devices.
 */
@property (nonatomic, strong) CBCentralManager *centralManager;



/*!
 * @brief Used to represent GlucoWatch (peripheral device)
 */
@property (nonatomic, strong) CBPeripheral     *glucoWatchPeripheral;




/************************************** Interface Builder Outlet  **********************************/


/*!
 * @brief Displays device information.
 */
@property (strong, nonatomic) IBOutlet UITextView *deviceInformation;
@property (strong, nonatomic) IBOutlet UILabel *bloodGlucoseLabel;



/****************************** Property Declarations For Device Data ******************************/


/*!
 * @brief Used to represent connection status.
 */
@property (nonatomic, strong) NSString   *isDeviceConnected;



/*!
 * @brief Used to represent device manufacturer.
 */
@property (nonatomic, strong) NSString   *deviceManufacturer;



/*!
 * @brief Used to represent device data.
 */
@property (nonatomic, strong) NSString   *glucoWatchDeviceData;



/*!
 * @brief Blood glucose value from the sensor.
 */
@property (assign) uint16_t bloodGlucoseValue;




/***************************** Property Declaration For Blood Glucose *****************************/



/*!
 * @brief This label will display the current blood glucose value.
 */
//@property (nonatomic, strong) UILabel  *bloodGlucoseLabel;




/**************************************** Instance Methods ***************************************/



/*!
 * @discussion Retrieves blood glucose information from gluco watch
 * @return The characteristic value related to blood glucose
 */
- (void) fetchBloodGlucoseCharacteristicData: (CBCharacteristic *) characteristic error: (NSError *) error;



/*!
 * @discussion Retrieves manufacturer name from gluco watch
 * @return The characteristic value related to manufacturer name
 */
- (void) fetchDeviceManufacturerName: (CBCharacteristic*) characteristic;


























@end

