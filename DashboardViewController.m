/*
 * DashboardViewController.m
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



#import "DashboardViewController.h"
#import "UUIDDefines.h"



@interface DashboardViewController ()

@end




@implementation DashboardViewController


/******************************** View Setup Methods ********************************/





/* Called after the controller's view is loaded into memory. */
- (void) viewDidLoad {
   
   
   /* Initializing device data */
   self.glucoWatchDeviceData = nil;
   
   
   /* Setting properties for the text view */
   [self.deviceInformation setText:@"GlucoWatch Not Connected"];
   [self.deviceInformation setUserInteractionEnabled:NO];
   
   
   /* Setting properties for blood glucose label */
   [self.bloodGlucoseLabel setText:[NSString stringWithFormat:@"%i", 0]];
   
   
  
   
   /*!
    * @brief This array stores all the UUIDs that app is searching for
    * using the CoreBluetooth Framework.
    */
   NSArray *bluetoothScanningService = @[[CBUUID UUIDWithString:GLUCOWATCH_CC2650_CPU_MAIN_UUID]];
   
   
   /* A central manager object. The first argument sets the delegate which
    * is the view controller. The second argument  is set to 'nil'. This is
    * because the peripherl manager will be running on the main thread.
    *
    * See Following Website For Details:
    * https://www.raywenderlich.com/52080/introduction-core-bluetooth-building-heart-rate-monitor
    *
    */
   CBCentralManager *centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
   
   
   
   /* Informs the central manager object to scan for all of the required services
    * within the range of the Bluetooth LE module on iOS. The required services are
    * identified in 'bluetoothScanningService' array.
    */
   NSLog(@"Hello");
   [centralManager scanForPeripheralsWithServices:nil options:nil];
   self.centralManager = centralManager;
   
}






/***************************** CBCentralManager Delegate *****************************/


- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
   
   
   
   /* The view controller is set to be the delegate of the peripheral 
    * object such that the peripheral object is able to notify the 
    * view controller using callbacks.
    */
   [peripheral setDelegate:self];
   
   
   
   /* This method asks the peripheral object to discover services which are
    * related to GlucoWatch. This operation takes place if there are 
    * no errors in the previous method above: 'setDelegate'.
    */
   [peripheral discoverServices:nil];
   
   
   
   /* The following determines the peripheral's current state to check
    * whether a connection has been made with the device.
    */
   self.isDeviceConnected = [NSString stringWithFormat:@"Device Connected %@",
                           peripheral.state == CBPeripheralStateConnected? @"YES" : @"NO"];
   
   
   /* IMPORTANT NOTE ABOUT CONNECTION FAILURES
    * If the connection with the device fails for whatever reason, the central manager
    * will respond by calling the 'centralManager:didFailToConnectPeripheral:error' method. 
    */
   
   
   
   /* Sending a message to the console with the connection status of the device */
   NSLog(@"%@", self.isDeviceConnected);
   
   
}



- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
   
   
   /*!
    * @brief A string which stores the local name of the peripheral device.
    */
   NSLog(@"DID DISCOVER");
   NSString *localNameofPeripheral = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
   
   
   
   
   /* The following if-statement checks to see that a scanned device has 'non-empty'
    * local name. This will be useful, because the local name can be stored and 
    * scanning for devices will be stopped and a connection will be made with the
    * peripheral device. This if statement is for debugging purposes and not a user
    * focused feature.The results from this logic will be displayed in the console 
    * of the Xcode IDE.
    *
    * See Following Website For Details:
    * https://www.raywenderlich.com/52080/introduction-core-bluetooth-building-heart-rate-monitor
    *
    */
   
   if (![localNameofPeripheral isEqual:@""]) {
      
     /* Console output message */
      NSLog(@"Found GlucoWatch (TI CC2650 ARM CHIPSET): %@", localNameofPeripheral);
      
      
      /* Once the device is found, the central manager will stop scanning */
      [self.centralManager stopScan];
      
      
      /* Assigns glucoWatchPeripheral object to peripheral */
      self.glucoWatchPeripheral = peripheral;
      peripheral.delegate = self;
      
      
      /* Central manager connects to the peripheral */
      [self.centralManager connectPeripheral:peripheral options:nil];
      
      
   } /* End of if-statement */
   
   
}



