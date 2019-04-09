const PictionNetwork = artifacts.require("PictionNetwork");

require("chai")
    .use(require("chai-as-promised"))
    .should();

contract("PictionNetwork", function (accounts) {
    const owner = accounts[0];
    const AccountsManager = accounts[1];
    const ContentsManager = accounts[2];
    
    let pictionNetwork;

    describe("PictionNetwork", () => {
        it("initial pictionNewtork", async () => {
          pictionNetwork = await PictionNetwork.new(
                {from: owner}).should.be.fulfilled;
          });

        it("set managers", async () => {
            await pictionNetwork.setManager("Accounts", AccountsManager, {from: owner})
            await pictionNetwork.setManager("Contents", ContentsManager, {from: owner})

            const accountsManager = await pictionNetwork.getManager("Accounts")
            const contentsManager = await pictionNetwork.getManager("Contents")
            
            accountsManager.should.be.equal(AccountsManager)
            contentsManager.should.be.equal(ContentsManager)
        });
    });
});