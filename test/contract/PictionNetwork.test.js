const InitialPictionNetwork = require("./InitialPictionNetwork.js");
const ContentsRevenue = artifacts.require("ContentsRevenue");
const ContentsManager = artifacts.require("ContentsManager");

const decimals = Math.pow(10, 18);

const BigNumber = require("bigNumber.js");

require("chai")
    .use(require("chai-as-promised"))
    .use(require("chai-bignumber")(BigNumber))
    .should();

contract("PictionNetwork", function (accounts) {
    const owner = accounts[0];
    const contentsDistributor1 = accounts[7];

    let pictionNetwork;
    
    const userAdoptionPoolRate = 0.02 * decimals;

    describe("PictionNetwork", () => {
        it("initial pictionNewtork", async () => {
            pictionNetwork = await InitialPictionNetwork(accounts);
        });

        it("set address", async () => {
            const contentsManager = await ContentsManager.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
            await pictionNetwork.setAddress("ContentsManager", contentsManager.address, {from: owner}).should.be.fulfilled;

            const registeredContentsManager = await pictionNetwork.getAddress("ContentsManager").should.be.fulfilled;
            
            registeredContentsManager.should.be.equal(contentsManager.address);
        });

        if("set ContentsDistributor", async () => {
            await pictionNetwork.setContentsDistributor("ContentsDistributor1", contentsDistributor1, {from: owner}).should.be.fulfilled;

            const registeredContentsDistributor = pictionNetwork.getContentsDistributor("ContentsDistributor1").should.be.fulfilled;

            registeredContentsDistributor.should.be.equal(contentsDistributor1);
        });

        it("get invalid address", async () => {
            await pictionNetwork.getAddress("contentsrevenue").should.be.rejected;
        });

        it("set rate", async () => {
            await pictionNetwork.setRate("UserAdoptionPool", userAdoptionPoolRate).should.be.fulfilled;

            const registeredUserAdoptionPoolRate = await pictionNetwork.getRate("UserAdoptionPool").should.be.fulfilled;

            new BigNumber(userAdoptionPoolRate).should.be.bignumber.equal(registeredUserAdoptionPoolRate);
        });

        it("updateAddress", async () => {
            const contentsRevenueAddress = await pictionNetwork.getAddress("ContentsRevenue");
            const contentsRevenue = await ContentsRevenue.at(contentsRevenueAddress);
            const newContentsManager = await ContentsManager.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;

            await pictionNetwork.setAddress("ContentsManager", newContentsManager.address);

            await contentsRevenue.updateAddress({from: owner}).should.be.fulfilled;
        });
    });
});