package com.abelium.braintreeccform;

import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import com.facebook.react.bridge.Callback;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.pw.droplet.braintree.Braintree;

import java.util.Map;

import javax.annotation.Nullable;

public class CreditCardControlManager extends SimpleViewManager<RCTCreditCardControl>
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
  protected RCTCreditCardControl createViewInstance(ThemedReactContext reactContext) {
    return new RCTCreditCardControl(reactContext, this);
  }

  public Braintree getBraintreeModule() {
    return braintreeModule;
  }

  @ReactProp(name = "requiredCard")
  public void setRequireCVV(RCTCreditCardControl control, String requiredCard) {
    control.setRequiredCardName(requiredCard);
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

  @Nullable
  @Override
  public Map<String, Object> getExportedCustomDirectEventTypeConstants() {
    return MapBuilder.of(
      "onNonceReceived", (Object) MapBuilder.of("registrationName", "onNonceReceived")
    );
  }
}