- (void) centralManagerDidUpdateState:(CBCentralManager *)central {
   
   
   /* In this method, through the use of simple if-else staements,
    * the app will determine the state of the peripheral device in
    * relation with the app and the CoreBluetooth framework. This
    * verification process is used for debugging purposes and is
    * not a user focused feature. The results from this logic will
    * be displayed in the console of the Xcode IDE. Descriptions for
    * the console print outs take from the Documentation notes provided
    * to developers by Apple.
    */
   
   
   /* If state is off */
   if ([central state] == CBCentralManagerStatePoweredOff) {
      
      NSLog(@"Bluetooth is currently powered off.");
   }
   
   /* If state is on */
   else if ([central state] == CBCentralManagerStatePoweredOn) {
      
      NSLog(@"Bluetooth is currently powered on and available to use.");
   }
   
   /* If state is unauthorized */
   else if ([central state] == CBCentralManagerStateUnauthorized) {
      
      NSLog(@"The app is not authorized to use Bluetooth low energy.");
   }
   
   /* If state is unknown */
   else if ([central state] == CBCentralManagerStateUnknown) {
      
      NSLog(@"The current state of the central manager is unknown; an update is imminent.");
   }
   
   
   /* If state is unsupported */
   else if ([central state] == CBCentralManagerStateUnsupported) {
      
      NSLog(@"The platform does not support Bluetooth low energy.");
   }
   
   
}


/******************************** CBPeripheral Delegate ******************************/



- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
   
   
   /* The following if-statement will iterate through each of the services
    * discovered and then log it's corresponding UUID. Once the UUID is logged
    * a method is called to discover the characteristics related to the particular
    * service which was discovered previously.
    */
   
   
   /*!
    * @brief This array stores all the UUIDs that app is searching for
    * using the CoreBluetooth Framework.
    */
  NSArray *bluetoothScanningCharacteristic = @[[CBUUID UUIDWithString:GLUCOWATCH_BLOOD_GLUCOSE_SERVICE_UUID]];
   
   for (CBService *service in peripheral.services) {
      
      /* Message displayed in console */
      NSLog(@"The following service has been discovered: %@", service.UUID);
      
      /* Discover characteristics related to a particular service */
      [peripheral discoverCharacteristics:bluetoothScanningCharacteristic forService:service];
   }
   
   
}




- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
   
   
   /* The following work flow will be implemented in this method. The steps are described below, additionally, the steps
    * will be marked beside the corresponding segment of code which implements that step:
    *
    * STEP 1:
    * Check to see if the service is the blood glucose service. This service stores the current blood glucose value
    * in this service on the MCU. 
    *
    * STEP 2:
    * If the service is the blood glucose service, then a method will iterate through the characteristics array to
    * determine if charactertistic is a blood glucose service notification. If it is the blood glucose notification
    * then the app will "subscribe" to the characteristic. This will tell the central manager to monitor to see if
    * there are any changes and update accordingly.
    *
    * STEP 3:
    * Check to see if the service is the device information service, if so, then retrieve the device name and read
    * the corresponding value and display it accordingly.
    */
   
   
   if ([service.UUID isEqual:[CBUUID UUIDWithString:GLUCOWATCH_BLOOD_GLUCOSE_SERVICE_UUID]]) {
      
      
      /* STEP 1 */
      for (CBCharacteristic *someCharacteristic in service.characteristics) {
         
         /* Requesting blood glucose notification */
         if ([someCharacteristic.UUID isEqual:[CBUUID UUIDWithString:GLUCOWATCH_BLOOD_GLUCOSE_SERVICE_UUID]]) {
            
            /* STEP 2 */
            [self.glucoWatchPeripheral setNotifyValue:YES forCharacteristic:someCharacteristic];
            
            /* Log message for console */
            NSLog(@"The Blood Glucose Characteristic was found.");
         }
      
      } /* End of for-loop for blood glucose notifcation */
      
   } /* End of if-statement */
   
   
   
   
   /* STEP 3 */
   if ([service.UUID isEqual:[CBUUID UUIDWithString:BT_SIG_DEVICE_INFO_SERVICE]]) {
      
      
      for (CBCharacteristic *someCharacteristic in service.characteristics) {
         
         /* Requesting device information notification */
         if ([someCharacteristic.UUID isEqual:[CBUUID UUIDWithString:BT_SIG_DEVICE_INFO_SERVICE]]) {
            

            [self.glucoWatchPeripheral readValueForCharacteristic:someCharacteristic];
            
            /* Log message for console */
            NSLog(@"The Device Information Characteristic was found.");
         }
         
      } /* End of for-loop for device information read */
      
   } /* End of if-statement */
   
   
   
}


- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
   
   
   /* The following work flow will be implemented in this method. The steps are described below, additionally, the steps
    * will be marked beside the corresponding segment of code which implements that step:
    *
    * STEP 1:
    * Check to see if a notification was received by the app for blood glucose service. If so, then the next step
    * is to call the custom instance method 'fetchBloodGlucoseCharacteristicData:characteristic:error'. The value
    * will be passed to this method.
    *
    * STEP 2:
    * Check to see if a notification was received by the app for device manufactuer information. If so, then the next step
    * is to call the custom instance method 'fetchDeviceManufacturerName:characteristic'. The value
    * will be passed to this method.

    *
    * STEP 3:
    * The last step is collect all the values and place them in the appropriate UI elements inside the app. The blood
    * glucose value will be displayed inside the bloodGlucoseValue label object and the device information will be 
    * displayed inside the UITextField object.
    */
   
   
   /* STEP 1 */
   if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:GLUCOWATCH_BLOOD_GLUCOSE_SERVICE_UUID]]) {
      
      /* Fetch the blood glucose value */
      [self fetchBloodGlucoseCharacteristicData:characteristic error:error];
   }
   
   
   /* STEP 2 */
   if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BT_SIG_DEVICE_INFO_SERVICE]]) {
      
      /* Fetch the device information */
      [self fetchDeviceManufacturerName:characteristic];
   }
   
   
   /* STEP 3: Add device information and connection status inside the UITextView */
   self.deviceInformation.text = [NSString stringWithFormat:@"%@\n%@\n", self.isDeviceConnected, self.deviceManufacturer];
   

}




/************************* CBCharacteristic Helper Methods ***************************/


- (void) fetchBloodGlucoseCharacteristicData:(CBCharacteristic *)characteristic error:(NSError *)error {
   
   
   /* In order to display the blood glucose value, the characteristic value
    * needs to be converted to a data object. For this, an instance of the
    * NSData class is used to create a data object to store the characteristic
    * value of blood glucose.
    */
   NSData *bloodGlucosedata = [characteristic value];
   
   
   
   /* Once the data object has been made, the byte sequence of that object
    * will be obtained and assigned to the reportData object.
    */
   const uint8_t *reportBloodGlucoseData = [bloodGlucosedata bytes];
   
   
   
   /* Initialization of an unsigned variable to store the blood glucose
    * data information.
    */
   uint16_t bloodGlucoseNumber = 0;
   
   
   
   /* The first step is to get the first byte of at index 0 and
    * in the array, this is defined by reportBloodGlucoseData[0]. 
    * Every bit except the 1st bit will be masked out. The result of 
    * this operation should return a '0'. If so, this means that the 
    * 2nd bit has not been set or the 1st is set. If the 2nd bit is not
    * set, then the blood glucose value is at second byte location or
    * inded position 1 in the array.
    */
   
   if ((reportBloodGlucoseData[0] & 0x01) == 0) {
      
      bloodGlucoseNumber = reportBloodGlucoseData[1];
   }
   else {
      
      /* If the second bit is set, then, convert the value to a 16-Bit value */
      bloodGlucoseNumber = CFSwapInt16LittleToHost(*(uint16_t *)(&reportBloodGlucoseData[1]));
   }
   
   
   /* The next step is to display the blood glucose value inside the UILabel.
    * Before this, a check needs to made to make sure that there was no error
    * when obtaining the blood glucose value.
    */
   if (characteristic.value) {
      
      self.bloodGlucoseValue = bloodGlucoseNumber;
      self.bloodGlucoseLabel.text = [NSString stringWithFormat:@"%i ", bloodGlucoseNumber];
      
   }
   
   return;
   
}


- (void) fetchDeviceManufacturerName:(CBCharacteristic *)characteristic {
   
   
   NSString *manufacturerName = [[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
   
   self.deviceManufacturer = [NSString stringWithFormat:@"Manufacturer: %@", manufacturerName];
   return;
   
}













@end
