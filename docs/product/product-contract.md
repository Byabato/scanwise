# ScanWise Product Contract

## Product definition

ScanWise is a privacy-first mobile scan-intelligence application that helps
users capture, understand, assess, act on and organize information from QR
codes and barcodes.

It adds a trusted interpretation and decision layer beyond ordinary camera
scanning.

It does this by:

- translating encoded content into understandable information;
- revealing actual URL destinations;
- identifying relevant structural warning signs;
- presenting context-aware actions;
- saving valuable scans into a searchable local workspace.

## Product category

Scan intelligence and information workspace.

ScanWise is not positioned as:

- a generic QR scanner;
- a basic barcode reader;
- a camera replacement;
- an antivirus product;
- a warehouse inventory platform;
- an online reputation service.

## Product promise

For every accepted scan, ScanWise should help the user answer:

1. What did I scan?
2. What information does it contain?
3. Is there anything I should verify?
4. What useful action can I take?
5. Should I save or organize it?

## Product flow

Capture → Interpret → Assess → Act → Organize

## Primary product principles

### Understand before acting

Scanned content is interpreted before external actions are offered.

### User control

No URL, phone call, message, map, calendar action or other external action
occurs automatically.

### Responsible security language

ScanWise identifies structural indicators but does not claim certainty about
the current safety or reputation of a destination.

### Local-first privacy

Scan contents are processed locally by default and are not uploaded by the
application.

### Useful reuse

Saved scans remain searchable, editable and organized rather than becoming an
unstructured history list.

### Offline usefulness

Core interpretation, local analysis and Library functionality must work
without an internet connection.

## Primary users

- everyday smartphone users;
- students and researchers;
- professionals;
- event participants;
- small-business operators;
- field teams;
- privacy-conscious users.

## Main user jobs

- inspect an unknown QR URL before opening it;
- understand Wi-Fi, contact, calendar or location codes;
- save useful scanned information;
- find a previous scan;
- add context through notes and collections;
- recognize that an item has been scanned before;
- safely choose an appropriate next action.

## Core result experience

Every result should prioritize:

1. content type;
2. human-readable title;
3. important interpreted details;
4. destination or identifier;
5. warning or verification state;
6. one main action;
7. secondary actions;
8. save and organization controls;
9. technical details;
10. raw encoded content.

Raw values should not dominate the interface.

## Privacy statement

Preferred wording:

> Scan contents are processed on your device and are not uploaded by ScanWise.

This wording must remain accurate across all implemented SDKs and services.


Product Definition
Working Product Name
ScanWise
Tagline
Scan. Understand. Decide.
Alternative tagline
Know what is behind the code before you act.

1. Product Vision
ScanWise is a privacy-first mobile intelligence app that helps users understand, verify, organize, and act on information captured from QR codes, barcodes, screenshots, images, documents, and physical products.
It is not designed merely to detect a code and open a link.
It transforms encoded information into a clear, safe, actionable experience.
The application should answer four questions immediately:
What did I scan?
What does it contain?
Is there anything I should verify?
What useful action can I take next?
The scanner is only the capture layer.
The real product is an intelligent decision layer between the scanned object and the user’s next action.

2. Product Mission
To make every scan understandable, trustworthy, useful, and reusable.
ScanWise should protect users from blindly opening unknown content, reduce the effort required to interpret encoded information, and help users convert scans into organized personal or professional records.

3. Core User Problem
Current phone cameras and scanner applications are optimized primarily for detection.
They commonly perform this sequence:
Detect code → Display value → Open destination
This is fast, but incomplete.
Users are often left with unanswered questions:
Is this link legitimate?
Why is the domain different from the organization shown on the poster?
Is this a payment instruction, contact, Wi-Fi network, event, product, or plain text?
Have I scanned this before?
Can I save it for a specific project?
Can I add context or notes?
Can I compare it with another scan?
Can I export multiple scans?
What exactly will happen when I press the action button?
Can I inspect the information without sending it to a server?
ScanWise addresses the gap between code recognition and informed action.

4. Product Positioning
Category
Scan intelligence and information workspace
Not:
only a QR scanner;
only a barcode reader;
only a link-opening tool;
only a scan-history app;
only a security scanner.
Positioning statement
For people who regularly encounter QR codes, barcodes, screenshots, product labels, event codes, contacts, payment instructions, and encoded information, ScanWise is a mobile scan-intelligence app that interprets content, highlights relevant risks, recommends appropriate actions, and organizes valuable scans into a searchable workspace.
Unlike ordinary phone cameras and generic scanner apps, ScanWise does not treat every code as a destination to open. It treats every scan as information that should first be understood.

