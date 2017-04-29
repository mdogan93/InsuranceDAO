pragma solidity ^0.4.10;

contract InsuranceVO{
    
    mapping(address=>uint) hospitals;
    mapping(address=>uint) reimbursements;
    
   

    uint public deposit;
    uint public premium;
   struct Customer{
    uint endPremium;
    mapping(uint=>bool) hospitalVotes;
    uint weight;
    bool isValid;
   }
   
   mapping(address=>Customer) customers;
   struct Hospital{
    address hospitalAddr;

   }
   struct Proposal{
    bytes32 link;
    uint voteCount;
    uint proposalID;
    uint amountOfService;
   }
   
  Proposal[] public proposals;

  function InsuranceVO(){
    deposit=5 ether;
    premium=50 ether;

  }
   // Pays premium values.
   function payPremium() public payable{
    if(msg.value<premium){
      throw;
    }
    //Checks if not customer.
    if((customers[msg.sender]).isValid){
      if((customers[msg.sender]).endPremium>now){
        throw;
      }else{
        //Customers whose premium date is expired. Renews his insurance.
        customers[msg.sender].endPremium=now+365 days;
        reimbursements[msg.sender]=msg.value-premium;
      }
    }else{
      //Creates a new candidate customer for insurance.
      customers[msg.sender]=Customer({endPremium:now+365 days,isValid:true,weight:1});
      reimbursements[msg.sender]=msg.value-premium;
    }


  }
//Reimburses balances. If premium paid more, Customer invokes this method to get his money back.
  function reimburseMe() public {
    uint amnt;
    amnt=reimbursements[msg.sender];
    if(amnt>0){
      reimbursements[msg.sender]=0;
      if(!msg.sender.send(amnt)){
        reimbursements[msg.sender]=amnt;
      }
    }
  }
  function reimburseBalance() constant public returns(uint retval){
    return (reimbursements[msg.sender]);


  }









  
}