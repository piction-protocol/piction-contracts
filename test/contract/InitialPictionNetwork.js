const PXL = artifacts.require("PXL");
const ContentsDistributor = artifacts.require("ContentsDistributor");
const Storage = artifacts.require("Storage");
const AccountsManager = artifacts.require("AccountsManager");
const ContentsManager = artifacts.require("ContentsManager");
const PictionNetwork = artifacts.require("PictionNetwork");

module.exports = async (accounts) => {
    const owner = accounts[0];
    const user = accounts[1];
    const contentsDistributorAccount = accounts[2];
    const userAdoptionPool = accounts[3];
    const ecosystemFund = accounts[4];
    const contentsProvider = accounts[5];
    const supporterPool = accounts[6];

    const decimals = Math.pow(10, 18);
    const initialBalance = 100000 * decimals;
    const initialStaking = 1000 * decimals;

    const contentsDistributorRate = 0.12;
    const userAdoptionPoolRate = 0.02;
    const ecosystemFundRate = 0.10;
    const supporterPoolRate = 0.10;

    const userHash = '0xb0fef621727ff82a7d334d9f1f047dc662ed0e27e05aa8fd1aefd19b0fff312c';
    const writerHash = '0x0f78fcc486f5315418fbf095e71c0675ee07d318e5ac4d150050cd8e57966496';
    const contentHash = '0xb493d48364afe44d11c0165cf470a4164d1e2609911ef998be868d46ade3de4e';

    pictionNetwork = await PictionNetwork.new({from: owner}).should.be.fulfilled;

    pxl = await PXL.new({from: owner}).should.be.fulfilled;
    await pictionNetwork.setAddress("PXL", pxl.address, {from: owner}).should.be.fulfilled;
    await pxl.mint(initialBalance, {from: owner}).should.be.fulfilled;
    await pxl.transfer(user, 200 * decimals, {from: owner}).should.be.fulfilled;
    await pxl.transfer(contentsDistributorAccount, 1000 * decimals, {from: owner}).should.be.fulfilled;
    
    const accountsStorage = await Storage.new({from: owner}).should.be.fulfilled;
    await pictionNetwork.setAddress("AccountsStorage", accountsStorage.address, {from: owner}).should.be.fulfilled;

    const contentsStorage = await Storage.new({from: owner}).should.be.fulfilled;
    await pictionNetwork.setAddress("ContentsStorage", contentsStorage.address, {from: owner}).should.be.fulfilled;

    const relationStorage = await Storage.new({from: owner}).should.be.fulfilled;
    await pictionNetwork.setAddress("RelationStorage", relationStorage.address, {from: owner}).should.be.fulfilled;

    const accountsManager = await AccountsManager.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
    await pictionNetwork.setAddress("AccountsManager", accountsManager.address, {from: owner}).should.be.fulfilled;
    await accountsManager.createAccount("0", writerHash, "testData", contentsProvider, {from: owner}).should.be.fulfilled;
    await accountsManager.createAccount("1", userHash, "testData", user, {from: owner}).should.be.fulfilled;
    
    const contentsManager = await ContentsManager.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
    await pictionNetwork.setAddress("ContentsManager", contentsManager.address, {from: owner}).should.be.fulfilled;
    await contentsManager.createContents(writerHash, contentHash, "testData", {from: contentsProvider}).should.be.fulfilled;

    const contentsDistributor = await ContentsDistributor.new(pictionNetwork.address, initialStaking, contentsDistributorRate * decimals, contentsDistributorAccount, "BattleComics", {from: owner}).should.be.fulfilled;
    await pxl.transfer(contentsDistributor.address, 1000 * decimals, {from: contentsDistributorAccount}).should.be.fulfilled;
    await pictionNetwork.setContentsDistributor("BattleComics", contentsDistributor.address);

    // TODO: deploy UserAdoptionPool
    await pictionNetwork.setAddress("UserAdoptionPool", userAdoptionPool, {from: owner}).should.be.fulfilled;

    // TODO: deploy UserAdoptionPool
    await pictionNetwork.setAddress("SupporterPool", supporterPool, {from: owner}).should.be.fulfilled;

    await pictionNetwork.setAddress("EcosystemFund", ecosystemFund, {from: owner}).should.be.fulfilled;
    
    await pictionNetwork.setRate("UserAdoptionPool", userAdoptionPoolRate * decimals, {from: owner}).should.be.fulfilled;
    await pictionNetwork.setRate("EcosystemFund", ecosystemFundRate * decimals, {from: owner}).should.be.fulfilled;
    
    return pictionNetwork;
}