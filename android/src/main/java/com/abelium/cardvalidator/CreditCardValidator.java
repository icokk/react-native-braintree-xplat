package com.abelium.cardvalidator;

public class CreditCardValidator
{
    private static int luhnChecksum(String number) {
        int sum = 0;
        int length = number.length();
        for (int i = 1; i <= length; i++ ) {
            int digit = (int) number.charAt(length - i) - '0';
            if ( digit < 0 || digit > 9 )
                return -1;  // invalid character
            if ( (i & 1) == 0 ) {
                digit = 2 * digit;
                if ( digit > 9 )
                    digit = digit - 9;
            }
            sum += digit;
        }
        return sum % 10;
    }

    private static boolean luhnValid(String number) {
        return luhnChecksum(number) == 0;
    }

    private static String cleanupNumber(String number) {
        int length = number.length();
        StringBuilder sb = new StringBuilder(length);
        for ( int i = 0; i < length; i++ ) {
            char ch = number.charAt(i);
            if ( '0' <= ch && ch <= '9' )
                sb.append(ch);
            else if ( !(Character.isSpaceChar(ch) || ch == '-') )
                return null;
        }
        return sb.toString();
    }

    private static final CreditCardType[] cardTypes = CreditCardType.values();

    private static CardNumberMatch detectCard(String cardNumber, CreditCardType[] cardTypes) {
        String number = cleanupNumber(cardNumber);
        if ( number == null )
            return CardNumberMatch.NO_MATCH;
        if ( number.isEmpty() )
            return CardNumberMatch.EMPTY;
        CardNumberMatch match = getCreditCardType(number, cardTypes);
        // require luhn validity for full matches
        if ( match.getValidity() == Validity.Complete) {
            if ( !luhnValid(number) ) {
                if ( match.getCardType().isLengthMaximal(number) )
                    return CardNumberMatch.NO_MATCH;
                // it may still be extended to valid match
                return new CardNumberMatch(match.getCardType(), Validity.Partial);
            }
        }
        return match;
    }

    private static CardNumberMatch getCreditCardType(String number, CreditCardType[] cardTypes) {
        for ( CreditCardType card : cardTypes ) {
            Validity match = card.match(number);
            if ( match != Validity.Invalid)
                return new CardNumberMatch(card, match);
        }
        return CardNumberMatch.NO_MATCH;
    }

    public static CardNumberMatch detectCard(String cardNumber) {
        return detectCard(cardNumber, cardTypes);
    }

    public static Validity validateCardNumber(String cardNumber, CreditCardType... cardTypes) {
        return detectCard(cardNumber, cardTypes).getValidity();
    }

    public static final int MAX_CONTROL_LENGTH = 4;

    public static Validity validateCVC(String cvc, CreditCardType cardType) {
        if ( !ValidatorUtils.isDigitsOnly(cvc) )
            return Validity.Invalid;
        int maxCvcLength = cardType != null ? cardType.getCvcLength() : MAX_CONTROL_LENGTH;
        if ( cvc.length() > maxCvcLength )
            return Validity.Invalid;
        if ( cvc.length() < maxCvcLength )
            return Validity.Partial;
        return cardType != null ? Validity.Complete : Validity.Partial;
    }
}
