'use strict';

import { NativeModules, processColor } from 'react-native';
import CreditCardUI from './CreditCardUI';

var RCTBraintree = NativeModules.Braintree;

var Braintree = {

	setupWithURLScheme(token, urlscheme) {
		return new Promise(function(resolve, reject) {
			RCTBraintree.setupWithURLScheme(token, urlscheme, function(success) {
				success == true ? resolve(true) : reject("Invalid Token");
			});
		});
	},

	setup(token) {
		return new Promise(function(resolve, reject) {
			RCTBraintree.setup(token, function(success) {
				success == true ? resolve(true) : reject("Invalid Token");
			});
		});
	},

	showPaymentViewController(config = {}) {
    var options = {
      tintColor: processColor(config.tintColor),
      bgColor: processColor(config.bgColor),
      barBgColor: processColor(config.barBgColor),
      barTintColor: processColor(config.barTintColor),
    };
		return new Promise(function(resolve, reject) {
			RCTBraintree.showPaymentViewController(options, function(err, nonce) {
				nonce != null ? resolve(nonce) : reject(err);
			});
		});
	},

	showPayPalViewController() {
		return new Promise(function(resolve, reject) {
			RCTBraintree.showPayPalViewController(function(err, nonce) {
				nonce != null ? resolve(nonce) : reject(err);
			});
		});
	},

	getCardNonce(cardNumber, expirationMonth, expirationYear) {
		return new Promise(function(resolve, reject) {
			RCTBraintree.getCardNonce(cardNumber, expirationMonth, expirationYear, function(err, nonce) {
				nonce != null ? resolve(nonce) : reject(err);
			});
		});
	},

	showPayPalCheckoutController(amount, currency) {
		return new Promise(function(resolve, reject) {
			RCTBraintree.payWithPayPal(String(amount.toFixed(2)), currency || "EUR", function(err, nonce) {
    			nonce != null ? resolve(nonce) : reject(err);
    		});
		});
	},

  verify3DSecure(paymentNonce, amount) {
    return new Promise(function(resolve, reject) {
      RCTBraintree.verify3DSecure(paymentNonce, amount, function(err, nonce) {
        nonce != null ? resolve(nonce) : reject(err);
      });
    });
  },

	get3DSecureVerifiedCardNonce(cardNumber, expirationMonth, expirationYear, cvv, amount, verify) {
		return new Promise(function(resolve, reject) {
			RCTBraintree.tokenizeCardAndVerify(cardNumber, expirationMonth, expirationYear, cvv, amount, !!verify, function(err, nonce) {
    			nonce != null ? resolve(nonce) : reject(err);
    		});
		});
	},

	collectDeviceData() {
		return new Promise(function(resolve, reject) {
			RCTBraintree.collectDeviceData(function(err, nonce) {
				nonce != null ? resolve(nonce) : reject(err);
			});
		});
	},



  CreditCardUI: CreditCardUI,
};

module.exports = Braintree;
