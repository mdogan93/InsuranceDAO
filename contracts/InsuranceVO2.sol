pragma solidity ^0.4.10;

contract InsuranceVO{
//Mapping for hospial address to proposal id.
mapping(address=>uint) proposals;
//Mapping for customer address to reimbursement value.
mapping(address=>uint) reimbursements;
//Mapping for the adress to the hospital instance
mapping(address=>Hospital) hospitals;
//Default value of the deposit that the hospital gives.
uint public deposit;
//Default valuo of the premium price in Ethers.
uint public premium;
//Counter for the proposal ids.
uint public numberOfProposal;

var public votePercentLimit;
var public votePercentAccept;
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
mapping(address=>Customer) customers;

struct Hospital{

uint amountOfService;
uint endPeriod;
byte32[] invoices;
bytes32 proposalLink;
}
struct Proposal{
bytes32 link;
uint voteCount;
uint proposalID;
uint amountOfService;
uint durationOfService;
uint voteEnd;
uint yesVotes;
}
//Proposal array.
Proposal[] public proposals;
//Constructor of contract.
function InsuranceVO(){
deposit=5 ether;
premium=50 ether;
numberOfProposal=0;
votePercentAccept = 0.65;
votePercentLimit = 0.35;
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
@Param: description of proposal.
@Param: duration of insurance service offered by hospital.
*/
function propose(bytes32 description,uint amountService,uint serviceDuration)public{
if(msg.value<deposit){
throw
}
reimbursements[msg.sender] += deposit;
proposals[msg.sender]=numberOfProposal;
proposals.push(Proposal({durationOfService:serviceDuration, yesCount:0,link:description,proposalID:numberOfProposal,voteCount:0,amountOfService:amountService,voteEnd:now + 7 days}));
numberOfProposal++;
//Deposit should be implemented
}

function requestServe() public{
//Buraya da hastane invoke atacak, eğer votingperiod bitmişse proposal için
//Yeni hospital olştur adresle maple vs.
Proposal p = proposals[msg.sender];
if(p.voteEnd< now){
if (p.voteCount > customerCountvotePercentLimit) {
if (p.yesCount > p.voteCountvotePercentAccept) {
startServe(msg.sender , p);
}
}
}
}

function startServe(uint hospitalAdressi Proposal p){
hospitals[msg.sender]=Customer({endPeriod:now+p.durationOfService,amountService: p.amountService,proposalLink=p.link});
}
