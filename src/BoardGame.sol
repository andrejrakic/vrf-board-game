// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract BoardGame is VRFConsumerBaseV2 {
    struct Profile {
        uint32 fieldPosition;
        uint32 happiness;
        uint32 speed;
        uint32 wealth;
        bool isYourTurnInProgress;
    }

    VRFCoordinatorV2Interface internal immutable i_vrfCoordinator;
    uint64 internal immutable i_subscriptionId;
    bytes32 internal immutable i_keyHash;
    uint32 internal immutable i_callbackGasLimit;
    uint16 internal immutable i_requestConfirmations;
    uint32 internal immutable i_numWords;

    mapping(address => Profile) internal players;
    mapping(uint256 => address) internal requestIds;

    event NewTurn(address indexed player);
    event Moved(address indexed player, uint32 indexed newFieldPosition);

    constructor(
        uint64 subscriptionId,
        address vrfCoordinator,
        bytes32 keyHash,
        uint32 callbackGasLimit,
        uint16 requestConfirmations
    ) VRFConsumerBaseV2(vrfCoordinator) {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_subscriptionId = subscriptionId;
        i_keyHash = keyHash;
        i_callbackGasLimit = callbackGasLimit;
        i_requestConfirmations = requestConfirmations;
        i_numWords = 1;
    }

    function roleDice() external {
        require(
            !players[msg.sender].isYourTurnInProgress,
            "Your previous turn is still in progress"
        );
        require(players[msg.sender].fieldPosition < 40, "Game over");

        players[msg.sender].isYourTurnInProgress = true;

        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_keyHash,
            i_subscriptionId,
            i_requestConfirmations,
            i_callbackGasLimit,
            i_numWords
        );

        requestIds[requestId] = msg.sender;

        emit NewTurn(msg.sender);
    }

    function getScore(address player)
        external
        view
        returns (
            uint32 happiness,
            uint32 speed,
            uint32 wealth
        )
    {
        Profile memory playersProfile = players[player];
        return (
            playersProfile.happiness,
            playersProfile.speed,
            playersProfile.wealth
        );
    }

    function getReward(uint32 fieldPosition)
        public
        pure
        returns (
            uint32 happiness,
            uint32 speed,
            uint32 wealth
        )
    {
        if (fieldPosition == 0) {
            return (0, 0, 0);
        } else if (fieldPosition == 1) {
            return (10, 0, 0);
        } else if (fieldPosition == 2) {
            return (0, 10, 0);
        } else if (fieldPosition == 3) {
            return (0, 0, 10);
        } else if (fieldPosition == 4) {
            return (10, 10, 0);
        } else if (fieldPosition == 5) {
            return (10, 0, 10);
        } else if (fieldPosition == 6) {
            return (0, 10, 10);
        } else if (fieldPosition == 7) {
            return (10, 10, 10);
        } else if (fieldPosition == 8) {
            return (10, 0, 0);
        } else if (fieldPosition == 9) {
            return (0, 10, 0);
        } else if (fieldPosition == 10) {
            return (0, 0, 10);
        } else if (fieldPosition == 11) {
            return (10, 10, 0);
        } else if (fieldPosition == 12) {
            return (10, 0, 10);
        } else if (fieldPosition == 13) {
            return (0, 10, 10);
        } else if (fieldPosition == 14) {
            return (10, 10, 10);
        } else if (fieldPosition == 15) {
            return (10, 0, 0);
        } else if (fieldPosition == 16) {
            return (0, 10, 0);
        } else if (fieldPosition == 17) {
            return (0, 0, 10);
        } else if (fieldPosition == 18) {
            return (10, 10, 0);
        } else if (fieldPosition == 19) {
            return (10, 0, 10);
        } else if (fieldPosition == 20) {
            return (0, 10, 10);
        } else if (fieldPosition == 21) {
            return (10, 10, 10);
        } else if (fieldPosition == 22) {
            return (10, 0, 0);
        } else if (fieldPosition == 23) {
            return (0, 10, 0);
        } else if (fieldPosition == 24) {
            return (0, 0, 10);
        } else if (fieldPosition == 25) {
            return (10, 10, 0);
        } else if (fieldPosition == 26) {
            return (10, 0, 10);
        } else if (fieldPosition == 27) {
            return (0, 10, 10);
        } else if (fieldPosition == 28) {
            return (10, 10, 10);
        } else if (fieldPosition == 29) {
            return (10, 0, 0);
        } else if (fieldPosition == 30) {
            return (0, 10, 0);
        } else if (fieldPosition == 31) {
            return (0, 0, 10);
        } else if (fieldPosition == 32) {
            return (10, 10, 0);
        } else if (fieldPosition == 33) {
            return (10, 0, 10);
        } else if (fieldPosition == 34) {
            return (0, 10, 10);
        } else if (fieldPosition == 35) {
            return (10, 10, 10);
        } else if (fieldPosition == 36) {
            return (10, 0, 0);
        } else if (fieldPosition == 37) {
            return (0, 10, 0);
        } else if (fieldPosition == 38) {
            return (0, 0, 10);
        } else if (fieldPosition == 39) {
            return (10, 10, 0);
        } else if (fieldPosition == 40) {
            return (10, 0, 10);
        } else {
            return (0, 0, 0);
        }
    }

    // @inheritdoc
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        uint256 diceValue = (randomWords[0] % 6) + 1;
        address player = requestIds[requestId];

        players[player].fieldPosition += uint32(diceValue);
        (uint32 happiness, uint32 speed, uint32 wealth) = getReward(
            players[player].fieldPosition
        );
        players[player].happiness = happiness;
        players[player].speed = speed;
        players[player].wealth = wealth;

        emit Moved(msg.sender, players[player].fieldPosition);
    }
}
