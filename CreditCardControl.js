import { PropTypes } from 'react';
import { requireNativeComponent, View } from 'react-native';

var CreditCardControl = {
  name: 'CreditCardControl',
  propTypes: {
    require3dSecure: PropTypes.bool,
    requireCVV: PropTypes.bool,
    amount: PropTypes.number,
    onNonceReceived: PropTypes.func,
    // include the default view properties
    ...View.propTypes
  },
}

module.exports = requireNativeComponent('RCTCreditCardControl', CreditCardControl);
