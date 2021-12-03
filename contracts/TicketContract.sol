//SPDX-License-Identifier:MIT
pragma solidity >=0.8.0;

contract TicketContract{
    mapping(address=>uint256) public balances;// maintains no of RET tickets with each address
    uint cost_of_token=10;//cost of each token can only be set by owner 
    uint total_cnt_of_token;//no of tokens possessed by this contract account.
    address payable owner_address;//address of the contract deployer
    
    //while deploying this contract copy the wallet address and put in the box specified in remix
    constructor(address payable _wallet_addr){
        owner_address=_wallet_addr;
    }
    /*function to set the initial balance of the contract account 
    this function might seem empty but it is intended to empty 
    but this does the work setting the balance of the contract account
    */
    function set_contract_balance() external onlyOwner payable {
    
    }
    //this modifier is to ensure that the amount sent by payee is more than cost_of_token
    modifier valid1(){
        require(msg.value>=cost_of_token);
        _;
    }
    //this modifier is to ensure that the customer has enough balance to buy a token
    modifier valid2(){
        require(address(msg.sender).balance>cost_of_token);
        _;
    }
    //this modifier is for ensuring that only owner of the contract can modify or call a particular functions
    modifier onlyOwner(){
        require(msg.sender==owner_address);
        _;
    }
    //this function is to change the token price but can only be invoked by owner 
    function setTokenPrice(uint val) public onlyOwner{
        cost_of_token=val;
    }
    //this function returns the contract balance
    function getBalance() public view  returns(uint256){
        return address(this).balance;
    }
    
    //to buy a single token
    function buyToken() public payable valid1 valid2{
        balances[msg.sender]+=1;
        owner_address.transfer(msg.value);
    }
    
    //this modifier makes sure that the account has sent enough amount inorder to buy tokens
    modifier valid3(uint no_of_token){
        require(msg.value>=cost_of_token*no_of_token);
        _;
    }
    
    //checks if enough balances and buys tokens
    // if not enough balance we donot buy any tokens and throw error
    function buyTokens(uint no_of_tokens) public payable valid3(no_of_tokens) {
        balances[msg.sender]+=no_of_tokens;//adding tokens to the account
        owner_address.transfer(cost_of_token*no_of_tokens);//sending amount to the owner address from the buyer
    }
    
    //this modifier is for making sure that the customer has enough tokens ie meant to be used 
    modifier check_enough_tokens(uint no_of_tokens){
        require(balances[msg.sender]>=no_of_tokens);
        _;
    }
    // this function is to use a token while entering the hotel 
    function useTokens(uint no_of_tokens) public check_enough_tokens(no_of_tokens){
        balances[msg.sender]-=no_of_tokens;
    }
    
    event Transfer(address sender,address receiver,uint amount);
     
    //this modifier checks if the contract account has enough amount to pay to the seller 
    modifier check_enough_amount(uint no_of_tokens){
        require(address(this).balance>=no_of_tokens*cost_of_token);
        _;
    }
    // this is a function to increment the no of tokens which are owned by the contract
    function increment_tokens() internal{
        total_cnt_of_token+=1;
    }
    
    //this function sells tokens and are bought by the contract account 
    function sellTokens(uint no_of_tokens) external check_enough_tokens(no_of_tokens) check_enough_amount(no_of_tokens){
        balances[msg.sender]-=no_of_tokens;
        balances[address(this)]+=no_of_tokens;
        increment_tokens();
        //
        // emit Transfer(msg.sender, address(this),no_of_tokens);
        
        // e.g. the user is selling 100 tokens, send them 1000 wei
        payable(msg.sender).transfer(cost_of_token * no_of_tokens);
    }
    //this function is used for transfering the tokens from token possessor to his friends
    function transferTokens(address to_addr,uint no_of_tokens) public check_enough_tokens(no_of_tokens){
        balances[msg.sender]-=no_of_tokens;
        balances[to_addr]+=no_of_tokens;
        
    }
    //this function gives the no of tickets of any address
    function get_no_of_tokens(address addr) public view returns(uint) {
        return balances[addr];
    }
    
    
}