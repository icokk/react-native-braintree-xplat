package com.abelium.cardvalidator;

public class CardNumberMatch
{
    public static final CardNumberMatch NO_MATCH = new CardNumberMatch(null, Validity.Invalid);
    public static final CardNumberMatch EMPTY = new CardNumberMatch(null, Validity.Partial);

    private CreditCardType cardType;
    private Validity validity;

    public CardNumberMatch(CreditCardType cardType, Validity match) {
        this.cardType = cardType;
        this.validity = match;
    }

    public CreditCardType getCardType() {
        return cardType;
    }

    public Validity getValidity() {
        return validity;
    }
}
