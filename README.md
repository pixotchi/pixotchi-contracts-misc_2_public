# RewardForwarder

## Overview

`RewardForwarder` is a Solidity smart contract designed to forward incoming ETH to a specified address. The contract includes features for pausing forwarding, claiming ETH, and changing the forwarding address. It also keeps track of the total amount of ETH received and forwarded.

## Features

- **Forwarding ETH**: Automatically forwards received ETH to a specified address.
- **Pause/Unpause**: The owner can pause and unpause the forwarding functionality.
- **Claim ETH**: The owner can claim the ETH held in the contract.
- **Change Forwarding Address**: The owner can change the address to which ETH is forwarded.
- **Event Logging**: Emits events for key actions such as forwarding ETH, claiming ETH, and changing the forwarding address.

## Contract Details

### State Variables

- `address public forwardingAddress`: The address to which the ETH will be forwarded.
- `uint256 public ethForwarded`: Counter to track the amount of ETH forwarded.
- `uint256 public ethReceivedFallback`: Counter to track the amount of ETH received via the fallback function.

### Events

- `event ForwardingAddressChanged(address indexed previousAddress, address indexed newAddress)`: Emitted when the forwarding address is changed.
- `event ETHForwarded(address indexed from, address indexed to, uint256 amount)`: Emitted when ETH is forwarded.
- `event ETHClaimed(address indexed owner, address indexed to, uint256 amount)`: Emitted when ETH is claimed by the owner.
- `event ETHReceived(address indexed from, uint256 amount)`: Emitted when ETH is received by the fallback function.

### Functions

- `constructor(address _forwardingAddress)`: Initializes the contract with the forwarding address.
- `receive() external payable`: Receives ETH and forwards it to the forwarding address if not paused.
- `fallback() external payable`: Fallback function that receives ETH.
- `claimETH(address _to) external onlyOwner`: Allows the owner to claim the ETH in the contract.
- `changeForwardingAddress(address _newForwardingAddress) external onlyOwner`: Allows the owner to change the forwarding address.
- `pause() external onlyOwner`: Allows the owner to pause the contract, preventing ETH forwarding.
- `unpause() external onlyOwner`: Allows the owner to unpause the contract, allowing ETH forwarding.

## Usage

1. **Deploy the Contract**: Deploy the `RewardForwarder` contract with an initial forwarding address.
2. **Forwarding ETH**: Send ETH to the contract address. If the contract is not paused, it will automatically forward the ETH to the specified forwarding address.
3. **Pause/Unpause**: The owner can pause and unpause the contract using the `pause` and `unpause` functions.
4. **Claim ETH**: The owner can claim any ETH held in the contract using the `claimETH` function.
5. **Change Forwarding Address**: The owner can change the forwarding address using the `changeForwardingAddress` function.

## Security Considerations

- Ensure the forwarding address is set correctly to avoid loss of funds.
- Only the owner can pause, unpause, claim ETH, and change the forwarding address.
- The contract uses OpenZeppelin's `ReentrancyGuard`, `Ownable`, and `Pausable` for added security.

## License

This project is licensed under the MIT License.