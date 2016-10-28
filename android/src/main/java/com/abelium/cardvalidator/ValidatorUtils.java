package com.abelium.cardvalidator;

public class ValidatorUtils
{
    public static <T extends Comparable<? super T>> T min(T a, T b) {
        return a.compareTo(b) <= 0 ? a : b;
    }

    public static <T extends Comparable<? super T>> T max(T a, T b) {
        return a.compareTo(b) > 0 ? a : b;
    }

    public static boolean isDigitsOnly(String number) {
        int length = number.length();
        for ( int i = 0; i < length; i++ ) {
            char ch = number.charAt(i);
            if ( ch < '0' || ch > '9' )
                return false;
        }
        return true;
    }
}
