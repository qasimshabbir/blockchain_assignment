pragma solidity 0.4.24;

import "./AxiomDevToken.sol";
import "./Crowdsale.sol";

/**
 * Our crowdsale contract inherits CappedCrowdsale and RefundableCrowdsale 
 * (supplied by zeppelin-solidity) and therefore has a "goal and a hard cap". 
 * If the contract isn't able to raise a certain minimum amount of ETH during 
 * the crowdsale, the ETH amounts will be refunded to the investors. 
 * Similarly, the contract will not be able to raise more than a specific amount 
 * of ETH due to a hard cap.
 *
  */


contract AxiomDevCrowdsale is CappedCrowdsale, RefundableCrowdsale {

    // ICO Stage
    // ============
    enum CrowdsaleStage { PreICO, ICO }
    CrowdsaleStage public stage = CrowdsaleStage.PreICO; 
    // By default it's Pre Sale
    // =============

    /**
     * Token Distribution
     * ==================
     * There will be total 1000 AxiomDev Tokens generated. 
     * Out of 1000 600 will be sold in the ICO. Once the ICO is over 400 tokens will be minted
     * divided among three wallets such as Team Fund, ECO System Fund and Bounty Fund
     *  
     * Tokens are in Wei 10^18
     */
    uint256 public maxTokens = 1000000000000000000000; //1000 X 10^18 tokens
    uint256 public tokensForEcosystem = 200000000000000000000; //200 X 10^18 tokens
    uint256 public tokensForTeam = 100000000000000000000; // 100  X 10^18 Tokens
    uint256 public tokensForBounty = 100000000000000000000; // 100  X 10^18 tokens
    // 600 ADTs will be sold in ICO
    uint256 public totalTokensForSale = 600000000000000000000; //600  X 10^18 tokens
    // 200 out of 60 ADTs will be sold during PreICO
    uint256 public totalTokensForSaleDuringPreICO = 200000000000000000000; //200  X 10^18 tokens
    // ==============================

    // Amount raised in PreICO
    // ==================
    uint256 public totalWeiRaisedDuringPreICO;
    // ===================


    // Events
    event EthTransferred(string text);
    event EthRefunded(string text);


    // Constructor
    // ============
    constructor(
        uint256 _startTime, 
        uint256 _endTime, 
        uint256 _rate, 
        address _wallet, 
        uint256 _goal, 
        uint256 _cap
    ) 
        public
        CappedCrowdsale(_cap) 
        FinalizableCrowdsale() 
        RefundableCrowdsale(_goal) 
        Crowdsale(_startTime, _endTime, _rate, _wallet) 
    {
        //goal must be less than or equals to hard capped size
        require(_goal <= _cap,"Axiom Dev ICO is over its reached its achived its target");
    }
    // =============
    // Token Deployment
    // =================
    // Deploys the ERC20 token. Automatically called when crowdsale contract is deployed
    function createTokenContract() internal returns (MintableToken) {
        return new AxiomDevToken(); 
    }
    /* ======================
     * ICO Stage Management
     * =======================
     * The crowdsale has two stages: PreICO and ICO. 
     * You can change the stage and update rate variable to offer extra
     * discounts during presale. As per the contract 1 ETH can buy 50 tokens 
     * in PreICO and just 20 tokens in public sale. So, the early investors get 
     * extra discounts. Note: Max 200 tokens will be sold in PreICO.
     * 
     * Change Crowdsale Stage. Available Options: PreICO, ICO
    */
    function setCrowdsaleStage(uint value) public onlyOwner {

        CrowdsaleStage _stage;

        if (uint(CrowdsaleStage.PreICO) == value) {
            _stage = CrowdsaleStage.PreICO;
        } else if (uint(CrowdsaleStage.ICO) == value) {
            _stage = CrowdsaleStage.ICO;
        }

        stage = _stage;
        if (stage == CrowdsaleStage.PreICO) {
            setCurrentRate(50); //On PreICO 1 ETH = 50 ADTs
        
        } else if (stage == CrowdsaleStage.ICO) {
            setCurrentRate(20); //After Pre Sale 1 ETH = 20 ADTs
        }
    }

    // Change the current rate
    function setCurrentRate(uint256 _rate) private {
        rate = _rate;
    }

    // ========================= 
    // ICO Stage Management Over 
    // =========================

    
    // Token Purchase
    // =========================
    /**
     * When PreICO is live, the incoming ETH amounts are immediately transferred
     * to the beneficiary wallet (supplied while deploying the contract). 
     * However, in the public sale the raised ETH amounts are sent to a refund vault.
     * If the crowdsale reaches its goal, the funds are transferred to the beneficiary 
     * wallet. Otherwise, investors are allowed to claim refunds 
     * (check zeppelin-solidity/contracts/crowdsale/RefundVault.sol).
     */

    function () external payable {
        uint256 tokensThatWillBeMintedAfterPurchase = msg.value.mul(rate);
        if ((stage == CrowdsaleStage.PreICO) && (token.totalSupply() + tokensThatWillBeMintedAfterPurchase > totalTokensForSaleDuringPreICO)){
            msg.sender.transfer(msg.value); // Refund them
            emit EthRefunded("PreICO Limit Hit");
            return;
        }

        buyTokens(msg.sender);

        if (stage == CrowdsaleStage.PreICO) {
            totalWeiRaisedDuringPreICO = totalWeiRaisedDuringPreICO.add(msg.value);
        }
    }

    function forwardFunds() internal {
        if (stage == CrowdsaleStage.PreICO) {
            wallet.transfer(msg.value);
            emit EthTransferred("forwarding funds to wallet");
        } else if (stage == CrowdsaleStage.ICO) {
            emit EthTransferred("forwarding funds to refundable vault");
            super.forwardFunds();
        }
    }
    // ===========================

    
    
    // Finish: Mint Extra Tokens as needed before finalizing the Crowdsale.
    // ====================================================================
    /**
     * You have to call finish() to close the crowdsale. 
     * This is where remaining tokens are minted and distributed 
     * among various reserved funds. 
     * Note: Any unsold tokens are added to the ecocystem fund.
     */
    function finish(
        address _teamFund, 
        address _ecosystemFund, 
        address _bountyFund
    ) 
        public 
        onlyOwner 
    {

        require(!isFinalized,"Invalid call of finish. ICO already finished."); //not previously finished or called
        uint256 alreadyMinted = token.totalSupply(); 
        require(alreadyMinted < maxTokens); //Not reached the limit

        uint256 unsoldTokens = totalTokensForSale - alreadyMinted; //finding usold tokens
        if (unsoldTokens > 0) {
            //Add extra token to ECOSystem wallet
            tokensForEcosystem = tokensForEcosystem + unsoldTokens;
        }

        token.mint(_teamFund,tokensForTeam); //Mint remaining tokens for team
        token.mint(_ecosystemFund,tokensForEcosystem); //Mint/Transfer ECOSystem tokems  
        token.mint(_bountyFund,tokensForBounty); //Mint/Transfer Bounty Tokens

        finalize(); //Calling for closing of ICO
    }
    // ===============================

    // REMOVE THIS FUNCTION ONCE YOU ARE READY FOR PRODUCTION
    // USEFUL FOR TESTING `finish()` FUNCTION
    function hasEnded() public view returns (bool) {
        return true;
    }
}