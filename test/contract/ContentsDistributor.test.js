const PXL = artifacts.require("PXL");
const ContentsDistributor = artifacts.require("ContentsDistributor");
const InitialPictionNetwork = require("./InitialPictionNetwork.js");

const BigNumber = require("bigNumber.js");

require("chai")
    .use(require("chai-as-promised"))
    .use(require("chai-bignumber")(BigNumber))
    .should();

contract("ContentsDistributor", function (accounts) {
    const owner = accounts[0];
    const user = accounts[1];
    const contentsDistributorAccount = accounts[2];
    const userAdoptionPool = accounts[3];
    const ecosystemFund = accounts[4];
    const contentsProvider = accounts[5];
    const supporterPool = accounts[6];

    const decimals = Math.pow(10, 18);
    const initialStaking = 1000 * decimals;

    let pictionNetwork;

    const contentsDistributorRate = 0.12;
    const userAdoptionPoolRate = 0.02;
    const ecosystemFundRate = 0.10;
    const supporterPoolRate = 0;

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
        pictionNetwork = await InitialPictionNetwork(accounts);
    });

    describe("ContentsDistributor", () => {
        it("Distribute", async () => {
            const amount = 100 * decimals;

            const contentsDistributorAddress = await pictionNetwork.getContentsDistributor("BattleComics").should.be.fulfilled;
            const pxlAddress = await pictionNetwork.getAddress("PXL").should.be.fulfilled;

            const pxl = await PXL.at(pxlAddress);

            const beforeUserBalance = await pxl.balanceOf(user);
            const beforeContentsDistributorBalance = await pxl.balanceOf(contentsDistributorAddress);
            const beforeUserAdoptionPoolBalance = await pxl.balanceOf(userAdoptionPool);
            const beforeEcosystemFundBalance = await pxl.balanceOf(ecosystemFund);            
            const beforeSupporterPoolBalance = await pxl.balanceOf(supporterPool);
            const beforeContentsProviderBalance = await pxl.balanceOf(contentsProvider);

            console.log("beforeUserBalance: " + beforeUserBalance);
            console.log("beforeContentsDistributorBalance: " + (beforeContentsDistributorBalance - initialStaking));
            console.log("beforeUserAdoptionPoolBalance: " + beforeUserAdoptionPoolBalance);
            console.log("beforeEcosystemFundBalance: " + beforeEcosystemFundBalance);
            console.log("beforeSupporterPoolBalance: " + beforeSupporterPoolBalance);
            console.log("beforeContentsProviderBalance: " + beforeContentsProviderBalance);

            const param = web3.fromAscii(contentHash) + toBigNumber(1).substr(2) + toBigNumber(supporterPoolRate * decimals).substr(2)
            console.log("param: " + param);
            
            await pxl.approveAndCall(contentsDistributorAddress, amount, param, {from: user}).should.be.fulfilled;

            const afterUserBalance = await pxl.balanceOf(user);
            const afterContentsDistributorBalance = await pxl.balanceOf(contentsDistributorAddress);
            const afterUserAdoptionPoolBalance = await pxl.balanceOf(userAdoptionPool);
            const afterEcosystemFundBalance = await pxl.balanceOf(ecosystemFund);            
            const afterSupporterPoolBalance = await pxl.balanceOf(supporterPool);
            const afterContentsProviderBalance = await pxl.balanceOf(contentsProvider);

            console.log("afterUserBalance: " + afterUserBalance);
            console.log("afterContentsDistributorBalance: " + (afterContentsDistributorBalance - initialStaking));
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

        it("Set Staking", async () => {
            const contentsDistributorAddress = await pictionNetwork.getContentsDistributor("BattleComics").should.be.fulfilled;

            const contentsDistributor = await ContentsDistributor.at(contentsDistributorAddress);
            await contentsDistributor.setStaking(2000 * decimals, {from: owner}).should.be.fulfilled;

            await contentsDistributor.sendToContentsDistributor({from: owner}).should.be.rejected;

            await contentsDistributor.setStaking(1000 * decimals, {from: owner}).should.be.fulfilled;
        });

        it("Send to ContentsDistributor", async () => {
            const contentsDistributorAddress = await pictionNetwork.getContentsDistributor("BattleComics").should.be.fulfilled;
            const pxlAddress = await pictionNetwork.getAddress("PXL").should.be.fulfilled;

            const pxl = await PXL.at(pxlAddress);
            const contentsDistributor = await ContentsDistributor.at(contentsDistributorAddress);
            
            const beforeContentsDistributorBalance = await pxl.balanceOf(contentsDistributorAddress);
            const beforeContentsDistributorAccountBalance = await pxl.balanceOf(contentsDistributorAccount)
            console.log("beforeContentsDistributorBalance: " + (beforeContentsDistributorBalance));
            console.log("beforeContentsDistributorAccountBalance: " + (beforeContentsDistributorAccountBalance));
            
            await contentsDistributor.sendToContentsDistributor({from: owner}).should.be.fulfilled;

            const afterContentsDistributorBalance = await pxl.balanceOf(contentsDistributorAddress);
            const afterContentsDistributorAccountBalance = await pxl.balanceOf(contentsDistributorAccount);
            console.log("afterContentsDistributorBalance: " + (afterContentsDistributorBalance));
            console.log("afterContentsDistributorAccountBalance: " + (afterContentsDistributorAccountBalance));

            initialStaking.should.be.bignumber.equal(afterContentsDistributorBalance);
            beforeContentsDistributorBalance.sub(afterContentsDistributorBalance).should.be.bignumber.equal(afterContentsDistributorAccountBalance);
        });

        it("Send to ContentsDistributor after changed staking", async () => {
            const contentsDistributorAddress = await pictionNetwork.getContentsDistributor("BattleComics").should.be.fulfilled;
            const pxlAddress = await pictionNetwork.getAddress("PXL").should.be.fulfilled;

            const pxl = await PXL.at(pxlAddress);
            const contentsDistributor = await ContentsDistributor.at(contentsDistributorAddress);
            await contentsDistributor.setStaking(0, {from: owner}).should.be.fulfilled;
            
            const beforeContentsDistributorBalance = await pxl.balanceOf(contentsDistributorAddress);
            const beforeContentsDistributorAccountBalance = await pxl.balanceOf(contentsDistributorAccount)
            console.log("beforeContentsDistributorBalance: " + (beforeContentsDistributorBalance));
            console.log("beforeContentsDistributorAccountBalance: " + (beforeContentsDistributorAccountBalance));
            
            await contentsDistributor.sendToContentsDistributor({from: owner}).should.be.fulfilled;

            const afterContentsDistributorBalance = await pxl.balanceOf(contentsDistributorAddress);
            const afterContentsDistributorAccountBalance = await pxl.balanceOf(contentsDistributorAccount);
            console.log("afterContentsDistributorBalance: " + (afterContentsDistributorBalance));
            console.log("afterContentsDistributorAccountBalance: " + (afterContentsDistributorAccountBalance));

            afterContentsDistributorBalance.should.be.zero;
            initialStaking.should.be.bignumber.equal(afterContentsDistributorAccountBalance.sub(beforeContentsDistributorAccountBalance));
        });
    });
});