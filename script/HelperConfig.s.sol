//SPDX-License-Identifier: MIT

//Deploy mocks when we are on local chains (anvil)
//Keeps the track of contract address on different chains

pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggeregator.sol";

contract HelperConfig is Script {
    //If we are on local anvil, we deploy mocks
    //Otherwise, grab the existing address from the live network

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRIZE = 2000e8;

    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address priceFeed; //ETH/USD price feed address
    }

    constructor() {
        if(block.chainid == 11155111){
            activeNetworkConfig = getSepoliaEthConfig();
        }
        else if(block.chainid == 1){
            activeNetworkConfig = getMainnetEthConfig();
        }
        else {
            activeNetworkConfig = getOrCreateAnivlEthConfig();
        }
    }

    /* In every network we need PriceFeedAddress, 
    but what if we need more, like VRF Address, gas price, version
    for this we are going to create our own Types(STRUCT)
    */
    function getSepoliaEthConfig() public pure returns(NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns(NetworkConfig memory) {
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethConfig;
    }


    function getOrCreateAnivlEthConfig() public  returns(NetworkConfig memory) {
        //PriceFeedAddress

        if(activeNetworkConfig.priceFeed != address(0)){
            return activeNetworkConfig;
        }

        //1. Deploy Mocks
        //2. Return the mocks address

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRIZE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed : address(mockPriceFeed)
        });
        return anvilConfig;
    }
}