const PXL = artifacts.require("PXL");
const ContentsRevenue = artifacts.require("ContentsRevenue");
const AccountsStorage = artifacts.require("AccountsStorage");
const ContentsStorage = artifacts.require("ContentsStorage");
const RelationStorage = artifacts.require("RelationStorage");
const AccountsManager = artifacts.require("AccountsManager");
const ContentsManager = artifacts.require("ContentsManager");
const PictionNetwork = artifacts.require("PictionNetwork");

const BigNumber = require("bigNumber.js");

require("chai")
    .use(require("chai-as-promised"))
    .use(require("chai-bignumber")(BigNumber))
    .should();

contract("ContentsRevenue", function (accounts) {
    const owner = accounts[0];
    const user = accounts[1];
    const contentsDistributor = accounts[2];
    const userAdoptionPool = accounts[3];
    const ecosystemFund = accounts[4];
    const contentsProvider = accounts[5];
    const supporterPool = accounts[6];

    const decimals = Math.pow(10, 18);
    const initialBalance = 100000 * decimals;
        
    let pictionNetwork;
    let pxl;

    const contentsDistributorRate = 0.12;
    const userAdoptionPoolRate = 0.02;
    const ecosystemFundRate = 0.10;
    const supporterPoolRate = 0.10;

    const userHash = '0xb0fef621727ff82a7d334d9f1f047dc662ed0e27e05aa8fd1aefd19b0fff312c';
    const writerHash = '0x0f78fcc486f5315418fbf095e71c0675ee07d318e5ac4d150050cd8e57966496';
    const contentHash = '0xb493d48364afe44d11c0165cf470a4164d1e2609911ef998be868d46ade3de4e';

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
        await pictionNetwork.setAddress("PXL", pxl.address, {from: owner}).should.be.fulfilled;
        await pxl.unlock({from: owner}).should.be.fulfilled;
        await pxl.mint(initialBalance, {from: owner}).should.be.fulfilled;
        await pxl.transfer(user, 200 * decimals, {from: owner}).should.be.fulfilled;
        
        const accountsStorage = await AccountsStorage.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
        await pictionNetwork.setAddress("AccountsStorage", accountsStorage.address, {from: owner}).should.be.fulfilled;

        const contentsStorage = await ContentsStorage.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
        await pictionNetwork.setAddress("ContentsStorage", contentsStorage.address, {from: owner}).should.be.fulfilled;

        const relationStorage = await RelationStorage.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
        await pictionNetwork.setAddress("RelationStorage", relationStorage.address, {from: owner}).should.be.fulfilled;

        const accountsManager = await AccountsManager.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
        await pictionNetwork.setAddress("AccountsManager", accountsManager.address, {from: owner}).should.be.fulfilled;
        await accountsManager.createAccount("0", writerHash, "testData", contentsProvider, {from: owner}).should.be.fulfilled;
        await accountsManager.createAccount("1", userHash, "testData", user, {from: owner}).should.be.fulfilled;
        
        const contentsManager = await ContentsManager.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
        await pictionNetwork.setAddress("ContentsManager", contentsManager.address, {from: owner}).should.be.fulfilled;
        await contentsManager.createContents(writerHash, contentHash, "testData", {from: contentsProvider}).should.be.fulfilled;

        const contentsRevenue = await ContentsRevenue.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
        await pictionNetwork.setAddress("ContentsRevenue", contentsRevenue.address, {from: owner}).should.be.fulfilled;
        
        // TODO: deploy UserAdoptionPool
        await pictionNetwork.setAddress("UserAdoptionPool", userAdoptionPool, {from: owner}).should.be.fulfilled;

        // TODO: deploy UserAdoptionPool
        await pictionNetwork.setAddress("SupporterPool", supporterPool, {from: owner}).should.be.fulfilled;

        await pictionNetwork.setAddress("EcosystemFund", ecosystemFund, {from: owner}).should.be.fulfilled;
        
        await pictionNetwork.setRate("ContentsDistributor", contentsDistributorRate * decimals, {from: owner}).should.be.fulfilled;
        await pictionNetwork.setRate("UserAdoptionPool", userAdoptionPoolRate * decimals, {from: owner}).should.be.fulfilled;
        await pictionNetwork.setRate("EcosystemFund", ecosystemFundRate * decimals, {from: owner}).should.be.fulfilled;
    });

    describe("ContentsRevenue", () => {
        it("Distribute", async () => {
            const amount = 100 * decimals;

            const beforeUserBalance = await pxl.balanceOf(user);
            const beforeContentsDistributorBalance = await pxl.balanceOf(contentsDistributor);
            const beforeUserAdoptionPoolBalance = await pxl.balanceOf(userAdoptionPool);
            const beforeEcosystemFundBalance = await pxl.balanceOf(ecosystemFund);            
            const beforeSupporterPoolBalance = await pxl.balanceOf(supporterPool);
            const beforeContentsProviderBalance = await pxl.balanceOf(contentsProvider);

            console.log("beforeUserBalance: " + beforeUserBalance);
            console.log("beforeContentsDistributorBalance: " + beforeContentsDistributorBalance);
            console.log("beforeUserAdoptionPoolBalance: " + beforeUserAdoptionPoolBalance);
            console.log("beforeEcosystemFundBalance: " + beforeEcosystemFundBalance);
            console.log("beforeSupporterPoolBalance: " + beforeSupporterPoolBalance);
            console.log("beforeContentsProviderBalance: " + beforeContentsProviderBalance);

            const param = web3.fromAscii(contentHash) + toAddress(contentsDistributor).substr(2) + toBigNumber(1).substr(2) + toBigNumber(supporterPoolRate * decimals).substr(2)
            console.log("param: " + param);

            const contentsRevenueAddress = await pictionNetwork.getAddress("ContentsRevenue").should.be.fulfilled;
            
            await pxl.approveAndCall(contentsRevenueAddress, amount, param, {from: user}).should.be.fulfilled;

            const afterUserBalance = await pxl.balanceOf(user);
            const afterContentsDistributorBalance = await pxl.balanceOf(contentsDistributor);
            const afterUserAdoptionPoolBalance = await pxl.balanceOf(userAdoptionPool);
            const afterEcosystemFundBalance = await pxl.balanceOf(ecosystemFund);            
            const afterSupporterPoolBalance = await pxl.balanceOf(supporterPool);
            const afterContentsProviderBalance = await pxl.balanceOf(contentsProvider);

            console.log("afterUserBalance: " + afterUserBalance);
            console.log("afterContentsDistributorBalance: " + afterContentsDistributorBalance);
            console.log("afterUserAdoptionPoolBalance: " + afterUserAdoptionPoolBalance);
            console.log("afterEcosystemFundBalance: " + afterEcosystemFundBalance);            
            console.log("afterSupporterPoolBalance: " + afterSupporterPoolBalance);
            console.log("afterContentsProviderBalance: " + afterContentsProviderBalance);

            const cpAmount = amount - (amount * contentsDistributorRate) - (amount * userAdoptionPoolRate) - (amount * ecosystemFundRate) - (amount * supporterPoolRate);

            beforeUserBalance.sub(amount).should.be.bignumber.equal(afterUserBalance);
            beforeContentsDistributorBalance.add(amount * contentsDistributorRate).should.be.bignumber.equal(afterContentsDistributorBalance);
            beforeUserAdoptionPoolBalance.add(amount * userAdoptionPoolRate).should.be.bignumber.equal(afterUserAdoptionPoolBalance);
            beforeEcosystemFundBalance.add(amount * ecosystemFundRate).should.be.bignumber.equal(afterEcosystemFundBalance);            
            beforeSupporterPoolBalance.add(amount * supporterPoolRate).should.be.bignumber.equal(afterSupporterPoolBalance);
            beforeContentsProviderBalance.add(cpAmount).should.be.bignumber.equal(afterContentsProviderBalance);
        });
    });
});