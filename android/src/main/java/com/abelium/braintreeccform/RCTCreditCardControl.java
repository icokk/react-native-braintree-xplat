package com.abelium.braintreeccform;

import android.content.Context;
import android.util.AttributeSet;

import com.abelium.cardvalidator.CreditCardType;
import com.facebook.react.bridge.Callback;
import com.pw.droplet.braintree.Braintree;

public class RCTCreditCardControl extends CreditCardControl
{
  private Braintree braintreeModule;
  private boolean require3dSecure = false;
  private double amount;
  private Callback onNonceReceived;

  public RCTCreditCardControl(Context context) {
    super(context);
    initialize();
  }

  public RCTCreditCardControl(Context context, AttributeSet attrs) {
    super(context, attrs);
    initialize();
  }

  public RCTCreditCardControl(Context context, AttributeSet attrs, int defStyleAttr) {
    super(context, attrs, defStyleAttr);
    initialize();
  }

  private void initialize() {
    setOnSubmit(new CreditCardControl.SubmitHandler() {
      @Override
      public void submit(String number, String cvv, String month, String year) {
        obtainPaymentNonce(number, cvv, month, year);
      }
    });
  }

  private void obtainPaymentNonce(String number, String cvv, String month, String year) {
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

  public String getRequiredCardName() {
    CreditCardType card = getRequiredCard();
    return card == null ? null : card.getName();
  }

  public void setRequiredCardName(String requiredCard) {
    setRequiredCard(CreditCardType.byName(requiredCard));
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
