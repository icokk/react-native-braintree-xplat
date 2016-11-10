package com.abelium.braintreeccform;

import android.content.Context;
import android.util.Log;
import android.view.View;

import com.facebook.csslayout.CSSMeasureMode;
import com.facebook.csslayout.CSSNodeAPI;
import com.facebook.csslayout.MeasureOutput;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.uimanager.LayoutShadowNode;
import com.facebook.react.uimanager.annotations.ReactProp;

public class CreditCardShadowNode extends LayoutShadowNode
{
  private static class MeasureCreditCardControl extends CreditCardControl {
    public MeasureCreditCardControl(Context context) {
      super(context);
      initComponents();
    }
  }

  private MeasureCreditCardControl measureControl;

  public CreditCardShadowNode(ReactContext context) {
    this.measureControl = new MeasureCreditCardControl(context);
    setMeasureFunction(measureFunction);
  }

  @ReactProp(name = "hidePayButton")
  public void setHidePayButton(boolean hidePayButton) {
    measureControl.setHidePayButton(hidePayButton);
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
       Log.i(CreditCardControlManager.TAG, String.format("MEASURE %s, %s %s, %s %s", node, width, widthMode, height, heightMode));
      //noinspection WrongConstant
      measureControl.measure(
              View.MeasureSpec.makeMeasureSpec((int) width, translateMeasureSpec(widthMode)),
              View.MeasureSpec.makeMeasureSpec((int) height, translateMeasureSpec(heightMode)));
      measureOutput.width = measureControl.getMeasuredWidth();
      measureOutput.height = measureControl.getMeasuredHeight();
       Log.i(CreditCardControlManager.TAG, String.format("MEASURE RESULT: width=%s height=%s", measureOutput.width, measureOutput.height));
    }
  };
}
