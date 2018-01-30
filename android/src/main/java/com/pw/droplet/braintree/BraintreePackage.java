package com.pw.droplet.braintree;

import com.abelium.braintreeccform.CreditCardControlManager;
import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.JavaScriptModule;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ViewManager;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class BraintreePackage implements ReactPackage {
  private Braintree braintreeInstance;

  private synchronized Braintree getBraintreeInstance(ReactApplicationContext reactContext) {
    if ( braintreeInstance == null )
      braintreeInstance = new Braintree(reactContext);
    return braintreeInstance;
  }

  @Override
  public List<NativeModule> createNativeModules(ReactApplicationContext reactContext) {
    List<NativeModule> modules = new ArrayList<>();
    modules.add(getBraintreeInstance(reactContext));
    return modules;
  }

  @Override
  public List<ViewManager> createViewManagers(ReactApplicationContext reactContext) {
    List<ViewManager> viewManagers = new ArrayList<>();
    viewManagers.add(new CreditCardControlManager(getBraintreeInstance(reactContext), reactContext));
    return viewManagers;
  }
}
