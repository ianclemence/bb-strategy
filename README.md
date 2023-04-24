# BB Strategy

This is a GitHub repository for the `BB Strategy` trading algorithm created by `Ian Clemence`. The strategy uses Bollinger Bands and RSI indicators to generate buy and sell signals.

## Files

The repository contains one main file:

- `BB Strategy.mq4`: This is the main algorithm file that contains the code for the trading strategy.

## Inputs

The algorithm uses the following inputs:

- `bbPeriod` (default: `30`): The number of periods used to calculate the Bollinger Bands.
- `bandStdEntry` (default: `2`): The standard deviation used to calculate the entry Bollinger Bands.
- `bandStdProfitExit` (default: `1`): The standard deviation used to calculate the take profit Bollinger Bands.
- `bandStdLossExit` (default: `6`): The standard deviation used to calculate the stop loss Bollinger Bands.
- `rsiPeriod` (default: `14`): The number of periods used to calculate the RSI indicator.
- `riskPerTrade` (default: `0.02`): The percentage of the account balance risked per trade.
- `rsiLowerLevel` (default: `35`): The oversold level of the RSI indicator.
- `rsiUpperLevel` (default: `65`): The overbought level of the RSI indicator.

## Functions

The following custom functions are used in the algorithm:

- `CheckIfOpenOrdersByMagicNB(magicNB)`: Checks if there are any open orders with the specified `magicNB`.
- `OptimalLotSize(riskPerTrade,entryPrice,stopLossPrice)`: Calculates the optimal lot size for a trade based on the `riskPerTrade`, `entryPrice`, and `stopLossPrice`.

## Initialization and Deinitialization Functions

The algorithm uses the following initialization and deinitialization functions:

- `OnInit()`: This function is called when the algorithm is initialized. It returns `INIT_SUCCEEDED` if initialization is successful.
- `OnDeinit(reason)`: This function is called when the algorithm is deinitialized. It does not return anything.

## Tick Function

The algorithm uses the following tick function:

- `OnTick()`: This function is called on every tick. It calculates the Bollinger Bands and RSI indicator, and generates buy or sell signals based on the conditions specified in the code. If there are no open orders, it tries to enter a new position. If there is an open position, it updates the take profit and stop loss orders if necessary.

## Usage

This strategy can be used on any forex pair and timeframe, but it is
recommended to use it on a higher timeframe (such as H1 or above) to
reduce the number of false signals.

To use this strategy, copy the `BOMAWI Strategy.mq4` file into your
MetaTrader 4 indicators folder
(e.g. `C:\Program Files (x86)\MetaTrader 4\experts\indicators`). Then,
compile the file in MetaEditor and attach the compiled indicator to the
chart of your desired currency pair and timeframe. Set the parameters as
desired and start trading.

## Disclaimer

Trading involves risk and past performance is not indicative of future results. The algorithm provided in this repository is for educational purposes only and should not be used for live trading without thorough testing and analysis. The author and publisher of this repository are not responsible for any losses incurred as a result of using this algorithm.
