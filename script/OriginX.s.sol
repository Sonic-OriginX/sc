// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../lib/forge-std/src/Script.sol";
import "../src/OriginX.sol";
import "../src/MockSonic.sol";
import "../src/MockOriginSonic.sol";
import "../src/MockLBTC.sol";
import "../src/MockUSDCe.sol";
import "../src/MockWrappedSonic.sol";
import "../src/MockStakingEulerV2.sol"; // wS
import "../src/MockStakingLombard.sol"; // LBTC
import "../src/MockStakingOrigin.sol"; // OS
import "../src/MockStakingSiloV2.sol"; // S
import "../src/MockStakingSpectraV2.sol"; // USDCe

contract DeployOriginX is Script {
    function run() external {
        address routerAddress;

        if (block.chainid == 57054) {
            // Sonic Mainnet
            routerAddress = 0x2626664c2603336E57B271c5C0b26F421741e481;
        } else if (block.chainid == 57054) {
            // Sonic Blaze
            routerAddress = 0x94cC0AaC535CCDB3C01d6787D6413C739ae12bc4;
        } else {
            revert(
                "Unsupported network - Please use Sonic Mainnet or Sonic Blaze"
            );
        }

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy Mock Sonic
        MockSonic mockSonic = new MockSonic();
        console2.log("Mock Sonic deployed to:", address(mockSonic));

        // Deploy Mock Wrapped Sonic
        MockWrappedSonic mockwS = new MockWrappedSonic();
        console2.log("Mock Wrapped Sonic deployed to:", address(mockwS));

        // Deploy Mock Origin Sonic
        MockOriginSonic mockOS = new MockOriginSonic();
        console2.log("Mock Origin Sonic deployed to:", address(mockOS));

        // Deploy Mock Lombard Staked BTC
        MockLBTC mockLBTC = new MockLBTC();
        console2.log("Mock LBTC deployed to:", address(mockLBTC));

        // Deploy Mock USDCe
        MockUSDCe mockUSDCe = new MockUSDCe();
        console2.log("Mock USDCe deployed to:", address(mockUSDCe));

        // Deploy OriginX
        OriginX originX = new OriginX(routerAddress);
        console2.log("OriginX deployed to:", address(originX));

        uint256 initialSupply = 1_000_000_000_000_000_000_000_000 * 10 ** 6;

        // Mint & Transfer Sonic
        mockSonic.mint(address(originX), initialSupply);

        // Mint & Transfer Wrapped Sonic
        mockwS.mint(address(originX), initialSupply);

        // Mint & Transfer Origin Sonic
        mockOS.mint(address(originX), initialSupply);

        // Mint & Transfer WETH
        mockLBTC.mint(address(originX), initialSupply);

        // Mint & Transfer DAI
        mockUSDCe.mint(address(originX), initialSupply);

        // Deploy MockStakingEulerV2 with MockUNI as staking token
        uint8 fixedAPY = 10; // 10% APY
        uint256 durationInDays = 3; // 3 day staking period
        uint256 maxAmountStaked = 100_000 * 10 ** 6; // 100,000 MockUNI max stake

        MockStakingEulerV2 mockStakingEulerV2 = new MockStakingEulerV2(
            address(mockwS),
            fixedAPY,
            durationInDays,
            maxAmountStaked
        );
        console2.log(
            "MockStakingEulerV2 deployed to:",
            address(mockStakingEulerV2)
        );

        // Deploy MockStakingLombard with MockUSDT as staking token
        fixedAPY = 15; // 15% APY
        durationInDays = 7; // 7 day staking period
        maxAmountStaked = 100_000 * 10 ** 6; // 50,000 MockUSDT max stake

        MockStakingLombard mockStakingLombard = new MockStakingLombard(
            address(mockLBTC),
            fixedAPY,
            durationInDays,
            maxAmountStaked
        );
        console2.log(
            "MockStakingLombard deployed to:",
            address(mockStakingLombard)
        );

        // Deploy MockStakingOrigin with MockDAI as staking token
        fixedAPY = 20; // 20% APY
        durationInDays = 14; // 14 day staking period
        maxAmountStaked = 100_000 * 10 ** 6; // 25,000 MockDAI max stake

        MockStakingOrigin mockStakingOrigin = new MockStakingOrigin(
            address(mockOS),
            fixedAPY,
            durationInDays,
            maxAmountStaked
        );
        console2.log(
            "MockStakingOrigin deployed to:",
            address(mockStakingOrigin)
        );

        // Deploy MockStakingSiloV2 with MockWETH as staking token
        fixedAPY = 25; // 25% APY
        durationInDays = 30; // 30 day staking period
        maxAmountStaked = 100_000 * 10 ** 6; // 100,000 MockWETH max stake

        MockStakingSiloV2 mockStakingSiloV2 = new MockStakingSiloV2(
            address(mockSonic),
            fixedAPY,
            durationInDays,
            maxAmountStaked
        );
        console2.log(
            "MockStakingSiloV2 deployed to:",
            address(mockStakingSiloV2)
        );

        // Deploy MockStakingSpectraV2 with MockUSDC as staking token
        fixedAPY = 30; // 30% APY
        durationInDays = 60; // 60 day staking period
        maxAmountStaked = 100_000 * 10 ** 6; // 100,000 MockUSDC max stake

        MockStakingSpectraV2 mockStakingSpectraV2 = new MockStakingSpectraV2(
            address(mockUSDCe),
            fixedAPY,
            durationInDays,
            maxAmountStaked
        );
        console2.log("MockStakingSpectraV2 deployed to:", address(mockStakingSpectraV2));

        vm.stopBroadcast();
    }
}
