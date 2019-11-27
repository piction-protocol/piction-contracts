pragma solidity ^0.4.24;

import "../utils/ValidValue.sol";
import "../utils/ExtendsOwnable.sol";
import "../interfaces/IValidation.sol";
import "../interfaces/IPictionNetwork.sol";


contract ProjectManager is ExtendsOwnable, ValidValue {

    struct project {
        bool isRegistered;
        address wallet;
        string uri;
    }

    mapping (string => project) projects;
    mapping (string => bool) isDuplicateString;

    IPictionNetwork private pictionNetwork;

    string private constant ACCOUNTMANAGER = "AccountManager";

    constructor(address pictionNetworkAddress) public validAddress(pictionNetworkAddress) {
        pictionNetwork = IPictionNetwork(pictionNetworkAddress);
    }

    function deploy(string hash, string uri) external validString(hash) validString(uri) {
        require(IValidation(pictionNetwork.getAddress(ACCOUNTMANAGER)).accountValidation(msg.sender), "ProjectManager deploy 0");
        require(!projects[hash].isRegistered, "ProjectManager deploy 1");
        require(!isDuplicateString[uri], "ProjectManager deploy 2");

        projects[hash].isRegistered = true;
        projects[hash].wallet = msg.sender;
        projects[hash].uri = uri;

        isDuplicateString[uri] = true;

        emit Deploy(msg.sender, hash, uri);
    }

    function migration(address user, string hash, string uri) external onlyOwner validString(hash) validString(uri) {
        require(IValidation(pictionNetwork.getAddress(ACCOUNTMANAGER)).accountValidation(user), "ProjectManager migration 0");
        require(!projects[hash].isRegistered, "ProjectManager migration 1");
        require(!isDuplicateString[uri], "ProjectManager migration 2");

        projects[hash].isRegistered = true;
        projects[hash].wallet = user;
        projects[hash].uri = uri;

        isDuplicateString[uri] = true;

        emit Migration(msg.sender, user, hash, uri);
    }

    function stringValidation(string str) external view returns(bool) {
        return isDuplicateString[str];
    }

    function getProjectOwner(string hash) external view returns(address) {
        return projects[hash].wallet;
    }

    function getProject(string hash) external view returns(bool, address, string) {
        return (projects[hash].isRegistered, projects[hash].wallet, projects[hash].uri);
    }

    event Deploy(address indexed sender, string hash, string uri);
    event Migration(address indexed sender, address indexed user, string hash, string uri);
}