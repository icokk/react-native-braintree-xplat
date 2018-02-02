import React, { PropTypes } from 'react'
import { View, requireNativeComponent, Platform, NativeModules, findNodeHandle, ColorPropType, processColor } from 'react-native'

export default class CreditCardControl extends React.Component {
  static displayName = "CreditCardControl";

  static propTypes = {
    // include the default view properties
    ...View.propTypes,
    // extra properties
    clientToken: PropTypes.string,
    requiredCard: PropTypes.string,
    require3dSecure: PropTypes.bool,
    requireCVV: PropTypes.bool,
    hidePayButton: PropTypes.bool,
    amount: PropTypes.number,
    // callbacks
    onNonceReceived: PropTypes.func,
    // translations
    translations: PropTypes.shape({
        cardNumber: PropTypes.string,
        cvv: PropTypes.string,
        month: PropTypes.string,
        year: PropTypes.string,
        invalid: PropTypes.string,
    }),
    // colors
    focusColor: ColorPropType,
    blurColor: ColorPropType,
    errorColor: ColorPropType,
    // icon font and glyph
    showIcon: PropTypes.bool,
    iconFont: PropTypes.string,
    iconGlyph: PropTypes.string,
  };

  _onNonceReceived(event) {
    if ( this.props.onNonceReceived ) {
      var nonce = null, error = null;
      var result = event.nativeEvent.nonce;
      if (Array.isArray(result)) {
        nonce = result[0];
        error = result[1];
      } else {
        nonce = result;
      }
      this.props.onNonceReceived(nonce, error);
    }
  }

  submitCardData() {
    this._runCommand("submitCardData", []);
  }

  _runCommand(name, args) {
    switch (Platform.OS) {
      case 'android':
        NativeModules.UIManager.dispatchViewManagerCommand(
            findNodeHandle(this.nativeControl),
            NativeModules.UIManager.RCTCreditCardControl.Commands[name],
            args
        );
        break;
      case 'ios':
        NativeModules.RCTCreditCardControl[name].apply(
            NativeModules.RCTCreditCardControl[name],
            [findNodeHandle(this.nativeControl), ...args]
        );
        break;
      default:
        break;
    }
  }

  render() {
    return (
      <RCTCreditCardControl {...this.props}
        focusColor={processColor(this.props.focusColor)}
        blurColor={processColor(this.props.blurColor)}
        errorColor={processColor(this.props.errorColor)}
        ref={(ref) => { this.nativeControl = ref; }}
        onNonceReceived={(event) => { this._onNonceReceived(event); }}
      />
    );
  }
}

const RCTCreditCardControl = requireNativeComponent('RCTCreditCardControl', CreditCardControl);
