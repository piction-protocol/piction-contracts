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
            contentsStorage = await ContentsStorage.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
            await pictionNetwork.setAddress(tagContentsStorage, contentsStorage.address, {from: owner}).should.be.fulfilled;
            relationStorage = await RelationStorage.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
            await pictionNetwork.setAddress(tagRelationStorage, relationStorage.address, {from: owner}).should.be.fulfilled;

            accountsManager = await AccountsManager.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
            await pictionNetwork.setAddress(tagAccountsManager, accountsManager.address, {from: owner}).should.be.fulfilled;
            contentsManager = await ContentsManager.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
            await pictionNetwork.setAddress(tagContentsManager, contentsManager.address, {from: owner}).should.be.fulfilled;
            postManager = await PostManager.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
            await pictionNetwork.setAddress(tagPostManager, postManager.address, {from: owner}).should.be.fulfilled;

            await accountsStorage.addOwner(accountsManager.address, {from: owner}).should.be.fulfilled;
            await contentsStorage.addOwner(contentsManager.address, {from: owner}).should.be.fulfilled;
            await contentsStorage.addOwner(postManager.address, {from: owner}).should.be.fulfilled;
            await relationStorage.addOwner(contentsManager.address, {from: owner}).should.be.fulfilled;
            await relationStorage.addOwner(postManager.address, {from: owner}).should.be.fulfilled;
        });

        it("contentsManager test start", async () => {
            //accountsManager 계정 생성
            await accountsManager.createAccount('0', 'userHash', 'accountRawData', user1, {from: owner}).should.be.fulfilled;
            
            //-- 콘텐츠 생성 --
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

            
            //-- 콘텐츠 업데이트 --
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


            //-- 콘텐츠 삭제 --
            //비정상 유저 해시 입력
            await contentsManager.deleteContents("FakeUserHash", "contentsHash", {from: user1})
                .should.be.rejected;
            //비정상 유저 Address 시도
            await contentsManager.deleteContents("userHash", "contentsHash", {from: user2})
                .should.be.rejected;

            //정상 콘텐츠 삭제
            await contentsManager.deleteContents("userHash", "contentsHash", {from: user1})
                .should.be.fulfilled;
            
            //삭제 검증- Address
            writer = await contentsManager.getWriter.call("contentsHash", {from: user1})
                writer.should.be.equal("0x0000000000000000000000000000000000000000");

            //삭제 검증 - RawData
            raw = await contentsManager.getContentsRawData.call("contentsHash", {from: user1})
                raw.should.be.equal("")
            
            //삭제 검증- UserHash
            uHash = await contentsManager.getUserHash.call("contentsHash", {from: user1})
                uHash.should.be.equal("");
            
            //owner 삭제 테스트를 위한 콘텐츠 업로드
            await contentsManager.createContents("userHash", "contentsHash", "contentsRawData", {from: user1})
                .should.be.fulfilled;

            //owner 삭제
            await contentsManager.deleteContents("userHash", "contentsHash", {from: owner})
                .should.be.fulfilled;

            //삭제 검증 - Address
            writer = await contentsManager.getWriter.call("contentsHash", {from: user1})
                writer.should.be.equal("0x0000000000000000000000000000000000000000");

            //삭제 검증 - RawData
            raw = await contentsManager.getContentsRawData.call("contentsHash", {from: user1})
                raw.should.be.equal("")
            
            //삭제 검증- UserHash
            uHash = await contentsManager.getUserHash.call("contentsHash", {from: user1})
                uHash.should.be.equal("");
            
        });

        it("postManager test start", async () => {

            //-- Post 생성 --
            //삭제된 Contents 해시로 Post 생성 시도
            await postManager.createPost("userHash", "contentsHash", "postHash", "postRawData", {from: user1})
                .should.be.rejected;
            
            //테스트를 위한 콘텐츠 등록
            await contentsManager.createContents("userHash", "contentsHash", "contentsRawData", {from: user1})
                .should.be.fulfilled;
            
            //비정상 유저 해시 입력
            await postManager.createPost("fakeUserHash", "contentsHash", "postHash", "postRawData", {from: user1})
                .should.be.rejected;
            
            //비정상 유저 Address 시도
            await postManager.createPost("userHash", "contentsHash", "postHash", "postRawData", {from: user2})
                .should.be.rejected;

            //비정상 콘텐츠 해시
            await postManager.createPost("userHash", "fakeContentsHash", "postHash", "postRawData", {from: user1})
                .should.be.rejected;

            //정상 Post 생성
            await postManager.createPost("userHash", "contentsHash", "postHash", "postRawData", {from: user1})
                .should.be.fulfilled;

            //저장 값 검증 - Address
            let writer = await postManager.getPostWriter.call("postHash", {from: user1});
                writer.should.be.equal(user1);
            
            //저장 값 검증 - RawData
            let raw = await postManager.getPostRawData.call("postHash", {from: user1});
                raw.should.be.equal("postRawData");
            
            //저장 값 검증 - ContentHash
            let cHash = await postManager.getContentsHash.call("postHash", {from: user1});
                cHash.should.be.equal("contentsHash");

            //중복 생성 검증
            await postManager.createPost("userHash", "contentsHash", "postHash", "postRawData", {from: user1})
                .should.be.rejected;

            
            //-- Post 업데이트 --
            //비정상 유저 해시 입력
            await postManager.updatePost("fakeUserHash", "contentsHash", "postHash", "postRawData", {from: user1})
                .should.be.rejected;
            
            //비정상 유저 Address 시도
            await postManager.updatePost("userHash", "contentsHash", "postHash", "postRawData", {from: user2})
                .should.be.rejected;

            //비정상 콘텐츠 해시
            await postManager.updatePost("userHash", "fakeContentsHash", "postHash", "postRawData", {from: user1})
                .should.be.rejected;

            //정상 Post 업데이트
            await postManager.updatePost("userHash", "contentsHash", "postHash", "postUpdateRawData", {from: user1})
                .should.be.fulfilled;
            
            //저장 값 검증 - RawData
            raw = await contentsManager.getContentsRawData.call("postHash", {from: user1});
                raw.should.be.equal("postUpdateRawData");


            //-- Post 이동 --
            //테스트를 위한 임의 콘텐츠 등록
            await contentsManager.createContents("userHash", "contentsHashTwo", "contentsRawDataTwo", {from: user1})
                .should.be.fulfilled;

            //비정상 유저 해시 입력
            await postManager.movePost("fakeUserHash", "contentsHash", "contentsHashTwo", "postHash", {from: user1})
                .should.be.rejected;
            
            //비정상 유저 Address 시도
            await postManager.movePost("userHash", "contentsHash", "contentsHashTwo", "postHash", {from: user2})
                .should.be.rejected;

            // //비정상 콘텐츠 해시
            await postManager.movePost("userHash", "fakeContentsHash", "contentsHashTwo", "postHash", {from: user1}).should.be.rejected;
            await postManager.movePost("userHash", "contentsHash", "fakeContentsHashTwo", "postHash", {from: user1}).should.be.rejected;
            await postManager.movePost("userHash", "fakeContentsHash", "fakeContentsHashTwo", "postHash", {from: user1}).should.be.rejected;

            //정상 Post 이동
            await postManager.movePost("userHash", "contentsHash", "contentsHashTwo", "postHash", {from: user1})
                .should.be.fulfilled;

            //저장 값 검증 - 이후 컨텐츠 해시
            cHash = await postManager.getContentsHash.call("postHash", {from: user1});
                cHash.should.be.equal("contentsHashTwo");


            //-- Post 삭제--
            //비정상 유저 해시 입력
            await postManager.deletePost("fakeUserHash", "contentsHashTwo", "postHash", {from: user1})
                .should.be.rejected;
            
            //비정상 유저 Address 시도
            await postManager.deletePost("userHash", "contentsHashTwo", "postHash", {from: user2})
                .should.be.rejected;

            //비정상 콘텐츠 해시
            await postManager.deletePost("userHash", "fakeContentsHashTwo", "postHash", {from: user1})
                .should.be.rejected;
                
            //정상 Post 삭제
            await postManager.deletePost("userHash", "contentsHashTwo", "postHash", {from: user1})
                .should.be.fulfilled;
            
            //삭제 검증- Address
            writer = await postManager.getPostWriter.call("postHash", {from: user1})
                writer.should.be.equal("0x0000000000000000000000000000000000000000");

            //삭제 검증 - RawData
            raw = await postManager.getPostRawData.call("postHash", {from: user1})
                raw.should.be.equal("")
        
            //삭제 검증- UserHash
            cHash = await postManager.getContentsHash.call("postHash", {from: user1})
                cHash.should.be.equal("");
            
            //Owner 테스트를 위한 Post 등록
            await postManager.createPost("userHash", "contentsHashTwo", "postHash", "postRawData", {from: user1})
                .should.be.fulfilled;
            
            //Owner Post 삭제
            await postManager.deletePost("userHash", "contentsHashTwo", "postHash", {from: owner})
                .should.be.fulfilled;
            
            //삭제 검증- Address
            writer = await postManager.getPostWriter.call("postHash", {from: user1})
                writer.should.be.equal("0x0000000000000000000000000000000000000000");

            //삭제 검증 - RawData
            raw = await postManager.getPostRawData.call("postHash", {from: user1})
                raw.should.be.equal("")
        
            //삭제 검증- UserHash
            cHash = await postManager.getContentsHash.call("postHash", {from: user1})
                cHash.should.be.equal("");
        });
    });
});