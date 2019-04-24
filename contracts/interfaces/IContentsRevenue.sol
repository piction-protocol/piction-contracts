pragma solidity ^0.4.24;

interface IContentsRevenue {
    function calculateDistributionPxl(uint256 distributionRate, string contentHash, uint256 amount) external view returns (address[] memory addresses, uint256[] memory amounts);
}