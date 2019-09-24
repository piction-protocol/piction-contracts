const Proxy = artifacts.require("Proxy");
const Project = artifacts.require("LogStorage");
const LogStorage = artifacts.require("LogStorage");
const PictionNetwork = artifacts.require("PictionNetwork");
const ProjectManager = artifacts.require("ProjectManager");

require("chai")
    .use(require("chai-as-promised"))
    .use(require("chai-bignumber")(BigNumber))
    .should();

contract("Test LogStorage with Proxy contract", async function (accounts){
    
});