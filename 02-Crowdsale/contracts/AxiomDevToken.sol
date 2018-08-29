/* ----------------------------------------------------------------------------
// 'DevToken' CROWDSALE token contract
//
// Deployed to : 0xFb6058AC92F3f6216625D35cE9045A8584dc02da
// Symbol      : DVT
// Name        : Axiom Dev Token
// Total supply: Gazillion
// Decimals    : 18
//
// Enjoy.
//
// (c) by Qasim - Axiom 2018.
// ----------------------------------------------------------------------------*/

pragma solidity 0.4.24;


import "./Tokens.sol";

/*
    Defination of DevToken
    ----------------------
    Extending MintableToken provided by zeppelin-solidity package. 
    MintableTokenitself inherits ERC20 token contract 
    (find it inside zeppelin-solidity/contracts/token/ directory). 
    So, the end result is that our new token DevToken is an ERC20 token.

    MintableToken means that the total supply of the token starts with 0
    and increases as people purchase the tokens in the crowdsale.
    If you decide to create 100 tokens and sell 60 of them in crowdsale,
    the supply will increase up to 60 (as people pay ETH and buy the
    tokens). Once the crowdsale is over, 40 more tokens will 
    be minted making the total supply 100.
*/
contract AxiomDevToken is MintableToken {
    string public name = "Axiom Dev Token";
    string public symbol = "ADT";
    uint8 public decimals = 18;
}