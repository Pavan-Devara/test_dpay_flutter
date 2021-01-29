library dpay_flutter;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:logger/logger.dart';
import 'package:webview_flutter/webview_flutter.dart';


const String BASE_URL = "https://checkout-staging.durianpay.id";
const String CHECKOUT_URL = BASE_URL + "/public";
const String LOCAL_BASE_URL = "http://10.0.2.2:4000";
const String LOCAL_CHECKOUT_URL = LOCAL_BASE_URL + "/public";

class CheckoutOptions {
  String _accessToken;
  String _environment;
  String _locale;
  String _siteName;
  String themeColor;
  String accentColor;
  String currency;
  String _orderId;
  String _customerId;
  String customerEmail;
  String customerGivenName;
  String customerMobile;
  String customerAddressLine1;
  String customerAddressLine2;
  String customerCity;
  String customerRegion;
  String customerCountry;
  String customerPostalCode;


  String get accessToken => _accessToken;

  set accessToken(String accessToken) {
    _accessToken = accessToken;
  }

  String get environment => _environment;

  set environment(String environment) {
    _environment = environment;
  }

  String get locale => _locale;

  set locale(String locale) {
    _locale = locale;
  }

  String get siteName => _siteName;

  set siteName(String site_name) {
    _siteName = site_name;
  }

  String get orderId => _orderId;

  set orderId(String order_id) {
    _orderId = order_id;
  }

  String get customerId => _customerId;

  set customerId(String customer_id) {
    _customerId = customer_id;
  }
}

var logger = Logger();

class Durianpay {
  static checkout(
      BuildContext context,
      CheckoutOptions checkoutOptions
      ) {
    var buffer = new StringBuffer();
    if(checkoutOptions.accessToken != null) {
      buffer.write("&access_key=");
      buffer.write(checkoutOptions.accessToken);
    }
    if(checkoutOptions.environment != null) {
      buffer.write("&environment=");
      buffer.write(checkoutOptions.environment);
    }
    if(checkoutOptions.locale != null) {
      buffer.write("&locale=");
      buffer.write(checkoutOptions.locale);
    }
    if(checkoutOptions.siteName != null) {
      buffer.write("&site_name=");
      buffer.write(checkoutOptions.siteName);
    }
    if(checkoutOptions.orderId != null) {
      buffer.write("&order_id=");
      buffer.write(checkoutOptions.orderId);
    }
    if(checkoutOptions.customerId != null) {
      buffer.write("&customer_id=");
      buffer.write(checkoutOptions.customerId);
    }
    logger.d("url", buffer.toString());
    var url = buffer.toString();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DurianpayCheckout(url: url)),
    );
  }
}

class DurianpayCheckout extends StatelessWidget {
  var url;
  InAppWebViewController _webViewController;
  final Set<JavascriptChannel> jsChannels = [
    JavascriptChannel(
        name: 'android',
        onMessageReceived: (JavascriptMessage message) {
          logger.d("success", message.message);
          print(message.message);
        }),
  ].toSet();
  DurianpayCheckout({Key key, this.url}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("DurianPay")),
        body: Container(
            child: InAppWebView(
              initialUrl: LOCAL_CHECKOUT_URL + "?" + url,
              initialHeaders: {},
              onWebViewCreated: (InAppWebViewController controller) {
                _webViewController = controller;
              },
              initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                      debuggingEnabled: true,
                      useShouldOverrideUrlLoading: true
                  ),
                  android: AndroidInAppWebViewOptions(
                      supportMultipleWindows: true
                  )
              ),
              onCreateWindow: (controller, onCreateWindowRequest) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                        content: Container(
                            width: 700,
                            child: Column(children: <Widget>[
                              Expanded(
                                  child: InAppWebView(
                                    initialUrl: onCreateWindowRequest.url,
                                    initialOptions: InAppWebViewGroupOptions(
                                        crossPlatform: InAppWebViewOptions(
                                            debuggingEnabled: true,
                                            useShouldOverrideUrlLoading: true)),
                                    onLoadStart: (InAppWebViewController controller,
                                        String url) {},
                                    onLoadStop: (controller, url) async {
                                      print(url);
                                      if (url == "myURL") {
                                        Navigator.pop(context);
                                        return;
                                      }
                                    },
                                    shouldOverrideUrlLoading: (controller,
                                        shouldOverrideUrlLoadingRequest) async {
                                      print(shouldOverrideUrlLoadingRequest.url);
                                      // if (shouldOverrideUrlLoadingRequest.url == "myURL") {
                                      //   Navigator.pop(context);
                                      // }
                                      return ShouldOverrideUrlLoadingAction.ALLOW;
                                    },
                                  ))
                            ])));
                  },
                );
              },
            )
        )
    );
  }
}