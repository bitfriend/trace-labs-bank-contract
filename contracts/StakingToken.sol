// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingToken is ERC20, Ownable {
    using SafeMath for uint256;

    uint256 public epoch; // in seconds

    uint256 public timeUnit; // in seconds

    /**
     * @notice We usually require to know who are all the stakeholders.
     */
    address[] internal stakeholders;

    /**
     * @notice The stakes for each stakeholder.
     */
    mapping(address => uint256) internal stakes;

    /**
     * @notice The period that each stakeholder was rewarded.
     */
    mapping(address => uint8) internal rewardedPeriods;

    /**
     * @notice The constructor for the Staking Token.
     * @param _name The name of token.
     * @param _symbol The symbol of token.
     * @param _timeUnit The deposit period in seconds.
     * @param _supply The amount of tokens to mint on construction.
     */
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _timeUnit,
        uint256 _supply
    ) ERC20(_name, _symbol) {
        epoch = block.timestamp;
        timeUnit = _timeUnit;
        _mint(msg.sender, _supply);
    }

    function deposit(uint256 amount) public {
        require(block.timestamp < epoch.add(timeUnit), "Deposit period was elapsed");
        createStake(amount);
    }

    function withdraw() public {
        require(block.timestamp >= epoch.add(timeUnit.mul(2)), "Withdraw time is not started");

        uint8 currentPeriod = 0;
        if (block.timestamp >= epoch.add(timeUnit.mul(4))) { // Reward3 period
            currentPeriod = 3;
        } else if (block.timestamp >= epoch.add(timeUnit.mul(3))) { // Reward2 period
            currentPeriod = 2;
        } else if (block.timestamp >= epoch.add(timeUnit.mul(2))) { // Reward1 period
            currentPeriod = 1;
        }

        uint256 totalStaked = totalStakes(0);
        uint256 totalRewards = totalStaked.mul(20).div(100);
        uint256 firstRewards = totalRewards.mul(20).div(100);
        uint256 secondRewards = totalRewards.mul(30).div(100);
        uint256 thirdRewards = totalRewards.mul(50).div(100);

        uint256 staked = stakeOf(msg.sender);
        uint256 rewarded = 0;

        if (block.timestamp >= epoch.add(timeUnit.mul(4))) { // Reward3 period
            uint256 aliveStaked = totalStakes(3);
            rewarded = rewarded.add(thirdRewards.mul(staked).div(aliveStaked));
        }
        if (block.timestamp >= epoch.add(timeUnit.mul(3))) { // Reward2 period
            uint256 aliveStaked = totalStakes(2);
            rewarded = rewarded.add(secondRewards.mul(staked).div(aliveStaked));
        }
        if (block.timestamp >= epoch.add(timeUnit.mul(2))) { // Reward1 period
            uint256 aliveStaked = totalStakes(1);
            rewarded = rewarded.add(firstRewards.mul(staked).div(aliveStaked));
        }

        rewardedPeriods[msg.sender] = currentPeriod;
        _mint(msg.sender, staked + rewarded);
    }

    // ---------- STAKES ----------

    /**
     * @notice A method for a stakeholder to create a stake.
     * @param _stake The size of the stake to be created.
     */
    function createStake(uint256 _stake) private {
        _burn(msg.sender, _stake);
        if (stakes[msg.sender] == 0) {
            addStakeholder(msg.sender);
        }
        stakes[msg.sender] = stakes[msg.sender].add(_stake);
    }

    /**
     * @notice A method for a stakeholder to remove a stake.
     * @param _stake The size of the stake to be removed.
     */
    function removeStake(uint256 _stake) private {
        stakes[msg.sender] = stakes[msg.sender].sub(_stake);
        if (stakes[msg.sender] == 0) {
            removeStakeholder(msg.sender);
        }
        _mint(msg.sender, _stake);
    }

    /**
     * @notice A method to retrieve the stake for a stakeholder.
     * @param _stakeholder The stakeholder to retrieve the stake for.
     * @return uint256 The amount of wei staked.
     */
    function stakeOf(address _stakeholder) public view returns (uint256) {
        return stakes[_stakeholder];
    }

    /**
     * @notice A method to the aggregated stakes from all stakeholders.
     * @return uint256 The aggregated stakes from all stakeholders.
     */
    function totalStakes(uint8 rewardPeriod) public view returns (uint256) {
        uint256 _totalStakes = 0;
        for (uint256 i = 0; i < stakeholders.length; i += 1) {
            address stakeholder = stakeholders[i];
            if (rewardPeriod != 0 && rewardedPeriods[stakeholder] != 0) {
                if (rewardedPeriods[stakeholder] < rewardPeriod) {
                    continue;
                }
            }
            _totalStakes = _totalStakes.add(stakes[stakeholder]);
        }
        return _totalStakes;
    }

    // ---------- STAKEHOLDERS ----------

    /**
     * @notice A method to check if an address is a stakeholder.
     * @param _address The address to verify.
     * @return bool, uint256 Whether the address is a stakeholder,
     * and if so its position in the stakeholders array.
     */
    function isStakeholder(address _address) public view returns (bool, uint256) {
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            if (_address == stakeholders[s]) {
                return (true, s);
            }
        }
        return (false, 0);
    }

    /**
     * @notice A method to add a stakeholder.
     * @param _stakeholder The stakeholder to add.
     */
    function addStakeholder(address _stakeholder) public {
        (bool _isStakeholder, ) = isStakeholder(_stakeholder);
        if (!_isStakeholder) {
            stakeholders.push(_stakeholder);
        }
    }

    /**
     * @notice A method to remove a stakeholder.
     * @param _stakeholder The stakeholder to remove.
     */
    function removeStakeholder(address _stakeholder) public {
        (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
        if (_isStakeholder) {
            stakeholders[s] = stakeholders[stakeholders.length - 1];
            stakeholders.pop();
        }
    }
}
