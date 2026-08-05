use anchor_lang::prelude::*;
use anchor_spl::token_2022::{self, MintTo, Token2022};
use anchor_spl::token_interface::{Mint, TokenAccount};

declare_id!("2ameKJBTGHssRqHBeW2WZeXdoETWVXfrceGaEw5K83Um");

/// Max supply: 10_000_000_000 MUTTER with 9 decimals → 10B * 10^9 base units.
pub const MAX_SUPPLY_BASE_UNITS: u64 = 10_000_000_000 * 1_000_000_000;
pub const DECIMALS: u8 = 9;

#[program]
pub mod mutter_token {
    use super::*;

    /// Registers an existing Token-2022 mint under the emission controller.
    /// Mint authority must already be (or be transferred to) the config PDA.
    pub fn initialize(ctx: Context<Initialize>, max_supply: u64) -> Result<()> {
        require!(max_supply > 0, MutterError::InvalidMaxSupply);
        require!(
            max_supply <= MAX_SUPPLY_BASE_UNITS,
            MutterError::MaxSupplyTooHigh
        );

        let config = &mut ctx.accounts.config;
        config.authority = ctx.accounts.authority.key();
        config.mint = ctx.accounts.mint.key();
        config.max_supply = max_supply;
        config.total_minted = 0;
        config.paused = false;
        config.bump = ctx.bumps.config;

        msg!(
            "MutterCoin emission initialized | mint={} max_supply={}",
            config.mint,
            config.max_supply
        );
        Ok(())
    }

    /// Mints `amount` base units to `destination`, capped by max_supply.
    pub fn mint_tokens(ctx: Context<MintTokens>, amount: u64) -> Result<()> {
        require!(amount > 0, MutterError::InvalidAmount);

        let config = &mut ctx.accounts.config;
        require!(!config.paused, MutterError::Paused);
        require_keys_eq!(config.mint, ctx.accounts.mint.key(), MutterError::MintMismatch);

        let new_total = config
            .total_minted
            .checked_add(amount)
            .ok_or(MutterError::Overflow)?;
        require!(new_total <= config.max_supply, MutterError::SupplyCapExceeded);

        let seeds: &[&[u8]] = &[b"config", config.mint.as_ref(), &[config.bump]];
        let signer = &[seeds];

        let cpi = CpiContext::new_with_signer(
            ctx.accounts.token_program.to_account_info(),
            MintTo {
                mint: ctx.accounts.mint.to_account_info(),
                to: ctx.accounts.destination.to_account_info(),
                authority: config.to_account_info(),
            },
            signer,
        );
        token_2022::mint_to(cpi, amount)?;

        config.total_minted = new_total;
        msg!(
            "Minted {} MUTTER base units | total_minted={}",
            amount,
            config.total_minted
        );
        Ok(())
    }

    pub fn set_paused(ctx: Context<AdminOnly>, paused: bool) -> Result<()> {
        ctx.accounts.config.paused = paused;
        msg!("MutterCoin emission paused={}", paused);
        Ok(())
    }
}

#[account]
pub struct EmissionConfig {
    pub authority: Pubkey,
    pub mint: Pubkey,
    pub max_supply: u64,
    pub total_minted: u64,
    pub paused: bool,
    pub bump: u8,
}

impl EmissionConfig {
    pub const LEN: usize = 8 + 32 + 32 + 8 + 8 + 1 + 1;
}

#[derive(Accounts)]
pub struct Initialize<'info> {
    #[account(mut)]
    pub authority: Signer<'info>,

    pub mint: InterfaceAccount<'info, Mint>,

    #[account(
        init,
        payer = authority,
        space = EmissionConfig::LEN,
        seeds = [b"config", mint.key().as_ref()],
        bump
    )]
    pub config: Account<'info, EmissionConfig>,

    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct MintTokens<'info> {
    pub authority: Signer<'info>,

    #[account(
        mut,
        seeds = [b"config", mint.key().as_ref()],
        bump = config.bump,
        has_one = authority @ MutterError::Unauthorized,
        has_one = mint @ MutterError::MintMismatch
    )]
    pub config: Account<'info, EmissionConfig>,

    #[account(mut)]
    pub mint: InterfaceAccount<'info, Mint>,

    #[account(mut)]
    pub destination: InterfaceAccount<'info, TokenAccount>,

    pub token_program: Program<'info, Token2022>,
}

#[derive(Accounts)]
pub struct AdminOnly<'info> {
    pub authority: Signer<'info>,

    #[account(
        mut,
        seeds = [b"config", config.mint.as_ref()],
        bump = config.bump,
        has_one = authority @ MutterError::Unauthorized
    )]
    pub config: Account<'info, EmissionConfig>,
}

#[error_code]
pub enum MutterError {
    #[msg("Unauthorized")]
    Unauthorized,
    #[msg("Emission is paused")]
    Paused,
    #[msg("Mint does not match config")]
    MintMismatch,
    #[msg("Amount must be > 0")]
    InvalidAmount,
    #[msg("Max supply must be > 0")]
    InvalidMaxSupply,
    #[msg("Max supply exceeds protocol cap (10B)")]
    MaxSupplyTooHigh,
    #[msg("Mint would exceed max supply")]
    SupplyCapExceeded,
    #[msg("Arithmetic overflow")]
    Overflow,
}
