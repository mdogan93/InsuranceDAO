pragma solidity ^0.4.8;

contract InsuranceVO{
    //Mapping for hospial address to proposal id.
    mapping(address=>uint) proposal;
    //Mapping for customer address to reimbursement value.
    mapping(address=>uint) reimbursements;
 
    uint public deposit;
    uint public premium;
    uint public numberOfProposal;
    uint public votePercentLimit;
    uint public votePercentAccept;
    uint customerCount;
    /*
    Structure for customer. It holds premium duration, validity, total votes and eligibility 
    for voting.
    */
   struct Customer{
    uint endPremium;
    mapping(uint=>bool) hospitalVotes;
    uint weight;
    bool isValid;
   }
   //Holds all customers.
   
   struct Hospital{
    address hospitalAddr;

   }
   mapping(address=>Customer) customers;
   mapping(address=>Hospital) hospitals;
   struct Proposal{
    bytes32 link;
    uint voteCount;
    uint proposalID;
    uint amountOfService;
    uint durationOfService;
    uint voteEnd;
    uint evetler;
   }
   //Proposal array.
  Proposal[] public proposals;
//Constructor of contract.
  function InsuranceVO(){
    deposit=5 ether;
    premium=50 ether;
    numberOfProposal=0;
    votePercentAccept =65;
    votePercentLimit = 35;
    customerCount=0;
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
      customerCount++;
      reimbursements[msg.sender]=msg.value-premium;
    }


  }
//Reimburses a customer. If premium paid more, Customer invokes this method to get his money back.
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

  //Repays the customer if paid more.
  /*
  @return: reimbursed amount of customer.
  */
  function reimburseBalance() constant public returns(uint retval){
    return (reimbursements[msg.sender]);

  }
  /*
    Offer function for hospitals. 
    @param: description of proposal.
    @param: duration of insurance service offered by hospital.
  */
  function propose(bytes32 description,uint amountService,uint serviceDuration)public{
    proposal[msg.sender]=numberOfProposal;
    proposals.push(Proposal({durationOfService:serviceDuration, evetler:0,link:description,proposalID:numberOfProposal,voteCount:0,amountOfService:amountService,voteEnd:now + 7 days}));
    numberOfProposal++;
    //Deposit should be implemented
  }

  function startServe() public{
    //Buraya da hastane invoke atacak, eğer votingperiod bitmisse proposal icin
    //Yeni hospital olstur adresle maple vs.
  }










  
}