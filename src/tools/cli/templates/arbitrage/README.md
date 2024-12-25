# {{project_name}}

An arbitrage bot that monitors and executes trades between two pools when price differences exceed a threshold.

## Configuration

Edit `buzz.toml` to customize:
- Entry/exit thresholds
- Pool configurations
- Asset pairs
- Price feed sources
- Risk parameters

## Strategy

The bot monitors price differences between {{pool1_name}} and {{pool2_name}} for {{asset1}}/{{asset2}}.

Enters when:
- Price difference > {{entry_threshold}}%

Exits when:
- Price difference < {{exit_threshold}}%

Position sizing:
- Maximum size: {{max_size}}
- Liquidity ratio: {{liquidity_ratio}}

## Development

1. Modify `main.buzz` to customize the strategy
2. Test using `buzz test`
3. Deploy using `buzz deploy`

## License

This project is licensed under the terms specified in the project root.
