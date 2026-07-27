# ScanWise User Flows

## Flow 1: First launch

1. User opens ScanWise.
2. User sees concise onboarding.
3. User reviews the local-processing promise.
4. User continues to the camera-permission explanation.
5. User grants camera access or chooses gallery import.
6. User reaches the Scan screen.

## Flow 2: Normal URL

1. User scans a QR code.
2. ScanWise accepts one result and pauses detection.
3. ScanWise parses and normalizes the URL.
4. The real destination domain is shown prominently.
5. Structural findings are displayed.
6. User chooses Open, Copy, Share or Save.
7. External actions require explicit user input.
8. Scanner resumes after the result is dismissed.

## Flow 3: Concerning URL

1. User scans a URL.
2. ScanWise identifies structural warning signs.
3. Result displays “Review this destination.”
4. Actual destination is shown prominently.
5. Findings are explained in plain language.
6. User may cancel, copy, share for verification, save or explicitly open.
7. ScanWise does not claim that the destination is malicious or safe.

## Flow 4: Wi-Fi

1. User scans a Wi-Fi QR code.
2. ScanWise displays network name, security and hidden status.
3. Password is masked by default.
4. User may reveal or copy the password.
5. User may open Wi-Fi settings.
6. Sharing warns that credentials may be exposed.

## Flow 5: Contact

1. User scans a vCard.
2. ScanWise displays structured fields.
3. User selects which fields to import.
4. User explicitly adds the contact.
5. User may save the original scan to Library.

## Flow 6: Product code

1. User scans a product barcode.
2. ScanWise displays symbology and identifier.
3. Local validation is shown where supported.
4. The app does not invent unavailable product data.
5. User may search externally, copy, add a note or save.

## Flow 7: Save to Library

1. User selects Save.
2. ScanWise suggests a relevant collection.
3. User may select another collection or create one.
4. User may add a note.
5. Record is stored locally.
6. A confirmation snackbar includes Undo.

## Flow 8: Duplicate

1. User scans a previously saved value.
2. ScanWise recognizes the duplicate.
3. Previous title, date, collection and note are shown.
4. User may open the existing record, update the occurrence, save separately or
   dismiss.

## Flow 9: Incognito

1. User activates incognito scanning.
2. ScanWise communicates that accepted scans will not be stored.
3. User scans and uses results normally.
4. No Library record or occurrence is created.

## Flow 10: Permission denied

1. Camera permission is denied.
2. ScanWise explains why access is needed.
3. User may retry, import from gallery or open app settings.
4. The screen remains usable and does not show a broken camera.