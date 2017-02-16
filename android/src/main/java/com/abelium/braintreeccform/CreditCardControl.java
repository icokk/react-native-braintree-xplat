package com.abelium.braintreeccform;

import android.content.Context;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.AttributeSet;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
import android.widget.FrameLayout;

import com.abelium.cardvalidator.CardNumberMatch;
import com.abelium.cardvalidator.CreditCardType;
import com.abelium.cardvalidator.CreditCardValidator;
import com.abelium.cardvalidator.DateValidator;
import com.abelium.cardvalidator.DateValidity;
import com.abelium.cardvalidator.ValidatorUtils;
import com.abelium.cardvalidator.Validity;
import com.pw.droplet.braintree.R;

import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.uimanager.events.RCTEventEmitter;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class CreditCardControl extends FrameLayout implements CreditCardField.OnEditorActionListener, View.OnClickListener
{
    public interface SubmitHandler {
        void submit(String number, String cvv, String month, String year);
    }

    private enum ControlType {
        Number, CVV, Month, Year
    }

    private class CCTextWatcher implements TextWatcher {
        private ControlType control;

        public CCTextWatcher(ControlType control) {
            this.control = control;
        }

        @Override
        public void beforeTextChanged(CharSequence s, int start, int count, int after) {
          layoutRequest();
        }

        @Override
        public void onTextChanged(CharSequence s, int start, int before, int count) {
          layoutRequest();
        }

        @Override
        public void afterTextChanged(Editable s) {
            switch ( control ) {
                case Number:
                    if(ccNumber.getText().length() != 0) validateNumber(false);
                    else markField(ControlType.Number, Validity.Complete, false);
                    break;
                case CVV:
                    validateCVV(false);
                    break;
                case Month:
                {
                   if (ccYear != null && ccYear.getText().length() == 0)
                       validateMonth(false);
                   else validateDate(false);

                    break;
                }
                case Year:
                    validateDate(false);
                    break;
            }
        }
    }

    private SubmitHandler onSubmit;
    private CreditCardType requiredCard = null;
    private boolean requireCVV = true;
    private boolean hidePayButton = false;

    private boolean initialized = false;

    private CreditCardField ccNumber, ccCVV, ccMonth, ccYear;
    private Button ccPayBtn;

    private String numberString = "Credit Card Number";
    private String cvvString = "CVC/CVV";
    private String monthString = "Month (MM)";
    private String yearString = "Year (YYYY)";
    private String invalidString = "INVALID";

    public CreditCardControl(Context context) {
        super(context);
        initializeViews(context);
    }

    public CreditCardControl(Context context, AttributeSet attrs) {
        super(context, attrs);
        initializeViews(context);
    }

    public CreditCardControl(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initializeViews(context);
    }

    private void initializeViews(Context context) {
        LayoutInflater inflater = (LayoutInflater) context
                .getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        inflater.inflate(R.layout.cc_layout, this);
    }

    @Override
    protected void onFinishInflate() {
        super.onFinishInflate();
        initComponents();
    }

    private void layoutRequest() {
      this.requestLayout();
    }

    protected void initComponents() {
        if ( initialized )
            return;
        // set fields
        this.ccNumber = (CreditCardField) findViewById(R.id.cc_number);
        this.ccCVV = (CreditCardField) findViewById(R.id.cc_cvv);
        this.ccMonth = (CreditCardField) findViewById(R.id.cc_month);
        this.ccYear = (CreditCardField) findViewById(R.id.cc_year);
        this.ccPayBtn = (Button) findViewById(R.id.cc_pay_btn);
        // control settings
        ccNumber.setShowIcon(true);
        ccNumber.setLabel(getNumberString());
        ccNumber.setImeOptions(EditorInfo.IME_ACTION_NEXT);
        ccCVV.setLabel(getCvvString());
        ccCVV.setImeOptions(EditorInfo.IME_ACTION_DONE);
        ccMonth.setLabel(getMonthString());
        ccMonth.setImeOptions(EditorInfo.IME_ACTION_NEXT);
        ccYear.setLabel(getYearString());
        ccYear.setImeOptions(EditorInfo.IME_ACTION_NEXT);
        // add handlers
        ccNumber.setOnEditorActionListener(this);
        ccCVV.setOnEditorActionListener(this);
        ccMonth.setOnEditorActionListener(this);
        ccYear.setOnEditorActionListener(this);
        //
        ccPayBtn.setOnClickListener(this);
        // add validation handlers
        ccNumber.addTextChangedListener(new CCTextWatcher(ControlType.Number));
        ccCVV.addTextChangedListener(new CCTextWatcher(ControlType.CVV));
        ccMonth.addTextChangedListener(new CCTextWatcher(ControlType.Month));
        ccYear.addTextChangedListener(new CCTextWatcher(ControlType.Year));
        // set control state
        this.ccCVV.setVisibility(requireCVV ? VISIBLE : GONE);
        this.ccPayBtn.setVisibility(hidePayButton ? GONE : VISIBLE);
        //
        initialized = true;
    }

    @Override
    public boolean onEditorAction(CreditCardField v, int actionId, KeyEvent event) {
        if ( actionId == EditorInfo.IME_ACTION_DONE ) {
            ccPayBtn.requestFocus();
            validateAndSubmit();
            return false;
        } else if ( actionId == EditorInfo.IME_ACTION_NEXT ) {
            if ( v == ccNumber )
                ccMonth.requestFocus();
            else if ( v == ccMonth )
                ccYear.requestFocus();
            else if ( v == ccYear )
                ccCVV.requestFocus();
            return true;
        }
        return false;
    }

    @Override
    public void onClick(View v) {
        validateAndSubmit();
    }

    private CreditCardField getControlLayout(ControlType control) {
        switch ( control ) {
            case Number:
                return ccNumber;
            case CVV:
                return ccCVV;
            case Month:
                return ccMonth;
            case Year:
                return ccYear;
        }
        throw new UnsupportedOperationException();
    }

    private void markField(ControlType control, Validity validity, boolean submit) {
        boolean error = validity == Validity.Invalid || (submit && validity == Validity.Partial);
        setError(control, error);
    }

    public static boolean equals(Object a, Object b) {
        return (a == null) ? (b == null) : a.equals(b);
    }

    public void setError(ControlType control, boolean error) {
        CreditCardField field = getControlLayout(control);
        field.setError(error);
        String prevMarker = field.getInvalidMarker();
        field.setInvalidMarker(field.isError() ? getInvalidString() : null);
        if ( !equals(prevMarker, field.getInvalidMarker()) )
            layoutRequest();
    }

    public boolean hasAnyError() {
        CreditCardField[] fields = { ccNumber, ccCVV, ccMonth, ccYear };
        for ( CreditCardField field : fields )
            if ( field.isError() )
                return true;
        return false;
    }

    private Validity validateNumber(boolean submit) {
        CardNumberMatch ccmatch = CreditCardValidator.detectCard(ccNumber.getText());
        Validity validity = ccmatch.getValidity();
        if ( requiredCard != null && requiredCard != ccmatch.getCardType() )
            validity = Validity.Invalid;
        markField(ControlType.Number, validity, submit);
        return ccmatch.getValidity();
    }

    private Validity validateCVV(boolean submit) {
        CreditCardType cardType = requiredCard;
        if ( requiredCard == null )
            cardType = CreditCardValidator.detectCard(ccNumber.getText()).getCardType();
        Validity validity = CreditCardValidator.validateCVC(ccCVV.getText(), cardType);
        markField(ControlType.CVV, validity, submit);
        return validity;
    }

    private Validity validateMonth(boolean submit) {
        DateValidity dv = DateValidator.validateDate(ccMonth.getText(), ccYear.getText());
        markField(ControlType.Month, dv.monthValidity() , submit);
        return dv.monthValidity();
    }

    private Validity validateDate(boolean submit) {
        DateValidity dv = DateValidator.validateDate(ccMonth.getText(), ccYear.getText());
        markField(ControlType.Month, dv.monthValidity(), submit);
        markField(ControlType.Year, dv.yearValidity(), submit);
        return dv.validity();
    }

    private Validity validate(boolean submit) {
        Validity validity = Validity.Complete;
        validity = ValidatorUtils.min(validity, validateNumber(submit));
        validity = ValidatorUtils.min(validity, validateCVV(submit));
        validity = ValidatorUtils.min(validity, validateDate(submit));
        return validity;
    }

    public boolean validateAndSubmit() {
        Validity validity = validate(true);
        if ( validity == Validity.Complete ) {
            submit();
            return true;
        } else {
            showSubmitMode(false);
            Callback errorCallback = new Callback() {
                @Override
                public void invoke(Object... args) {
                    String errorMessage = (String) args[0];
                    // Log.w(TAG, "BRAINTREE ERROR " + errorMessage);
                    // emit event
                    WritableArray res = Arguments.createArray();
                    res.pushNull(); res.pushString(errorMessage);
                    WritableMap eventArgs = Arguments.createMap();
                    eventArgs.putArray("nonce", res);
                    emitEvent("onNonceReceived", eventArgs);
                }
            };
            errorCallback.invoke("Error - Validation Failed.");
            return false;
        }
    }

    private void emitEvent(String name, WritableMap eventArgs) {
        ReactContext reactContext = (ReactContext) getContext();
        RCTEventEmitter eventEmitter = reactContext.getJSModule(RCTEventEmitter.class);
        eventEmitter.receiveEvent(getId(), name, eventArgs);
    }
    
    private void submit() {
        if ( this.onSubmit == null )
            return;
        String number = ccNumber.getText();
        String cvv = requireCVV ? ccCVV.getText() : null;
        DateValidity dv = DateValidator.validateDate(ccMonth.getText(), ccYear.getText());
        String month = String.format(Locale.US, "%02d", dv.getMonth());
        String year = String.format(Locale.US, "%04d", dv.getYear());
        showSubmitMode(true);
        try {
            onSubmit.submit(number, cvv, month, year);
        } catch ( Exception e ) {
            showSubmitMode(false);
            throw e;
        }
    }

    private void showSubmitMode(boolean submitting) {
        View[] controls = { ccNumber, ccCVV, ccMonth, ccYear, ccPayBtn };
        for ( View control : controls )
            control.setEnabled(!submitting);
        layoutRequest();
    }

    // public interface

    public void endSubmit(boolean success, String errorMessage) {
        showSubmitMode(false);
        //if ( !success && errorMessage != null )
          //  setError(ControlType.Number, true);
    }

    public SubmitHandler getOnSubmit() {
        return onSubmit;
    }

    public void setOnSubmit(SubmitHandler onSubmit) {
        this.onSubmit = onSubmit;
    }

    public CreditCardType getRequiredCard() {
        return requiredCard;
    }

    public void setRequiredCard(CreditCardType requiredCard) {
        this.requiredCard = requiredCard;
    }

    public boolean isRequireCVV() {
      return requireCVV;
    }

    public void setRequireCVV(boolean requireCVV) {
        this.requireCVV = requireCVV;
        if (this.ccCVV != null)
            this.ccCVV.setVisibility(requireCVV ? VISIBLE : GONE);
    }

    public void setHidePayButton(boolean hidePayButton) {
        this.hidePayButton = hidePayButton;
        if ( this.ccPayBtn != null )
            this.ccPayBtn.setVisibility(hidePayButton ? GONE : VISIBLE);
    }

    public boolean isHidePayButton() {
        return hidePayButton;
    }

    // string translations

    public String getNumberString() {
        return numberString;
    }

    public void setNumberString(String numberString) {
        this.numberString = numberString;
        if ( ccNumber != null )
            ccNumber.setLabel(numberString);
    }

    public String getCvvString() {
        return cvvString;
    }

    public void setCvvString(String cvvString) {
        this.cvvString = cvvString;
        if ( ccCVV != null )
            ccCVV.setLabel(cvvString);
    }

    public String getMonthString() {
        return monthString;
    }

    public void setMonthString(String monthString) {
        this.monthString = monthString;
        if ( ccMonth != null )
            ccMonth.setLabel(monthString);
    }

    public String getYearString() {
        return yearString;
    }

    public void setYearString(String yearString) {
        this.yearString = yearString;
        if ( ccYear != null )
            ccYear.setLabel(yearString);
    }

    public String getInvalidString() {
        return invalidString;
    }

    public void setInvalidString(String invalidString) {
        this.invalidString = invalidString;
    }

    private List<CreditCardField> fieldList() {
        CreditCardField[] fields = { ccNumber, ccCVV, ccMonth, ccYear };
        List<CreditCardField> result = new ArrayList<>();
        for ( CreditCardField field : fields )
            if ( field != null )
                result.add(field);
        return result;
    }

    public void setFocusColor(Integer color) {
        for ( CreditCardField field : fieldList() )
            field.setFocusColor(color);
    }

    public void setBlurColor(Integer color) {
        for ( CreditCardField field : fieldList() )
            field.setBlurColor(color);
    }

    public void setErrorColor(Integer color) {
        for ( CreditCardField field : fieldList() )
            field.setErrorColor(color);
    }

    public void setIconFont(String font) {
        if ( ccNumber != null )
            ccNumber.setIconFont(font);
    }

    public void setIconGlyph(String text) {
        if ( ccNumber != null )
            ccNumber.setIconGlyph(text);
    }
}
