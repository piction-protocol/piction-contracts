const PXL = artifacts.require("PXL");
const PictionNetwork = artifacts.require("PictionNetwork");
const ProjectManager = artifacts.require("ProjectManager");
const ContentsRevenue = artifacts.require("ContentsRevenue");
const ContentsDistributor = artifacts.require("ContentsDistributor");
const UserAdoptionPool = artifacts.require("UserAdoptionpool");
const EcosystemFund = artifacts.require("EcosystemFund");
const AccountManager = artifacts.require("AccountManager");

const BigNumber = require("bigNumber.js");

require("chai")
    .use(require("chai-as-promised"))
    .use(require("chai-bignumber")(BigNumber))
    .should();

contract("ContentsDistributor", function (accounts) {
    const owner = accounts[0];
    const creator = accounts[1];
    const user = accounts[2];
    const cdOwner = accounts[3];
    const cdOwner2 = accounts[4];

    const decimals = Math.pow(10, 18);
    const initialBalance = 1000000000 * decimals;
    const initialStaking = 1000 * decimals;
    const testPXLAmount = 10000 * decimals;
    const subscriptionPrice = 100 * decimals;

    const contentsDistributorRate = 0.08;
    const userAdoptionPoolRate = 0;
    const ecosystemFundRate = 0;
    const supporterPoolRate = 0;

    // TODO: setting userAdoptionPoolRate, ecosystemFundRate after PIC deploy
    // const userAdoptionPoolRate = 0.02;
    // const ecosystemFundRate = 0.1;
    
    const creatorLoginId = 'creator';
    const creatorEmail = 'creator@piction.network';
    const userLoginId = 'user';
    const userEmail = 'user@piction.network';

    const projectHash = '0x9cd28583d0fe0f239963cb641a6c6c94598a4d9de52983f1d11604006888f089';   // string -> convert md5 -> convert kecca256
    const projectUri = 'projectUri';

    const cdName = "PictionNetworkCD";

    let pictionNetwork;
    let pxl;
    let projectManager;
    let contentsRevenue;
    let contentsDistributor;
    let userAdoptionPool;
    let ecosystemFund;
    let accountManager;
    //TODO: deploy supporterPool contract
    let supporterPool = accounts[4];


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

    before("deploy contracts and initial setting contracts", async () => {
        
        //Deploy and setting address
        pictionNetwork = await PictionNetwork.new({from: owner}).should.be.fulfilled;

        pxl = await PXL.new({from: owner}).should.be.fulfilled;
        await pictionNetwork.setAddress("PXL", pxl.address, {from: owner}).should.be.fulfilled;

        accountManager = await AccountManager.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
        await pictionNetwork.setAddress("AccountManager", accountManager.address, {from: owner}).should.be.fulfilled;

        projectManager = await ProjectManager.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
        await pictionNetwork.setAddress("ProjectManager", projectManager.address, {from: owner}).should.be.fulfilled;

        contentsRevenue = await ContentsRevenue.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
        await pictionNetwork.setAddress("ContentsRevenue", contentsRevenue.address, {from: owner}).should.be.fulfilled;

        userAdoptionPool = await UserAdoptionPool.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
        await pictionNetwork.setAddress("UserAdoptionPool", userAdoptionPool.address, {from: owner}).should.be.fulfilled;

        ecosystemFund = await EcosystemFund.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
        await pictionNetwork.setAddress("EcosystemFund", ecosystemFund.address, {from: owner}).should.be.fulfilled;

        //TODO: deploy supporterPool contract
        //supporterPool = await SupporterPool.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
        await pictionNetwork.setAddress("SupporterPool", supporterPool, {from: owner}).should.be.fulfilled;

        contentsDistributor = await ContentsDistributor.new(pictionNetwork.address, initialStaking, contentsDistributorRate * decimals, cdOwner, cdName).should.be.fulfilled;
        await pictionNetwork.setContentsDistributor(cdName, contentsDistributor.address);
        
        //setting fee rate
        await pictionNetwork.setRate("UserAdoptionPool", userAdoptionPoolRate * decimals, {from: owner}).should.be.fulfilled;
        await pictionNetwork.setRate("EcosystemFund", ecosystemFundRate * decimals, {from: owner}).should.be.fulfilled;
        await pictionNetwork.setRate("SupporterPool", userAdoptionPoolRate * decimals, {from: owner}).should.be.fulfilled;
        await pictionNetwork.setRate("ContentsDistributor", contentsDistributorRate * decimals, {from: owner}).should.be.fulfilled;

        //Mint and transfer PXL
        await pxl.mint(initialBalance, {from: owner}).should.be.fulfilled;
        await pxl.transfer(creator, testPXLAmount, {from: owner}).should.be.fulfilled;
        await pxl.transfer(user, testPXLAmount, {from: owner}).should.be.fulfilled;
        await pxl.transfer(cdOwner, testPXLAmount, {from: owner}).should.be.fulfilled;
        await pxl.transfer(cdOwner2, testPXLAmount, {from: owner}).should.be.fulfilled;

        //signup
        await accountManager.signup(creatorLoginId, creatorEmail, {from: creator}).should.be.fulfilled;
        await accountManager.signup(userLoginId, userEmail, {from: user}).should.be.fulfilled;

        //create project
        await projectManager.create(projectHash, projectUri, {from: creator}).should.be.fulfilled;
    });

    describe("ContentsDistributor", () => {
        it("send initial staking PXL", async() => {
            await pxl.transfer(contentsDistributor.address, initialStaking, {from: cdOwner}).should.be.fulfilled;

            const contractBalance = await pxl.balanceOf(contentsDistributor.address, {from: creator});
            initialStaking.should.be.bignumber.equal(contractBalance);
        });

        it("distribute", async () => {

            const param = web3.fromAscii(projectHash);
            await pxl.approveAndCall(contentsDistributor.address, subscriptionPrice, param, {from: user}).should.be.fulfilled;

            const userBalance = await pxl.balanceOf(user, {from: user});
            const creatorBalance = await pxl.balanceOf(creator, {from: creator});
            const contentsDistributorBalance = await pxl.balanceOf(contentsDistributor.address, {from: cdOwner});

            (testPXLAmount - subscriptionPrice).should.be.bignumber.equal(userBalance);
            (testPXLAmount + (subscriptionPrice * (1 - contentsDistributorRate))).should.be.bignumber.equal(creatorBalance);
            (initialStaking + (subscriptionPrice * contentsDistributorRate)).should.be.bignumber.equal(contentsDistributorBalance);
        });

        it("withdraw PXL", async () => {
            const contractBalance = await pxl.balanceOf(contentsDistributor.address, {from: cdOwner});
            const withdrawValue = contractBalance - initialStaking;

            await contentsDistributor.withdrawPXL({from: owner}).should.be.rejected;
            await contentsDistributor.withdrawPXL({from: cdOwner}).should.be.fulfilled;

            const afterCdOwnerBalance = await pxl.balanceOf(cdOwner, {from: cdOwner});
            const afterContractBalance = await pxl.balanceOf(contentsDistributor.address, {from: cdOwner});

            (testPXLAmount - initialStaking + withdrawValue).should.be.bignumber.equal(afterCdOwnerBalance);
            initialStaking.should.be.bignumber.equal(afterContractBalance);
        });

        it("change initial staking amount", async () => {
            await contentsDistributor.setStaking(500 * decimals, {from: cdOwner}).should.be.rejected;
            await contentsDistributor.setStaking(500 * decimals, {from: owner}).should.be.fulfilled;

            await contentsDistributor.withdrawPXL({from: cdOwner}).should.be.fulfilled;

            const afterCdOwnerBalance = await pxl.balanceOf(cdOwner, {from: cdOwner});
            const afterContractBalance = await pxl.balanceOf(contentsDistributor.address, {from: cdOwner});

            (testPXLAmount + (8 * decimals) - (initialStaking / 2)).should.be.bignumber.equal(afterCdOwnerBalance);
            (500 * decimals).should.be.bignumber.equal(afterContractBalance);
        });

        it("change ContentsDistributor owner address", async () => {
            await pxl.transfer(contentsDistributor.address, initialStaking, {from: owner}).should.be.fulfilled;

            await contentsDistributor.setCDAddress(cdOwner2, {from: cdOwner}).should.be.rejected;
            await contentsDistributor.setCDAddress(cdOwner2, {from: owner}).should.be.fulfilled;

            await contentsDistributor.withdrawPXL({from: cdOwner}).should.be.rejected;
            await contentsDistributor.withdrawPXL({from: cdOwner2}).should.be.fulfilled;

            const afterCdOwner2Balance = await pxl.balanceOf(cdOwner2, {from: cdOwner2});

            (testPXLAmount + initialStaking).should.be.bignumber.equal(afterCdOwner2Balance);
        });
    });
});