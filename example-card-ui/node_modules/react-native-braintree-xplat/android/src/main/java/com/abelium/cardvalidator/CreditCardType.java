package com.abelium.cardvalidator;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public enum CreditCardType {
    Visa("visa", "Visa",
            "^4\\d*$",
            new int[] { 16 }, "CVV", 3),
    MasterCard("master-card", "MasterCard",
            "^(5|5[1-5]\\d*|2|22|222|222[1-9]\\d*|2[3-6]\\d*|27[0-1]\\d*|2720\\d*)$",
            new int[] { 16 }, "CVC", 3),
    AmericanExpress("american-express", "American Express",
            "^3([47]\\d*)?$",
            new int[] { 15 }, "CID", 4),
    DinersClub("diners-club", "Diners Club",
            "^3((0([0-5]\\d*)?)|[689]\\d*)?$",
            new int[] { 14 }, "CVV", 3),
    Maestro("maestro", "Maestro",
            "^((5((0|[6-9])\\d*)?)|(6|6[37]\\d*))$",
            new int[] { 12, 13, 14, 15, 16, 17, 18, 19 }, "CVC", 3),
    Discover("discover", "Discover",
            "^6(0|01|011\\d*|5\\d*|4|4[4-9]\\d*)?$",
            new int[] { 16, 19 }, "CID", 3),
    JCB("jcb", "JCB",
            "^((2|21|213|2131\\d*)|(1|18|180|1800\\d*)|(3|35\\d*))$",
            new int[] { 16 }, "CVV", 3);

    private String name;
    private String niceName;
    private Pattern pattern;
    private int[] lengths;
    private int maxLength;
    private String cvcName;
    private int cvcLength;

    CreditCardType(String jsName, String niceName, String pattern, int[] lengths, String cvcName, int cvcLength) {
        this.name = jsName;
        this.niceName = niceName;
        this.pattern = Pattern.compile(pattern);
        this.lengths = lengths;
        this.maxLength = 0;
        for ( int length : lengths )
            maxLength = Math.max(maxLength, length);
        this.cvcName = cvcName;
        this.cvcLength = cvcLength;
    }

    Validity match(String number) {
        // check pattern match
        Matcher matcher = pattern.matcher(number);
        if ( !matcher.matches() )
            return Validity.Invalid;
        // check length match
        int length = number.length();
        if ( length > maxLength )
            return Validity.Invalid;
        for ( int len : lengths )
            if ( len == length )
                return Validity.Complete;
        return Validity.Partial;
    }

    public static CreditCardType byName(String name) {
        for ( CreditCardType card : CreditCardType.values() )
            if ( card.name.equals(name) || card.niceName.equals(name) )
                return card;
        return null;
    }

    boolean isLengthMaximal(String number) {
        return number.length() == maxLength;
    }

    public String getName() {
        return name;
    }

    public String getNiceName() {
        return niceName;
    }

    public String getCvcName() {
        return cvcName;
    }

    public int getCvcLength() {
        return cvcLength;
    }
}
