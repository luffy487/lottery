#[test_only]
module lottery::lottery_tests;

use lottery::lottery;
use std::debug;
use sui::coin;
use sui::random::{Self, Random};
use sui::sui::SUI;
use sui::test_scenario::{Self, next_tx, ctx};

#[error]
const LOTTERY_CREATION_FAILED: vector<u8> =
    b"Lottery creation is failed and the value of the coin created is not zero";

#[error]
const WINNER_AMOUNT_TRANSFER_FAILED: vector<u8> =
    b"Transferring winning amount of lottery to the winner is failed";

#[test]

public fun test_lottery() {
    let owner = @0x0100;
    let zero = @0x0000;
    let user1 = @0x0200;
    let user2 = @0x0300;
    let user3 = @0x0400;
    let user4 = @0x0500;
    let mut scenario = test_scenario::begin(owner);

    lottery::create_lottery(1, ctx(&mut scenario));

    next_tx(&mut scenario, owner);
    {
        let lottery = test_scenario::take_shared<lottery::Lottery>(&scenario);
        assert!(coin::value(lottery.prize_pool()) == 0, LOTTERY_CREATION_FAILED);
        test_scenario::return_shared(lottery);
    };

    next_tx(&mut scenario, user1);
    {
        let mut fees = coin::mint_for_testing<SUI>(1, ctx(&mut scenario));
        let mut lottery = test_scenario::take_shared<lottery::Lottery>(&scenario);
        assert!(coin::value(&fees) >= lottery.ticket_price());
        lottery::buy_ticket(&mut fees, &mut lottery, ctx(&mut scenario));
        test_scenario::return_shared(lottery);
        transfer::public_transfer(fees, user1);
    };
    next_tx(&mut scenario, user2);
    {
        let mut fees = coin::mint_for_testing<SUI>(1, ctx(&mut scenario));
        let mut lottery = test_scenario::take_shared<lottery::Lottery>(&scenario);
        assert!(coin::value(&fees) >= lottery.ticket_price());
        lottery::buy_ticket(&mut fees, &mut lottery, ctx(&mut scenario));
        test_scenario::return_shared(lottery);
        transfer::public_transfer(fees, user2);
    };
    next_tx(&mut scenario, user3);
    {
        let mut fees = coin::mint_for_testing<SUI>(1, ctx(&mut scenario));
        let mut lottery = test_scenario::take_shared<lottery::Lottery>(&scenario);
        assert!(coin::value(&fees) >= lottery.ticket_price());
        lottery::buy_ticket(&mut fees, &mut lottery, ctx(&mut scenario));
        test_scenario::return_shared(lottery);
        transfer::public_transfer(fees, user3);
    };
    next_tx(&mut scenario, user4);
    {
        let mut fees = coin::mint_for_testing<SUI>(1, ctx(&mut scenario));
        let mut lottery = test_scenario::take_shared<lottery::Lottery>(&scenario);
        assert!(coin::value(&fees) >= lottery.ticket_price());
        lottery::buy_ticket(&mut fees, &mut lottery, ctx(&mut scenario));
        test_scenario::return_shared(lottery);
        transfer::public_transfer(fees, user4);
    };
    next_tx(&mut scenario, zero);
    {
        random::create_for_testing(ctx(&mut scenario));
    };
    next_tx(&mut scenario, owner);
    {
        let mut lottery = test_scenario::take_shared<lottery::Lottery>(&scenario);
        let random = test_scenario::take_shared<Random>(&scenario);
        let winner = lottery::draw_winner(&mut lottery, &random, ctx(&mut scenario));
        let won_object = test_scenario::take_from_address<coin::Coin<SUI>>(&scenario, winner);
        let winning_amount = coin::value(lottery.prize_pool());
        debug::print(&won_object);
        debug::print(&winner);
        assert!(coin::value(&won_object) == winning_amount, WINNER_AMOUNT_TRANSFER_FAILED);
        test_scenario::return_shared(lottery);
        transfer::public_transfer(won_object, winner);
        test_scenario::return_shared(random);
    };
    scenario.end();
}

#[test]
#[expected_failure(abort_code = lottery::INVALID_USER_TO_BUY_TICKET)]
public fun test_owner_cannot_buy_ticket() {
    let owner = @0x0100;
    let mut scenario = test_scenario::begin(owner);

    lottery::create_lottery(1, ctx(&mut scenario));

    next_tx(&mut scenario, owner);
    {
        let lottery = test_scenario::take_shared<lottery::Lottery>(&scenario);
        assert!(coin::value(lottery.prize_pool()) == 0, LOTTERY_CREATION_FAILED);
        test_scenario::return_shared(lottery);
    };

    next_tx(&mut scenario, owner);
    {
        let mut lottery = test_scenario::take_shared<lottery::Lottery>(&scenario);
        let mut fees = coin::mint_for_testing<SUI>(1, ctx(&mut scenario));
        lottery::buy_ticket(&mut fees, &mut lottery, ctx(&mut scenario));
        test_scenario::return_shared(lottery);
        transfer::public_transfer(fees, owner);
    };
    scenario.end();
}

