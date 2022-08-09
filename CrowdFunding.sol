// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

// Import this file to use console.log

contract CrowdFunding {
    mapping(address=>uint) public contributors;
    address public manager;
    uint public minContribution;
    uint public deadline;
    uint public target;
    uint public raisedAMount;
    uint public noOfContributors;
    uint public x = 10;
    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address => bool) VoterStatus;
    }
    mapping (uint=>Request) public requests;

    uint public numRequests;

    constructor(uint _target, uint _deadline){
        target = _target;
        deadline = block.timestamp + _deadline;
        minContribution = 100;
        manager = msg.sender;
        numRequests = 0;
    }
    function up(uint a) public{
        x = a;
    } 
    function sendEth() public payable{
        require(block.timestamp < deadline, "Deadline has passed");

        require(msg.value >= minContribution, "Minimum contribution is not met");
        if(contributors[msg.sender] == 0){
            noOfContributors++;
        }
        contributors[msg.sender] += msg.value;
        raisedAMount+=msg.value;
    }

    function refund() public{
        require(block.timestamp > deadline && raisedAMount < target, "you can not right now");
        require(contributors[msg.sender] > 0);
        address payable user = payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender] = 0;
    }
    function getContractBalance() public view returns(uint){
        return address(this).balance;
    }
    modifier onlyManger(){
        require(msg.sender == manager,"only manager can access this function");
        _;
    }

    function createRequests(string memory _description, address payable _recipent, uint _value) public onlyManger{
        Request storage newRequest = requests[numRequests];
        numRequests++;
        newRequest.description = _description;
        newRequest.recipient = _recipent;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;
    }
    function voteRequest(uint _reqestNo) public{
        
        require(contributors[msg.sender] > 0, "you must be contributor");
        Request storage thisRequest = requests[_reqestNo];
        require(thisRequest.completed!=true,"this request is already done");
        require(thisRequest.VoterStatus[msg.sender] == false, "you have already voted");
        thisRequest.VoterStatus[msg.sender] = true;
        thisRequest.noOfVoters++;
    }   
    function MakePayment(uint _requestNo) public onlyManger{
        require(raisedAMount >= target, "target money is not reached");
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.completed == false, "payment is already done");
        require(thisRequest.noOfVoters > noOfContributors/2, "not enough votes to clear payment");
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed = true;
    }
}  
