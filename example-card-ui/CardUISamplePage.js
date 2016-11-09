/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, {Component} from 'react';
import {AppRegistry, StyleSheet, Text, View, TouchableOpacity} from 'react-native';

import BraintreeClient, {CreditCardControl} from 'react-native-braintree-xplat';

export default class CardUISamplePage extends Component {
    constructor() {
        super();
        this.state = {
            clientToken: null,
            paymentNonce: null
        };
        this.obtainClientToken();
    }

    render() {
        return (
            <View style={styles.container}>
                <View style={styles.smallContainer}>
                    <CreditCardControl
                        // style={{ width: 240, height: 270 }}
                        ref={(ref) => { this.control = ref; }}
                        clientToken={this.state.clientToken}
                        onNonceReceived={(nonce) => {
                            console.log("NONCE", nonce);
                            this.setState({ paymentNonce: nonce });
                        }}/>
                </View>
                <TouchableOpacity style={styles.button}
                                  onPress={() => {
                                      this.control.submitCardData();
                                  }}>
                    <Text style={styles.buttonText}>Pay!</Text>
                </TouchableOpacity>
                <Text style={styles.instructions}>
                    CLIENT TOKEN = {this.state.clientToken && this.state.clientToken.slice(0, 40) + '...'}
                </Text>
                <Text style={styles.instructions}>
                    PAYMENT NONCE = {this.state.paymentNonce}
                </Text>
            </View>
        );
    }

    obtainClientToken() {
        console.log("INIT");
        fetch(
            // 'http://10.0.3.2:8080/goopti-services/braintree/start_payment',
            'https://gotest.matheo.si/goopti-services/braintree/start_payment',
            {
                method: 'POST',
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({requestId: 1000001150})
            })
            .then(response => response.json())
            .then(data => {
                console.log("TOKEN = ", data.clientNonce);
                //BraintreeClient.setup(data.clientNonce);
                this.setState({ clientToken: data.clientNonce });
            })
            .catch((err) => {
                console.log("ERROR " + err);
            });
    }
}

var alignHoriz = 'center';

const styles = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'center',
        alignItems: alignHoriz,
        backgroundColor: '#F5FCFF',
    },
    welcome: {
        fontSize: 20,
        textAlign: 'center',
        margin: 10,
    },
    instructions: {
        textAlign: 'center',
        color: '#333333',
        marginBottom: 5,
    },
    button: {
        backgroundColor: "#800040",
        paddingVertical: 6,
        paddingHorizontal: 16,
        borderRadius: 4,
    },
    buttonText: {
        color: "#FFFFFF",
    },
    smallContainer: {
        // flex: 1,
        // flexDirection: 'column',
        // justifyContent: 'flex-start',
        alignItems: alignHoriz,
        margin: 10,
        padding: 5,
        borderWidth: 1,
    }
});
