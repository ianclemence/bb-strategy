# BB Strategy

This is a GitHub repository for the `BB Strategy` trading algorithm created by `Ian Clemence`. The strategy uses Bollinger Bands and RSI indicators to generate buy and sell signals.

## Strategy Parameters

The strategy has the following parameters that can be customized:

- `bbPeriod` (default: `30`): The number of periods used to calculate the Bollinger Bands.
- `bandStdEntry` (default: `2`): The standard deviation used to calculate the entry Bollinger Bands.
- `bandStdProfitExit` (default: `1`): The standard deviation used to calculate the take profit Bollinger Bands.
- `bandStdLossExit` (default: `6`): The standard deviation used to calculate the stop loss Bollinger Bands.
- `rsiPeriod` (default: `14`): The number of periods used to calculate the RSI indicator.
- `riskPerTrade` (default: `0.02`): The percentage of the account balance risked per trade.
- `rsiLowerLevel` (default: `35`): The oversold level of the RSI indicator.
- `rsiUpperLevel` (default: `65`): The overbought level of the RSI indicator.

## Trading Rules

The strategy enters a long position if the following conditions are
met: - the current Ask price is below the lower Bollinger Band; - the
previous candle's open price is above the lower Bollinger Band; - the
current William's Percent Range value is lower than `rsiLowerLevel`;

The strategy enters a short position if the following conditions are
met: - the current Bid price is above the upper Bollinger Band; - the
previous candle's open price is below the upper Bollinger Band; - the
current William's Percent Range value is higher than `rsiUpperLevel`;

The strategy places a buy limit order at the lower Bollinger Band with
the stop loss at the lower Bollinger Band minus `bandStdLossExit`
standard deviations and the take profit at the upper Bollinger Band plus
`bandStdProfitExit` standard deviations. The lot size is determined
based on the `riskPerTrade` parameter.

The strategy places a sell limit order at the upper Bollinger Band with
the stop loss at the upper Bollinger Band plus `bandStdLossExit`
standard deviations and the take profit at the lower Bollinger Band
minus `bandStdProfitExit` standard deviations. The lot size is
determined based on the `riskPerTrade` parameter.

## Disclaimer

Trading involves risk and past performance is not indicative of future results. The algorithm provided in this repository is for educational purposes only and should not be used for live trading without thorough testing and analysis. The author and publisher of this repository are not responsible for any losses incurred as a result of using this algorithm.
