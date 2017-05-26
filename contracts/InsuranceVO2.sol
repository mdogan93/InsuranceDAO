pragma solidity ^0.4.10;

contract InsuranceVO{
//Mapping for hospial address to proposal id.
mapping(address=>uint) mapProposals;
//Mapping for customer address to reimbursement value.
mapping(address=>uint) mapReimbursements;
//Mapping for the adress to the hospital instance
mapping(address=>Hospital) mapHospitals;
//Default value of the deposit that the hospital gives.
mapping(address=>Customer) mapCustomers;
uint public deposit;
//Default valuo of the premium price in Ethers.
uint public premium;
//Counter for the proposal ids.
uint public numberOfProposal;
uint public customerThreshold;
uint public votePercentLimit;
uint public votePercentAccept;
uint customerCount;
/*
Structure for customer. It holds premium duration, validity, total votes and eligibility
for voting.
*/
struct Customer{
  uint endPremium;
  mapping(uint=>bool) mapHospitalVotes;
  uint weight;
  bool isValid;
}
//Holds all mapCustomers.


struct Hospital{

  uint amountOfService;
  uint endPeriod;
  bytes32[] invoices;
  bytes32[] proposalLink;
}
struct Proposal{
  bytes32[] link;
  uint voteCount;
  uint proposalID;
  uint amountOfService;
  uint durationOfService;
  uint voteEnd;
  uint yesVotes;
}
//Proposal array.
Proposal[] public arrProposals;
//Constructor of contract.
function InsuranceVO(){
  deposit=5 ether;
  premium=50 ether;
  numberOfProposal=0;
  votePercentAccept = 65;
  votePercentLimit = 35;
  customerThreshold=1000;
  customerCount=0;
}
// Pays premium values.
function payPremium() public payable{
if(msg.value<premium){
  throw;
}
//Checks if not customer.
if((mapCustomers[msg.sender]).isValid){
  if((mapCustomers[msg.sender]).endPremium>now){
    throw;
    }else{
//mapCustomers whose premium date is expired. Renews his insurance.
    mapCustomers[msg.sender].endPremium=now+365 days;
    mapReimbursements[msg.sender]=msg.value-premium;
    }
}else{
//Creates a new candidate customer for insurance.
  mapCustomers[msg.sender]=Customer({endPremium:now+365 days,isValid:true,weight:1});
  customerCount++;
  mapReimbursements[msg.sender]=msg.value-premium;
  }

}
//Reimburses a customer. If premium paid more, Customer invokes this method to get his money back.
function reimburseMe() public {
  uint amnt;
  amnt=mapReimbursements[msg.sender];
  if(amnt>0){
    mapReimbursements[msg.sender]=0;
    if(!msg.sender.send(amnt)){
      mapReimbursements[msg.sender]=amnt;
    }
  }
}

//Repays the customer if paid more.
/*
@return: reimbursed amount of customer.
*/
function reimburseBalance() constant public returns(uint retval){
  return (mapReimbursements[msg.sender]);

}
/*
Offer function for hospitals.
@Param: description of proposal.
@Param: duration of insurance service offered by hospital.
*/
function propose(bytes32[] description,uint amountService,uint serviceDuration)public payable{
  if(msg.value<deposit){
    throw;
}
  mapReimbursements[msg.sender] += deposit;
  mapProposals[msg.sender]=numberOfProposal;
  arrProposals.push(Proposal({durationOfService:serviceDuration, yesVotes:0,link:description,proposalID:numberOfProposal,voteCount:0,amountOfService:amountService,voteEnd:now + 7 days}));
  numberOfProposal++;
//Deposit should be implemented
}

function requestServe() public{
//Buraya da hastane invoke atacak, eğer voting period bitmişse proposal için
//Yeni hospital olştur adresle maple vs.
 uint index = mapProposals[msg.sender];
 Proposal p= arrProposals[index];
  if(p.voteEnd< now){
    if (p.voteCount > (customerCount*votePercentLimit)/100) {
      if (p.yesVotes > (p.voteCount*votePercentAccept)/100) {
       // startServe(msg.sender , p);
      }
    }
  }
}


/*function startServe(address hospitalAdress, Proposal p){
  mapHospitals[hospitalAdress]=Customer({endPeriod:(now+p.durationOfService),amountOfService: p.amountService,proposalLink:p.link});
}
*/
}