5. Core Product Promise
Before ScanWise
A user scans a code and is immediately pushed toward opening, copying, or leaving the app.
With ScanWise
A user scans a code and receives:
a clear explanation;
a human-readable preview;
relevant warnings;
context-aware actions;
organization options;
a record that remains useful later.
The experience becomes:
Capture → Interpret → Assess → Act → Organize

6. Product Pillars
Pillar 1: Intelligent Interpretation
ScanWise should not simply show raw encoded data.
It should translate technical payloads into understandable information.
Examples:
URL
Instead of showing:
https://secure-login.example.co.tz/account?id=2394
Show:
Destination: example.co.tz
Connection: HTTPS
Path: Account
Parameters detected
Full destination
Relevant warning indicators
Wi-Fi
Instead of showing:
WIFI:T:WPA;S:OfficeNet;P:example123;;
Show:
Network: OfficeNet
Security: WPA
Password included
Hidden network: No
Contact
Show structured fields:
Name
Organization
Phone
Email
Website
Calendar event
Show:
Event title
Date
Time
Location
Organizer
Calendar-add action
Product code
Show:
Barcode format
Product identifier
Check-digit validity
Possible external search options
Collection and note actions
Plain text
Show:
detected language where possible;
formatted content;
copy, share, save, and annotate actions.
The user should rarely need to understand the technical encoding format.

Pillar 2: Safe Decision Support
ScanWise should help users decide whether and how to proceed.
The app should inspect structural risk indicators such as:
HTTP instead of HTTPS;
raw IP-address destinations;
shortened URLs;
unusual ports;
embedded credentials;
excessive subdomains;
punycode;
misleading Unicode characters;
suspicious URL patterns;
unsupported schemes;
malformed destinations.
The language must remain responsible.
The app should not claim:
“This link is completely safe.”
“This website is malware-free.”
Instead, it should say:
No obvious structural warning detected.
Review the destination before opening.
This destination uses an uncommon pattern.
This link may hide its final destination.
The domain contains characters that may be misleading.
ScanWise cannot confirm the current reputation of this site while offline.
This makes the app trustworthy without overstating its capabilities.

Pillar 3: Context-Aware Actions
The app should present actions based on the content type.
It should not show the same buttons for every scan.
Examples:
URL
Open destination
Copy link
Share
Save
Inspect details
Phone number
Call
Send message
Copy
Add to contacts
Save
Email
Compose email
Copy address
Add to contacts
Save
Wi-Fi
Copy password
Copy full details
Open Wi-Fi settings
Save network information
Contact
Add contact
Copy selected fields
Share contact
Save to collection
Location
Open map
Copy coordinates
Share location
Save
Calendar event
Add to calendar
Copy details
Share
Save
Product code
Search product
Copy identifier
Add note
Add to collection
Compare with another code
Every primary action should be explicit about what will happen.

Pillar 4: Personal Scan Workspace
The app should turn scans into useful records.
Users should be able to:
search scanned items;
filter by type;
filter by date;
create collections;
rename items;
add notes;
mark favorites;
identify repeated scans;
reopen previous results;
export selected records;
delete individual records;
clear all records;
use private scanning mode.
Example collections:
Event contacts
Products to compare
Research resources
Work equipment
Wi-Fi networks
Business cards
Field visits
Books
Receipts and payments
Training materials
Personal documents
This transforms the app from a one-time tool into a reusable information system.

Pillar 5: Privacy by Design
Scan contents may include sensitive information such as:
passwords;
private URLs;
phone numbers;
email addresses;
payment instructions;
business information;
contact details;
internal documents.
The product should therefore default to:
on-device scanning;
on-device parsing;
local storage;
no automatic scan-content upload;
no scan content in logs;
no scan content in analytics;
clear delete controls;
incognito scanning;
transparent permissions.
Recommended product language:
Your scan contents are processed on your device and are not uploaded by ScanWise.
Do not use claims such as “zero knowledge” unless every SDK, backup mechanism, log, and cloud component has been verified against that claim.

