package com.pw.droplet.braintree;

import android.content.Intent;
import android.content.Context;
import android.app.Activity;

import com.braintreepayments.api.PayPal;
import com.braintreepayments.api.PaymentRequest;
import com.braintreepayments.api.ThreeDSecure;
import com.braintreepayments.api.interfaces.BraintreeErrorListener;
import com.braintreepayments.api.models.PayPalRequest;
import com.braintreepayments.api.models.PaymentMethodNonce;
import com.braintreepayments.api.BraintreePaymentActivity;
import com.braintreepayments.api.BraintreeFragment;
import com.braintreepayments.api.exceptions.InvalidArgumentException;
import com.braintreepayments.api.models.CardBuilder;
import com.braintreepayments.api.Card;
import com.braintreepayments.api.interfaces.PaymentMethodNonceCreatedListener;

import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ActivityEventListener;

import java.util.Locale;

public class Braintree extends ReactContextBaseJavaModule implements ActivityEventListener {
  private static final int PAYMENT_REQUEST = 1;
  private String token;

  private Callback nonceCreatedCallback;
  private Callback errorCallback;

  private Context mActivityContext;

  private BraintreeFragment mBraintreeFragment;

  public Braintree(ReactApplicationContext reactContext) {
    super(reactContext);
    reactContext.addActivityEventListener(this);
  }

  @Override
  public String getName() {
    return "Braintree";
  }

  public String getToken() {
    return this.token;
  }

  public void setToken(String token) {
    this.token = token;
  }

  @ReactMethod
  public void setup(final String token, final Callback successCallback, final Callback errorCallback) {
    try {
      this.mBraintreeFragment = BraintreeFragment.newInstance(getCurrentActivity(), token);
      this.mBraintreeFragment.addListener(new PaymentMethodNonceCreatedListener() {
        @Override
        public void onPaymentMethodNonceCreated(PaymentMethodNonce paymentMethodNonce) {
          nonceCreatedHandler(paymentMethodNonce.getNonce());
        }
      });
      this.mBraintreeFragment.addListener(new BraintreeErrorListener() {
        @Override
        public void onError(Exception error) {
          errorHandler(error.getMessage());
        }
      });
      this.setToken(token);
      successCallback.invoke(this.getToken());
    } catch (InvalidArgumentException e) {
      errorCallback.invoke(e.getMessage());
    }
  }

  private void nonceCreatedHandler(String nonce) {
    if ( this.nonceCreatedCallback != null )
      this.nonceCreatedCallback.invoke(nonce);
  }

  private void errorHandler(Object errorMessage) {
    if ( this.errorCallback !=  null )
      this.errorCallback.invoke(errorMessage);
  }

  @ReactMethod
  public void getCardNonce(final String cardNumber, final String expirationMonth, final String expirationYear, final Callback successCallback, final Callback errorCallback) {
    try {
      this.nonceCreatedCallback = successCallback;
      this.errorCallback = errorCallback;

      CardBuilder cardBuilder = new CardBuilder()
        .cardNumber(cardNumber)
        .expirationMonth(expirationMonth)
        .expirationYear(expirationYear);

      Card.tokenize(this.mBraintreeFragment, cardBuilder);
    } catch (Exception e) {
      errorCallback.invoke(e.getMessage());
    }
  }

  @ReactMethod
  public void paymentRequest(final Callback successCallback, final Callback errorCallback) {
    try {
      this.nonceCreatedCallback = successCallback;
      this.errorCallback = errorCallback;

      PaymentRequest paymentRequest = new PaymentRequest()
        .clientToken(this.getToken());

      Activity currentActivity = getCurrentActivity();
      if ( currentActivity != null ) {
        currentActivity.startActivityForResult(
          paymentRequest.getIntent(currentActivity),
          PAYMENT_REQUEST
        );
      }
    } catch (Exception e) {
      errorCallback.invoke(e.getMessage());
    }
  }

  @Override
  public void onActivityResult(final int requestCode, final int resultCode, final Intent data) {
    if (requestCode == PAYMENT_REQUEST) {
      switch (resultCode) {
        case Activity.RESULT_OK:
          PaymentMethodNonce paymentMethodNonce = data.getParcelableExtra(
            BraintreePaymentActivity.EXTRA_PAYMENT_METHOD_NONCE
          );
          this.nonceCreatedHandler(paymentMethodNonce.getNonce());
          break;
        case BraintreePaymentActivity.BRAINTREE_RESULT_DEVELOPER_ERROR:
        case BraintreePaymentActivity.BRAINTREE_RESULT_SERVER_ERROR:
        case BraintreePaymentActivity.BRAINTREE_RESULT_SERVER_UNAVAILABLE:
          this.errorHandler(
            data.getSerializableExtra(BraintreePaymentActivity.EXTRA_ERROR_MESSAGE)
          );
          break;
        default:
          break;
      }
    }
  }

  @ReactMethod
  public void verify3DSecure(String paymentNonce, double amount, final Callback successCallback, final Callback errorCallback) {
    try {
      this.nonceCreatedCallback = successCallback;
      this.errorCallback = errorCallback;

      String amountStr = String.format(Locale.US, "%.2f", amount);

      ThreeDSecure.performVerification(mBraintreeFragment, paymentNonce, amountStr);
    } catch (Exception e) {
      errorCallback.invoke(e.getMessage());
    }
  }

  @ReactMethod
  public void tokenizeCardAndVerify(String cardNumber, String expirationMonth, String expirationYear, String cvv, double amount, boolean verify,
                                    final Callback successCallback, final Callback errorCallback)
  {
    try {
      this.nonceCreatedCallback = successCallback;
      this.errorCallback = errorCallback;

      CardBuilder cardBuilder = new CardBuilder()
        .cardNumber(cardNumber)
        .expirationMonth(expirationMonth)
        .expirationYear(expirationYear)
        .cvv(cvv);

      if ( verify ) {
        String amountStr = String.format(Locale.US, "%.2f", amount);
        ThreeDSecure.performVerification(this.mBraintreeFragment, cardBuilder, amountStr);
      } else {
        Card.tokenize(this.mBraintreeFragment, cardBuilder);
      }
    } catch (Exception e) {
      errorCallback.invoke(e.getMessage());
    }
  }

  @ReactMethod
  public void payWithPayPal(double amount, String currency, final Callback successCallback, final Callback errorCallback) {
    try {
      this.nonceCreatedCallback = successCallback;
      this.errorCallback = errorCallback;

      String amountStr = String.format(Locale.US, "%.2f", amount);

      PayPalRequest request = new PayPalRequest(amountStr)
        .currencyCode(currency);

      PayPal.requestOneTimePayment(mBraintreeFragment, request);
    } catch (Exception e) {
      errorCallback.invoke(e.getMessage());
    }
  }

}
