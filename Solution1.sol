// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Bank{
    address owner;
    uint256 bankBalance = 0;

    uint256 idCounter = 0;

    struct User {
        uint256 id;
        string name;
        string profession;
        string dateOfBirth;
    }

    mapping (address => User) users;
    mapping (address => uint256) balances;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Access denied!");
        _;
    }


    modifier onlyRegistered(address _userAddress) {
        require(users[_userAddress].id != 0, "Account doesn't exist!");
        _;
    }

    modifier validAmount(uint256 _amount){
        require(balances[msg.sender] >= _amount, "Not sufficient funds!");
        _;
    }

    function register(string memory _name,
                      string memory _profession,
                      string memory _dateOfBirth) external{
        require(users[msg.sender].id == 0, "Account aleardy exist!");
        idCounter += 1;
        users[msg.sender] = User({id: idCounter,
                                  name: _name,
                                  profession: _profession,
                                  dateOfBirth: _dateOfBirth
                                  });
        balances[msg.sender] = 0;                          
    }

    receive() onlyRegistered(msg.sender) external payable{
        balances[msg.sender] += msg.value;

    } 
  function withdraw(uint256 _amount) onlyRegistered(msg.sender)
                                       validAmount(_amount) external payable{
        balances[msg.sender] -= _amount;
        bankBalance -= _amount;
        payable(msg.sender).transfer(_amount);
    }
    

    function transfer(address _to, uint256 _amount) onlyRegistered(msg.sender)
                                                    onlyRegistered(_to)
                                                    validAmount(_amount) external{
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
    }

    function getUserInfo() onlyRegistered(msg.sender) external view returns (uint256,
                                                                             string memory,
                                                                             string memory,
                                                                             string memory,
                                                                             uint256
                                                                             ){
        return (users[msg.sender].id,
                users[msg.sender].name,
                users[msg.sender].profession,
                users[msg.sender].dateOfBirth,
                balances[msg.sender]);
    }

    function getBankInfo() onlyOwner external view returns (uint256, uint256){
        return(idCounter,
               bankBalance);
    }
    function getBalance() external view returns (uint256){
        return(balances[msg.sender]);

    }




}