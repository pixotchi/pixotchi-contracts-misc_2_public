// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title A contract for claiming tokens with ECDSA-signed vouchers and tracking claimed tokens and nonces for wallets
/// @dev This contract utilizes EIP712 for typed structured data hashing and signing
contract Claim is EIP712("PixelClaimer", "1"), Ownable(msg.sender), ReentrancyGuard {
//what are you trying to find?
    address public signer;
    address public token;
    address public vault;

    /// @notice Tracks the nonces for each address to prevent replay attacks and the amount of tokens each wallet has claimed
    mapping(address => WalletData) public wallets;

    /// @notice Indicates whether the claim functionality is currently enabled
    bool public enabled = true;

    /// @notice Emitted when tokens are successfully claimed
    event Claimed(
        address indexed wallet,
        uint256 indexed amount,
        uint256 indexed claimType,
        uint256 nonce
    );

    /// @notice Error for when an invalid signer is detected
    error InvalidSigner();

    /// @notice Represents a claim voucher that a wallet can redeem for tokens
    struct Voucher {
        address wallet;
        uint256 amount;
        uint256 claimType;
        uint256 nonce;
    }

    /// @notice Structure to store the nonce and the total amount of tokens each wallet has claimed
    struct WalletData {
        uint256 nonce;
        mapping(uint256 => uint256) claimed;
    }

    constructor(address _token, address _signer, address _vault) {
        token = _token;
        signer = _signer;
        vault = _vault;
    }

    function setSigner(address _signer) public onlyOwner {
        signer = _signer;
    }

    function setVault(address _vault) external onlyOwner {
        vault = _vault;
    }

    function setEnabled(bool _enabled) external onlyOwner {
        enabled = _enabled;
    }

    function setToken(address _token) external onlyOwner {
        token = _token;
    }

    /// @notice Gets the nonce for a specific wallet
    /// @param wallet The address of the wallet
    /// @return The nonce of the specified wallet
    function getNonce(address wallet) public view returns (uint256) {
        return wallets[wallet].nonce;
    }

    /// @notice Gets the claimed token amount for a specific token ID in a wallet
    /// @param wallet The address of the wallet
    /// @param tokenId The token ID
    /// @return The amount of tokens claimed for the specified token ID in the specified wallet
    function getClaimed(address wallet, uint256 tokenId) public view returns (uint256) {
        return wallets[wallet].claimed[tokenId];
    }

    function redeem(Voucher calldata _voucher, bytes memory _signature) external {
        require(enabled, "Claim is disabled");
        require(signer != address(0), "Signer not set");
        require(wallets[_voucher.wallet].nonce == _voucher.nonce, "Invalid nonce");
        require(_voucher.wallet == msg.sender, "Invalid wallet");

        address _signer = ECDSA.recover(_hashTypedDataV4(keccak256(abi.encode(
            keccak256("Voucher(address wallet,uint256 amount,uint256 claimType,uint256 nonce)"),
            _voucher.wallet,
            _voucher.amount,
            _voucher.claimType,
            _voucher.nonce
        ))), _signature);

        if (_signer != signer) revert InvalidSigner();

        emit Claimed(_voucher.wallet, _voucher.amount, _voucher.claimType, _voucher.nonce);

        wallets[_voucher.wallet].nonce++;
        wallets[_voucher.wallet].claimed[_voucher.claimType] += _voucher.amount;
        IERC20(token).transferFrom(vault, _voucher.wallet, _voucher.amount);
    }
}
//still didn't find what you are looking for?
