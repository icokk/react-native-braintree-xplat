package com.abelium.braintreeccform;

import com.facebook.react.bridge.Callback;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.pw.droplet.braintree.Braintree;

public class CreditCardControlManager extends SimpleViewManager<CreditCardControl>
{
  public static final String CLASS_NAME = "RCTCreditCardControl";

  private Braintree braintreeModule;

  public CreditCardControlManager(Braintree braintreeModule) {
    this.braintreeModule = braintreeModule;
  }

  @Override
  public String getName() {
    return CLASS_NAME;
  }

  @Override
  protected CreditCardControl createViewInstance(ThemedReactContext reactContext) {
    RCTCreditCardControl control = new RCTCreditCardControl(reactContext);
    control.setBraintreeModule(braintreeModule);
    return control;
  }

  @ReactProp(name = "require3dSecure")
  public void setRequire3dSecure(RCTCreditCardControl control, boolean require3dSecure) {
    control.setRequire3dSecure(require3dSecure);
  }

  @ReactProp(name = "requireCVV")
  public void setRequireCVV(RCTCreditCardControl control, boolean requireCVV) {
    control.setRequireCVV(requireCVV);
  }

  @ReactProp(name = "amount")
  public void setAmount(RCTCreditCardControl control, double amount) {
    control.setAmount(amount);
  }

  @ReactProp(name = "onNonceReceived")
  public void setOnNonceReceived(RCTCreditCardControl control, Callback onNonceReceived) {
    control.setOnNonceReceived(onNonceReceived);
  }
}
