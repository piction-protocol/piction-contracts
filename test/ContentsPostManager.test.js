const PictionNetwork = artifacts.require("PictionNetwork");

const AccountsManager = artifacts.require("AccountsManager");
const AccountsStorage = artifacts.require("AccountsStorage");

const ContentsManager = artifacts.require("ContentsManager");
const PostManager = artifacts.require("PostManager");
const ContentsStorage = artifacts.require("ContentsStorage");

const BigNumber = require("bigNumber.js");

require("chai")
    .use(require("chai-as-promised"))
    .use(require("chai-bignumber")(BigNumber))
    .should();

contract("manager", function (accounts) {
    const owner = accounts[0];
    const user1 = accounts[1];
    const user2 = accounts[2];

    let pictionNetwork;
    let accountsManager;
    let accountsStorage;
    let contentsManager;
    let postManager;
    let contentsStorage;

    let tagAccountMnanager = "AccountsManager";
    let tagAccountsStorage = "AccountsStorage";
    let tagContentsManager = "ContentsManager";
    let tagPostManager = "PostManager";
    let tagContentsStorage = "ContentsStorage";

    describe("manager", () => {
        it("deploy contracts", async () => {
            pictionNetwork = await PictionNetwork.new({from: owner}).should.be.fulfilled;

            accountsManager = await AccountsManager.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
            accountsStorage = await AccountsStorage.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
            contentsManager = await ContentsManager.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
            postManager = await PostManager.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
            contentsStorage = await ContentsStorage.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
        });

        it("set PictionNetwork Contracts", async () => {
            await pictionNetwork.setAddress(tagAccountMnanager, accountsManager.address, {from: owner}).should.be.fulfilled;
            await pictionNetwork.setAddress(tagAccountsStorage, accountsStorage.address, {from: owner}).should.be.fulfilled;
            await pictionNetwork.setAddress(tagContentsManager, contentsManager.address, {from: owner}).should.be.fulfilled;
            await pictionNetwork.setAddress(tagPostManager, postManager.address, {from: owner}).should.be.fulfilled;
            await pictionNetwork.setAddress(tagContentsStorage, contentsStorage.address, {from: owner}).should.be.fulfilled;
        });

        //todo
        //1. accountsManager 유저 생성 및 검증
        //2. contentsManager 콘텐츠 생성 및 검증
        //3. postManager Post 생성 및 검증
    });
});