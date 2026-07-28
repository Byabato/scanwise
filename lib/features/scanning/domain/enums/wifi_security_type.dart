/// Recognized Wi-Fi QR payload security types (the `T:` field).
///
/// `unknown` covers every value the standard payload does not define
/// (including vendor variants like `WPA2-EAP`) — [WifiPayload.securityRaw]
/// preserves the original text so the UI can still display it.
enum WifiSecurityType { open, wep, wpa, unknown }
