const PictionNetwork = artifacts.require("PictionNetwork");
const decimals = Math.pow(10, 18);

const BigNumber = require("bigNumber.js");

require("chai")
    .use(require("chai-as-promised"))
    .use(require("chai-bignumber")(BigNumber))
    .should();

contract("PictionNetwork", function (accounts) {
    const owner = accounts[0];
    const accountsManager = accounts[1];
    const contentsManager = accounts[2];
    const contentsRevenue = accounts[3];
    
    let pictionNetwork;
    
    const userAdoptionPoolRate = 0.02 * decimals;

    describe("PictionNetwork", () => {
        it("initial pictionNewtork", async () => {
            pictionNetwork = await PictionNetwork.new({from: owner}).should.be.fulfilled;
        });

        it("set address", async () => {
            await pictionNetwork.setAddress("AccountsManager", accountsManager, {from: owner}).should.be.fulfilled;
            await pictionNetwork.setAddress("ContentsManager", contentsManager, {from: owner}).should.be.fulfilled;

            const registedAccountsManager = await pictionNetwork.getAddress("AccountsManager").should.be.fulfilled;
            const registedContentsManager = await pictionNetwork.getAddress("ContentsManager").should.be.fulfilled;
            
            registedAccountsManager.should.be.equal(accountsManager);
            registedContentsManager.should.be.equal(contentsManager);
        });

        it("get invalid address", async () => {
            await pictionNetwork.setAddress("ContentsRevenue", contentsRevenue, {from: owner}).should.be.fulfilled;
            
            await pictionNetwork.getAddress("contentsrevenue").should.be.rejected;
        });

        it("set rate", async () => {
            await pictionNetwork.setRate("UserAdoptionPool", userAdoptionPoolRate).should.be.fulfilled;

            const registedUserAdoptionPoolRate = await pictionNetwork.getRate("UserAdoptionPool").should.be.fulfilled;

            new BigNumber(userAdoptionPoolRate).should.be.bignumber.equal(registedUserAdoptionPoolRate);
        });
    });
});