#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <stdio.h>
#include <sys/types.h>
#include <stdlib.h>
#include <unistd.h>
#include <limits.h>
#include <usb.h>

static AV *List				( void );

/**************** Perl Stubs ****************/

/*
//	HV*    devlist;
//	SV*    devid;
//	int    n, i;
//	njb_t*  ni;

//	devlist = newHV();

//	if (USB_List(njbs, 0, &n) == -1) {
//		XSRETURN( 0 );
//	}

//	for (i=0; i<n; i++) {
//		XPUSHs( newRV_noinc( (SV*) devlist ));
//		devid = newSViv ( (IV) &(njbs[i]) );
//		hv_store (devlist, "DEVID", 5, devid, 0);
//		ni = njbs[i];
//		hv_store (devlist, "NAME", 4, newSVpv ( ni->idstring, strlen(ni->idstring) ), 0);
//	}

//	XSRETURN( i );
*/

MODULE = Device::USB		PACKAGE = Device::USB

void
List ()
	PPCODE:
	AV*  AV_bus;
	AV*  AV_dev;
//	HV*  HV_dev;
	struct usb_bus *bus;
	struct usb_device *dev;

	usb_init();

	usb_find_busses();
	usb_find_devices();

	AV_bus = newAV();
	
	XPUSHs( newRV_noinc( (SV*) AV_bus));

	AV_dev = newAV();
		
	for (bus = usb_busses; bus; bus = bus->next) {
		
		for (dev = bus->devices; dev; dev = dev->next) {
			int ret, i;
			char string[256];
			usb_dev_handle *udev;
			HV*  HV_dev_info;
			HV*  HV_config;
			HV*  HV_endpoints;
			HV*  HV_alti;
			
			AV*  AV_config;
			AV*  AV_endpoints;
			AV*  AV_alti;
			SV*  data;
	
			HV_dev_info = newHV();
			HV_config = newHV();
			HV_alti = newHV();
			HV_endpoints = newHV();
			AV_config = newAV();
			AV_alti = newAV();
			AV_endpoints = newAV();
			
			data = newSVpv ( bus->dirname, strlen (bus->dirname) );
			hv_store(HV_dev_info,"dirname", 7, data, 0);
			
			data = newSVpv ( dev->filename, strlen (dev->filename) );
			hv_store(HV_dev_info,"filename", 8, data, 0);
			
			data = newSViv ( dev->descriptor.idVendor );
			hv_store(HV_dev_info,"vendor", 6, data, 0);
			
			data = newSViv ( dev->descriptor.idProduct );
			hv_store(HV_dev_info,"product", 7, data, 0);
			
			udev = usb_open(dev);
			if (udev) {
				//XPUSHs( newRV_noinc( (SV*) HV_dev_info));
				if (dev->descriptor.iManufacturer) {
					ret = usb_get_string_simple(udev, dev->descriptor.iManufacturer, string, sizeof(string));
					if (ret > 0) {
						data = newSVpv ( string, strlen (string) );
						hv_store(HV_dev_info,"manuf", 5, data, 0);
//						printf("- Manufacturer : %s\n", string);
					} else {
//						printf("- Unable to fetch manufacturer string\n");
					}
				}

				if (dev->descriptor.iProduct) {
					ret = usb_get_string_simple(udev, dev->descriptor.iProduct, string, sizeof(string));
					if (ret > 0) {
						data = newSVpv ( string, strlen (string) );
						hv_store(HV_dev_info,"prod", 4, data, 0);
//						printf("- Product      : %s\n", string);
					} else {
//						printf("- Unable to fetch product string\n");
					}
				}
	
				if (dev->descriptor.iSerialNumber) {
					ret = usb_get_string_simple(udev, dev->descriptor.iSerialNumber, string, sizeof(string));
					if (ret > 0) {
						data = newSVpv ( string, strlen (string) );
						hv_store(HV_dev_info,"serial", 6, data, 0);
//						printf("- Serial Number: %s\n", string);
					} else {
//						printf("- Unable to fetch serial number string\n");
					}
				}

				usb_close (udev);
			}
			
			//hv_store(HV_dev, "devices", 7, newRV((SV*) HV_dev_info), 0);
			av_push(AV_dev, newRV((SV*) HV_dev_info));
			
			if (!dev->config) {
//				printf("  Couldn't retrieve descriptors\n");
				continue;
			}
  
			hv_store (HV_dev_info, "config", 6, newRV((SV*) AV_config), 0);
			
			for (i = 0; i < dev->descriptor.bNumConfigurations; i++) {
				struct usb_config_descriptor *config = &dev->config[i];
				int j;

				av_push(AV_config, newRV((SV*) HV_config));
				
				data = newSViv ( (IV) config->wTotalLength );
				hv_store(HV_config,"totallength", 11, data, 0);
//  				printf("  wTotalLength:         %d\n", config->wTotalLength);
				
				data = newSViv ( (IV) config->bNumInterfaces );
				hv_store(HV_config,"numinterfaces", 13, data, 0);
//				printf("  bNumInterfaces:       %d\n", config->bNumInterfaces);
				
				data = newSViv ( (IV) config->bConfigurationValue );
				hv_store(HV_config,"configurationvalue", 18, data, 0);
//				printf("  bConfigurationValue:  %d\n", config->bConfigurationValue);
				
				data = newSViv ( (IV) config->iConfiguration );
				hv_store(HV_config,"configuration", 13, data, 0);
//				printf("  iConfiguration:       %d\n", config->iConfiguration);
				
				data = newSViv ( config->bmAttributes );
				hv_store(HV_config,"attributes", 10, data, 0);
//				printf("  bmAttributes:         %02xh\n", config->bmAttributes);
				
				data = newSViv ( (IV) config->MaxPower );
				hv_store(HV_config,"maxpower", 8, data, 0);
//				printf("  MaxPower:             %d\n", config->MaxPower);
				
				hv_store (HV_dev_info, "altinterfaces", 13, newRV((SV*) AV_alti), 0);
				
				for (j = 0; j < config->bNumInterfaces; j++) {
					struct usb_interface *interface = &config->interface[j];
					int k;

					av_push(AV_alti, newRV((SV*) HV_alti));
					
					
					for (k = 0; k < interface->num_altsetting; k++) {
						struct usb_interface_descriptor *altinterface = &interface->altsetting[k];
						int l;
						
						data = newSViv ( (IV) altinterface->bInterfaceNumber );
						hv_store(HV_alti,"interfacenumber", 15, data, 0);
//						printf("    bInterfaceNumber:   %d\n", altinterface->bInterfaceNumber);
						
						data = newSViv ( (IV) altinterface->bAlternateSetting );
						hv_store(HV_alti,"alternatesetting", 16, data, 0);
//						printf("    bAlternateSetting:  %d\n", altinterface->bAlternateSetting);
						
						data = newSViv ( (IV) altinterface->bNumEndpoints );
						hv_store(HV_alti,"numendpoints", 12, data, 0);
//						printf("    bNumEndpoints:      %d\n", altinterface->bNumEndpoints);
						
						data = newSViv ( (IV) altinterface->bInterfaceClass );
						hv_store(HV_alti,"interfaceclass", 14, data, 0);
//						printf("    bInterfaceClass:    %d\n", altinterface->bInterfaceClass);
						
						data = newSViv ( (IV) altinterface->bInterfaceSubClass );
						hv_store(HV_alti,"interfacesubclass", 17, data, 0);
//						printf("    bInterfaceSubClass: %d\n", altinterface->bInterfaceSubClass);
						
						data = newSViv ( (IV) altinterface->bInterfaceProtocol );
						hv_store(HV_alti,"interfaceprotocol", 17, data, 0);
//						printf("    bInterfaceProtocol: %d\n", altinterface->bInterfaceProtocol);

						data = newSViv ( (IV) altinterface->iInterface );
						hv_store(HV_alti,"interface", 9, data, 0);
//						printf("    iInterface:         %d\n", altinterface->iInterface);
					
						hv_store (HV_dev_info, "endpoints", 9, newRV((SV*) AV_endpoints), 0);
						av_push(AV_endpoints, newRV((SV*) HV_endpoints));
						
						for (l = 0; l < altinterface->bNumEndpoints; l++) {
							struct usb_endpoint_descriptor *endpoint = &altinterface->endpoint[l];
					

							data = newSViv ( (IV) endpoint->bEndpointAddress );
							hv_store(HV_endpoints,"endpointaddress", 15, data, 0);
//							printf("      bEndpointAddress: %02xh\n", endpoint->bEndpointAddress);
							
							data = newSViv ( (IV) endpoint->bmAttributes );
							hv_store(HV_endpoints,"attributes", 10, data, 0);
//							printf("      bmAttributes:     %02xh\n", endpoint->bmAttributes);
							
							data = newSViv ( (IV) endpoint->wMaxPacketSize );
							hv_store(HV_endpoints,"maxpacketsize", 13, data, 0);
//							printf("      wMaxPacketSize:   %d\n", endpoint->wMaxPacketSize);
							
							data = newSViv ( (IV) endpoint->bInterval );
							hv_store(HV_endpoints,"interval", 8, data, 0);
//							printf("      bInterval:        %d\n", endpoint->bInterval);
							
							data = newSViv ( (IV) endpoint->bRefresh );
							hv_store(HV_endpoints,"refresh", 7, data, 0);
//							printf("      bRefresh:         %d\n", endpoint->bRefresh);
							
							data = newSViv ( (IV) endpoint->bInterval );
							hv_store(HV_endpoints,"synchaddress", 12, data, 0);
//							printf("      bSynchAddress:    %d\n", endpoint->bInterval);
						}
					}
				}
			}
		}
		//av_push(AV_bus, newRV((SV*) HV_dev));
		av_push(AV_bus, newRV((SV*) AV_dev));
	}
	
	XSRETURN( 1 );

