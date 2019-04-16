const PictionNetwork = artifacts.require("PictionNetwork");

const AccountsManager = artifacts.require("AccountsManager");
const ContentsManager = artifacts.require("ContentsManager");
const PostManager = artifacts.require("PostManager");

const AccountsStorage = artifacts.require("AccountsStorage");
const ContentsStorage = artifacts.require("ContentsStorage");
const RelationStorage = artifacts.require("RelationStorage");

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
    let contentsManager;
    let postManager;

    let accountsStorage;
    let contentsStorage;
    let relationStorage;

    let tagAccountsManager = "AccountsManager";
    let tagContentsManager = "ContentsManager";
    let tagPostManager = "PostManager";
    let tagAccountsStorage = "AccountsStorage";
    let tagContentsStorage = "ContentsStorage";
    let tagRelationStorage = "RelationStorage";

    describe("manager", () => {
        it("deploy contracts", async () => {
            pictionNetwork = await PictionNetwork.new({from: owner}).should.be.fulfilled;

            accountsStorage = await AccountsStorage.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
            await pictionNetwork.setAddress(tagAccountsStorage, accountsStorage.address, {from: owner}).should.be.fulfilled;
            accountsManager = await AccountsManager.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
            await pictionNetwork.setAddress(tagAccountsManager, accountsManager.address, {from: owner}).should.be.fulfilled;
            contentsManager = await ContentsManager.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
            await pictionNetwork.setAddress(tagContentsManager, contentsManager.address, {from: owner}).should.be.fulfilled;
            postManager = await PostManager.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
            await pictionNetwork.setAddress(tagPostManager, postManager.address, {from: owner}).should.be.fulfilled;

            contentsStorage = await ContentsStorage.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
            await pictionNetwork.setAddress(tagContentsStorage, contentsStorage.address, {from: owner}).should.be.fulfilled;
            relationStorage = await RelationStorage.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
            await pictionNetwork.setAddress(tagRelationStorage, relationStorage.address, {from: owner}).should.be.fulfilled;
        });

        it("contentsManager test start", async () => {    
            //accountsManager 계정 생성
            await accountsManager.createAccount('0', 'userHash', 'accountRawData', user1, {from: owner}).should.be.fulfilled;
            
            //콘텐츠 생성 검증
            //비정상 유저 해시
            await contentsManager.createContents("FakeUserHash", "contentsHash", "contentsRawData", {from: user1}).should.be.rejected;
            //비정상 유저 Address
            await contentsManager.createContents("userHash", "contentsHash", "contentsRawData", {from: user2}).should.be.rejected;

            //contentsManager 콘텐츠 생성
            await contentsManager.createContents("userHash", "contentsHash", "contentsRawData", {from: user1}).should.be.fulfilled;

            //중복 생성

            //업데이트

            //삭제
        });

        it("postManager test start", async () => {

            //Post 삭제된 Contents 기반 생성
            //Post 생성
            //Post Update
            //Post Move 임의 Contents
            //Post Move
            //Post 삭제
        });
    });
});