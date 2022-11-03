// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PriceConsumerV3 {

    
    /**
     * Network: Goerli
        BTC / USD	0xA39434A63A52E749F02807ae27335515BA4b07F7
        DAI / USD	0x0d79df66BE487753B02D015Fb622DED7f0E9798d
        ETH / USD	0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
        FORTH / USD	0x7A65Cf6C2ACE993f09231EC1Ea7363fb29C13f2F
        JPY / USD	0x295b398c95cEB896aFA18F25d0c6431Fd17b1431 
        LINK / USD	0x48731cF7e84dc94C5f84577882c14Be11a5B7456
        USDC / USD	0xAb5c49580294Aff77670F839ea425f5b78ab3Ae7
        XAU / USD	0x7b219F57a8e9C7303204Af681e9fA69d17ef626f
     */
    
    /**
     * Returns the latest price
     */
    function getLatestPrice( address _tokenAddress) public  view returns (int) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(_tokenAddress);
 
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return price;
    }
}

contract Witlab is ERC721, ERC721URIStorage, Ownable, PriceConsumerV3 {

    using Counters for Counters.Counter;

    Counters.Counter public _tokenIdCounter;

    mapping (address => bool) public isMinted;
    uint mintFeeInEth = 0.001 ether;
    constructor() ERC721("Witlab", "WIT") {}

    function safeMint() internal {
        
        address to = msg.sender;

        require(isMinted[to] == false, "Only one minting allowed per address"  );

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        string memory _to = toString(to);
        _setTokenURI(tokenId,  _to);
    }

    function mintUsingToken(address _tokenAddress) public  {
        int256 priceInEth = getTokenPriceInETH(_tokenAddress);  
        int mintFee = int(mintFeeInEth)/priceInEth; 
    }  

    function getTokenPriceInETH(address _tokenAddress) public view returns(int){
        return PriceConsumerV3.getLatestPrice(_tokenAddress)/PriceConsumerV3.getLatestPrice(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
    }

    function toString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);            
        }
        return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override virtual {
        require(from == address(0), "Err: token transfer is BLOCKED"); 
        super._beforeTokenTransfer(from, to, tokenId);  
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}