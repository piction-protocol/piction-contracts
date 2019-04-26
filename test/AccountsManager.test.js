const PictionNetwork = artifacts.require("PictionNetwork");
const AccountsStorage = artifacts.require("AccountsStorage");
const AccountsManager = artifacts.require("AccountsManager");

const BigNumber = require("bigNumber.js");

require("chai")
    .use(require("chai-as-promised"))
    .use(require("chai-bignumber")(BigNumber))
    .should();

contract("AccountsManager", function(accounts) {
    const owner = accounts[0];
    const user = accounts[1];
    
    const addressZero = '0x0000000000000000000000000000000000000000';

    const storageName = 'AccountsStorage';
    const managerName = 'AccountsManager';

    const userId = 'account';
    const userHash = 'account_hash';
    const rawData = '{"jsonData": "test data"}';
    const updateRawData = '{"jsonData": "update data"}';

    let pictionNetwork;
    let storage;
    let manager;

    describe("AccountsManager", () => {
        it("deploy contracts and initial setting contracts", async() => {
            pictionNetwork = await PictionNetwork.new({from: owner}).should.be.fulfilled;
            storage = await AccountsStorage.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;

            manager = await AccountsManager.new(pictionNetwork.address, {from: owner}).should.be.rejected;

            await pictionNetwork.setAddress(storageName, storage.address, {from: owner}).should.be.fulfilled;

            manager = await AccountsManager.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
            await pictionNetwork.setAddress(managerName, manager.address, {from: owner}).should.be.fulfilled;
        }); 

        it("check piction network registration address ", async() => {
            const storageAddress = await pictionNetwork.getAddress(storageName).should.be.fulfilled;
            const managerAddress = await pictionNetwork.getAddress(managerName).should.be.fulfilled;

            storageAddress.should.be.equal(storage.address);
            managerAddress.should.be.equal(manager.address);
        });

        it("create user account", async() => {
            let resultAvailableId = await manager.availableId(userId);
            let resultAvailableUserHash = await manager.availableUserHash(userHash);
            let resultUserAddress = await manager.getUserAddress(userHash);
            let resultAccountValidation = await manager.accountValidation(userHash, rawData);

            resultAvailableId.should.be.equal(true);
            resultAvailableUserHash.should.be.equal(true);
            resultUserAddress.should.be.equal(addressZero);
            resultAccountValidation.should.be.equal(false);

            await manager.createAccount(userId, userHash, rawData, user, {from: user}).should.be.rejected;
            await manager.createAccount(userId, userHash, rawData, user, {from: owner}).should.be.fulfilled;

            resultAvailableId = await manager.availableId(userId);
            resultAvailableUserHash = await manager.availableUserHash(userHash);
            resultUserAddress = await manager.getUserAddress(userHash);
            resultAccountValidation = await manager.accountValidation(userHash, rawData);

            resultAvailableId.should.be.equal(false);
            resultAvailableUserHash.should.be.equal(false);
            resultUserAddress.should.be.equal(user);
            resultAccountValidation.should.be.equal(true);
        });

        it("update user account", async() => {
            let resultAvailableId = await manager.availableId(userId);
            let resultAvailableUserHash = await manager.availableUserHash(userHash);
            let resultUserAddress = await manager.getUserAddress(userHash);
            let resultAccountValidation = await manager.accountValidation(userHash, rawData);

            resultAvailableId.should.be.equal(false);
            resultAvailableUserHash.should.be.equal(false);
            resultUserAddress.should.be.equal(user);
            resultAccountValidation.should.be.equal(true);

            await manager.updateAccount(userId, userHash, updateRawData, user, {from: user}).should.be.rejected;
            await manager.updateAccount(userId, userHash, updateRawData, user, {from: owner}).should.be.fulfilled;

            resultAvailableId = await manager.availableId(userId);
            resultAvailableUserHash = await manager.availableUserHash(userHash);
            resultUserAddress = await manager.getUserAddress(userHash);
            resultAccountValidation = await manager.accountValidation(userHash, updateRawData);

            resultAvailableId.should.be.equal(false);
            resultAvailableUserHash.should.be.equal(false);
            resultUserAddress.should.be.equal(user);
            resultAccountValidation.should.be.equal(true);
        });

        it("delete user account", async() => {
            let resultAvailableId = await manager.availableId(userId);
            let resultAvailableUserHash = await manager.availableUserHash(userHash);
            let resultUserAddress = await manager.getUserAddress(userHash);
            let resultAccountValidation = await manager.accountValidation(userHash, updateRawData);

            resultAvailableId.should.be.equal(false);
            resultAvailableUserHash.should.be.equal(false);
            resultUserAddress.should.be.equal(user);
            resultAccountValidation.should.be.equal(true);

            await manager.deleteAccount(userId, userHash, rawData, user, {from: user}).should.be.rejected;
            await manager.deleteAccount(userId, userHash, updateRawData, user, {from: owner}).should.be.fulfilled;

            resultAvailableId = await manager.availableId(userId);
            resultAvailableUserHash = await manager.availableUserHash(userHash);
            resultUserAddress = await manager.getUserAddress(userHash);
            resultAccountValidation = await manager.accountValidation(userHash, updateRawData);

            resultAvailableId.should.be.equal(true);
            resultAvailableUserHash.should.be.equal(true);
            resultUserAddress.should.be.equal(addressZero);
            resultAccountValidation.should.be.equal(false);
        });

        it("invalid parameter", async() => {
            await manager.createAccount(userId, userHash, rawData, user, {from: owner}).should.be.fulfilled;

            await manager.createAccount(userId, userHash, updateRawData, user, {from: owner}).should.be.rejected;
            await manager.updateAccount(userId, rawData, rawData, user, {from: owner}).should.be.rejected;
            await manager.deleteAccount(userId, userHash, updateRawData, user, {from: owner}).should.be.rejected;

            await manager.createAccount("", "", "", user, {from: owner}).should.be.rejected;
            await manager.createAccount(userId, userHash, updateRawData, addressZero, {from: owner}).should.be.rejected;
        });
    });
});
