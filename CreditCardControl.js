import React, { PropTypes } from 'react'
import { View, requireNativeComponent } from 'react-native'

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
    amount: PropTypes.number,
    onNonceReceived: PropTypes.func,
  };

  _onNonceReceived(event) {
    if ( this.props.onNonceReceived )
      this.props.onNonceReceived(event.nativeEvent.nonce);
  }

  render() {
    return (
      <RCTCreditCardControl {...this.props}
        onNonceReceived={(event) => { this._onNonceReceived(event); }} />
    );
  }
}

const RCTCreditCardControl = requireNativeComponent('RCTCreditCardControl', CreditCardControl);
