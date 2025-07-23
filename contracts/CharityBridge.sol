// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CharityBridge is Ownable {
    struct Charity {
        string name;
        string description;
        address walletAddress;
        uint256 chainId;
        bool verified;
    }


    struct Donation {
        address donor;
        uint256 amount;
        uint256 charityId;
        uint256 timestamp;
        uint256 originChain;

    }

    uint256 public charityCount;
    mapping(uint256 => Charity) public charities;
    mapping(address => Donation[]) public donorHistory;
    mapping(uint256 => Donation[]) public charityDonations;
    IERC20 public token;

    event CharityAdded(uint256 indexed charityId, string name);
    event DonationSent(address indexed donor, uint256 indexed charityId, uint256 amount);
    event CrossChainDonationInitiated(address indexed donor, uint256 indexed charityId, uint256 amount, uint256 targetChain);

    constructor(address _tokenAddress) Ownable(msg.sender) {
        token = IERC20(_tokenAddress);
    }

    function addCharity(
        string memory _name,
        string memory _description,
        address _walletAddress,
        uint256 _chainId
    ) external onlyOwner 
{
        uint256 charityId = charityCount++;
        charities[charityId] = Charity({
            name: _name,
            description: _description,
            walletAddress: _walletAddress,
            chainId: _chainId,
            verified: true
        });
        emit CharityAdded(charityId, _name);
    }

    function donate(uint256 _charityId, uint256 _amount) external {
        Charity memory charity = charities[_charityId];
        require(charity.verified, "Charity not verified");
        require(_amount > 0, "Amount must be positive");

        require(token.transferFrom(msg.sender, charity.walletAddress, _amount), "Transfer failed");

        Donation memory donation = Donation({
            donor: msg.sender,
            amount: _amount,
            charityId: _charityId,
            timestamp: block.timestamp,
            originChain: block.chainid
        });

        donorHistory[msg.sender].push(donation);
        charityDonations[_charityId].push(donation);
        emit DonationSent(msg.sender, _charityId, _amount);
    }

    function initiateCrossChainDonation(
        uint256 _charityId,
        uint256 _amount,
        uint256 _targetChain
    ) external {
        Charity memory charity = charities[_charityId];
        require(charity.verified, "Charity not verified");
        require(charity.chainId == _targetChain, "Chain mismatch");
        require(_amount > 0, "Amount must be positive");

        require(token.transferFrom(msg.sender, address(this), _amount), "Transfer failed");

        emit CrossChainDonationInitiated(msg.sender, _charityId, _amount, _targetChain);
    }

    function getDonorHistory(address _donor) external view returns (Donation[] memory) {
        return donorHistory[_donor];
    }

    function getCharityDonations(uint256 _charityId) external view returns (Donation[] memory) {
        return charityDonations[_charityId];
    }
}
