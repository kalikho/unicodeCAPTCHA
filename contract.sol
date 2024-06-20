// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/**
 * @title UnicodeCAPTCHA
 */
contract UnicodeCAPTCHA {

    uint128 threshold;
    bytes32 hashAnswer;
    string  image1;
    string  image2;
    string  image3;
    string  image4;
    string  proverResponse;
    string  answer;
    address challanger;

    // Creating a mapping
    mapping (address => bytes32) response;
    mapping (address => bool) submission;

    constructor() {
        challanger = msg.sender;
    }
    
    /**
     * @dev Store value in variable
     * @param _blocknumber value to store
     */
    function setThreshold(uint128 _blocknumber) isAdmin public {
        threshold = _blocknumber;
    }

    /**
     * @dev Store hash of the answer in variable
     * @param _hashAnswer value to store
     */
    function commitAnswer(bytes32 _hashAnswer) isAdmin public {
        hashAnswer = _hashAnswer;
    }
    /**
     * @dev Store unicode strings of the options
     * @param _image1 is the first image
     * @param _image2 is the second image
     * @param _image3 is the third image
     * @param _image4 is the fourth image
     */
    function setQuestion(string memory _image1, string memory _image2, string memory _image3, string memory _image4) isAdmin public payable {
        image1 = _image1;
        image2 = _image2;
        image3 = _image3;
        image4 = _image4;
    }

    function getQuestion() public view returns(string memory){
        return string.concat(image1,image2,image3,image4);
    }  

    /**
     * @dev Store hash of the prover response in variable
     * @param _proverResponse value to store
     */
    function commitResponse(bytes32 _proverResponse) notAttempted public {
        /*allow only if the threshold is not expired*/
        require(block.number <= threshold, "airdrop expired");
        response[msg.sender] = _proverResponse;
        submission[msg.sender] == true;
    }

    function discloseResult(string memory plaintext,string memory option) isAdmin public {
        require(keccak256calculator(plaintext)== hashAnswer,"hash mismatch");
        answer = option;
    }

    function discloseResponse(string memory plaintext,string memory option) public  {
        require(keccak256calculator(plaintext) == response[msg.sender],"incorrect plaintext");
        require(keccak256(abi.encodePacked(option)) == keccak256(abi.encodePacked(answer)),"captcha verification failed");{
         /*Account is human, transfer ether*/
        payable(msg.sender).transfer(0.1 ether);
        }
    }

  function keccak256calculator(string memory input) public pure returns (bytes32 res){
    res = keccak256(abi.encodePacked(input));
    return res;
  }

  modifier isAdmin  { 
        require(challanger == msg.sender); 
        _; 
    } 

 modifier notAttempted {
    require(submission[msg.sender] == false,"challange already attempted");
    _;
 }

}