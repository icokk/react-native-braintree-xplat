package com.abelium.braintreeccform;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableMapKeySetIterator;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.LayoutShadowNode;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.pw.droplet.braintree.Braintree;

import java.util.Map;

import javax.annotation.Nullable;

public class CreditCardControlManager extends ViewGroupManager<RCTCreditCardControl>
{
  public static final String TAG = CreditCardControlManager.class.getName();

  public static final String CLASS_NAME = "RCTCreditCardControl";

  private static final int SUBMIT_CARD_DATA = 1;

  private Braintree braintreeModule;
  private ReactApplicationContext reactContext;

  public CreditCardControlManager(Braintree braintreeModule, ReactApplicationContext reactContext) {
    this.braintreeModule = braintreeModule;
    this.reactContext = reactContext;
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

  @ReactProp(name = "hidePayButton")
  public void setHidePayButton(RCTCreditCardControl control, boolean hidePayButton) {
    control.setHidePayButton(hidePayButton);
  }

  @ReactProp(name = "amount")
  public void setAmount(RCTCreditCardControl control, double amount) {
    control.setAmount(amount);
  }

  @ReactProp(name = "clientToken")
  public void setClientToken(RCTCreditCardControl control, String clientToken) {
    control.setClientToken(clientToken);
  }

  @ReactProp(name = "translations")
  public void setTranslations(RCTCreditCardControl control, ReadableMap translations) {
    ReadableMapKeySetIterator iterator = translations.keySetIterator();
    while ( iterator.hasNextKey() ) {
      String name = iterator.nextKey();
      String text = translations.getString(name);
      switch (name) {
        case "cardNumber":
          control.setNumberString(text);
          break;
        case "cvv":
          control.setCvvString(text);
          break;
        case "month":
          control.setMonthString(text);
          break;
        case "year":
          control.setYearString(text);
          break;
        case "invalid":
          control.setInvalidString(text);
          break;
      }
    }
  }


  @Nullable
  @Override
  public Map<String, Integer> getCommandsMap() {
    return MapBuilder.of(
            "submitCardData", SUBMIT_CARD_DATA
    );
  }

  @Override
  public void receiveCommand(RCTCreditCardControl root, int commandId, @Nullable ReadableArray args) {
    switch ( commandId ) {
      case SUBMIT_CARD_DATA:
        root.validateAndSubmit();
        break;
    }
  }

  @Nullable
  @Override
  public Map<String, Object> getExportedCustomDirectEventTypeConstants() {
    return MapBuilder.of(
      "onNonceReceived", (Object) MapBuilder.of("registrationName", "onNonceReceived")
    );
  }

  @Override
  public LayoutShadowNode createShadowNodeInstance() {
    return new CreditCardShadowNode(reactContext);
  }

  @Override
  public Class<? extends LayoutShadowNode> getShadowNodeClass() {
    return CreditCardShadowNode.class;
  }
}
