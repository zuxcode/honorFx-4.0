#include "report.mqh"
#include "supportAndRessitance.mqh"
#include "volume.mqh"

input int stopLossOff       = 2;     // stop loss offset
input int entryOffSet       = 4;     // entry offset
input int ExpertMagicNumber = 999;   // Expert magic number
input int takeProfitOffset  = 2;     // take profit offset

const double fixVolume = volume();
const int    volumeMax = 10;

void SellLimit() {
    const double entryPrice       = resistancePrice - entryOffSet;
    const double tp               = 0;
    const double sl               = resistancePrice;
    const double volumeDifference = NormalizeDouble(fixVolume - volumeMax, _Digits);

    if(fixVolume <= volumeMax) {
        const bool success = trade.SellLimit(fixVolume, entryPrice, _Symbol, sl, tp);
        if(!success) {
            reportError();
        }
        return;
    }

    if(volumeDifference < volumeMax) {
        const bool tradeOneStatus = trade.SellLimit(volumeMax, entryPrice, _Symbol, sl, tp);
        const bool tradeTwoStatus = trade.SellLimit(volumeDifference, entryPrice, _Symbol, sl, tp);
        if(!tradeOneStatus || !tradeTwoStatus) {
            reportError();
        }
        return;
    }

    if(volumeDifference >= volumeMax) {
        const bool tradeOneStatus = trade.SellLimit(volumeMax, entryPrice, _Symbol, sl, tp);
        const bool tradeTwoStatus = trade.SellLimit(volumeMax, entryPrice, _Symbol, sl, tp);
        if(!tradeOneStatus || !tradeTwoStatus) {
            reportError();
        }
        return;
    }
}

void BuyLimit() {
    const double entryPrice       = supportPrice + entryOffSet;
    const double sl               = supportPrice;
    const double tp               = 0;
    const double volumeDifference = NormalizeDouble(fixVolume - volumeMax, _Digits);

    if(fixVolume <= volumeMax) {
        const bool success = trade.BuyLimit(fixVolume, entryPrice, _Symbol, sl, tp);
        if(!success) {
            reportError();
        }
        return;
    }

    if(volumeDifference < volumeMax) {
        const bool tradeOneStatus = trade.BuyLimit(volumeMax, entryPrice, _Symbol, sl, tp);
        const bool tradeTwoStatus = trade.BuyLimit(volumeDifference, entryPrice, _Symbol, sl, tp);
        if(!tradeOneStatus || !tradeTwoStatus) {
            reportError();
        }
        return;
    }

    if(volumeDifference >= volumeMax) {
        const bool tradeOneStatus = trade.BuyLimit(volumeMax, entryPrice, _Symbol, sl, tp);
        const bool tradeTwoStatus = trade.BuyLimit(volumeMax, entryPrice, _Symbol, sl, tp);
        if(!tradeOneStatus || !tradeTwoStatus) {
            reportError();
        }
        return;
    }
}

void closePendinOrders() {
    uint total = OrdersTotal();
    for(uint index = 0; index < total; index++) {
        trade.OrderDelete(OrderGetTicket(index));
    }
}

void closePositions() {
    for(int i = 0; i < PositionsTotal(); i++) {
        const ulong positionTicket = PositionGetTicket(i);
        trade.PositionClose(positionTicket);
    }
}

void tradeManager() {
    for(int i = 0; i < PositionsTotal(); i++) {
        const ulong  positionTicket    = PositionGetTicket(i);
        const double positionPriceOpen = PositionGetDouble(POSITION_PRICE_OPEN);
        const double positionSl        = PositionGetDouble(POSITION_SL);
        const double bid               = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        const double ask               = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

        if(PositionGetSymbol(POSITION_SYMBOL) != _Symbol)
            continue;
        if(PositionGetInteger(POSITION_MAGIC) != ExpertMagicNumber)
            continue;
        if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && bid <= supportPrice)
            trade.PositionClose(positionTicket);

        if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && ask >= resistancePrice) {
            trade.PositionClose(positionTicket);
        }
    }
}

void orderModify() {
    const int    position     = supportAndResistancePosition - 1;
    const int    lowestPoint  = iLowest(_Symbol, _Period, MODE_LOW, position, 1);
    const int    highestPoint = iHighest(_Symbol, _Period, MODE_HIGH, position, 1);
    const double high         = iHigh(_Symbol, _Period, highestPoint);
    const double low          = iLow(_Symbol, _Period, lowestPoint);
    const double buyLimitTp   = high - 2;
    const double sellLimitTp  = low + 2;

    for(int i = 0; i < PositionsTotal(); i++) {
        if(PositionGetSymbol(POSITION_SYMBOL) != _Symbol)
            continue;
        if(PositionGetInteger(POSITION_MAGIC) != ExpertMagicNumber)
            continue;
        const double positionTP = PositionGetDouble(POSITION_TP);

        if(positionTP != 0)
            continue;

        const double positionSl     = PositionGetDouble(POSITION_SL);
        const ulong  positionTicket = PositionGetTicket(i);

        if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) {
            trade.PositionModify(positionTicket, positionSl, sellLimitTp);
        }

        if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) {
            trade.PositionModify(positionTicket, positionSl, buyLimitTp);
        }
    }
}