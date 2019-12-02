const PictionNetwork = artifacts.require("PictionNetwork");
const AccountManager = artifacts.require("AccountManager");

const BigNumber = require("bigNumber.js");

require("chai")
    .use(require("chai-as-promised"))
    .use(require("chai-bignumber")(BigNumber))
    .should();

contract("AccountManager", function(accounts) {
    const owner = accounts[0];
    const user = accounts[1];
    const user2 = accounts[2];
    const migrationUser = accounts[3];

    const managerName = 'AccountManager';

    const loginId = 'test1';
    const email = 'test1@piction.network';
    const updateEmail = 'test2@piction.network';
    const invalidLoginId = 'test2';

    const migrationLoginId = 'migration';
    const migrationEmail = 'migration@piction.network';

    let pictionNetwork;
    let accountManager;

    before("deploy contracts and initial setting contracts", async () => {
        
        //Deploy and setting address
        pictionNetwork = await PictionNetwork.new({from: owner}).should.be.fulfilled;
        accountManager = await AccountManager.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
        await pictionNetwork.setAddress(managerName, accountManager.address, {from: owner}).should.be.fulfilled;
    });

    describe("AccountManager", () => {
        it("check piction network registration address ", async() => {
            const managerAddress = await pictionNetwork.getAddress(managerName).should.be.fulfilled;
            managerAddress.should.be.equal(accountManager.address);
        });

        it("signup user", async() => {
            await accountManager.signup(loginId, email, {from: user}).should.be.fulfilled;

            const isRegistered = await accountManager.accountValidation(user, {from: user});
            isRegistered.should.be.equal(true);            
        });

        it("check invalid user", async() => {
            const invalidUser = await accountManager.accountValidation(user2, {from: user2});
            invalidUser.should.be.equal(false);
        });

        it("update user account", async() => {
            await accountManager.updateAccount(loginId, updateEmail, {from: user}).should.be.fulfilled;

            const result = await accountManager.getAccount(user, {from: user});

            result[0].should.be.equal(true);
            result[1].should.be.equal(loginId);
            result[2].should.be.equal(updateEmail);
        });

        it("invalid update user account", async() => {
            await accountManager.updateAccount(loginId, updateEmail, {from: user2}).should.be.rejected;
            await accountManager.updateAccount(invalidLoginId, updateEmail, {from: user}).should.be.rejected;

            const result = await accountManager.getAccount(user, {from: user});

            result[0].should.be.equal(true);
            result[1].should.be.equal(loginId);
            result[2].should.be.equal(updateEmail);
        });

        it("migration user account", async() => {
            await accountManager.migration(migrationUser, migrationLoginId, migrationEmail, {from: migrationUser}).should.be.rejected;
            await accountManager.migration(migrationUser, migrationLoginId, migrationEmail, {from: owner}).should.be.fulfilled;

            const isRegistered = await accountManager.accountValidation(migrationUser, {from: migrationUser});
            isRegistered.should.be.equal(true);            
        });
    });
});
