const PXL = artifacts.require("PXL");
const SponsorshipConnector = artifacts.require("SponsorshipConnector");

const BigNumber = require("bigNumber.js");

require("chai")
    .use(require("chai-as-promised"))
    .use(require("chai-bignumber")(BigNumber))
    .should();

contract("SponsorshipConnector", function(accounts) {
    const owner = accounts[0];
    const writer1 = accounts[1];
    const writer2 = accounts[2];
    const user = accounts[3];
    const revertUser = accounts[4];

    const decimals = Math.pow(10, 18);
    const totalSupply = 1000000000 * decimals;
    const airdropAmount = 1000 * decimals;
    const supportAmount = 500 * decimals;

    let pxl;
    let sponsorshipConnector;

    describe("SponsorshipConnector", () => {
        it("deploy contract.", async() => {
            pxl = await PXL.new({from: owner}).should.be.fulfilled;
            sponsorshipConnector = await SponsorshipConnector.new(pxl.address, {from: owner}).should.be.fulfilled;

            const pxlAddress = await sponsorshipConnector.getPxlAddress({from: owner});
            pxlAddress.should.be.equal(pxl.address);
        });

        it("mint and airdrop pxl", async() => {
            await pxl.mint(totalSupply, {from: owner}).should.be.fulfilled;

            const ownerBalance = await pxl.balanceOf(owner);
            totalSupply.should.be.bignumber.equal(ownerBalance)

            await pxl.transfer(user, airdropAmount, {from: owner}).should.be.fulfilled;
            const userBalance = await pxl.balanceOf(user);
            airdropAmount.should.be.bignumber.equal(userBalance);
        });

        it("register the address of the content provider", async() => {
            await sponsorshipConnector.putContentProvider(writer1, {from: owner}).should.be.fulfilled;
            await sponsorshipConnector.putContentProvider(writer2, {from: owner}).should.be.fulfilled;

            await sponsorshipConnector.putContentProvider(writer1, {from: owner}).should.be.rejected;

            const isRegisterdAddress1 = await sponsorshipConnector.isPictionContentProvider(writer1, {from: user});
            const isRegisterdAddress2 = await sponsorshipConnector.isPictionContentProvider(writer2, {from: user});

            isRegisterdAddress1.should.be.equal(true);
            isRegisterdAddress2.should.be.equal(true);
        });

        it("delete the address of the content provider", async() => {
            await sponsorshipConnector.deleteContentProvider(writer2, {from: writer2}).should.be.rejected;
            await sponsorshipConnector.deleteContentProvider(writer2, {from: owner}).should.be.fulfilled;
            await sponsorshipConnector.deleteContentProvider(writer2, {from: owner}).should.be.rejected;

            const isRegisterdAddress = await sponsorshipConnector.isPictionContentProvider(writer2);
            isRegisterdAddress.should.be.equal(false);
        });

        it("sponsor to Content Providers", async()=> {
            const userBeforeBalance = await pxl.balanceOf(user, {from:user});
            airdropAmount.should.be.bignumber.equal(userBeforeBalance);

            await pxl.approveAndCall(sponsorshipConnector.address, supportAmount, writer2, {from: user}).should.be.rejected;
            await pxl.approveAndCall(sponsorshipConnector.address, supportAmount, writer1, {from: revertUser}).should.be.rejected;

            await pxl.approveAndCall(sponsorshipConnector.address, supportAmount, writer1, {from: user}).should.be.fulfilled;
            
            const userAferBalance = await pxl.balanceOf(user, {from:user});
            supportAmount.should.be.bignumber.equal(userAferBalance);

            const writerAfterBalance = await pxl.balanceOf(writer1, {from:writer1});
            supportAmount.should.be.bignumber.equal(writerAfterBalance);
        });
    });
});