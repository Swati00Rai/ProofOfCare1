// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

contract ProofOfCare is Ownable {
    enum ActivityType { Healthcare, Volunteer, Education }

    struct ActivityRecord {
        address participant;
        ActivityType activityType;
        uint256 hoursCompleted;
        string description;
        uint256 timestamp;
        address verifiedBy;
    }

    mapping(address => ActivityRecord[]) public userRecords;
    mapping(address => bool) public verifiers;
    uint256 public totalRecords;

    event RecordAdded(address indexed participant, ActivityType activityType, uint256 hoursCompleted);
    event VerifierAdded(address indexed verifier);
    event VerifierRemoved(address indexed verifier);

    constructor() Ownable(msg.sender) {
        verifiers[msg.sender] = true;
    }

    function addVerifier(address _verifier) external onlyOwner {
        verifiers[_verifier] = true;
        emit VerifierAdded(_verifier);
    }

    function removeVerifier(address _verifier) external onlyOwner {
        verifiers[_verifier] = false;
        emit VerifierRemoved(_verifier);
    }

    function addRecord(
        address _participant,
        ActivityType _activityType,
        uint256 _hoursCompleted,
        string memory _description
    ) external {
        require(verifiers[msg.sender], "Not authorized verifier");
        require(_hoursCompleted > 0, "Hours must be positive");

        userRecords[_participant].push(ActivityRecord({
            participant: _participant,
            activityType: _activityType,
            hoursCompleted: _hoursCompleted,
            description: _description,
            timestamp: block.timestamp,
            verifiedBy: msg.sender
        }));

        totalRecords++;
        emit RecordAdded(_participant, _activityType, _hoursCompleted);
    }

    function getUserRecords(address _user) external view returns (ActivityRecord[] memory) {
        return userRecords[_user];
    }

    function getTotalHours(address _user, ActivityType _activityType) external view returns (uint256) {
        uint256 total = 0;
        for (uint i = 0; i < userRecords[_user].length; i++) {
            if (userRecords[_user][i].activityType == _activityType) {
                total += userRecords[_user][i].hoursCompleted;
            }
        }
        return total;
    }
}
