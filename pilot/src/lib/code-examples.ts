interface Benchmark {
  metric: string;
  rust: string;
  buzz: string;
  diff: string;
}

interface CodeExample {
  rust: string;
  buzz: string;
  benchmarks: Benchmark[];
}

const formatMetric = (name: string): string => name.padEnd(12);
const formatNumber = (num: number | string, width: number = 8): string => {
  const n = typeof num === 'string' ? num : num.toString();
  return n.padStart(width);
};
const formatDiff = (diff: number): string => {
  return `-${diff}%`.padStart(6);
};

const createBenchmarks = (
  rustLines: number,
  buzzLines: number,
  rustSize: number,
  buzzSize: number,
  rustCU: number,
  buzzCU: number,
  rustDevTime: number,
  buzzDevTime: number
): Benchmark[] => {
  const timeToMarketRust = Math.round((rustLines * rustCU * rustDevTime) / 1000);
  const timeToMarketBuzz = Math.round((buzzLines * buzzCU * buzzDevTime) / 1000);
  
  return [
    {
      metric: formatMetric("Lines"),
      rust: formatNumber(rustLines),
      buzz: formatNumber(buzzLines),
      diff: formatDiff(Math.round((rustLines - buzzLines) / rustLines * 100))
    },
    {
      metric: formatMetric("Size (KB)"),
      rust: formatNumber(rustSize.toFixed(1)),
      buzz: formatNumber(buzzSize.toFixed(1)),
      diff: formatDiff(Math.round((rustSize - buzzSize) / rustSize * 100))
    },
    {
      metric: formatMetric("CU"),
      rust: formatNumber(rustCU),
      buzz: formatNumber(buzzCU),
      diff: formatDiff(Math.round((rustCU - buzzCU) / rustCU * 100))
    },
    {
      metric: formatMetric("Dev Time (h)"),
      rust: formatNumber(rustDevTime),
      buzz: formatNumber(buzzDevTime),
      diff: formatDiff(Math.round((rustDevTime - buzzDevTime) / rustDevTime * 100))
    },
    {
      metric: formatMetric("TTM Coef."),
      rust: formatNumber(timeToMarketRust),
      buzz: formatNumber(timeToMarketBuzz),
      diff: formatDiff(Math.round((timeToMarketRust - timeToMarketBuzz) / timeToMarketRust * 100))
    }
  ];
};

export const securityExample: CodeExample = {
  rust: `#[program]
mod secure_transfer {
use anchor_lang::prelude::*;
#[account]
struct TokenAccount {
  balance: u64,
  owner: Pubkey,
}
pub fn transfer(ctx: Context<Transfer>, amount: u64) -> Result<()> {
  let account = &mut ctx.accounts.token;
  require!(
    account.owner == ctx.accounts.signer.key(),
    ErrorCode::Unauthorized
  );
  require!(
    account.balance >= amount,
    ErrorCode::InsufficientFunds
  );
  Ok(())
}}`,
  buzz: `@program_id("Sec1...")
contract SecureTransfer:
  balance: u64
  owner: PublicKey
  @verify_ownership("token")
  @prevent_reentrancy
  def transfer(amount: u64):
    if self.balance >= amount:
      self.send_tokens(amount)`,
  benchmarks: createBenchmarks(26, 9, 4.2, 1.8, 12000, 11000, 45, 15)
};

export const cpiExample: CodeExample = {
  rust: `#[program]
mod token_swap {
pub fn swap(ctx: Context<Swap>, amount: u64) -> Result<()> {
  let cpi_program = ctx.accounts.token;
  let cpi_accounts = Transfer {
    from: ctx.accounts.user_token,
    to: ctx.accounts.pool_token,
    authority: ctx.accounts.user,
  };
  token::transfer(
    CpiContext::new(cpi_program, cpi_accounts),
    amount
  )?;
  Ok(())
}}`,
  buzz: `@program_id("Swp1...")
contract TokenSwap:
  pool: TokenAccount
  def swap(amount: u64):
    token_program.transfer(
      from=user.token,
      to=self.pool,
      amount=amount)`,
  benchmarks: createBenchmarks(23, 8, 3.8, 1.4, 8000, 8000, 30, 10)
};

export const agentExample: CodeExample = {
  rust: `#[program]
mod market_maker {
#[account]
struct Agent {
  state: AgentState,
}
pub fn handle_price(ctx: Context<Price>, data: PriceData) -> Result<()> {
  if data.is_significant_change() {
    adjust_position(ctx)?;
    let arb = ctx.accounts.arb_program;
    let accounts = Opportunity {
      source: ctx.accounts.source,
      target: ctx.accounts.target,
    };
    arbitrage::notify(
      CpiContext::new(arb, accounts)
    )?;
  }
  Ok(())
}}`,
  buzz: `@agent(name="MarketMaker")
contract MarketMakerAgent:
  state: AgentState
  @on_message("price_update")
  def handle_price(data: PriceData):
    if data.significant_change():
      self.adjust_position()
      self.send_message(
        to="ArbitrageAgent",
        type="opportunity",
        data=self.calc_opp())`,
  benchmarks: createBenchmarks(31, 11, 5.6, 2.2, 15000, 14000, 60, 20)
};

export const syntaxExample: CodeExample = {
  rust: `#[program]
mod calculator {
#[account]
struct Calculator {
  result: u64,
  precision: u8,
}
pub fn compute(ctx: Context<Compute>, a: u64, b: u64) -> Result<()> {
  let calc = &mut ctx.accounts.calc;
  calc.result = if a > b { a - b } else { a + b };
  Ok(())
}}`,
  buzz: `contract Calculator:
  result: u64
  precision: u8
  def compute(a: u64, b: u64):
    self.result = if a > b: a - b
    else: a + b`,
  benchmarks: createBenchmarks(22, 8, 2.8, 1.2, 5000, 5000, 20, 5)
};
