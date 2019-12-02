const PictionNetwork = artifacts.require("PictionNetwork");
const ProjectManager = artifacts.require("ProjectManager");
const AccountManager = artifacts.require("AccountManager");

const BigNumber = require("bigNumber.js");

require("chai")
    .use(require("chai-as-promised"))
    .use(require("chai-bignumber")(BigNumber))
    .should();

contract("projectManager", function(accounts) {
    const owner = accounts[0];
    const creator = accounts[1];
    const creator2 = accounts[2];
    const migrationCreator = accounts[3];

    const addressZero = '0x0000000000000000000000000000000000000000';

    const projectManagerName = 'ProjectManager';
    const accountManagerName = 'AccountManager';

    const loginId = 'creator';
    const email = 'creator@piction.network';
    const migrationLoginId = 'migration';
    const migrationEmail = 'migration@piction.network';

    const hash = 'projectHash';
    const uri = 'test1';
    const invalidHash = 'invalidHash';
    const invalidUri = 'invalidUri';
    const migrationHash = 'migrationHash';
    const migrationUri = 'migrationUri';

    let pictionNetwork;
    let projectManager;
    let accountManager;

    describe("ProjectManager", () => {
        it("deploy contracts and initial setting contracts", async() => {
            pictionNetwork = await PictionNetwork.new({from: owner}).should.be.fulfilled;
            projectManager = await ProjectManager.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
            accountManager = await AccountManager.new(pictionNetwork.address, {from: owner}).should.be.fulfilled;
            await pictionNetwork.setAddress(projectManagerName, projectManager.address, {from: owner}).should.be.fulfilled;
            await pictionNetwork.setAddress(accountManagerName, accountManager.address, {from: owner}).should.be.fulfilled;
        }); 

        it("check piction network registration address ", async() => {
            const managerAddress = await pictionNetwork.getAddress(projectManagerName).should.be.fulfilled;
            managerAddress.should.be.equal(projectManager.address);
        });

        it("sign up creator", async() => {
            await accountManager.signup(loginId, email, {from: creator}).should.be.fulfilled;

            const isRegistered = await accountManager.accountValidation(creator, {from: creator});
            isRegistered.should.be.equal(true);
        });

        it("create project", async() => {
            await projectManager.create(hash, uri, {from: creator}).should.be.fulfilled;

            const isRegistered = await projectManager.hashValidation(hash, {from: creator});
            isRegistered.should.be.equal(true);            
        });

        it("check invalid hash", async() => {
            const invalidResult = await projectManager.hashValidation(invalidHash, {from: creator});
            invalidResult.should.be.equal(false);
        });

        it("check unique uri", async() => {
            const result = await projectManager.stringValidation(uri, {from: creator});
            result.should.be.equal(true);

            const result2 = await projectManager.stringValidation(invalidUri, {from: creator});
            result2.should.be.equal(false);
        });

        it("check project owner", async() => {
            const result = await projectManager.getProjectOwner(hash, {from: creator});
            result.should.be.equal(creator);

            const result2 = await projectManager.getProjectOwner(invalidHash, {from: creator2});
            result2.should.be.equal(addressZero);
        });

        it("check project info", async() => {
            const project = await projectManager.getProject(hash, {from: creator});

            project[0].should.be.equal(true);
            project[1].should.be.equal(creator);
            project[2].should.be.equal(uri);
        }); 

        it("migration project", async() => {
            await projectManager.migration(creator2, migrationHash, migrationUri, {from: owner}).should.be.rejected;
            await projectManager.migration(migrationCreator, migrationHash, migrationUri, {from: owner}).should.be.rejected;

            await accountManager.signup(migrationLoginId, migrationEmail, {from: migrationCreator}).should.be.fulfilled;
            await projectManager.migration(migrationCreator, migrationHash, migrationUri, {from: owner}).should.be.fulfilled;

            const isRegistered = await projectManager.hashValidation(migrationHash, {from: creator});
            isRegistered.should.be.equal(true);            
        });
    });
});
