# Lab 10

All documentation is written in markdown format

## Snort Logging LetMeCry Exploit Alerts

1. Log into pfsense - 172.16.20.250
1. Accept agreement
1. Install Snort
    1. System &rarr; Package Manager &rarr; Available Packages
    1. Search for Snort
    1. Install Snort
    1. Confirm
1. Add Snort interface
    1. Service &rarr; Snort &rarr; Interfaces
    1. Add
    1. SUBSCRN
    1. Check "Send Alerts to System Log"
1. Service &rarr; Snort &rarr; Edit Interface SUBSCRN
    1. Custom rule

```txt
alert tcp any any -> 172.16.10.100 80 (msg: "LetMeCry Exploit"; content: "GET"; content:"%3A%3A%28%29x0001%5E%28%3A%3A%29%28xFFFF%29"; sid: 12345;)
```

1. Wait a minute or two for green check
