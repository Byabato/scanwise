class UrlAnalysisPolicy {
  const UrlAnalysisPolicy._();

  static const supportedSchemes = {'http', 'https'};
  static const commonPorts = {80, 443, 8080, 8443};
  static const shortenerHosts = {
    'bit.ly',
    'buff.ly',
    'cutt.ly',
    'is.gd',
    'ow.ly',
    't.co',
    'tinyurl.com',
  };

  static const maximumUrlLength = 2048;
  static const maximumHostnameLength = 253;
  static const maximumLabelLength = 63;
  static const maximumHostLabels = 5;
  static const maximumQueryParameters = 20;
}
