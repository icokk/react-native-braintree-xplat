package com.abelium.braintreeccform;

import android.content.Context;
import android.support.design.widget.TextInputLayout;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.AttributeSet;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.abelium.cardvalidator.CardNumberMatch;
import com.abelium.cardvalidator.CreditCardType;
import com.abelium.cardvalidator.CreditCardValidator;
import com.abelium.cardvalidator.DateValidator;
import com.abelium.cardvalidator.DateValidity;
import com.abelium.cardvalidator.ValidatorUtils;
import com.abelium.cardvalidator.Validity;
import com.pw.droplet.braintree.R;

import java.util.Locale;

public class CreditCardControl extends FrameLayout implements TextView.OnEditorActionListener, View.OnClickListener
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
        public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

        @Override
        public void onTextChanged(CharSequence s, int start, int before, int count) {}

        @Override
        public void afterTextChanged(Editable s) {
            switch ( control ) {
                case Number:
                    validateNumber(false);
                    break;
                case CVV:
                    validateCVV(false);
                    break;
                case Month:
                case Year:
                    validateDate(false);
                    break;
            }
        }
    }

    private SubmitHandler onSubmit;
    private CreditCardType requiredCard = null;
    private boolean requireCVV = true;

    private boolean initialized = false;
    private EditText ccNumber, ccCVV, ccMonth, ccYear;
    private TextInputLayout ccNumberLayout, ccCVVLayout, ccMonthLayout, ccYearLayout;
    private Button ccPayBtn;
    private ProgressBar ccSpinner;

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
        inflater.inflate(R.layout.cc_control, this);
    }

    @Override
    protected void onFinishInflate() {
        super.onFinishInflate();
        initComponents();
    }

    protected void initComponents() {
        if ( initialized )
            return;
        // set fields
        this.ccNumber = (EditText) findViewById(R.id.cc_number);
        this.ccCVV = (EditText) findViewById(R.id.cc_cvv);
        this.ccMonth = (EditText) findViewById(R.id.cc_month);
        this.ccYear = (EditText) findViewById(R.id.cc_year);
        this.ccNumberLayout = (TextInputLayout) findViewById(R.id.cc_number_layout);
        this.ccCVVLayout = (TextInputLayout) findViewById(R.id.cc_cvv_layout);
        this.ccMonthLayout = (TextInputLayout) findViewById(R.id.cc_month_layout);
        this.ccYearLayout = (TextInputLayout) findViewById(R.id.cc_year_layout);
        this.ccPayBtn = (Button) findViewById(R.id.cc_pay_btn);
        this.ccSpinner = (ProgressBar) findViewById(R.id.ctrlActivityIndicator);
        // add handlers
        ccNumber.setOnEditorActionListener(this);
        ccCVV.setOnEditorActionListener(this);
        ccMonth.setOnEditorActionListener(this);
        ccYear.setOnEditorActionListener(this);
        ccPayBtn.setOnClickListener(this);
        // add validation handlers
        ccNumber.addTextChangedListener(new CCTextWatcher(ControlType.Number));
        ccCVV.addTextChangedListener(new CCTextWatcher(ControlType.CVV));
        ccMonth.addTextChangedListener(new CCTextWatcher(ControlType.Month));
        ccYear.addTextChangedListener(new CCTextWatcher(ControlType.Year));
        // set control state
        this.ccCVV.setVisibility(requireCVV ? VISIBLE : GONE);
        //
        initialized = true;
    }

    @Override
    public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
        if ( actionId == EditorInfo.IME_ACTION_DONE ) {
            ccPayBtn.requestFocus();
            validateAndSubmit();
            return false;
        }
        return false;
    }

    @Override
    public void onClick(View v) {
        validateAndSubmit();
    }

    private String getErrorMessage(ControlType control, Validity validity) {
        if ( control == ControlType.Number )
            return getContext().getString(R.string.invalid_cc_number);
        if ( control == ControlType.CVV )
            return getContext().getString(R.string.invalid_cc_cvv);
        if ( control == ControlType.Month )
            return getContext().getString(R.string.invalid_cc_date);
        return " ";  // year doesn't have it's own error message
    }

    private void markField(ControlType control, TextInputLayout layout, Validity validity, boolean submit) {
        if ( validity == Validity.Invalid || (submit && validity == Validity.Partial) ) {
            layout.setErrorEnabled(true);
            layout.setError(getErrorMessage(control, validity));
        } else {
            layout.setError(null);
            layout.setErrorEnabled(false);
        }
    }

    private Validity validateNumber(boolean submit) {
        CardNumberMatch ccmatch = CreditCardValidator.detectCard(ccNumber.getText().toString());
        Validity validity = ccmatch.getValidity();
        if ( requiredCard != null && requiredCard != ccmatch.getCardType() )
            validity = Validity.Invalid;
        markField(ControlType.Number, ccNumberLayout, validity, submit);
        return ccmatch.getValidity();
    }

    private Validity validateCVV(boolean submit) {
        CreditCardType cardType = requiredCard;
        if ( requiredCard == null )
            cardType = CreditCardValidator.detectCard(ccNumber.getText().toString()).getCardType();
        Validity validity = CreditCardValidator.validateCVC(ccCVV.getText().toString(), cardType);
        markField(ControlType.CVV, ccCVVLayout, validity, submit);
        return validity;
    }

    private Validity validateDate(boolean submit) {
        DateValidity dv = DateValidator.validateDate(ccMonth.getText().toString(), ccYear.getText().toString());
        markField(ControlType.Month, ccMonthLayout, dv.validity(), submit);
        markField(ControlType.Year, ccYearLayout, dv.validity(), submit);
        return dv.validity();
    }

    private Validity validate(boolean submit) {
        Validity validity = Validity.Complete;
        validity = ValidatorUtils.min(validity, validateNumber(submit));
        validity = ValidatorUtils.min(validity, validateCVV(submit));
        validity = ValidatorUtils.min(validity, validateDate(submit));
        return validity;
    }

    private boolean validateAndSubmit() {
        Validity validity = validate(true);
        if ( validity == Validity.Complete ) {
            submit();
            return true;
        } else {
            showSubmitMode(false);
            return false;
        }
    }

    private void submit() {
        if ( this.onSubmit == null )
            return;
        String number = ccNumber.getText().toString();
        String cvv = requireCVV ? ccCVV.getText().toString() : null;
        DateValidity dv = DateValidator.validateDate(ccMonth.getText().toString(), ccYear.getText().toString());
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
        View[] controls = { ccNumber, ccCVV, ccMonth, ccYear,
                ccNumberLayout, ccCVVLayout, ccMonthLayout, ccYearLayout,
                ccPayBtn };
        for ( View control : controls )
            control.setEnabled(!submitting);
        ccSpinner.setVisibility(submitting ? VISIBLE : GONE);
    }

    // public interface

    public void endSubmit(boolean success, String errorMessage) {
        showSubmitMode(false);
        if ( !success && errorMessage != null )
            ccNumberLayout.setError(getContext().getString(R.string.error_cc_not_accepted));
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
      if ( this.ccCVV != null )
        this.ccCVV.setVisibility(requireCVV ? VISIBLE : GONE);
    }
}
