const PXL = artifacts.require("PXL");
const PictionNetwork = artifacts.require("PictionNetwork");
const ProjectManager = artifacts.require("ProjectManager");
const Project = artifacts.require("Project");
const ContentsRevenue = artifacts.require("ContentsRevenue");
const ContentsDistributor = artifacts.require("ContentsDistributor");
const UserAdoptionPool = artifacts.require("UserAdoptionpool");
const EcosystemFund = artifacts.require("EcosystemFund");
const Airdrop =  artifacts.require("Airdrop");

const BigNumber = require("bigNumber.js");

require("chai")
    .use(require("chai-as-promised"))
    .use(require("chai-bignumber")(BigNumber))
    .should();

contract("BaoBab Testnet.", function (accounts) {
    const owner = accounts[0];
    const user = accounts[1];
    const cp = accounts[2];

    const decimals = Math.pow(10, 18);
    const initialBalance = 1000000000 * decimals;
    const initialStaking = 1000 * decimals;
    const airdropAmount = 100000000 * decimals;

    const cdName = "PictionNetworkCD";
    
    const projectUri = "piction"
    const projectTitle = "pixel"
    const projectPrice = 100 * decimals;

    let pictionNetwork;
    let pxl;
    let projectManager;
    let project;
    let contentsRevenue;
    let contentsDistributor;
    let userAdoptionPool;
    let ecosystemFund;
    let airdrop;

    const contentsDistributorRate = 0.1;
    const userAdoptionPoolRate = 0;
    const ecosystemFundRate = 0.1;
    const supporterPoolRate = 0;

    let toBigNumber = function bigNumberToPaddedBytes32(num) {
        var n = num.toString(16).replace(/^0x/, '');
        while (n.length < 64) {
            n = "0" + n;
        }
        return "0x" + n;
    }

    let toAddress = function bigNumberToPaddedBytes32(num) {
        var n = num.toString(16).replace(/^0x/, '');
        while (n.length < 40) {
            n = "0" + n;
        }
        return "0x" + n;
    }

    before("initial contract", async () => {
        pictionNetwork = await PictionNetwork.new({from: owner}).should.be.fulfilled;
        
        pxl = await PXL.new({from: owner}).should.be.fulfilled;
        await pxl.mint(initialBalance, {from: owner}).should.be.fulfilled;
        await pictionNetwork.setAddress("PXL", pxl.address, {from: owner}).should.be.fulfilled;

        projectManager = await ProjectManager.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
        await pictionNetwork.setAddress("ProjectManager", projectManager.address, {from: owner}).should.be.fulfilled;

        contentsRevenue = await ContentsRevenue.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
        await pictionNetwork.setAddress("ContentsRevenue", contentsRevenue.address, {from: owner}).should.be.fulfilled;

        contentsDistributor = await ContentsDistributor.new(pictionNetwork.address, initialStaking, contentsDistributorRate, owner, cdName, {from: owner}).should.be.fulfilled;
        await pictionNetwork.setContentsDistributor(cdName, contentsDistributor.address, {from: owner}).should.be.fulfilled;

        userAdoptionPool = await UserAdoptionPool.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
        await pictionNetwork.setAddress("UserAdoptionPool", userAdoptionPool.address, {from: owner}).should.be.fulfilled;
        await pictionNetwork.setRate("UserAdoptionPool", userAdoptionPoolRate * decimals, {from: owner}).should.be.fulfilled;

        ecosystemFund = await EcosystemFund.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
        await pictionNetwork.setAddress("EcosystemFund", ecosystemFund.address, {from: owner}).should.be.fulfilled;
        await pictionNetwork.setRate("EcosystemFund", ecosystemFundRate * decimals, {from: owner}).should.be.fulfilled;

        airdrop = await Airdrop.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
        await pictionNetwork.setAddress("Airdrop", airdrop.address, {from: owner}).should.be.fulfilled;

        await pxl.transfer(airdrop.address, airdropAmount, {from: owner}).should.be.fulfilled;        
    });

    describe("Full Test", () => {
        it("Request airdrop", async () => {
            await airdrop.requestAirdrop({from:user}).should.be.fulfilled;
            await airdrop.requestAirdrop({from:cp}).should.be.fulfilled;

            const userBalance = await pxl.balanceOf(user);
            const cpBalance = await pxl.balanceOf(cp);

            console.log('user pxl amount: ' + userBalance / decimals);
            console.log('cp pxl amount: ' + cpBalance / decimals);
        });

        it("create project", async () => {
            const receipt = await projectManager.createProject(projectUri, projectTitle, projectPrice, {from:cp}).should.be.fulfilled;
            project = receipt.logs[0].args.projectAddress
            console.log(receipt.logs[0].args);
        });

        it("subscription", async () => {
            const receipt = await pxl.approveAndCall(contentsDistributor.address, projectPrice, project, {from:user}).should.be.fulfilled;

            const userBalance = await pxl.balanceOf(user);
            const cpBalance = await pxl.balanceOf(cp);

            console.log('user pxl amount: ' + userBalance / decimals);
            console.log('cp pxl amount: ' + cpBalance / decimals);
        });
    });
});