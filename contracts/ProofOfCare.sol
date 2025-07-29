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

    mapping(address => ActivityRecord[]) private _userRecords;
    mapping(address => bool) private _verifiers;
    uint256 private _totalRecords;

    event RecordAdded(address indexed participant, ActivityType activityType, uint256 hoursCompleted);
    event VerifierAdded(address indexed verifier);
    event VerifierRemoved(address indexed verifier);

    constructor() {
        _verifiers[msg.sender] = true;
    }

    modifier onlyVerifier() {
        require(_verifiers[msg.sender], "Caller is not a verifier");
        _;
    }

    function addVerifier(address verifier) external onlyOwner {
        require(verifier != address(0), "Invalid verifier address");
        _verifiers[verifier] = true;
        emit VerifierAdded(verifier);
    }

    function removeVerifier(address verifier) external onlyOwner {
        require(_verifiers[verifier], "Verifier not found");
        _verifiers[verifier] = false;
        emit VerifierRemoved(verifier);
    }

    function addRecord(
        address participant,
        ActivityType activityType,
        uint256 hoursCompleted,
        string calldata description
    ) external onlyVerifier {
        require(hoursCompleted > 0, "Hours must be greater than zero");

        ActivityRecord memory newRecord = ActivityRecord({
            participant: participant,
            activityType: activityType,
            hoursCompleted: hoursCompleted,
            description: description,
            timestamp: block.timestamp,
            verifiedBy: msg.sender
        });

        _userRecords[participant].push(newRecord);
        _totalRecords++;

        emit RecordAdded(participant, activityType, hoursCompleted);
    }

    function getUserRecords(address user) external view returns (ActivityRecord[] memory) {
        return _userRecords[user];
    }

    function getTotalHours(address user, ActivityType activityType) external view returns (uint256 total) {
        ActivityRecord[] memory records = _userRecords[user];
        for (uint i = 0; i < records.length; i++) {
            if (records[i].activityType == activityType) {
                total += records[i].hoursCompleted;
            }
        }
    }

    function isVerifier(address addr) external view returns (bool) {
        return _verifiers[addr];
    }

    function totalRecords() external view returns (uint256) {
        return _totalRecords;
    }
}
