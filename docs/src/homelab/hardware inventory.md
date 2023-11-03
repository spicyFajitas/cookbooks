# Hardware Inventory

## Homelab Corner

### Router

- ASUS RT-AX1800S WiFi 6 Router | [Link](https://www.asus.com/networking-iot-servers/wifi-routers/asus-wifi-routers/rt-ax1800s/techspec/)


### Switch

Ruckus ICX 7150-C12P [specs](https://www.commscope.com/product-type/enterprise-networking/ethernet-switches/itemicx7150-c12p/)

Documentation on commands [linked here](https://docs.ruckuswireless.com/fastiron/08.0.50/fastiron-08050-commandref/GUID-0FCE99FF-A5E5-4A6F-88D6-60740D7965D6-homepage.html)

Lost password - [forum](https://community.ruckuswireless.com/t5/RUCKUS-Support-for-Lennar-Homes/ICX-7150-Login-Issue-after-Factory-Reset-and-quot-no-password/m-p/52814)

Once the password is reset, follow [this guide](https://docs.commscope.com/en-US/bundle/icx-quickstart/page/GUID-3AD21FAD-D8BF-49FF-BBF3-5620F197E322.html) to set password for web-ui.

```serial
device> enable
device# configure terminal
device(config)# crypto-ssl certificate generate
device(config)# username <username> password <password>
device(config)# aaa authentication login default local
device(config)# aaa authentication web-server default local
device(config)# no telnet server
device(config)# enable aaa console
device(config)# web-management https
device(config)# password-change any
device(config)# ip ssh timeout 30
device(config)# ip ssh idle-time 20
device(config)# console timeout 30
device(config)# write memory
device(config)# exit
device#
```

Console connection settings:
| Parameter             | Value |
| --------------------- | ----- |
| Baud: Bits per second | 9600  |
| Data bits             | 8     |
| Parity                | None  |
| Stop bits             | 1     |
| Flow control          | None  |

### Virtualization Host

Dell OptiPlex 3050

- Intel Core i5-7500 4 core 4 thread
- 16GB DDR4 2400Mhz Ram
- 1TB TeamGroup SSD
- ~about 150 W PSU

### TrueNAS

Use top ethernet port. Top 4 disks in disk tray are disks to be used. Bottom 5th is cold spare.

NAS:

| Component   | Part                                         | Specs Sheet | Documentation Link |
| ----------- | -------------------------------------------- | ----------- | ------------------ |
| Motherboard | SuperMicro X9SRI-f                           | ?           | ?                  |
| CPU         | Intel Xeon E5-2690 v1                        | ?           | ?                  |
| CPU Fan     | be quiet! Pure Rock 2 (BK006)                | ?           | ?                  |
| RAM         | *Hynix hmt41gr7bf4c-rd                       | ?           | ?                  |
| Case        | ?                                            | ?           | ?                  |
| PCIe Card   | *LSI 9211-8i 6G SAS HBA FW:P20 IT Mode       | ?           | ?                  |
| SAS Disks   | *HGST Ultrastar He10 10TB 7200RPM SAS 12Gbps | ?           | ?                  |

*RAM (model number): Hynix hmt41gr7bf4c-rd (88 GB 1600 MHz) mix of 16 GB + 8 GB sticks
 
2x SFF-8087 SAS cables

*HGST Ultrastar drives: HUH721010AL4200/42C0

## Not In Use

- Netgear Nighthawk R6700v3 AC1750 | [Link](https://www.netgear.com/home/wifi/routers/r6700/)
- TP-Link TL-SG1005P V2
- Unifi AP Lite 6
- Thinkcentre M93p Core(TM) i7-4785T CPU | 2x8 GB SODIMM DDR3 1600 MHz | 256GB Samsung SSD 860

## Kyle's PC

PC:

| Component   | Part                                      | Specs Sheet | Documentation Link |
| ----------- | ----------------------------------------- | ----------- | ------------------ |
| Motherboard | Asus ROG Strix B450-I Gaming Mini ITX AM4 | ?           | ?                  |
| CPU         | AMD Ryzen 5 3600 6-Core                   | ?           | ?                  |
| CPU Fan     | Noctua NH-L9a-AM4 33.84 CFM               | ?           | ?                  |
| RAM         | *T-Force Vulcan Z16 DDR4-30000 CL16       | ?           | ?                  |
| Case        | SGPC ITX Case - K39                       | ?           | ?                  |
| Boot Drive  | Samsung SSD 960 EVO 250GB                 | ?           | ?                  |

*Teamgroup T-Force Vulcan Z 16 GB (2 x 8 GB) DDR4-3000 CL16 Memory