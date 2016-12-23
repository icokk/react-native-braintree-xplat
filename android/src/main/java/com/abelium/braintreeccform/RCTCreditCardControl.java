package com.abelium.braintreeccform;

import android.annotation.SuppressLint;
import android.util.Log;
import java.util.ArrayList;

import com.abelium.cardvalidator.CreditCardType;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableArray;

import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.pw.droplet.braintree.Braintree;

@SuppressLint("ViewConstructor")
public class RCTCreditCardControl extends CreditCardControl
{
  public static final String TAG = RCTCreditCardControl.class.getName();

  private CreditCardControlManager manager;
  private boolean require3dSecure = false;
  private double amount;
  private String clientToken;

  public RCTCreditCardControl(ReactContext context, CreditCardControlManager manager) {
    super(context);
    this.manager = manager;
    setHidePayButton(true);
    initComponents();       // must call here beacuse onFinishInflate is not called in react native
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
        WritableArray res = Arguments.createArray();
        res.pushString(nonce); res.pushNull();
        WritableMap eventArgs = Arguments.createMap();
        eventArgs.putArray("nonce", res);
        emitEvent("onNonceReceived", eventArgs);
      }
    };
    Callback errorCallback = new Callback() {
      @Override
      public void invoke(Object... args) {
        String errorMessage = (String) args[0];
        Log.w(TAG, "BRAINTREE ERROR " + errorMessage);
        endSubmit(false, errorMessage);
        // emit event
        WritableArray res = Arguments.createArray();
        res.pushNull(); res.pushString(errorMessage);
        WritableMap eventArgs = Arguments.createMap();
        eventArgs.putArray("nonce", res);
        emitEvent("onNonceReceived", eventArgs);
      }
    };
    try {
      Braintree braintreeModule = manager.getBraintreeModule();
      if ( clientToken != null && !clientToken.equals(braintreeModule.getToken()) )
        braintreeModule.setup(clientToken);
      braintreeModule.tokenizeCardAndVerify(number, month, year, cvv, amount, require3dSecure,
        successCallback, errorCallback);
    } catch (Exception e) {
      Log.e(TAG, "Could not initialize payment gateway", e);
      errorCallback.invoke("Could not initialize payment gateway");
    }
  }

  private void emitEvent(String name, WritableMap eventArgs) {
    ReactContext reactContext = (ReactContext) getContext();
    RCTEventEmitter eventEmitter = reactContext.getJSModule(RCTEventEmitter.class);
    eventEmitter.receiveEvent(getId(), name, eventArgs);
  }

  private final Runnable measureAndLayout = new Runnable() {
    @Override
    public void run() {
      measure(MeasureSpec.makeMeasureSpec(getWidth(), MeasureSpec.EXACTLY),
              MeasureSpec.makeMeasureSpec(getHeight(), MeasureSpec.EXACTLY));
      layout(getLeft(), getTop(), getRight(), getBottom());
    }
  };

  @Override
  public void requestLayout() {
    super.requestLayout();
    // Log.i(TAG, "requestLayout " + this);
    post(measureAndLayout);
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

  public String getClientToken() {
    return clientToken;
  }

  public void setClientToken(String clientToken) {
    // Log.i(TAG, "SET CLIENT TOKEN " + clientToken);
    this.clientToken = clientToken;
  }
}
