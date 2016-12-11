package com.abelium.braintreeccform;

import android.app.Activity;
import android.content.Context;
import android.content.ContextWrapper;
import android.content.res.AssetManager;
import android.graphics.Typeface;
import android.text.TextWatcher;
import android.util.AttributeSet;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.pw.droplet.braintree.R;

public class CreditCardField extends LinearLayout
{
    public static final String TAG = CreditCardField.class.getName();

    public interface OnEditorActionListener {
        boolean onEditorAction(CreditCardField v, int actionId, KeyEvent event);
    }


    private boolean initialized = false;
    private boolean error = false;
    private boolean focused = false;

    public CreditCardField(Context context) {
        super(context);
        initializeViews(context);
    }

    public CreditCardField(Context context, AttributeSet attrs) {
        super(context, attrs);
        initializeViews(context);
    }

    public CreditCardField(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initializeViews(context);
    }

    private void initializeViews(Context context) {
        LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        inflater.inflate(R.layout.cc_field, this);
    }

    @Override
    protected void onFinishInflate() {
        super.onFinishInflate();
        initComponents();
    }

    private Activity getActivity() {
        Context context = getContext();
        while (context instanceof ContextWrapper) {
            if (context instanceof Activity) {
                return (Activity)context;
            }
            context = ((ContextWrapper)context).getBaseContext();
        }
        return null;
    }

    private TextView ccLabel;
    private LinearLayout ccFieldLayout;
    private TextView ccIcon;
    private EditText ccText;
    private TextView ccInvalidMarker;
    private View ccUnderline;

    private static final Object iconFontLock = new Object();
    private static Typeface iconFont = null;

    protected void initComponents() {
        if (initialized)
            return;
        // layout params
        this.setOrientation(VERTICAL);
        // save components
        this.ccLabel = (TextView) findViewById(R.id.cc_label);
        this.ccFieldLayout = (LinearLayout) findViewById(R.id.cc_field_layout);
        this.ccIcon = (TextView) findViewById(R.id.cc_icon);
        this.ccText = (EditText) findViewById(R.id.cc_text);
        this.ccInvalidMarker = (TextView) findViewById(R.id.cc_invalid_marker);
        this.ccUnderline = (View) findViewById(R.id.cc_underline);
        // set icon font
        synchronized (iconFontLock) {
            if (iconFont == null) {
                try {
                    AssetManager assets = getActivity().getAssets();
                    iconFont = Typeface.createFromAsset(assets, "fonts/FontAwesome.ttf");
                } catch ( Exception e ) {
                    Log.e(TAG, "Cannot find font FontAwesome.ttf");
                }
            }
        }
        if ( iconFont != null )
            ccIcon.setTypeface(iconFont);
        // set focus listener
        ccText.setOnFocusChangeListener(new OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                setFocusLayout(hasFocus);
            }
        });
        // set start focus state
        setFocusLayout(false);
        //
        initialized = true;
    }

    public boolean getShowIcon() {
        return ccIcon.getVisibility() == VISIBLE;
    }

    public void setShowIcon(boolean showIcon) {
        ccIcon.setVisibility(showIcon ? VISIBLE : GONE);
    }

    public String getInvalidMarker() {
        return ccInvalidMarker.getVisibility() == VISIBLE ? ccInvalidMarker.getText().toString() : null;
    }

    public void setInvalidMarker(String text) {
        if ( text == null ) {
            ccInvalidMarker.setVisibility(GONE);
            ccInvalidMarker.setText("");
        } else {
            ccInvalidMarker.setText(text);
            ccInvalidMarker.setVisibility(VISIBLE);
            ccInvalidMarker.setTextColor(errorColor);
        }
    }

    public String getText() {
        return ccText.getText().toString();
    }

    public void setText(String text) {
        ccText.setText(text);
    }

    public String getLabel() {
        return ccLabel.getText().toString();
    }

    public void setLabel(String text) {
        ccLabel.setText(text);
        ccText.setHint(text);
    }

    public boolean isEnabled() {
        return ccText.isEnabled();
    }

    public void setEnabled(boolean enabled) {
        super.setEnabled(enabled);
        ccText.setEnabled(enabled);
    }

    public int getImeOptions() {
        return ccText.getImeOptions();
    }

    public void setImeOptions(int imeOptions) {
        ccText.setImeOptions(imeOptions);
    }

    public void addTextChangedListener(TextWatcher textWatcher) {
        ccText.addTextChangedListener(textWatcher);
    }

    public void setOnEditorActionListener(final OnEditorActionListener listener) {
        ccText.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                return listener.onEditorAction(CreditCardField.this, actionId, event);
            }
        });
    }

    int focusedColor = 0xFF4B4B4B;
    //int blurColor = 0xFFF2F4F8;
    int blurColor = 0xFFA0A0A0;
    int errorColor = 0xFFD0011B;

    private void setFocusLayout(boolean focused) {
        this.focused = focused;
        //
        ccLabel.setVisibility(focused ? VISIBLE : GONE);
        // margins
        MarginLayoutParams margin = (MarginLayoutParams) ccFieldLayout.getLayoutParams();
        margin.topMargin = focused ? 4 : 22;
        margin.bottomMargin = focused ? 4 : 15;
        ViewGroup.LayoutParams underlineParams = ccUnderline.getLayoutParams();
        underlineParams.height = focused ? 2 : 1;
        // colors
        updateColors();
        ccText.getNextFocusDownId();
    }

    private void updateColors() {
        ccText.setTextColor(textColor());
        ccText.setHintTextColor(hintColor());
        ccLabel.setTextColor(labelColor());
        ccIcon.setTextColor(labelColor());
        ccUnderline.setBackgroundColor(labelColor());
    }

    private int textColor() {
        return focused ? focusedColor : blurColor;
    }

    private int hintColor() {
        return focused ? 0 : blurColor;
    }

    private int labelColor() {
        return error ? errorColor : textColor();
    }

    public boolean isError() {
        return error;
    }

    public void setError(boolean error) {
        this.error = error;
        updateColors();
    }
}
