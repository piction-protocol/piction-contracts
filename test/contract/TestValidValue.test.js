const TestValidValue = artifacts.require("TestValidValue");
const decimals = Math.pow(10, 18);

const BigNumber = require("bigNumber.js");

require("chai")
    .use(require("chai-as-promised"))
    .use(require("chai-bignumber")(BigNumber))
    .should();

contract("TestValidValue", function (accounts) {
    const owner = accounts[0];
    
    let testValidValue;

    before("initial TestValidValue", async () => {
        testValidValue = await TestValidValue.new({from: owner}).should.be.fulfilled;
    });
    
    describe("Test validRange", () => {
        it("validRange: Pass", async () => {
            await testValidValue.testValidRange(1).should.be.fulfilled;
        });

        it("validRange: The value must be greater than 0.", async () => {
            await testValidValue.testValidRange(0).should.be.rejected;
        });
    });

    describe("Test validAddress", () => {
        it("validAddress: Pass", async () => {
            const testAddress = accounts[1];
            await testValidValue.testValidAddress(testAddress).should.be.fulfilled;
        });

        it("validAddress: The address 0 is not allowed.", async () => {
            await testValidValue.testValidAddress('0x0').should.be.rejected;
        });

        it("validAddress: This address is Same address as current contract.", async () => {
            await testValidValue.testValidAddress(testValidValue.address).should.be.rejected;
        });
    });

    describe("Test validString", () => {
        it("validString: Pass", async () => {
            await testValidValue.testValidString("test").should.be.fulfilled;
        });

        it("validString: The string value must be at least one character.", async () => {
            await testValidValue.testValidString("").should.be.rejected;
        });
    });

    describe("Test validRate", () => {
        it("validRate: Pass", async () => {
            const testRate = 0.02 * decimals;
            await testValidValue.testValidRate(testRate).should.be.fulfilled;
        });

        it("validRate: The ratio must be greater than 0.", async () => {
            const testRate = 0 * decimals;
            await testValidValue.testValidRate(testRate).should.be.rejected;
        });

        it("validRate: The ratio must be less than 1.", async () => {
            const testRate = 1.1 * decimals;
            await testValidValue.testValidRate(testRate).should.be.rejected;
        });
    });
});