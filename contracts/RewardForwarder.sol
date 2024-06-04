// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * @title RewardForwarder
 * @dev A contract that forwards incoming ETH to another contract address.
 * The owner can pause forwarding, claim ETH, and change the forwarding address.
 * It keeps track of the total amount of ETH received and forwarded.
 */
contract RewardForwarder is ReentrancyGuard, Ownable, Pausable {
    /// @notice Address to which the ETH will be forwarded
    address public forwardingAddress;

    /// @notice Counter to track the amount of ETH forwarded
    uint256 public ethForwarded;

    /// @notice Counter to track the amount of ETH received via the fallback function
    uint256 public ethReceivedFallback;

    /// @notice Event emitted when the forwarding address is changed
    /// @param previousAddress The previous forwarding address
    /// @param newAddress The new forwarding address
    event ForwardingAddressChanged(address indexed previousAddress, address indexed newAddress);

    /// @notice Event emitted when ETH is forwarded
    /// @param from The address from which the ETH was sent
    /// @param to The address to which the ETH was forwarded
    /// @param amount The amount of ETH forwarded
    event ETHForwarded(address indexed from, address indexed to, uint256 amount);

    /// @notice Event emitted when ETH is claimed by the owner
    /// @param owner The address of the owner claiming the ETH
    /// @param to The address to which the ETH was sent
    /// @param amount The amount of ETH claimed
    event ETHClaimed(address indexed owner, address indexed to, uint256 amount);

    /// @notice Event emitted when ETH is received by the fallback function
    /// @param from The address from which the ETH was sent
    /// @param amount The amount of ETH received
    event ETHReceived(address indexed from, uint256 amount);

    /**
     * @dev Initializes the contract with the forwarding address.
     * @param _forwardingAddress The address to which the ETH will be forwarded
     */
    constructor(address _forwardingAddress) Ownable(msg.sender) {
        require(_forwardingAddress != address(0), "Forwarding address cannot be zero address");
        forwardingAddress = _forwardingAddress;
    }

    /**
     * @dev Receives ETH and forwards it to the forwarding address if not paused.
     * Increments the ethReceived counter.
     */
    receive() external payable nonReentrant whenNotPaused {
        uint256 amount = msg.value;
        ethForwarded += amount;
        (bool success, ) = forwardingAddress.call{value: amount}("");
        require(success, "ETH forwarding failed");
        emit ETHForwarded(msg.sender, forwardingAddress, amount);
    }

    /**
     * @dev Fallback function that receives ETH.
     * Increments the ethReceived counter.
     */
    fallback() external payable {
        uint256 amount = msg.value;
        ethReceivedFallback += amount;
        emit ETHReceived(msg.sender, amount);
    }

    /**
     * @dev Allows the owner to claim the ETH in the contract.
     * @param _to The address to which the claimed ETH will be sent
     */
    function claimETH(address _to) external onlyOwner nonReentrant {
        require(_to != address(0), "Claim address cannot be zero address");
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to claim");
        (bool success, ) = _to.call{value: balance}("");
        require(success, "ETH claim failed");
        emit ETHClaimed(owner(), _to, balance);
    }

    /**
     * @dev Allows the owner to change the forwarding address.
     * @param _newForwardingAddress The new forwarding address
     */
    function changeForwardingAddress(address _newForwardingAddress) external onlyOwner {
        require(_newForwardingAddress != address(0), "New forwarding address cannot be zero address");
        address previousAddress = forwardingAddress;
        forwardingAddress = _newForwardingAddress;
        emit ForwardingAddressChanged(previousAddress, _newForwardingAddress);
    }

    /**
     * @dev Allows the owner to pause the contract, preventing ETH forwarding.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Allows the owner to unpause the contract, allowing ETH forwarding.
     */
    function unpause() external onlyOwner {
        _unpause();
    }
}
