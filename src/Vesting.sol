// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./VestingWalletCliff.sol";

/**
 * @title Vesting
 * @dev This contract extends VestingWalletCliff to implement a vesting wallet with a cliff period.
 * The vesting schedule defines how tokens are vested over time with an initial cliff period.
 */
contract Vesting is VestingWalletCliff {

    uint64 private constant MAX_DURATION = 60 * 30 days;

    event VestingWalletCreated(address indexed beneficiary, address vestingWallet, uint64 startTimestamp, uint64 durationSeconds, uint64 cliffSeconds);
    /// @dev The specified duration is larger than the maximum allowed duration.
    error InvalidDuration(uint64 durationSeconds);

    /**
     * @dev Sets up a vesting wallet with a cliff period.
     * @param beneficiary The address of the beneficiary to whom vested tokens are transferred.
     * @param startTimestamp The timestamp when the vesting starts.
     * @param durationSeconds The total duration of the vesting period in seconds.
     * @param cliffSeconds The duration of the cliff period in seconds.
     */
    constructor(address beneficiary, uint64 startTimestamp, uint64 durationSeconds, uint64 cliffSeconds)
        VestingWallet(beneficiary, startTimestamp, durationSeconds)
        VestingWalletCliff(cliffSeconds)
    {
         if (durationSeconds > MAX_DURATION) {
            revert InvalidDuration(durationSeconds);
        }
        emit VestingWalletCreated(beneficiary, address(this), startTimestamp, durationSeconds, cliffSeconds);
    }
}
