// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "chainlink-brownie-contracts/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";


abstract contract CodeConstants {
        /* VRF mock Values */ 
        uint96 public constant MOCK_BASE_FEE = 0.25 ether;
        uint96 public constant MOCK_GAS_PRICE_LINK = 1e9;
        // LINK / ETH price
        int256 public constant MOCK_WEI_PER_UINT_LINK = 4e15;

        /* */

        uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
        uint256 public constant LOCAL_CHAIN_ID = 31337;
}

contract HelperConfig is CodeConstants, Script {

    error HelperConfig__InvalidChainId();

    struct NetWorking {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint32  callbackGasLimit;
        uint256 subscriptionId;
    }

    NetWorking public localNetworkConfig;
    mapping(uint256 => NetWorking) public networkConfigs;

    constructor () {
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getSepoliaEthConfig();
    }

    function getConfigByChainId(uint256 chainId) public returns (NetWorking memory) {
        if (networkConfigs[chainId].vrfCoordinator != address(0)){
            return networkConfigs[chainId];
        }else if (chainId == LOCAL_CHAIN_ID){
            // getOrCreateAnvilConfig()
        }else{
            revert HelperConfig__InvalidChainId();
        }

    }

    function getConfig() public returns (NetWorking memory) {
        return getConfigByChainId(block.chainid);
    } 

    function getSepoliaEthConfig() public pure returns (NetWorking memory) {
        return NetWorking ({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
            gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            callbackGasLimit: 500000,
            subscriptionId: 0
        });
    }

    function getOrCreateAnvilConfig() public returns (NetWorking memory) {
        // check to see if we set an active network config
        if (localNetworkConfig.vrfCoordinator != address(0)){
            return localNetworkConfig;
        }

        // Deploy mock and such
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinatorMock = new VRFCoordinatorV2_5Mock(MOCK_BASE_FEE, MOCK_GAS_PRICE_LINK, MOCK_WEI_PER_UINT_LINK);
        vm.stopBroadcast();

        localNetworkConfig = NetWorking ({
             entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: address(vrfCoordinatorMock),
            // dosen't mmatter
            gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            callbackGasLimit: 500000,
            subscriptionId: 0
        });
        
        return localNetworkConfig;
    }
}