import React, { PropTypes } from 'react'
import { View, requireNativeComponent, Platform, NativeModules, findNodeHandle } from 'react-native'

// // requireNativeComponent automatically resolves this to “MapBoxManager”
// module.exports = requireNativeComponent("CrediCardUI", null);


export default class CrediCardUI extends React.Component {//control za komponento
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
  };

  _onNonceReceived(event) {
    if ( this.props.onNonceReceived )
      this.props.onNonceReceived(event.nativeEvent.nonce); //iz callbacka
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
      console.log(name);
      console.log(NativeModules);
      console.log(findNodeHandle(this.nativeControl));
      console.log(NativeModules.UIManager.RCTCreditCardUI["get Commands"]);
        NativeModules.CrediCardUI[name].apply(
            NativeModules.CrediCardUI[name],
            [findNodeHandle(this.nativeControl), ...args]
        );
        break;
      default:
        break;
    }
  }

  render() {
    return (
      <RCTCreditCardUI {...this.props}
        ref={(ref) => { console.log(this.nativeControl); this.nativeControl = ref; }}
        onNonceReceived={(event) => { console.log(event); this._onNonceReceived(event); }}
      />
    );
  }
}

const RCTCreditCardUI = requireNativeComponent('RCTCreditCardUI', CrediCardUI);