7. Primary User Segments
1. Everyday users
People scanning:
restaurant menus;
payment instructions;
posters;
Wi-Fi cards;
links;
product packaging;
event registrations.
Value:
understand before opening;
avoid suspicious destinations;
retain useful information.
2. Students and researchers
People scanning:
books;
journal links;
library materials;
class resources;
event materials;
contact information.
Value:
collections;
notes;
searchable records;
export.
3. Professionals
People scanning:
business cards;
event contacts;
product labels;
internal assets;
documents;
meeting information.
Value:
structured records;
contact actions;
collections;
reusable history.
4. Small businesses
People scanning:
stock labels;
products;
deliveries;
equipment;
invoices;
supplier information.
Value:
batch workflows later;
exports;
product records;
operational traceability.
5. Field teams
People working in:
surveys;
logistics;
NGOs;
public-health programs;
inspections;
events;
research.
Value:
offline operation;
organized sessions;
notes;
exports;
low-connectivity support.

8. Core User Experience
Home Experience
The home screen should not look like a technical camera utility.
It should immediately communicate:
what the app does;
what the user can scan;
that results are interpreted before action;
that scanning remains private.
Primary interface:
large central scanning surface;
clear framing area;
gallery import;
flashlight;
recent scans preview;
private-mode toggle;
concise guidance.
Example message:
Position a QR code or barcode inside the frame. ScanWise will explain it before you open or save anything.

Scan Result Experience
The result should open as a structured information card, not a raw-text bottom sheet.
Result hierarchy
Content type
Human-readable title
Key details
Risk or verification notice
Primary action
Secondary actions
Save and organization controls
Raw data, collapsed by default
Example URL result
Website link
University of Dar es Salaam
Destination: udsm.ac.tz
Status:
HTTPS connection
Recognizable domain structure
No obvious local warning detected
Primary action:
Open Website
Secondary actions:
Copy
Share
Save
View technical details
Example suspicious URL result
Review this destination
Destination:
udsm-login.verify-example.net
Warnings:
The organization name appears in a subdomain, not the main domain.
The actual registered destination appears to be verify-example.net.
Review carefully before continuing.
Primary action:
Open Anyway
Secondary actions:
Copy destination
Share for verification
Save
Cancel
The experience should inform without frightening or confusing the user.

9. UI and Visual Direction
Design character
The interface should feel:
calm;
intelligent;
trustworthy;
modern;
clean;
fast;
premium;
accessible.
Avoid:
cyber-security clichés;
excessive red warning colors;
crowded technical dashboards;
neon scanner effects;
unnecessary animations;
raw data overload.
Visual language
Use:
spacious layouts;
clear typography;
soft elevation;
rounded result cards;
subtle motion;
strong visual hierarchy;
semantic icons;
status chips;
accessible contrast;
dark scanner mode;
light and dark application themes.
Suggested navigation
Use four primary sections:
Scan
Live camera and gallery import.
Library
Saved scans, search, collections, filters, and favorites.
Insights
Useful summaries such as:
most scanned types;
repeated scans;
recently added collections;
unreviewed suspicious links;
scans without notes.
This should remain practical rather than becoming a meaningless analytics dashboard.
Settings
Privacy, history behavior, appearance, permissions, export, and about.
For the first public release, Insights may be included as a small section within Library rather than a separate tab.

10. Signature Experiences
The application needs memorable interactions that cameras and ordinary scanners do not provide.
Signature 1: Domain Reveal
For links, animate the result from the full URL into the actual destination domain.
Example:
login.udsm.ac.tz.account-check.example.net
becomes:
Actual destination: example.net
This provides immediate educational and security value.

Signature 2: Explain This Scan
A prominent action displays a plain-language explanation:
This QR code contains a website address. Opening it will leave ScanWise and launch your browser. The main destination is example.net.
For Wi-Fi:
This QR code contains the name and password of a wireless network. Copying or sharing it may expose the password.
This improves digital literacy.

Signature 3: Smart Save
When saving a result, suggest a useful collection based on the content.
Examples:
contact → Event contacts;
book barcode → Reading list;
product code → Products;
location → Places;
Wi-Fi → Networks.
Suggestions should happen locally and remain optional.

Signature 4: Scan Session
Users can start a temporary scanning session such as:
Conference contacts;
Store inventory check;
Book collection;
Field visit;
Product comparison.
Every scan during that session is grouped automatically.
This feature creates real professional and business value.
It also provides a future path toward batch scanning without turning the first release into a warehouse system.

