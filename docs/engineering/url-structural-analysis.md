# URL structural analysis

ScanWise assesses URL structure locally and deterministically. It never fetches
a destination, follows redirects, performs DNS, or queries reputation,
certificate, WHOIS, or browsing-history services. Findings describe structure;
they do not prove that a website is safe, malicious, or currently reachable.

## Terminology

The UI says **Destination host**. ScanWise does not calculate a registrable
domain because no approved Public Suffix List implementation is bundled. Naive
last-two-label extraction would be wrong for multi-label public suffixes. No
production dependency was added.

## Severity and ordering

`none`, `information`, `caution`, and `high` are authoritative domain levels.
Overall severity is the highest finding severity. Findings are ordered high,
caution, information, then by stable code. There is no score.

## Finding catalogue

| Code | Level | Deterministic trigger |
|---|---|---|
| `url.http_connection` | caution | HTTP scheme |
| `url.unsupported_scheme` | high | scheme other than HTTP/HTTPS |
| `url.missing_host` | high | empty host |
| `url.embedded_credentials` | high | URI user-info exists |
| `url.explicit_default_port` | information | explicit 80/HTTP or 443/HTTPS |
| `url.unusual_port` | caution | explicit port outside 80, 443, 8080, 8443 |
| `url.ipv4_host` / `url.ipv6_host` | information | IP literal host |
| `url.localhost` | caution | localhost or loopback |
| `url.private_network_host` | caution | RFC1918, IPv4 link-local, IPv6 ULA/link-local |
| `url.excessive_subdomains` | caution | more than five host labels |
| `url.punycode_label` | caution | label begins `xn--` |
| `url.unusual_unicode` | caution | non-ASCII hostname character |
| `url.mixed_script_label` | high | Latin/Greek/Cyrillic mixed in one label |
| `url.shortened_destination` | caution | exact local-catalogue host match |
| `url.excessive_total_length` | caution | more than 2048 characters |
| `url.excessive_hostname_length` | caution | more than 253 characters |
| `url.excessive_label_length` | caution | label longer than 63 characters |
| `url.nested_url_parameter` | information | decoded query value is a URL |
| `url.ambiguous_encoding` | high | malformed or repeated percent encoding |
| `url.malformed_component` | high | control, zero-width, or directional character |

Nested URL evidence records parameter names only. User-info and query values are
never copied into findings. The shortener catalogue is an exact,
case-insensitive set: bit.ly, buff.ly, cutt.ly, is.gd, ow.ly, t.co, and
tinyurl.com. Subdomains do not inherit a match.

## Action policy

No action occurs automatically. Open remains platform-disabled until the
external-action milestone. Caution and high assessments mark it as requiring
confirmation for the future dispatcher. Copy and Save remain available; Share
remains preview-only. Unsupported or malformed destinations cannot produce an
enabled Open action.

## Limitations and deferrals

There is no Public Suffix List, browser-grade confusable/homograph engine,
organization-ownership catalogue, redirect resolution, or online reputation.
Organization-like subdomain claims are deferred because a generic rule would
create unacceptable false positives. Unicode script detection is deliberately
limited to deterministic Latin, Greek, and Cyrillic ranges.

