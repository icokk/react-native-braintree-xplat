package com.abelium.braintreeccform;

import android.content.Context;
import android.view.View;

import com.facebook.yoga.YogaMeasureMode;
import com.facebook.yoga.YogaMeasureFunction;
import com.facebook.yoga.YogaNode;
import com.facebook.yoga.YogaMeasureOutput;
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

  public static int translateMeasureSpec(YogaMeasureMode mode) {
    switch ( mode ) {
      case AT_MOST: return View.MeasureSpec.AT_MOST;
      case EXACTLY: return View.MeasureSpec.EXACTLY;
      case UNDEFINED: return View.MeasureSpec.UNSPECIFIED;
    }
    return View.MeasureSpec.UNSPECIFIED;
  }

  public final YogaMeasureFunction measureFunction = new YogaMeasureFunction() {
    @Override
    public long measure(YogaNode node, float width, YogaMeasureMode widthMode, float height, YogaMeasureMode heightMode) {
      //noinspection WrongConstant
      measureControl.measure(
        View.MeasureSpec.makeMeasureSpec((int) width, translateMeasureSpec(widthMode)),
        View.MeasureSpec.makeMeasureSpec((int) height, translateMeasureSpec(heightMode)));
      return YogaMeasureOutput.make(measureControl.getMeasuredWidth(), measureControl.getMeasuredHeight());
    }
  };
}
