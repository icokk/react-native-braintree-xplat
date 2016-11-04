package com.abelium.braintreeccform;

import android.annotation.SuppressLint;

import com.abelium.cardvalidator.CreditCardType;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.events.RCTEventEmitter;

@SuppressLint("ViewConstructor")
public class RCTCreditCardControl extends CreditCardControl
{
  private CreditCardControlManager manager;
  private boolean require3dSecure = false;
  private double amount;

  public RCTCreditCardControl(ThemedReactContext context, CreditCardControlManager manager) {
    super(context);
    this.manager = manager;
    initializeHandlers();
  }

  private void initializeHandlers() {
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
        // emit event
        WritableMap eventArgs = Arguments.createMap();
        eventArgs.putString("nonce", nonce);
        emitEvent("onNonceReceived", eventArgs);
      }
    };
    Callback errorCallback = new Callback() {
      @Override
      public void invoke(Object... args) {
        String errorMessage = (String) args[0];
        endSubmit(false, errorMessage);
      }
    };
    manager.getBraintreeModule().tokenizeCardAndVerify(number, month, year, cvv, amount, require3dSecure,
      successCallback, errorCallback);
  }

  private void emitEvent(String name, WritableMap eventArgs) {
    ReactContext reactContext = (ReactContext) getContext();
    RCTEventEmitter eventEmitter = reactContext.getJSModule(RCTEventEmitter.class);
    eventEmitter.receiveEvent(getId(), name, eventArgs);
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
}
