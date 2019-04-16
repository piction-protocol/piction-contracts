const PictionNetwork = artifacts.require("PictionNetwork");
const AccountsStorage = artifacts.require("AccountsStorage");

const BigNumber = require("bigNumber.js");

require("chai")
    .use(require("chai-as-promised"))
    .use(require("chai-bignumber")(BigNumber))
    .should();

contract("AccountsStorage", function (accounts) {
    const owner = accounts[0];
    const accountsManager = accounts[1];
    const user = accounts[2];

    let pictionNetwork;
    let accountsStorage;


    describe("AccountsStorage", () => {
        it("deploy contracts", async () => {
            pictionNetwork = await PictionNetwork.new({from: owner}).should.be.fulfilled;
            accountsStorage = await AccountsStorage.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
        });

        it("set accounts manager address", async () => {
            await pictionNetwork.setAddress("AccountsManager", accountsManager, {from: owner}).should.be.fulfilled;

            const registeredAccountsManager = await pictionNetwork.getAddress("AccountsManager").should.be.fulfilled;

            registeredAccountsManager.should.be.equal(accountsManager);
        });

        it("set default mapping variable", async () => {
            const key = 'testKey';
            const tag = 'test';
            const hash = 'hash';

            // contract owner reject test
            await accountsStorage.setBooleanValue(key, true, tag, {from: owner}).should.be.rejected;
            await accountsStorage.getBooleanValue(key, {from: owner}).should.be.rejected;

            await accountsStorage.setBooleanValue(key, true, tag, {from: accountsManager}).should.be.fulfilled;
            await accountsStorage.setUintValue(key, 100, tag, {from: accountsManager}).should.be.fulfilled;
            await accountsStorage.setStringValue(key, 'test', tag, {from: accountsManager}).should.be.fulfilled;

            const boolResult = await accountsStorage.getBooleanValue(key, {from: accountsManager});
            const uintResult = await accountsStorage.getUintValue(key, {from: accountsManager});
            const stringResult = await accountsStorage.getStringValue(key, {from: accountsManager});

            boolResult.should.be.equal(true);
            new BigNumber(100).should.be.bignumber.equal(uintResult);
            stringResult.should.be.equal('test');
        });

        it("delete mapping variable", async () => {
            const key = 'testKey';
            const tag = 'test';
            const hash = 'hash';

            // contract owner reject test
            await accountsStorage.setBooleanValue(key, true, tag, {from: owner}).should.be.rejected;
            await accountsStorage.getBooleanValue(key, {from: owner}).should.be.rejected;

            await accountsStorage.setBooleanValue(key, true, tag, {from: accountsManager}).should.be.fulfilled;
            await accountsStorage.setUintValue(key, 100, tag, {from: accountsManager}).should.be.fulfilled;
            await accountsStorage.setStringValue(key, 'test', tag, {from: accountsManager}).should.be.fulfilled;

            let boolResult = await accountsStorage.getBooleanValue(key, {from: accountsManager});
            let uintResult = await accountsStorage.getUintValue(key, {from: accountsManager});
            let stringResult = await accountsStorage.getStringValue(key, {from: accountsManager});

            boolResult.should.be.equal(true);
            new BigNumber(100).should.be.bignumber.equal(uintResult);
            stringResult.should.be.equal('test');

            await accountsStorage.deleteBooleanValue(key, tag, {from: owner}).should.be.rejected;

            await accountsStorage.deleteBooleanValue(key, tag, {from: accountsManager}).should.be.fulfilled;
            await accountsStorage.deleteUintValue(key, tag, {from: accountsManager}).should.be.fulfilled;
            await accountsStorage.deleteStringValue(key, tag, {from: accountsManager}).should.be.fulfilled;

            boolResult = await accountsStorage.getBooleanValue(key, {from: accountsManager});
            uintResult = await accountsStorage.getUintValue(key, {from: accountsManager});
            stringResult = await accountsStorage.getStringValue(key, {from: accountsManager});

            boolResult.should.be.equal(false);
            new BigNumber(0).should.be.bignumber.equal(uintResult);
            stringResult.should.be.equal('');
        });
    });
});