package com.abelium.braintreeccform;

import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
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
    final RCTCreditCardControl control = new RCTCreditCardControl(reactContext);
    control.setBraintreeModule(braintreeModule);
    control.setOnSubmit(new CreditCardControl.SubmitHandler() {
      @Override
      public void submit(String number, String cvv, String month, String year) {
        control.obtainPaymentNonce(number, cvv, month, year);
      }
    });
    return control;
  }
}
