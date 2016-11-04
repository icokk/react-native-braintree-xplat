import React, { PropTypes } from 'react'
import { View, requireNativeComponent } from 'react-native'

export default class CreditCardControl extends React.Component {
  static displayName = "CreditCardControl";

  static propTypes = {
    // include the default view properties
    ...View.propTypes,
    // extra properties
    requiredCard: PropTypes.string,
    require3dSecure: PropTypes.bool,
    requireCVV: PropTypes.bool,
    amount: PropTypes.number,
    onNonceReceived: PropTypes.func,
  };

  render() {
    return (
      <RCTCreditCardControl {...this.props} />
    );
  }
}

const RCTCreditCardControl = requireNativeComponent('RCTCreditCardControl', CreditCardControl);
