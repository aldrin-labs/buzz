# {{project_name}}

A yield farming bot that automatically rebalances positions between lending pools to maximize returns.

## Configuration

Edit `buzz.toml` to customize:
- Rebalance thresholds
- Pool configurations
- Utilization targets
- Risk parameters
- Rebalance interval

## Strategy

The bot manages positions in {{pool1_name}} ({{asset1}}) and {{pool2_name}} ({{asset2}}) pools.

Rebalancing:
- Moves funds when APY difference > {{rebalance_threshold}}%
- Checks every {{rebalance_interval}}

Risk Management:
- Max utilization: {{max_utilization}}%
- Target utilization: {{target_utilization}}%
- Risk percentage: {{risk_percentage}}%

## Development

1. Modify `main.buzz` to customize the strategy
2. Test using `buzz test`
3. Deploy using `buzz deploy`

## License

This project is licensed under the terms specified in the project root.
