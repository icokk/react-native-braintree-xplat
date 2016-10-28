package com.abelium.braintreeccform;

import android.content.Context;
import android.util.AttributeSet;

import com.facebook.react.bridge.Callback;
import com.pw.droplet.braintree.Braintree;

public class RCTCreditCardControl extends CreditCardControl
{
  public RCTCreditCardControl(Context context) {
    super(context);
  }

  public RCTCreditCardControl(Context context, AttributeSet attrs) {
    super(context, attrs);
  }

  public RCTCreditCardControl(Context context, AttributeSet attrs, int defStyleAttr) {
    super(context, attrs, defStyleAttr);
  }

  private Braintree braintreeModule;
  private boolean require3dSecure = false;
  private boolean requireCVV = true;
  private double amount;
  private Callback onNonceReceived;

  public void obtainPaymentNonce(String number, String cvv, String month, String year) {
    Callback successCallback = new Callback() {
      @Override
      public void invoke(Object... args) {
        String nonce = (String) args[0];
        endSubmit(true, null);
        if ( onNonceReceived != null )
          onNonceReceived.invoke(nonce);
      }
    };
    Callback errorCallback = new Callback() {
      @Override
      public void invoke(Object... args) {
        String errorMessage = (String) args[0];
        endSubmit(false, errorMessage);
      }
    };
    braintreeModule.tokenizeCardAndVerify(number, month, year, cvv, amount, require3dSecure,
      successCallback, errorCallback);
  }

  public Braintree getBraintreeModule() {
    return braintreeModule;
  }

  public void setBraintreeModule(Braintree braintreeModule) {
    this.braintreeModule = braintreeModule;
  }

  public boolean isRequire3dSecure() {
    return require3dSecure;
  }

  public void setRequire3dSecure(boolean require3dSecure) {
    this.require3dSecure = require3dSecure;
  }

  public boolean isRequireCVV() {
    return requireCVV;
  }

  public void setRequireCVV(boolean requireCVV) {
    this.requireCVV = requireCVV;
  }

  public double getAmount() {
    return amount;
  }

  public void setAmount(double amount) {
    this.amount = amount;
  }

  public Callback getOnNonceReceived() {
    return onNonceReceived;
  }

  public void setOnNonceReceived(Callback onNonceReceived) {
    this.onNonceReceived = onNonceReceived;
  }
}
