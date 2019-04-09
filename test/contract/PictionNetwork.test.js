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
            await pictionNetwork.setManager("accounts", AccountsManager, {from: owner})
            await pictionNetwork.setManager("contents", ContentsManager, {from: owner})

            const accountsManager = await pictionNetwork.getManager("accounts")
            const contentsManager = await pictionNetwork.getManager("contents")
            
            accountsManager.should.be.equal(AccountsManager)
            contentsManager.should.be.equal(ContentsManager)
        });
    });
});