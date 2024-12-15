module lottery::lottery;

use sui::coin;
use sui::random::{Self, Random};
use sui::sui::SUI;

public struct Lottery has key, store {
    id: UID,
    ticket_price: u64,
    participants: vector<address>,
    prize_pool: coin::Coin<SUI>,
    is_active: bool,
    owner: address,
}

#[error]
const INACTIVE_LOTTERY: vector<u8> = b"Lottery is not active right now";

#[error]
const ALREADY_PARTICIPANT: vector<u8> = b"You're already a participant in the lottery";

#[error]
const INSUFFICIENT_AMOUNT: vector<u8> = b"The coin you sent has insufficent balance to buy ticket";

#[error]
const NOT_A_OWNER: vector<u8> = b"You're not the owner of the lottery";

#[error]
const INVALID_USER_TO_BUY_TICKET: vector<u8> = b"Owner can't buy the lottery ticket";

const FEE_PORTION_PERCENTAGE: u64 = 10;

public fun create_lottery(ticket_price: u64, ctx: &mut TxContext) {
    let lottery = Lottery {
        id: object::new(ctx),
        ticket_price,
        participants: vector[],
        prize_pool: coin::zero<SUI>(ctx),
        is_active: true,
        owner: ctx.sender(),
    };
    transfer::share_object(lottery);
}

public fun buy_ticket(fees: &mut coin::Coin<SUI>, lottery: &mut Lottery, ctx: &mut TxContext) {
    assert!(lottery.is_active, INACTIVE_LOTTERY);
    assert!(lottery.owner != ctx.sender(), INVALID_USER_TO_BUY_TICKET);
    assert!(!lottery.participants.contains(&ctx.sender()), ALREADY_PARTICIPANT);
    assert!(coin::value(fees) >= lottery.ticket_price, INSUFFICIENT_AMOUNT);
    lottery.participants.push_back(ctx.sender());
    let transfer_portion = coin::split(fees, lottery.ticket_price, ctx);
    coin::join(&mut lottery.prize_pool, transfer_portion);
}

public fun draw_winner(lottery: &mut Lottery, r: &Random, ctx: &mut TxContext): (address) {
    assert!(lottery.owner == ctx.sender(), NOT_A_OWNER);
    let mut generator = random::new_generator(r, ctx);
    let winnerIndex = random::generate_u64_in_range(
        &mut generator,
        0,
        lottery.participants.length() - 1,
    );
    let winner = *vector::borrow(&lottery.participants, winnerIndex);
    let fees = (coin::value(&lottery.prize_pool) * FEE_PORTION_PERCENTAGE) / 100;
    let winning_amount = coin::value(&lottery.prize_pool);
    let fee_portion = coin::split(
        &mut lottery.prize_pool,
        fees,
        ctx,
    );
    let winner_portion = coin::split(&mut lottery.prize_pool, winning_amount, ctx);
    transfer::public_transfer(fee_portion, lottery.owner);
    transfer::public_transfer(winner_portion, winner);
    lottery.is_active = false;
    (winner)
}

#[test_only]
public fun ticket_price(lottery: &Lottery) : u64 {
    lottery.ticket_price
} 

#[test_only]
public fun prize_pool(lottery: &Lottery) : &coin::Coin<SUI> {
    &lottery.prize_pool
}

