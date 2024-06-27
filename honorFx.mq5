//+------------------------------------------------------------------+
//|                                                      HonorFX.mq5 |
//|                                         Copyright 2024, zuxcode  |
//|                                          https://www.zuxcode.dev |
//+------------------------------------------------------------------+

#property copyright "Copyright 2024, zuxcode"
#property link "https://www.zuxcode.dev"
#property version "4.0"
#property description "Strategy Based on Range Break 200 Index"

#include "lib/supportAndRessitance.mqh"
#include "lib/trade.mqh"

input int             SupportAndResistanceOffset = 28;   // Support and Resistance offSet
int                   barsTotal;
bool                  hasSpiked = true;
datetime              time      = TimeCurrent();
const ENUM_TIMEFRAMES Timeframe = _Period;

int OnInit() {
    deleteSupportAndResistance();
    findSupportAndResistanceLevel(0, Bars(_Symbol, Timeframe));
    supportAndResistanceLineConfig();
    trade.SetExpertMagicNumber(ExpertMagicNumber);
    trade.SetAsyncMode(true);
    barsTotal = Bars(_Symbol, Timeframe);
    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
    Print("Expert Advisory Deinitialize and the reason is ", reason, " ...");
    deleteSupportAndResistance();
}

void OnTick() {
    const int    candlePosition = 0;
    const double bid            = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    const double ask            = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    const double open           = iOpen(_Symbol, Timeframe, candlePosition);
    const double close          = iClose(_Symbol, Timeframe, candlePosition);
    const double high           = iHigh(_Symbol, Timeframe, candlePosition);
    const double low            = iLow(_Symbol, Timeframe, candlePosition);
    const double BullCandleBody = NormalizeDouble(close - open, _Digits);
    const double BearCandleBody = NormalizeDouble(open - close, _Digits);
    const double calBuyOffset   = resistancePrice - ask;
    const double calSellOffset  = bid - supportPrice;

    if(PositionsTotal() > 0) {
        tradeManager();
    }
    if(BearCandleBody >= PriceOffset || BullCandleBody >= PriceOffset) {
        supportPrice                 = low;
        resistancePrice              = high;
        hasSpiked                    = true;
        supportAndResistancePosition = 0;
        updateSupportAndResistancePriceLevel();
        closePendinOrders();
        closePositions();
    }

    if(BearCandleBody >= PriceOffset) {
        isBearCandle = true;
    }

    if(BullCandleBody >= PriceOffset) {
        isBearCandle = false;
    }

    if(Bars(_Symbol, Timeframe) != barsTotal) {
        barsTotal = Bars(_Symbol, Timeframe);
        supportAndResistancePosition++;
    }

    if(!hasSpiked)
        return;

    if(!isBearCandle && calBuyOffset >= SupportAndResistanceOffset) {
        SellLimit();
        hasSpiked = false;
    }
    if(isBearCandle && calSellOffset >= SupportAndResistanceOffset) {
        BuyLimit();
        hasSpiked = false;
    }
}

void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest     &request,
                        const MqlTradeResult      &result) {
    HistorySelect(time, TimeCurrent());
    if(trans.symbol == _Symbol) {
        if(trans.type == TRADE_TRANSACTION_DEAL_ADD) {
            if(HistoryDealGetInteger(trans.deal, DEAL_ENTRY) == DEAL_ENTRY_IN) {
                orderModify();
            }
        }
    }
}