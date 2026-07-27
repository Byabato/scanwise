# ScanWise Version 1 Scope

## Objective

Release a reliable Android application that provides clear value beyond the
phone camera through interpretation, local structural assessment, controlled
actions and a searchable personal scan library.

## Included

### Capture

- live camera scanning;
- gallery image scanning;
- scan framing;
- torch;
- haptic feedback;
- single accepted result at a time;
- duplicate detection gate;
- camera lifecycle handling.

### Supported symbologies

- QR Code;
- EAN-8;
- EAN-13;
- UPC-A;
- UPC-E;
- Code 128;
- Data Matrix;
- PDF417;
- Aztec.

The implementation may restrict formats when required for performance.

### Interpreted content

- URL;
- Wi-Fi;
- contact or vCard;
- email;
- phone;
- SMS;
- geographical location;
- calendar event;
- product identifier;
- ISBN;
- plain text;
- unknown or unsupported content.

### URL assessment

Local structural analysis may identify:

- HTTP;
- malformed URLs;
- unsupported schemes;
- IP-address hosts;
- unusual ports;
- embedded credentials;
- excessive subdomains;
- punycode;
- suspicious Unicode;
- recognizable URL-shortener patterns;
- misleading organization names placed in subdomains.

The application must not claim to determine live malware reputation offline.

### Actions

- open URL;
- copy;
- share;
- call;
- compose email;
- compose SMS;
- open location;
- add calendar event;
- add contact;
- open Wi-Fi settings where supported;
- search product identifier externally;
- save to Library.

### Library

- automatic saving according to settings;
- incognito scanning;
- search;
- filter by type;
- filter by date;
- favorites;
- collections;
- notes;
- renaming;
- duplicate recognition;
- last scanned date;
- scan occurrence count;
- delete;
- Undo;
- clear all data.

### Settings

- processing and privacy explanation;
- automatic history preference;
- incognito mode;
- confirmation before external actions;
- haptic feedback;
- theme preference;
- supported formats;
- permission management;
- clear data;
- About.

### Quality

- unit tests;
- Flutter widget tests;
- automated integration tests with fake scan input;
- documented physical-device tests;
- GitHub Actions;
- Android debug and release build preparation;
- accessibility checks;
- privacy review.

## Explicitly excluded from version 1

- user accounts;
- cloud synchronization;
- advertisements;
- online malware guarantees;
- automatic URL opening;
- automatic Wi-Fi connection;
- OCR;
- document scanning;
- generic AI chatbot;
- team collaboration;
- warehouse inventory management;
- payment execution;
- product price aggregation;
- enterprise administration dashboard;
- iOS release;
- web release;
- social features;
- public profiles.