import React, { PropTypes } from 'react'
import { View, requireNativeComponent, Platform, NativeModules, findNodeHandle } from 'react-native'

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
    onNonceReceived: PropTypes.func,
    // translations
    numberString: PropTypes.string,
    cvvString: PropTypes.string,
    monthString: PropTypes.string,
    yearString: PropTypes.string,
    invalidString: PropTypes.string,
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
        ref={(ref) => { this.nativeControl = ref; }}
        onNonceReceived={(event) => { this._onNonceReceived(event); }}
      />
    );
  }
}

const RCTCreditCardControl = requireNativeComponent('RCTCreditCardControl', CreditCardControl);
