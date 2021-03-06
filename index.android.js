'use strict';

import { NativeModules, processColor } from 'react-native';
var Braintree = NativeModules.Braintree;

module.exports = {
  setup(token) {
    return new Promise(function(resolve, reject) {
      Braintree.setup(token, (test) => resolve(test), (err) => reject(err));
    });
  },

  getCardNonce(cardNumber, expirationMonth, expirationYear) {
    return new Promise(function(resolve, reject) {
      Braintree.getCardNonce(cardNumber, expirationMonth, expirationYear, (nonce) => resolve(nonce), (err) => reject(err))
    });
  },

  showPaymentViewController() {
    return new Promise(function(resolve, reject) {
      Braintree.paymentRequest((nonce) => resolve(nonce), (error) => reject(error));
    });
  },

	showPayPalCheckoutController(amount, currency) {
		return new Promise(function(resolve, reject) {
			Braintree.payWithPayPal(amount, currency || "EUR", (nonce) => resolve(nonce), (error) => reject(error));
		});
	},

  verify3DSecure(paymentNonce, amount) {
    return new Promise(function(resolve, reject) {
      Braintree.verify3DSecure(paymentNonce, amount, (nonce) => resolve(nonce), (error) => reject(error));
    });
  },

	get3DSecureVerifiedCardNonce(cardNumber, expirationMonth, expirationYear, cvv, amount, verify) {
		return new Promise(function(resolve, reject) {
			Braintree.tokenizeCardAndVerify(cardNumber, expirationMonth, expirationYear, cvv, amount, !!verify,
                                      (nonce) => resolve(nonce), (error) => reject(error));
		});
	},

};
