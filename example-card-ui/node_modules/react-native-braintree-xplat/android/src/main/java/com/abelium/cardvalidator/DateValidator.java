package com.abelium.cardvalidator;

import com.abelium.cardvalidator.DateValidity.PartValidity;

import java.util.Calendar;

public class DateValidator
{
    private static final String CENTURY = "20";
    private static final int MAX_VALIDITY_YEARS = 30;

    public static PartValidity validateMonth(String month) {
        if ( !ValidatorUtils.isDigitsOnly(month) || month.length() > 2 )
            return PartValidity.invalid(0);
        if ( month.length() == 0 )
            return PartValidity.partial(0);
        int monthInt = Integer.parseInt(month);
        if ( monthInt < 1 || monthInt > 12 )
             return PartValidity.invalid(monthInt);
        return PartValidity.full(monthInt);
    }

    public static PartValidity validateYear(String year) {
        if ( !ValidatorUtils.isDigitsOnly(year) || year.length() > 4 )
            return PartValidity.invalid(0);
        if ( year.length() < 2 )
            return PartValidity.partial(0);
        if ( year.length() == 3 )
            return year.startsWith(CENTURY) ? PartValidity.partial(0) : PartValidity.invalid(0);
        int yearInt = Integer.parseInt(year.length() == 2 ? CENTURY + year : year);
        int currentYear = Calendar.getInstance().get(Calendar.YEAR);
        if ( yearInt < currentYear || yearInt > currentYear + MAX_VALIDITY_YEARS ) {
            if ( year.equals(CENTURY) )    // special case - may be completed
                return PartValidity.partial(yearInt);
            return PartValidity.invalid(yearInt);
        }
        return PartValidity.full(yearInt);
    }

    public static DateValidity validateDate(String month, String year) {
        PartValidity monthV = validateMonth(month);
        PartValidity yearV = validateYear(year);
        if ( monthV.validity != Validity.Complete || yearV.validity != Validity.Complete)
            return new DateValidity(monthV, yearV);
        Calendar date = Calendar.getInstance();
        int currentMonth = date.get(Calendar.MONTH) - Calendar.JANUARY + 1;
        int currentYear = date.get(Calendar.YEAR);
        // check date to be at least current date
        if ( yearV.value > currentYear )
            return new DateValidity(monthV, yearV); // valid
        if ( yearV.value == currentYear && monthV.value >= currentMonth )
            return new DateValidity(monthV, yearV); // valid
        // year must be valid if it passed year validation, so month is wrong
        // (month 1 can still be completed to valid 11 or 12)
        PartValidity monthValidity = monthV.value == 1 ? PartValidity.partial(monthV.value) : PartValidity.invalid(monthV.value);
        return new DateValidity(monthValidity, yearV);
    }
}
