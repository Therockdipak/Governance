// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

contract Governance {
    // Define variables
    address public owner;
    mapping(address => bool) public members;
    mapping(address => bool) public gardeners;
    Task[] public tasks;
    uint256 public tasksCount;
    mapping(address => uint256) public contributions;
    uint256 public totalContributions;
    uint256 public rewardPerContribution;

    // Define structs
    struct Task {
        string description;
        uint256 reward;
        address[] assignedTo;
        bool completed;
    }

    // Define events
    event TaskCreated(string description, uint256 reward);
    event TaskAssigned(uint256 taskId, address assignee);
    event TaskCompleted(uint256 taskId);
    event ContributionAdded(address contributor, uint256 amount);
    event RewardPaid(address contributor, uint256 amount);

    // Define modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    modifier onlyMember() {
        require(members[msg.sender], "Only members can call this function.");
        _;
    }

    modifier onlyGardener() {
        require(
            gardeners[msg.sender],
            "Only gardeners can call this function."
        );
        _;
    }

    // Constructor
    constructor() {
        owner = msg.sender;
        members[msg.sender] = true;
        rewardPerContribution = 1;
    }

    // Functions
    function addMember(address _member) public onlyOwner {
        members[_member] = true;
    }

    function removeMember(address _member) public onlyOwner {
        members[_member] = false;
    }

    function addGardener(address _gardener) public onlyMember {
        gardeners[_gardener] = true;
    }

    function removeGardener(address _gardener) public onlyMember {
        gardeners[_gardener] = false;
    }

    function createTask(string memory _description, uint256 _reward)
        public
        onlyGardener
    {
        Task memory task = Task(_description, _reward, new address[](0), false);
        tasks.push(task);
        tasksCount++;
        emit TaskCreated(_description, _reward);
    }

    function assignTask(uint256 _taskId, address[] memory _assignees)
        public
        payable
        onlyGardener
    {
        Task storage task = tasks[_taskId];
        require(task.assignedTo.length == 0, "Task is already assigned.");
        for (uint256 i = 0; i < _assignees.length; i++) {
            require(gardeners[_assignees[i]], "Assignee is not a gardener.");
            task.assignedTo.push(_assignees[i]);
        }
        emit TaskAssigned(_taskId, _assignees[0]);
    }

    function completeTask(uint256 _taskId) public onlyGardener {
        Task storage task = tasks[_taskId];
        require(!task.completed, "Task is already completed.");
        for (uint256 i = 0; i < task.assignedTo.length; i++) {
            address assignee = task.assignedTo[i];
            contributions[assignee] += task.reward / task.assignedTo.length;
        }
        totalContributions += task.reward;
        task.completed = true;
        emit TaskCompleted(_taskId);
    }

    function addContribution() public payable {
        contributions[msg.sender] += msg.value;
        totalContributions += msg.value;
        emit ContributionAdded(msg.sender, msg.value);
    }

    function withdrawReward() public {
        uint256 reward = contributions[msg.sender] * rewardPerContribution;
        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(reward);
        emit RewardPaid(msg.sender, reward);
    }
}
