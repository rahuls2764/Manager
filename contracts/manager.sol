// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MyToken.sol";
import "./MyNFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Manager is Ownable, ReentrancyGuard {
    MyToken public token;
    MyNFT public quizNFT;
    
    // Quiz structure with IPFS hash
    struct Quiz {
        string quizTitle;
        string quizIPFSHash;  // IPFS hash to the quiz content
        uint256 minScore;
        uint256 tokenReward;
        bool active;
    }
    
    // Student structure
    struct Student {
        address walletAddress;
        bool registered;
        uint256 totalScore;
        uint256 quizzesTaken;
    }
    
    // Map of student addresses to their data
    mapping(address => Student) public students;
    // Map of quiz IDs to Quiz structs
    mapping(uint256 => Quiz) public quizzes;
    // Map to track if a student has completed a specific quiz
    mapping(address => mapping(uint256 => bool)) public quizCompleted;
    // Map to store the IPFS hashes of quiz results/certificates
    mapping(address => mapping(uint256 => string)) public resultIPFSHashes;
    
    uint256 public quizCount;
    
    // Events
    event StudentRegistered(address indexed studentAddress);
    event QuizCompleted(address indexed student, uint256 indexed quizId, uint256 score, string resultIPFSHash);
    event NFTAwarded(address indexed student, uint256 tokenId);
    event TokensRewarded(address indexed student, uint256 amount);
    event QuizCreated(uint256 indexed quizId, string quizTitle, string quizIPFSHash);
    
    constructor(address _tokenAddress, address _nftAddress) {
        token = MyToken(_tokenAddress);
        quizNFT = MyNFT(_nftAddress);
        quizCount = 0;
    }
    
    // Register a student
    function registerStudent() external {
        require(!students[msg.sender].registered, "Student already registered");
        
        students[msg.sender] = Student({
            walletAddress: msg.sender,
            registered: true,
            totalScore: 0,
            quizzesTaken: 0
        });
        
        emit StudentRegistered(msg.sender);
    }
    
    // Admin function to create a new quiz with IPFS hash
    function createQuiz(
        string memory _title,
        string memory _quizIPFSHash,
        uint256 _minScore,
        uint256 _tokenReward
    ) external onlyOwner {
        quizzes[quizCount] = Quiz({
            quizTitle: _title,
            quizIPFSHash: _quizIPFSHash,
            minScore: _minScore,
            tokenReward: _tokenReward,
            active: true
        });
        
        emit QuizCreated(quizCount, _title, _quizIPFSHash);
        quizCount++;
    }
    
    // Submit quiz results - called when a student completes a quiz
    function submitQuizResult(
        uint256 _quizId, 
        uint256 _score, 
        string memory _resultIPFSHash
    ) external nonReentrant {
        require(students[msg.sender].registered, "Student not registered");
        require(quizzes[_quizId].active, "Quiz not active");
        require(!quizCompleted[msg.sender][_quizId], "Quiz already completed");
        
        // Mark quiz as completed
        quizCompleted[msg.sender][_quizId] = true;
        
        // Store the result IPFS hash
        resultIPFSHashes[msg.sender][_quizId] = _resultIPFSHash;
        
        // Update student stats
        students[msg.sender].totalScore += _score;
        students[msg.sender].quizzesTaken += 1;
        
        emit QuizCompleted(msg.sender, _quizId, _score, _resultIPFSHash);
        
        // Award token rewards if the score meets the minimum requirement
        if (_score >= quizzes[_quizId].minScore) {
            // Generate token URI that points to the IPFS metadata
            string memory tokenURI = string(abi.encodePacked("ipfs://", _resultIPFSHash));
            
            // Mint NFT certificate - Note that only the owner can mint NFTs
            uint256 tokenId = quizNFT.mintNFT(msg.sender, tokenURI);
            emit NFTAwarded(msg.sender, tokenId);
            
            // Reward tokens
            uint256 rewardAmount = quizzes[_quizId].tokenReward;
            if (rewardAmount > 0) {
                require(token.transfer(msg.sender, rewardAmount), "Token transfer failed");
                emit TokensRewarded(msg.sender, rewardAmount);
            }
        }
    }
    
    // Get quiz details by ID
    function getQuizDetails(uint256 _quizId) external view returns (
        string memory quizTitle,
        string memory quizIPFSHash,
        uint256 minScore,
        uint256 tokenReward,
        bool active
    ) {
        Quiz storage quiz = quizzes[_quizId];
        return (
            quiz.quizTitle,
            quiz.quizIPFSHash,
            quiz.minScore,
            quiz.tokenReward,
            quiz.active
        );
    }
    
    // Get student result for a specific quiz
    function getStudentQuizResult(address _student, uint256 _quizId) external view returns (
        bool completed,
        string memory resultIPFSHash
    ) {
        return (
            quizCompleted[_student][_quizId],
            resultIPFSHashes[_student][_quizId]
        );
    }
    
    // Get student stats
    function getStudentStats(address _student) external view returns (uint256 totalScore, uint256 quizzesTaken) {
        return (students[_student].totalScore, students[_student].quizzesTaken);
    }
    
    // Admin function to deactivate a quiz
    function toggleQuizActive(uint256 _quizId) external onlyOwner {
        require(_quizId < quizCount, "Quiz does not exist");
        quizzes[_quizId].active = !quizzes[_quizId].active;
    }
    
    // Admin function to withdraw tokens if needed
    function withdrawTokens(uint256 _amount) external onlyOwner {
        require(token.transfer(owner(), _amount), "Transfer failed");
    }
}