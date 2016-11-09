package com.abelium.braintreeccform;

import android.content.Context;
import android.util.Log;
import android.view.View;

import com.braintreepayments.api.exceptions.InvalidArgumentException;
import com.facebook.csslayout.CSSMeasureMode;
import com.facebook.csslayout.CSSNodeAPI;
import com.facebook.csslayout.MeasureOutput;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableArray;
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

  @ReactProp(name = "amount")
  public void setAmount(RCTCreditCardControl control, double amount) {
    control.setAmount(amount);
  }

  @ReactProp(name = "clientToken")
  public void setClientToken(RCTCreditCardControl control, String clientToken) {
    control.setClientToken(clientToken);
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

  // layout calculation

  public static class CreditCardShadowNode extends LayoutShadowNode {
    private CreditCardControl dummyControl;

    public CreditCardShadowNode(Context context) {
      if ( dummyControl == null )
        dummyControl = new CreditCardControl(context);
      setMeasureFunction(measureFunction);
    }

    public static int translateMeasureSpec(CSSMeasureMode mode) {
      switch ( mode ) {
        case AT_MOST: return View.MeasureSpec.AT_MOST;
        case EXACTLY: return View.MeasureSpec.EXACTLY;
        case UNDEFINED: return View.MeasureSpec.UNSPECIFIED;
      }
      return View.MeasureSpec.UNSPECIFIED;
    }

    public final MeasureFunction measureFunction = new MeasureFunction() {
      @Override
      public void measure(CSSNodeAPI node, float width, CSSMeasureMode widthMode, float height, CSSMeasureMode heightMode, MeasureOutput measureOutput) {
        // Log.i(TAG, String.format("MEASURE %s, %s %s, %s %s", node, width, widthMode, height, heightMode));
        //noinspection WrongConstant
        dummyControl.measure(
                View.MeasureSpec.makeMeasureSpec((int) width, translateMeasureSpec(widthMode)),
                View.MeasureSpec.makeMeasureSpec((int) height, translateMeasureSpec(heightMode)));
        measureOutput.width = dummyControl.getMeasuredWidth();
        measureOutput.height = dummyControl.getMeasuredHeight();
        // Log.i(TAG, String.format("MEASURE RESULT: width=%s height=%s", measureOutput.width, measureOutput.height));
      }
    };
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
