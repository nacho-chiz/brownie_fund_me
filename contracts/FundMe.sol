//SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
    //this will stop integer from rolling over when gotten past the max value
    using SafeMathChainlink for uint256;

    //dictionary.py equivalent
    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    address public owner;
    AggregatorV3Interface public priceFeed;

    //Constructor is first function that executes as soon as contract is deployed
    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    function fund() public payable {
        //if we want to set minimun donation price in USD
        //what is ETHUSD rate
        uint256 minimunUSD = 50 * 10**18;
        require(
            getConversionRate(msg.value) >= minimunUSD,
            "you need to submit at least 50$"
        );
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer * 10000000000);
    }

    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
        //0.000002939250000000
    }

    function getEntranceFee() public view returns (uint256) {
        uint256 minUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return (minUSD * precision) / price;
    }

    modifier onlyOwner() {
        //set that only the contract owner can withraw funds
        //require msg.sender == owner
        require(msg.sender == owner);
        _; //this is where the modified function contents will be inserted
    }

    //will run onlyOwner modifier and istead of _ will be the conde inside withdraw
    function withdraw() public payable onlyOwner {
        //address(this) means get ADRESS of THIS contract
        msg.sender.transfer(address(this).balance);
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            addressToAmountFunded[funders[funderIndex]] = 0;
        }
        funders = new address[](0);
    }
}
