# {{project_name}}

A simple Buzz agent that trades based on moving average and RSI indicators.

## Configuration

Edit `buzz.toml` to customize:
- Risk percentage
- Moving average period
- RSI entry/exit levels
- Position sizing
- Pool selection

## Strategy

The agent enters when:
- Price is below the {{ma_period}}-period moving average
- RSI is below {{rsi_entry}}

The agent exits when:
- Price is above the {{ma_period}}-period moving average
- RSI is above {{rsi_exit}}

Position size is limited to the smaller of:
- {{max_size}} tokens
- {{liquidity_ratio}}% of available liquidity

## Development

1. Modify `main.buzz` to customize the strategy
2. Test using `buzz test`
3. Deploy using `buzz deploy`

## License

This project is licensed under the terms specified in the project root.
