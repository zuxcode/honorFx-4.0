#include <trade/trade.mqh>
CTrade trade;

void reportError() {
    const uint   code       = trade.ResultRetcode();
    const string retCodeDes = trade.ResultRetcodeDescription();
    Print("\n------------------------  <<< TRADELOG: TRADE REQUEST FAILED >>>  ------------------------");
    Print("Error = ", GetLastError(), " RetCodeDes = ", retCodeDes);
    switch(code) {
        //--- requote
        case 10004: {
            Print("\n------------------------  TRADE_RETCODE_REQUOTE  ------------------------");
            Print("trade.RequestPrice = ", trade.RequestPrice(), "   trade.ResultBid = ",
                  trade.ResultBid(), " trade.ResultAsk = ", trade.ResultAsk());
            break;
        }
        //--- order is not accepted by the server
        case 10006: {
            Print("\n------------------------  TRADE_RETCODE_REJECT  ------------------------");
            Print("trade.RequestPrice = ", trade.RequestPrice(), "   trade.ResultBid = ",
                  trade.ResultBid(), " trade.ResultAsk = ", trade.ResultAsk());
            break;
        }
        //--- invalid price
        case 10015: {
            Print("\n------------------------  TRADE_RETCODE_INVALID_PRICE  ------------------------");
            Print("trade.RequestPrice = ", trade.RequestPrice(), "   trade.ResultBid = ",
                  trade.ResultBid(), " trade.ResultAsk = ", trade.ResultAsk());
            break;
        }
        //--- invalid SL and/or TP
        case 10016: {
            Print("\n------------------------  TRADE_RETCODE_INVALID_STOPS  ------------------------");
            Print("trade.RequestSL = ", trade.RequestSL(), " trade.RequestTP = ", trade.RequestTP());
            Print("trade.ResultBid() = ", trade.ResultBid(), " trade.ResultAsk = ", trade.ResultAsk());
            break;
        }
        //--- invalid volume
        case 10014: {
            Print("\n------------------------  TRADE_RETCODE_INVALID_VOLUME  ------------------------");
            Print("trade.RequestVolume = ", trade.RequestVolume(), "   trade.ResultVolume = ",
                  trade.ResultVolume());
            break;
        }
        //--- not enough money for a trade operation
        case 10019: {
            Print("\n------------------------  TRADE_RETCODE_NO_MONEY  ------------------------");
            Print("trade.RequestVolume = ", trade.RequestVolume(), "   trade.ResultVolume = ",
                  trade.ResultVolume(), "   Trade.ResultComment = ", trade.ResultComment());
            break;
        }
        //--- some other reason, output the server response code
        default: {
            Print("Other code = ", code);
        }
    }
    ResetLastError();
}