Signature 5: Duplicate Intelligence
Instead of merely rejecting duplicate scans, tell the user:
You scanned this item three days ago.
Then show:
previous note;
collection;
previous action;
last scanned date.
This turns duplication into useful context.

Signature 6: Compare Scans
Allow users to compare two compatible scans.
Examples:
two product identifiers;
two URLs;
two contact cards;
two Wi-Fi configurations.
Comparison can initially show:
same or different;
changed fields;
matching domain;
matching identifier.
This is a distinctive feature that can later support product and business workflows.

11. Product Scope
Version 1.0 Core
Capture
live-camera scanning;
gallery image scanning;
QR and common barcode formats;
torch;
haptic feedback;
scan framing;
duplicate control.
Interpret
URLs;
Wi-Fi;
contact cards;
email;
phone;
SMS;
location;
calendar events;
product codes;
ISBN;
plain text.
Assess
URL normalization;
domain reveal;
HTTP warning;
short-link warning;
punycode warning;
unusual destination warning;
malformed-data handling.
Act
open;
call;
message;
email;
map;
calendar;
contact;
copy;
share.
Organize
local history;
search;
filters;
favorites;
notes;
collections;
duplicate recognition;
incognito mode.
Privacy
on-device processing;
no scan-content analytics;
clear deletion;
local storage;
transparent permissions.

12. Features Deliberately Excluded from Version 1.0
user accounts;
cloud synchronization;
advertisements;
automatic link opening;
automatic Wi-Fi connection;
online malware guarantees;
OCR;
inventory enterprise features;
team collaboration;
product-price aggregation;
payment execution;
unsupported financial claims;
web platform;
social feed;
generic AI chatbot.
These exclusions protect the product from becoming unfocused.

13. Future Expansion
Version 1.1
export CSV and JSON;
scan sessions;
advanced collections;
calendar parsing;
ISBN recognition;
duplicate insights.
Version 1.2
GS1 Digital Link interpretation;
batch scanning;
product traceability;
expiry and lot extraction;
structured field exports.
Version 2.0
encrypted account backup;
cross-device synchronization;
organization workspaces;
team scan sessions;
API integrations;
configurable business workflows;
optional online reputation checks.

14. Business Value
The product can develop through three levels.
Consumer utility
Value:
safer scanning;
better understanding;
useful history;
organization.
Potential monetization:
optional one-time Pro purchase;
advanced export;
scan sessions;
enhanced collections;
encrypted backup.
Professional utility
Value:
contact collection;
project-based scans;
field records;
structured export;
reusable sessions.
Potential monetization:
professional plan;
advanced export formats;
templates;
encrypted backup;
multi-device use.
Business workflow product
Value:
asset scanning;
inventory sessions;
event intake;
product traceability;
structured operational records.
Potential monetization:
team subscriptions;
branded deployments;
integration packages;
workflow configuration;
administrative dashboards.
The consumer product should first establish trust and usability. Business functionality should be added only after observing a repeated operational need.

15. Success Metrics
The product should not be measured only by the number of scans.
More useful indicators include:
percentage of scans successfully interpreted;
percentage of users who inspect details before opening;
percentage of scans saved;
percentage of users returning to Library;
number of collections created;
repeated-scan recognition usage;
notes added;
scan-session completion;
export usage;
crash-free sessions;
camera-start reliability;
average time from scan to useful action.
No metric should require collecting raw scan contents.

16. Product Principles
Principle 1
Understand before acting.
Principle 2
The user remains in control.
Principle 3
Explain risks without exaggerating certainty.
Principle 4
Store less by default and protect what is stored.
Principle 5
Every feature must improve a real post-scan decision.
Principle 6
The scanner is infrastructure, not the product.
Principle 7
Design for ordinary users, not only technical users.
Principle 8
Useful offline behavior is a core capability, not a fallback.

Final Product Definition
ScanWise is a privacy-first mobile scan-intelligence application that helps users capture, understand, assess, act on, and organize information from QR codes and barcodes. It adds a trusted interpretation and decision layer beyond ordinary camera scanning by revealing actual destinations, explaining encoded information, identifying structural warning signs, recommending context-aware actions, and preserving valuable scans inside a searchable personal workspace.
The product is not another scanner.
It is a trusted intermediary between the physical world, encoded digital information, and the user’s next decision.

