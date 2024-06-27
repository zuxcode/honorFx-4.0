double resistancePrice;
double supportPrice;
bool   isBearCandle = false;
int    supportAndResistancePosition;

input int    PriceOffset     = 30;             // Price offset
input string SupportName     = "Support";      // Support line name
input string ResistanceName  = "Resistance";   // Resistance line name
input color  SupportColor    = clrGreen;       // Support line color
input color  ResistanceColor = clrRed;         // Resistance line color
input int    LineWidth       = 3;              // line width

void deleteSupportAndResistance() {
    ObjectsDeleteAll(0, SupportName, 0, OBJ_HLINE);
    ObjectsDeleteAll(0, ResistanceName, 0, OBJ_HLINE);
    ChartRedraw(0);
}

void updateSupportAndResistancePriceLevel() {
    ObjectCreate(0, SupportName, OBJ_HLINE, 0, 0, supportPrice);
    ObjectCreate(0, ResistanceName, OBJ_HLINE, 0, 0, resistancePrice);
    ChartRedraw(0);
}

void supportAndResistanceLineConfig() {
    /**
     * set the property of the support line
     */
    ObjectSetInteger(0, SupportName, OBJPROP_COLOR, SupportColor);
    ObjectSetInteger(0, SupportName, OBJPROP_WIDTH, LineWidth);
    ObjectSetInteger(0, SupportName, OBJPROP_RAY_RIGHT, false);
    ObjectSetInteger(0, SupportName, OBJPROP_RAY_LEFT, false);
    ObjectSetInteger(0, SupportName, OBJPROP_SELECTABLE, true);
    ObjectSetInteger(0, SupportName, OBJPROP_SELECTED, false);
    ObjectSetInteger(0, SupportName, OBJPROP_STYLE, STYLE_SOLID);

    /**
     *  set the property of the resistance line
     */
    ObjectSetInteger(0, ResistanceName, OBJPROP_COLOR, ResistanceColor);
    ObjectSetInteger(0, ResistanceName, OBJPROP_RAY_RIGHT, false);
    ObjectSetInteger(0, ResistanceName, OBJPROP_RAY_LEFT, false);
    ObjectSetInteger(0, ResistanceName, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSetInteger(0, ResistanceName, OBJPROP_WIDTH, LineWidth);
    ObjectSetInteger(0, ResistanceName, OBJPROP_SELECTABLE, true);
    ObjectSetInteger(0, ResistanceName, OBJPROP_SELECTED, false);
}

void findSupportAndResistanceLevel(int startPos = 0, int endPos = NULL) {
    for(int i = startPos; i < endPos; i++) {
        const double open  = iOpen(_Symbol, _Period, i);
        const double close = iClose(_Symbol, _Period, i);

        // Read candle high price
        const double high = iHigh(_Symbol, _Period, i);
        const double low  = iLow(_Symbol, _Period, i);
        /**
         * @Read -> read the bid and ask price
         */
        double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

        // Calculate candle size
        const double BullCandleBody = NormalizeDouble(close - open, _Digits);
        const double BearCandleBody = NormalizeDouble(open - close, _Digits);

        if(BearCandleBody >= PriceOffset) {

            isBearCandle = true;
        }

        if(BullCandleBody >= PriceOffset) {
            isBearCandle = false;
        }

        if(BullCandleBody >= PriceOffset || BearCandleBody >= PriceOffset) {

            supportAndResistancePosition = i;
            resistancePrice              = high;
            supportPrice                 = low;
            updateSupportAndResistancePriceLevel();
            return;
        }
    }
}
