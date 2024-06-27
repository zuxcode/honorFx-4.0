const int    volumeDivider      = 10;     // volume Multiplier
input int    volumeStandardizer = 100;    // volume Standardizer
input double balancePercent     = 33.0;   // Balance percentage

double volume() {
    const double accountBalance             = AccountInfoDouble(ACCOUNT_BALANCE);
    const double calculateBalancePercentage = balancePercent / 100.0;
    const double balancePercentize          = accountBalance * calculateBalancePercentage;
    const int    volumeStandardize          = (int)balancePercentize / volumeDivider;
    const double volume                     = (double)volumeStandardize / volumeStandardizer;
    return volume;
}