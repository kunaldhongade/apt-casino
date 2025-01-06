// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Roulette {
    address public owner; // Owner of the contract

    event BetPlaced(
        address indexed player,
        uint8 betType,
        uint8 number,
        uint amount
    );
    event SpinResult(uint8 winningNumber);
    event Payout(address indexed player, uint amount);
    event FundsDeposited(address indexed sender, uint256 amount);

    struct Bet {
        uint8 betType; // 1: Straight, ..., 10: Low/High
        uint8 number; // Number or range for the bet
        uint amount; // Bet amount in wei
    }

    mapping(address => Bet[]) public playerBets; // Tracks bets for each player
    address[] private players; // List of players for the current round
    mapping(address => bool) private hasPlacedBet; // Tracks whether a player has placed a bet

    uint private nonce; // For generating pseudo-random numbers

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
        nonce = 0;
    }

    receive() external payable {
        emit FundsDeposited(msg.sender, msg.value);
    }

    function spinWheel() private {
        require(players.length > 0, "No bets placed");

        uint8 winningNumber = random();
        emit SpinResult(winningNumber);

        // Distribute winnings to the players who have winning bets
        distributeWinnings(winningNumber);
        resetBets();
    }

    // Place a bet
    function placeBet(
        uint8[] calldata betTypes,
        uint8[] calldata numbers
    ) external payable {
        require(
            betTypes.length == numbers.length,
            "Mismatched bet types and numbers"
        );
        require(msg.value > 0, "Bet amount must be greater than zero");

        uint totalAmount = msg.value;
        uint individualBetAmount = totalAmount / betTypes.length; // Divide total amount by the number of bets

        // Validate bet types and numbers before looping
        for (uint i = 0; i < betTypes.length; i++) {
            require(
                isValidBet(betTypes[i], numbers[i]),
                "Invalid bet type or number"
            );
        }

        // Iterate through the bets and record them
        for (uint i = 0; i < betTypes.length; i++) {
            uint8 betType = betTypes[i];
            uint8 number = numbers[i];

            // Record the bet
            Bet memory newBet = Bet({
                betType: betType,
                number: number,
                amount: individualBetAmount
            });
            playerBets[msg.sender].push(newBet);

            // Add player to the list if not already added
            if (!hasPlacedBet[msg.sender]) {
                players.push(msg.sender);
                hasPlacedBet[msg.sender] = true;
            }

            emit BetPlaced(msg.sender, betType, number, individualBetAmount);
        }

        // Automatically spin the wheel after placing a bet
        spinWheel();
    }

    // Distribute winnings based on the result
    function distributeWinnings(uint8 winningNumber) private {
        for (uint i = 0; i < players.length; i++) {
            address player = players[i];
            uint payout = calculatePayout(player, winningNumber);
            if (payout > 0) {
                payable(player).transfer(payout);
                emit Payout(player, payout);
            }
        }
    }

    // Calculate total payout for a player
    function calculatePayout(
        address player,
        uint8 winningNumber
    ) private view returns (uint) {
        uint totalPayout = 0;

        for (uint i = 0; i < playerBets[player].length; i++) {
            Bet memory bet = playerBets[player][i];
            if (isWinningBet(bet, winningNumber)) {
                totalPayout += calculateWinnings(bet);
            }
        }

        return totalPayout;
    }

    function isLineWinner(
        uint number,
        uint winningNumber
    ) private pure returns (bool) {
        uint start = (number - 1) * 6 + 1;
        uint end = start + 5;
        return winningNumber >= start && winningNumber <= end;
    }

    function isSplitWinner(
        uint8 number,
        uint8 winningNumber
    ) private pure returns (bool) {
        uint8[2][57] memory splits = [
            [1, 2],
            [2, 3],
            [4, 5],
            [5, 6],
            [7, 8],
            [8, 9],
            [10, 11],
            [11, 12],
            [13, 14],
            [14, 15],
            [16, 17],
            [17, 18],
            [19, 20],
            [20, 21],
            [22, 23],
            [23, 24],
            [25, 26],
            [26, 27],
            [28, 29],
            [29, 30],
            [31, 32],
            [32, 33],
            [34, 35],
            [35, 36],
            [1, 4],
            [2, 5],
            [3, 6],
            [4, 7],
            [5, 8],
            [6, 9],
            [7, 10],
            [8, 11],
            [9, 12],
            [10, 13],
            [11, 14],
            [12, 15],
            [13, 16],
            [14, 17],
            [15, 18],
            [16, 19],
            [17, 20],
            [18, 21],
            [19, 22],
            [20, 23],
            [21, 24],
            [22, 25],
            [23, 26],
            [24, 27],
            [25, 28],
            [26, 29],
            [27, 30],
            [28, 31],
            [29, 32],
            [30, 33],
            [31, 34],
            [32, 35],
            [33, 36]
        ];

        for (uint8 i = 0; i < splits.length; i++) {
            if (
                (number == splits[i][0] && winningNumber == splits[i][1]) ||
                (number == splits[i][1] && winningNumber == splits[i][0])
            ) {
                return true;
            }
        }
        return false;
    }

    function isStreetWinner(
        uint8 number,
        uint8 winningNumber
    ) private pure returns (bool) {
        uint8[3][12] memory streets = [
            [1, 2, 3],
            [4, 5, 6],
            [7, 8, 9],
            [10, 11, 12],
            [13, 14, 15],
            [16, 17, 18],
            [19, 20, 21],
            [22, 23, 24],
            [25, 26, 27],
            [28, 29, 30],
            [31, 32, 33],
            [34, 35, 36]
        ];

        require(number >= 1 && number <= 12, "Invalid street number");
        return (winningNumber == streets[number - 1][0] ||
            winningNumber == streets[number - 1][1] ||
            winningNumber == streets[number - 1][2]);
    }

    function isCornerWinner(
        uint8 number,
        uint8 winningNumber
    ) private pure returns (bool) {
        uint8[4][22] memory corners = [
            [1, 2, 4, 5],
            [2, 3, 5, 6],
            [4, 5, 7, 8],
            [5, 6, 8, 9],
            [7, 8, 10, 11],
            [8, 9, 11, 12],
            [10, 11, 13, 14],
            [11, 12, 14, 15],
            [13, 14, 16, 17],
            [14, 15, 17, 18],
            [16, 17, 19, 20],
            [17, 18, 20, 21],
            [19, 20, 22, 23],
            [20, 21, 23, 24],
            [22, 23, 25, 26],
            [23, 24, 26, 27],
            [25, 26, 28, 29],
            [26, 27, 29, 30],
            [28, 29, 31, 32],
            [29, 30, 32, 33],
            [31, 32, 34, 35],
            [32, 33, 35, 36]
        ];

        for (uint8 i = 0; i < corners.length; i++) {
            if (
                winningNumber == corners[i][0] ||
                winningNumber == corners[i][1] ||
                winningNumber == corners[i][2] ||
                winningNumber == corners[i][3]
            ) {
                return number == i + 1; // Corner index starts at 1
            }
        }
        return false;
    }

    // Determine if a bet is a winning bet
    function isWinningBet(
        Bet memory bet,
        uint8 winningNumber
    ) private pure returns (bool) {
        if (bet.betType == 1) return bet.number == winningNumber; // Straight
        if (bet.betType == 2) return isSplitWinner(bet.number, winningNumber); // Split
        if (bet.betType == 3) return isStreetWinner(bet.number, winningNumber); // Street
        if (bet.betType == 4) return isCornerWinner(bet.number, winningNumber); // Corner
        if (bet.betType == 5) return isLineWinner(bet.number, winningNumber); // Line
        if (bet.betType == 6) return (winningNumber - 1) % 3 == bet.number; // Column
        if (bet.betType == 7)
            return ((winningNumber - 1) / 12 + 1) == bet.number; // Dozen
        if (bet.betType == 8) return isRed(winningNumber) == (bet.number == 1); // Red/Black
        if (bet.betType == 9)
            return (winningNumber % 2 == 0) == (bet.number == 1); // Even/Odd
        if (bet.betType == 10)
            return
                (winningNumber >= 1 && winningNumber <= 18) ==
                (bet.number == 1); // Low/High
        return false;
    }

    // Calculate winnings for a single bet
    function calculateWinnings(Bet memory bet) private pure returns (uint) {
        if (bet.betType == 1) return bet.amount * 35; // Straight: 35:1
        if (bet.betType == 2) return bet.amount * 17; // Split: 17:1
        if (bet.betType == 3) return bet.amount * 11; // Street: 11:1
        if (bet.betType == 4) return bet.amount * 8; // Corner: 8:1
        if (bet.betType == 5) return bet.amount * 5; // Line: 5:1
        if (bet.betType == 6) return bet.amount * 2; // Column: 2:1
        if (bet.betType == 7) return bet.amount * 2; // Dozen: 2:1
        if (bet.betType == 8) return bet.amount * 2; // Red/Black: 1:1
        if (bet.betType == 9) return bet.amount * 2; // Even/Odd: 1:1
        if (bet.betType == 10) return bet.amount * 2; // Low/High: 1:1
        return 0;
    }

    // Check if a number is red
    function isRed(uint8 number) private pure returns (bool) {
        uint8[18] memory redNumbers = [
            1,
            3,
            5,
            7,
            9,
            12,
            14,
            16,
            18,
            19,
            21,
            23,
            25,
            27,
            30,
            32,
            34,
            36
        ];
        for (uint8 i = 0; i < redNumbers.length; i++) {
            if (redNumbers[i] == number) return true;
        }
        return false;
    }

    // Generate pseudo-random number
    function random() private returns (uint8) {
        nonce++;
        return
            uint8(
                uint(
                    keccak256(
                        abi.encodePacked(
                            block.timestamp,
                            block.prevrandao,
                            nonce
                        )
                    )
                ) % 37
            );
    }

    // Reset bets for the next round
    function resetBets() private {
        for (uint i = 0; i < players.length; i++) {
            delete playerBets[players[i]];
            hasPlacedBet[players[i]] = false;
        }
        delete players;
    }

    // Validate bet type and number
    function isValidBet(
        uint8 betType,
        uint8 number
    ) private pure returns (bool) {
        if (betType == 1) return number >= 0 && number <= 36; // Straight
        if (betType == 2) return number >= 0 && number <= 35; // Split
        if (betType == 3) return number >= 1 && number <= 12; // Street
        if (betType == 4) return number >= 1 && number <= 9; // Corner
        if (betType == 5) return number >= 1 && number <= 6; // Line
        if (betType == 6) return number >= 0 && number <= 2; // Column
        if (betType == 7) return number >= 1 && number <= 3; // Dozen
        if (betType == 8 || betType == 9 || betType == 10)
            return number == 1 || number == 2; // Others
        return false;
    }
}
