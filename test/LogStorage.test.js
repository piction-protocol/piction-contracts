const Proxy = artifacts.require("Proxy");
const Project = artifacts.require("Project");
const LogStorage = artifacts.require("LogStorage");
const PictionNetwork = artifacts.require("PictionNetwork");
const ProjectManager = artifacts.require("ProjectManager");


const BigNumber = web3.BigNumber;

require("chai")
    .use(require("chai-as-promised"))
    .use(require("chai-bignumber")(BigNumber))
    .should();

contract("Test LogStorage with Proxy contract", async function (accounts){
    const owner = accounts[0];
    const creator = accounts[1];
    const user = accounts[2];
    const invalidUser = accounts[3];

    let proxy;
    let project;
    let logStorage;
    let pictionNetwork;
    let projectManager;

    before("Deploy contract", async() => {
        proxy = await Proxy.new({from: owner});
        pictionNetwork = await PictionNetwork.new({from: owner});
        projectManager = await ProjectManager.new({from: owner});
        logStorage = await LogStorage.new({from: owner});

        console.log("deployed contract address..............")
        console.log("Proxy contract address: " + proxy.address);
        console.log("Piction Network contract address: " + pictionNetwork.address);
        console.log("Project Manager contract address: " + projectManager.address);
        console.log("Log Storage contract address: " + logStorage.address);        
        console.log();

        console.log("Set project manager address to piction network contract")
        await pictionNetwork.setAddress("ProjectManager", projectManager.address, {from: owner});
        console.log("Completed address setting: " + await pictionNetwork.getAddress("ProjectManager", {from: owner}));
        console.log();

        console.log("Set log storage address to piction network contract")
        await pictionNetwork.setAddress("LogStorage", logStorage.address, {from: owner});
        console.log("Completed address setting: " + await pictionNetwork.getAddress("LogStorage", {from: owner}));
        console.log();

        console.log("Deploy project contract")
        const receipt = await projectManager.createProject("testuri", "testtitle", 0, {from: creator});
        project = Project.at(receipt.receipt.logs[0].address);
        console.log("Completed address setting: " + project.address);

        console.log("Set target address for proxy contract");
        await await proxy.setTargetAddress(logStorage.address, {from: owner});
    });

    it("Test sign up and sign in", async() => {
        const proxyContract = LogStorage.at(proxy.address);

        let result;
        result = await proxyContract.signUp(creator, "test", {from: owner});
        result.receipt.status.should.be.equals("0x1");

        result = await proxyContract.signIn(creator, "test", {from: owner});
        result.receipt.status.should.be.equals("0x1");

        await proxyContract.signIn(creator, "test", {from: invalidUser}).should.be.rejected;
    });

    it("Test related project", async() => {
        const proxyContract = LogStorage.at(proxy.address);

        let result;
        result = await proxyContract.viewCount(project.address, 1, "test", {from: user});
        result.receipt.status.should.be.equals("0x1");

        result = await proxyContract.subscription(project.address, 1, "test", {from: user});
        result.receipt.status.should.be.equals("0x1");

        result = await proxyContract.unSubscription(project.address, "test", {from: user});
        result.receipt.status.should.be.equals("0x1");

        result = await proxyContract.like(project.address, 1, "test", {from: user});
        result.receipt.status.should.be.equals("0x1");

        await proxyContract.like(invalidUser, 1, "test", {from: user}).should.be.rejected;
    });

    it("Test sponsorship", async() => {
        const proxyContract = LogStorage.at(proxy.address);

        let result;
        result = await proxyContract.sponsorship(creator, 1, "test", {from: user});
        result.receipt.status.should.be.equals("0x1");

        await proxyContract.sponsorship('0x0', 1, "test", {from: user}).should.be.rejected;
    });
});