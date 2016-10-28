package com.abelium.cardvalidator;

public class DateValidity {
    static class PartValidity {
        final int value;
        final Validity validity;

        private PartValidity(int value, Validity validity) {
            this.value = value;
            this.validity = validity;
        }

        public static PartValidity invalid(int value) {
            return new PartValidity(value, Validity.Invalid);
        }

        public static PartValidity partial(int value) {
            return new PartValidity(value, Validity.Partial);
        }

        public static PartValidity full(int value) {
            return new PartValidity(value, Validity.Complete);
        }

        @Override
        public String toString() {
            return String.format("%s:%s", value, validity);
        }
    }

    private PartValidity month;
    private PartValidity year;

    public DateValidity(PartValidity month, PartValidity year) {
        this.month = month;
        this.year = year;
    }

    public int getMonth() {
        return month.value;
    }

    public int getYear() {
        return year.value;
    }

    public Validity monthValidity() {
        return month.validity;
    }

    public Validity yearValidity() {
        return year.validity;
    }

    public Validity validity() {
        return ValidatorUtils.min(month.validity, year.validity);
    }

    @Override
    public String toString() {
        return String.format("%s (month=%s, year=%s)", validity(), month.validity, year.validity);
    }
}
