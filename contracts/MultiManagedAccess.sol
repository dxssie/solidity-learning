// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract MultiManagedAccess {
    uint constant MANAGER_NUMBERS = 3; 
    address[MANAGER_NUMBERS] public managers;
    bool[MANAGER_NUMBERS] public confirmed;

    uint256 public rewardPerBlock;

    constructor(address[] memory _managers) {
        require(_managers.length == MANAGER_NUMBERS, "Manager size unmatched");
        for (uint i = 0; i < MANAGER_NUMBERS; i++) {
            managers[i] = _managers[i];
        }
    }

    function isManager(address _addr) internal view returns (bool) {
        for (uint i = 0; i < MANAGER_NUMBERS; i++) {
            if (managers[i] == _addr) return true;
        }
        return false;
    }

    function confirm() external {
        bool found = false;
        for (uint i = 0; i < MANAGER_NUMBERS; i++) {
            if (managers[i] == msg.sender) {
                confirmed[i] = true;
                found = true;
                break;
            }
        }
        require(found, "You are not a manager");
    }

    function allConfirmed() internal view returns (bool) {
        for (uint i = 0; i < MANAGER_NUMBERS; i++) {
            if (!confirmed[i]) return false;
        }
        return true;
    }

    function resetConfirmations() internal {
        for (uint i = 0; i < MANAGER_NUMBERS; i++) {
            confirmed[i] = false;
        }
    }

    modifier onlyAllConfirmed() {
        require(allConfirmed(), "Not all managers confirmed yet");
        resetConfirmations();
        _;
    }

    function setRewardPerBlock(uint256 _amount) external onlyAllConfirmed {
        rewardPerBlock = _amount;
    }
}
