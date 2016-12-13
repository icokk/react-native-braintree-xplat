import React, { PropTypes } from 'react'
import { View, requireNativeComponent, Platform, NativeModules, findNodeHandle, ColorPropType, processColor } from 'react-native'

export default class CrediCardUI extends React.Component {
  static displayName = "CrediCardUI";

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
    iconFont: PropTypes.string,
    iconGlyph: PropTypes.string,
  };

  _onNonceReceived(event) {
    if ( this.props.onNonceReceived )
      this.props.onNonceReceived(event.nativeEvent.nonce);
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
        NativeModules.UIManager.dispatchViewManagerCommand(
            findNodeHandle(this.nativeControl),
            NativeModules.UIManager.RCTCreditCardUI.Commands[name],
            args
        );
        break;
      default:
        break;
    }
  }

  render() {
    return (
      <RCTCreditCardUI {...this.props}
        focusColor={processColor(this.props.focusColor)}
        blurColor={processColor(this.props.blurColor)}
        errorColor={processColor(this.props.errorColor)}
        ref={(ref) => { this.nativeControl = ref; }}
        onNonceReceived={(event) => { this._onNonceReceived(event); }}
      />
    );
  }
}

const RCTCreditCardUI = requireNativeComponent('RCTCreditCardUI', CrediCardUI);