#[test]
#[expected_failure(abort_code = lottery::ALREADY_PARTICIPANT)]
public fun test_one_user_can_buy_two_tickets() {
    let owner = @0x0100;
    let user = @0x0200;
    let mut scenario = test_scenario::begin(owner);

    lottery::create_lottery(1, ctx(&mut scenario));

    next_tx(&mut scenario, owner);
    {
        let lottery = test_scenario::take_shared<lottery::Lottery>(&scenario);
        assert!(coin::value(lottery.prize_pool()) == 0, LOTTERY_CREATION_FAILED);
        test_scenario::return_shared(lottery);
    };

    next_tx(&mut scenario, user);
    {
        let mut lottery = test_scenario::take_shared<lottery::Lottery>(&scenario);
        let mut fees = coin::mint_for_testing<SUI>(1, ctx(&mut scenario));
        lottery::buy_ticket(&mut fees, &mut lottery, ctx(&mut scenario));
        test_scenario::return_shared(lottery);
        transfer::public_transfer(fees, user);
    };

    next_tx(&mut scenario, user);
    {
        let mut lottery = test_scenario::take_shared<lottery::Lottery>(&scenario);
        let mut fees = coin::mint_for_testing<SUI>(1, ctx(&mut scenario));
        lottery::buy_ticket(&mut fees, &mut lottery, ctx(&mut scenario));
        test_scenario::return_shared(lottery);
        transfer::public_transfer(fees, user);
    };
    scenario.end();
}

#[test]
#[expected_failure(abort_code = lottery::INSUFFICIENT_AMOUNT)]
public fun test_not_enough_amount_to_buy_ticket() {
    let owner = @0x0100;
    let user = @0x0200;
    let mut scenario = test_scenario::begin(owner);

    lottery::create_lottery(2, ctx(&mut scenario));

    next_tx(&mut scenario, owner);
    {
        let lottery = test_scenario::take_shared<lottery::Lottery>(&scenario);
        assert!(coin::value(lottery.prize_pool()) == 0, LOTTERY_CREATION_FAILED);
        test_scenario::return_shared(lottery);
    };

    next_tx(&mut scenario, user);
    {
        let mut lottery = test_scenario::take_shared<lottery::Lottery>(&scenario);
        let mut fees = coin::mint_for_testing<SUI>(1, ctx(&mut scenario));
        lottery::buy_ticket(&mut fees, &mut lottery, ctx(&mut scenario));
        test_scenario::return_shared(lottery);
        transfer::public_transfer(fees, user);
    };
    scenario.end();
}

#[test]
#[expected_failure(abort_code = lottery::NOT_A_OWNER)]
public fun test_not_owner_can_draw_winner() {
    {
        let owner = @0x0100;
        let zero = @0x0000;
        let user1 = @0x0200;
        let user2 = @0x0300;
        let mut scenario = test_scenario::begin(owner);

        lottery::create_lottery(1, ctx(&mut scenario));

        next_tx(&mut scenario, owner);
        {
            let lottery = test_scenario::take_shared<lottery::Lottery>(&scenario);
            assert!(coin::value(lottery.prize_pool()) == 0, LOTTERY_CREATION_FAILED);
            test_scenario::return_shared(lottery);
        };

        next_tx(&mut scenario, user1);
        {
            let mut fees = coin::mint_for_testing<SUI>(1, ctx(&mut scenario));
            let mut lottery = test_scenario::take_shared<lottery::Lottery>(&scenario);
            assert!(coin::value(&fees) >= lottery.ticket_price());
            lottery::buy_ticket(&mut fees, &mut lottery, ctx(&mut scenario));
            test_scenario::return_shared(lottery);
            transfer::public_transfer(fees, user1);
        };
        next_tx(&mut scenario, user2);
        {
            let mut fees = coin::mint_for_testing<SUI>(1, ctx(&mut scenario));
            let mut lottery = test_scenario::take_shared<lottery::Lottery>(&scenario);
            assert!(coin::value(&fees) >= lottery.ticket_price());
            lottery::buy_ticket(&mut fees, &mut lottery, ctx(&mut scenario));
            test_scenario::return_shared(lottery);
            transfer::public_transfer(fees, user2);
        };
        next_tx(&mut scenario, zero);
        {
            random::create_for_testing(ctx(&mut scenario));
        };
        next_tx(&mut scenario, user1);
        {
            let mut lottery = test_scenario::take_shared<lottery::Lottery>(&scenario);
            let random = test_scenario::take_shared<Random>(&scenario);
            let winner = lottery::draw_winner(&mut lottery, &random, ctx(&mut scenario));
            let won_object = test_scenario::take_from_address<coin::Coin<SUI>>(&scenario, winner);
            let winning_amount = coin::value(lottery.prize_pool());
            debug::print(&won_object);
            debug::print(&winner);
            assert!(coin::value(&won_object) == winning_amount, WINNER_AMOUNT_TRANSFER_FAILED);
            test_scenario::return_shared(lottery);
            transfer::public_transfer(won_object, winner);
            test_scenario::return_shared(random);
        };
        scenario.end();
    }
}
