# Hardware Inventory

## Homelab Corner

Checked items are currently in use.

### Router(s)

| In Use | Router Model       |                      Link                       |
| :----: | :----------------- | :---------------------------------------------: |
|  [X]   | Unifi Dream Router | [Link](https://store.ui.com/us/en/products/udr) |

### Switch(es)

| In Use | Router Model         |
| :----: | :------------------- |
|  [X]   | Ruckus ICX 7150-C12P |
|  [ ]   | TP-Link TL-SG        |

### Access Point(s)

| In Use | Router Model    |
| :----: | :-------------- |
|  [ ]   | Unifi AP Lite 6 |

### Compute

| In Use | Host              | Use / Future Plans            |
| :----: | :---------------- | ----------------------------- |
|  [ ]   | Thinkcentre M93p  | Proxmox Backup Server         |
|  [X]   | Thinkcentre M93p  | Plex Server (intel graphics)  |
|  [X]   | Beelink SER5 Mini | Proxmox Virtualization Server |

### Specs/Configs

#### Ruckus Switch

Console connection settings:

| Parameter             | Value |
| --------------------- | ----- |
| Baud: Bits per second | 9600  |
| Data bits             | 8     |
| Parity                | None  |
| Stop bits             | 1     |
| Flow control          | None  |

Documentation on commands [commands](https://docs.ruckuswireless.com/fastiron/08.0.50/fastiron-08050-commandref/GUID-0FCE99FF-A5E5-4A6F-88D6-60740D7965D6-homepage.html)

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

#### Virtualization Hosts

Beelink Mini PC

- Ryzen 7 5800H
- 2x16GB 3200MHz DDR4 Ram

??? example "Specs"
    [lshw](../file/lshw_beelink.txt)

    [lshw-short](../file/lshw_short_beelink.txt)

Two of ThinkCentre M93p

- Core(TM) i7-4785T CPU
- 2x8 GB SODIMM DDR3 1600 MHz
- 256GB Samsung SSD 860

#### TrueNAS

Using network port enp4s0. enp1s0 is inactive

New NAS:

Ugreen NASync DX4800 Plus

- Intel Pentium Gold 8505
- 32GB Ram
- 4x12TB SATA HDD HGST Ultrastar DC HC 520 HUH721212ALE601

Old NAS:

| Component | Part                                         |
| --------- | -------------------------------------------- |
| PCIe Card | *LSI 9211-8i 6G SAS HBA FW:P20 IT Mode       |
| SAS Disks | *HGST Ultrastar He10 10TB 7200RPM SAS 12Gbps |
| GPU       | Gigabyte GTX 1050 OC Low Profile 2 GB        |

- *RAM (model number): Hynix hmt41gr7bf4c-rd (88 GB 1600 MHz) mix of 16 GB + 8 GB sticks
- 2x SFF-8087 SAS cables

#### Kyle's PC

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

### Misc Hardware

Wyze Cam v3

??? example "X-ES Firesale PC"
    [lshw](../file/xes_firesale_pc_lshw.txt)

    [lshw-short](../file/xes_firesale_pc_lshw_short.txt)
