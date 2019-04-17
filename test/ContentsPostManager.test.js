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
            
            //-- 콘텐츠 생성 검증 --
            //비정상 유저 해시 입력
            await contentsManager.createContents("FakeUserHash", "contentsHash", "contentsRawData", {from: user1})
                .should.be.rejected;
            //비정상 유저 Address 시도
            await contentsManager.createContents("userHash", "contentsHash", "contentsRawData", {from: user2})
                .should.be.rejected;

            //정상 콘텐츠 생성
            await contentsManager.createContents("userHash", "contentsHash", "contentsRawData", {from: user1})
                .should.be.fulfilled;
            //저장 값 검증 - Address
            let writer = await contentsManager.getWriter.call("contentsHash", {from: user1});
                writer.should.be.equal(user1);

            //저장 값 검증 - RawData
            let raw = await contentsManager.getContentsRawData.call("contentsHash", {from: user1});
                raw.should.be.equal("contentsRawData");
            
            //저장 값 검증 - UserHash
            let uHash = await contentsManager.getUserHash.call("contentsHash", {from: user1});
                uHash.should.be.equal("userHash");

            //중복 생성 검증
            await contentsManager.createContents("userHash", "contentsHash", "contentsRawData", {from: user1})
                .should.be.rejected;

            
            //-- 콘텐츠 업데이트 검증 --
            //비정상 유저 해시 입력
            await contentsManager.updateContents("FakeUserHash", "contentsHash", "contentsUpdateRawData", {from: user1})
                .should.be.rejected;
            //비정상 유저 Address 시도
            await contentsManager.updateContents("userHash", "contentsHash", "contentsUpdateRawData", {from: user2})
                .should.be.rejected;

            //정상 콘텐츠 업데이트
            await contentsManager.updateContents("userHash", "contentsHash", "contentsUpdateRawData", {from: user1})
                .should.be.fulfilled;

            //저장 값 검증 - RawData
            raw = await contentsManager.getContentsRawData.call("contentsHash", {from: user1});
                raw.should.be.equal("contentsUpdateRawData");

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