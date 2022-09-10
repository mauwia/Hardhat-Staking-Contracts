// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
//Chain link price Feed 
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

interface Token {
    function mint(uint256 amount, address receiver) external;

    function decimals() external view returns (uint8);
}
//errors

error Stake__NotEnoughEthEntered();
error Stake__NoStakeAmount();
error Stake__WithdrawFail();
/// @title Staking
/// @author @mauwia
/// @notice  User can stake ETH and get reawrd in the form of DevUSDC with 10% APY
contract Stake {
    uint8 private immutable i_APY = 10;
    struct Stakes {
        uint256 totalStake;
        uint256 reward;
        uint256 lastUpdateOn;
    }
    mapping(address => Stakes) public stakes;

    Token public token;
    AggregatorV3Interface internal priceFeed;

    constructor(address _priceFeedAddess, Token _tokenAddress) {
        token = _tokenAddress;
        priceFeed = AggregatorV3Interface(_priceFeedAddess);
    }

    function stake() public payable {
        if (stakes[msg.sender].totalStake + msg.value < 0.01 ether) {
            revert Stake__NotEnoughEthEntered();
        }

        if (stakes[msg.sender].totalStake > 0) {
            stakes[msg.sender].reward += calculateReward();
        }

        stakes[msg.sender].totalStake += msg.value;
        stakes[msg.sender].lastUpdateOn = block.timestamp;
    }

    function calculateReward() public view returns (uint) {
        uint256 period = (block.timestamp - stakes[msg.sender].lastUpdateOn);
        (, int price, , , ) = priceFeed.latestRoundData();
        // int price = 3000 * (10 ** 8);
        uint8 priceFeedDecimals = priceFeed.decimals();
        uint8 rewardTokenDecimals = token.decimals();
        uint8 stakeCurrencyDecimals = 18;
        assert(price > 0);

        uint256 rewardPerSecond = ((stakes[msg.sender].totalStake / 100) *
            i_APY) / 365 days;
        uint256 reward = rewardPerSecond * period;
        uint256 rewardInRewardToken = reward * uint256(price);
        uint256 decimals = stakeCurrencyDecimals +
            priceFeedDecimals -
            rewardTokenDecimals;

        return rewardInRewardToken / (10**decimals);
    }

    function withdraw() public {
        if (stakes[msg.sender].totalStake < 0) {
            revert Stake__NoStakeAmount();
        }
        stakes[msg.sender].reward += calculateReward();

        uint256 balance = stakes[msg.sender].totalStake;
        stakes[msg.sender].totalStake = 0;
        (bool successStakeWithdraw, ) = msg.sender.call{value: balance}("");
        if (!successStakeWithdraw) {
            revert Stake__WithdrawFail();
        }
        uint256 reward = stakes[msg.sender].reward;
        stakes[msg.sender].reward = 0;
        token.mint(reward, msg.sender);
    }
}
